//
//  DataAccess.h
//  FlutterApp2
//
//  Created by Dev on 04.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This class defines an interface for accessing data on the device file system.
//  It will NOT be used in the final version of the app, since all data will be stored in an SQLite database.
//  It fact this class is already no longer in use, and should not be used any more. The class DataAccessDB
//  has been created to interact with the SQLite database, and should be used instead. 


#import <Foundation/Foundation.h>


@interface DataAccess : NSObject {

}


//Create a new directory inside the Documents directory
+ (void)createDirectory:(NSString *)directoryName;

//Write the data to the file given by fileName and extension in the directoryName of the Documents directory, assuming directoryName already exists
+ (BOOL)writeToFileInDirectory:(NSData *)data:(NSString *)directoryName:(NSString *)fileName:(NSString *)extension;

//Check if the file given by fileName and extension in the directoryName of the Documents directory already exists
+ (BOOL)checkIfFileAlreadyExists:(NSString *)directoryName:(NSString *)fileName:(NSString *)extension;

//Delete the file pointed by fileName and extension in the directoryName of the Documents directory
+ (BOOL)deleteFileInDirectory:(NSString *)directoryName:(NSString *)fileName:(NSString *)extension;

//List all files in a given folder and returns an array containing these files without the extension
+(NSArray*)arrayOfFilesInFolder:(NSString*) folder;

//Generates a new user ID
+ (NSInteger)generateUserID;

//Creates a new user
+ (BOOL)createUser:(NSInteger)ID:(NSString *)name:(NSString *)password;

//Checks if a user already exists
+ (BOOL)checkIfUserAlreadyExists:(NSInteger)ID;

//List all user IDs
+(NSArray*)listOfAllUserIDs;

//Get a user name based on its ID
+(NSString*)getUserName:(NSInteger)ID;

//Get a user password based on its ID
+(NSString*)getUserPassword:(NSInteger)ID;

//Set a new user name to a user
+(BOOL)setUserName:(NSInteger)ID:(NSString *)newName;

//Set a new password to a user
+(BOOL)setUserPassword:(NSInteger)ID:(NSString *)newPassword;

//Deletes a user
+(BOOL)deleteUser:(NSInteger)ID;


@end
