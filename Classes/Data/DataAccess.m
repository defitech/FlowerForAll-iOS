//
//  DataAccess.m
//  FlutterApp2
//
//  Created by Dev on 04.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  Implementation of the DataAccess class


#import "DataAccess.h"

#include <math.h>


@implementation DataAccess

static NSString* dd;

// return current directory
+(NSString*) docDirectory {
    if (dd == nil) {
        dd = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [dd retain]; // otherwise it gets released 
    }
    return dd;
}

// return current directory
+(NSString*) docDirectoryWithPath:(NSString*)path {
    return [NSString stringWithFormat:@"%@/%@",[DataAccess docDirectory],path];
}



//Create a new directory inside the Documents directory
+ (void)createDirectory:(NSString *)dirPath {
	//Create a new directory inside the Documents directory
	[[NSFileManager defaultManager] createDirectoryAtPath:[self docDirectoryWithPath:dirPath] withIntermediateDirectories:YES attributes:nil error:nil];
	
}


//Move a  directory inside the Documents directory
+ (void)moveItemAtPath:(NSString *)srcpath toPath:(NSString *)dstpath {
	[[NSFileManager defaultManager] moveItemAtPath:[self docDirectoryWithPath:srcpath] 
                                            toPath:[self docDirectoryWithPath:dstpath] error:nil];
}


//Check if the file given by filePath
+ (BOOL)fileExists:(NSString *)filePath {
    return [[NSFileManager defaultManager] 
            fileExistsAtPath:[self docDirectoryWithPath:filePath]];
}


//Write the string to the filePath
+ (BOOL)writeToFile:(NSString*)str  filePath:(NSString *)filePath {
	return [[str dataUsingEncoding:NSUTF8StringEncoding] writeToFile:[self docDirectoryWithPath:filePath] atomically:YES];
    
}

//Read String from file
+(NSString*)readFromFile:(NSString *)filePath {
    if (! [self fileExists:filePath]) { 
        NSLog(@"**DataAccess readFromFile, file %@ does not exists",filePath);
        return nil;
    }
	return [NSString 
            stringWithContentsOfFile:[self docDirectoryWithPath:filePath] encoding:NSUTF8StringEncoding error:nil];  
}



//List all files in a given folder and returns an array containing these files 
+(NSArray*)arrayOfFilesInFolder:(NSString*) path {
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self docDirectoryWithPath:path] error:nil];
}


@end
