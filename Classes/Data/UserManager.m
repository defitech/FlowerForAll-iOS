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

@implementation UserManager

static User* currentU;

+(User*) currentUser {
    if (currentU == nil) {
        // return nil if they are several users 
        if ([[self listAllUser] count] > 1) {
            NSLog(@"UserManager: you must choose a user first");
            return nil;
        }
        if (! [DataAccess fileExists:[self uDir:0]]) { // Create owner
            NSLog(@"UserManager: create owner");
            [self createUser:NSLocalizedString(@"Owner", @"User name for the Owner of the App") password:@""];
        }
        NSLog(@"UserManager: autoload owner");
        currentU = [[User alloc] initWithId:0];
    }
    return currentU;
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



//Info 
+(BOOL)setUserInfo:(int)uid key:(NSString*)key value: (NSString *)value {
	return [DataAccess writeToFile:value  filePath:[self uFile:uid filePath:key]] ;
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
    NSMutableArray* ids = [[NSMutableArray alloc] init];
    for (NSString* strId in [DataAccess arrayOfFilesInFolder:@"/users"]) {
        [ids addObject:[[User alloc] initWithId:[strId intValue]]];
    }
    return ids;
}


@end
