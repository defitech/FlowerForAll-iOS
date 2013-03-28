//
//  DataAccess.m
//  FlutterApp2
//
//  Created by Dev on 04.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  Implementation of the DataAccess class


#import "DataAccess.h"
#import "UserManager.h"

#include <math.h>


@implementation DataAccess

static NSString* ld;
static NSString* dd;

/**
 * Check the data structure, init or upgrade it if needed
 */
+(void) initOrUpgrade {
    // move from structure where data was stored in Documents to Library
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self docDirectoryWithPath:@"users"]] &&
        ! [[NSFileManager defaultManager] fileExistsAtPath:[self libDirectoryWithPath:@"users"]]) {
        [[NSFileManager defaultManager] moveItemAtPath:[self docDirectoryWithPath:@"users"] 
                                                toPath:[self libDirectoryWithPath:@"users"] error:nil];
        
        NSLog(@"DataAccess.initOrUpgrade: Moved data to Library");
    }
    
    // reset owner password
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self libDirectoryWithPath:@"users/0/password"]] &&
        [[NSFileManager defaultManager] fileExistsAtPath:[self docDirectoryWithPath:@"resetpassword.txt"]]) {
        [UserManager setUserInfo:0 key:@"password" value:@""];
        NSLog(@"DataAccess.initOrUpgrade: Reset owner password");
        [[NSFileManager defaultManager] 
            removeItemAtPath:[self docDirectoryWithPath:@"resetpassword.txt"] error:nil]; 
    }
    
}



// return current lib directory
+(NSString*) libDirectory {
    if (ld == nil) {
        ld = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [ld retain]; // otherwise it gets released 
    }
    return ld;
}

// return current lib directory
+(NSString*) libDirectoryWithPath:(NSString*)path {
    return [NSString stringWithFormat:@"%@/%@",[DataAccess libDirectory],path];
}

// return current doc directory
+(NSString*) docDirectory {
    if (dd == nil) {
        dd = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [dd retain]; // otherwise it gets released 
    }
    return dd;
}

// return current doc directory
+(NSString*) docDirectoryWithPath:(NSString*)path {
    return [NSString stringWithFormat:@"%@/%@",[DataAccess docDirectory],path];
}




//Create a new directory inside the Library directory
+ (void)createDirectory:(NSString *)dirPath {
	//Create a new directory inside the Library directory
	[[NSFileManager defaultManager] createDirectoryAtPath:[self libDirectoryWithPath:dirPath] withIntermediateDirectories:YES attributes:nil error:nil];
	
}


//Move a  directory inside the Library directory
+ (void)moveItemAtPath:(NSString *)srcpath toPath:(NSString *)dstpath {
	[[NSFileManager defaultManager] moveItemAtPath:[self libDirectoryWithPath:srcpath] 
                                            toPath:[self libDirectoryWithPath:dstpath] error:nil];
}


//Check if the file given by filePath
+ (BOOL)fileExists:(NSString *)filePath {
    return [[NSFileManager defaultManager] 
            fileExistsAtPath:[self libDirectoryWithPath:filePath]];
}


//Write the string to the filePath
+ (BOOL)writeToFile:(NSString*)str  filePath:(NSString *)filePath {
	return [[str dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[self libDirectoryWithPath:filePath] atomically:YES];
    
}

//Read String from file
+(NSString*)readFromFile:(NSString *)filePath {
    if (! [self fileExists:filePath]) { 
        NSLog(@"**DataAccess readFromFile, file %@ does not exists",filePath);
        return nil;
    }
	return [[NSString 
            stringWithContentsOfFile:[self libDirectoryWithPath:filePath] encoding:NSUTF8StringEncoding error:nil] autorelease];
}



//List all files in a given folder and returns an array containing these files 
+(NSArray*)arrayOfFilesInFolder:(NSString*) path {
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self libDirectoryWithPath:path] error:nil];
}


@end
