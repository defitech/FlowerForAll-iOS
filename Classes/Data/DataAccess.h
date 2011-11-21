//
//  DataAccess.h
//  FlutterApp2
//
//  Created by Dev on 04.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This class defines an interface for accessing data on the device file system.
//  It will NOT be used in the final version of the app, since all data will be stored in an SQLite database.
//  It fact this class is already no longer in use, and should not be used any more. The class DB
//  has been created to interact with the SQLite database, and should be used instead. 


#import <Foundation/Foundation.h>


@interface DataAccess : NSObject {

}


/**
 * Check the data structure, init or upgrade it if needed
 */
+(void) initOrUpgrade;

// return current directory
+(NSString*) libDirectory;

// return current directory and append path
+(NSString*) libDirectoryWithPath:(NSString*)path;

// return current doc directory
+(NSString*) docDirectory;

// return current doc directory
+(NSString*) docDirectoryWithPath:(NSString*)path;

//Create a new directory inside the Library directory
+ (void)createDirectory:(NSString *)dirPath;

+ (void)moveItemAtPath:(NSString *)srcpath toPath:(NSString *)dstpath;

//Check if the file given by filePath
+ (BOOL)fileExists:(NSString *)filePath;

//Write the string to the filePath
+ (BOOL)writeToFile:(NSString*)str  filePath:(NSString *)filePath ;

//Read String from file
+(NSString*)readFromFile:(NSString *)filePath;

//List all files in a given folder and returns an array containing these files 
+(NSArray*)arrayOfFilesInFolder:(NSString*) path;

@end
