//
//  UserManager.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 24.08.11.
//  Copyright 2011 fondation Defitech http://defitech.ch All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserManager : NSObject {
    
}

/** 
 * return the current user and initialize the owner if needed 
 * will return null if we have to go thru user selection steps
 **/
+(User*) currentUser;

// user dir String
+(NSString*) uDir:(int)uid;

//Generates a new user ID
+ (int)nextAvailUserID;

//Creates a new user return id of this new user
+ (int)createUser:(NSString *)name password:(NSString *)password;



//Info 
+(BOOL)setUserInfo:(int)uid key:(NSString*)key value:(NSString *)value;            

//Set a new user name 
+(BOOL)setUserName:(int)uid newName:(NSString *)name;
            
//Set a new user password 
+(BOOL)setUserPassword:(int)uid newPassword:(NSString *)password;

//Get a User info based on its ID
+(NSString*)getUserInfo:(int)uid key:(NSString*)key;

//List all Users in a NSArray of Users
+(NSArray*)listAllUser;

@end
