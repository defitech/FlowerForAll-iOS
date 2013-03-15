//
//  UserManager.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 24.08.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "UserManager.h"
#import "DB.h"
#import "DataAccess.h"
#import "User.h"
#import "UserPicker.h"
#import "UserChooserViewController.h"
#import "Profil.h"
#import "FlowerController.h"
#import "ParametersManager.h"

@implementation UserManager

static User* currentU;

+(User*) currentUser {
    if (currentU == nil) {
        // return nil if they are several users 
        if ([[self listAllUser] count] > 1) {
            return nil;
        }
        if (! [DataAccess fileExists:[self uDir:0]]) { // Create owner
            NSLog(@"UserManager: create owner");
            [self createUser:NSLocalizedString(@"Owner", @"User name for the Owner of the App") password:@""];
        }
        NSLog(@"UserManager: autoload owner");
        [self setCurrentUser:0];
       
    }
    return currentU;
}


+(void) setCurrentUser:(int)uid {
    if (currentU != nil) {
        // close db
        [DB close];
        [currentU release];
    }
    currentU = [[User alloc] initWithId:uid];
    [DB db]; // load database
    // load user Profile
    [Profil reloadCurrent];
    // refresh flapix (if needed)
    [FlowerController initFlapix];
    // refresh history view
    [[[FlowerController currentFlower] bottomBarGL] reloadFromDB];
    //[[[FlowerController currentFlower] historyView] reloadFromDB];
    NSLog(@"setCurrent User %i: %@",[currentU uid],[currentU name]);
    [[NSNotificationCenter defaultCenter] postNotificationName: @"userDataChangeEvent" object: Nil];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"userchooserDataChangeEvent" object: Nil];
	
}

// bloc process until a user is choosen
+(void) requireUser {
    if ([self currentUser] == nil) {
        NSLog(@"UserManager requireUser Loop");
        [UserChooserViewController show];
//        [UserPicker show];
        [UserManager performSelector:@selector(requireUser) withObject:nil afterDelay:1];
    } else {
        NSLog(@"user already available");
    }
}

+(NSString*) uDir:(int)uid {
    return [NSString stringWithFormat:@"users/%i",uid];
}

+(NSString*) uFile:(int)uid filePath:(NSString*)filePath {
    return [NSString stringWithFormat:@"users/%i/%@",uid,filePath];
}


//Generates a new user ID
+ (int)nextAvailUserID {
    int i = 0;
    while ([DataAccess fileExists:[self uDir:i]]) i++;
	return i;
}


//Creates a user, return the User created
+ (int)createUser:(NSString *)name password:(NSString *)password {
    int uid = [self nextAvailUserID];
    [DataAccess createDirectory:[self uDir:uid]];
	[self setUserName:uid newName:name];
    [self setUserPassword:uid newPassword:password];
	return uid;
}

//Drop a user
+ (void)dropUser:(int)uid {
    if (currentU.uid == uid) {
        NSLog(@"ERROR : userManager.dropuser cannot drop current user");
        return;
    }
    [DataAccess createDirectory:@"trash"];
    NSString *dstDir = [NSString stringWithFormat:@"trash/%i.user",(int)CFAbsoluteTimeGetCurrent()];
    [DataAccess moveItemAtPath:[self uDir:uid] toPath:dstDir];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"userDataChangeEvent" object:nil];
}

//Info 
+(BOOL)setUserInfo:(int)uid key:(NSString*)key value: (NSString *)value {
    BOOL result = [DataAccess writeToFile:value  filePath:[self uFile:uid filePath:key]] ;
    [[NSNotificationCenter defaultCenter] postNotificationName: @"userDataChangeEvent" object:nil];
	return result;
}


//Get a User info based on its ID
+(NSString*)getUserInfo:(int)uid key:(NSString*)key {
    return [DataAccess readFromFile:[self uFile:uid filePath:key]] ;
}

            
//Set a new user name 
+(BOOL)setUserName:(int)uid newName:(NSString *)name {
    return [self setUserInfo:uid key:@"username" value:name];
}
            
//Set a new user password 
+(BOOL)setUserPassword:(int)uid newPassword:(NSString *)password {
    return [self setUserInfo:uid key:@"password" value:password];
}



//List all users (Users)
+(NSArray*)listAllUser {
    NSMutableArray* ids = [[[NSMutableArray alloc] init] autorelease];
    for (NSString* strId in [DataAccess arrayOfFilesInFolder:@"/users"]) {
        [ids addObject:[[User alloc] initWithId:[strId intValue]]];
    }
    return ids;
}


@end
