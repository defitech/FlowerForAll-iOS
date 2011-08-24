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




//Create a new directory inside the Documents directory
+ (void)createDirectory:(NSString *)directoryName {
	
	//Get the path to the Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//Create a new directory inside the Documents directory
	NSFileManager *nsfm= [NSFileManager defaultManager];
	[nsfm createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, directoryName] withIntermediateDirectories:YES attributes:nil error:nil];
	
}




//Write the data to the file given by fileName and extension in the directoryName of the Documents directory, assuming directoryName already exists
+ (BOOL)writeToFileInDirectory:(NSData *)data:(NSString *)directoryName:(NSString *)fileName:(NSString *)extension {
	
	//Get the path to the Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//Construct the full path of the file to be written (in the directory directoryName, located in the Documents directory)
	NSString *endOfPath = [NSString stringWithFormat:@"%@/%@.%@",directoryName, fileName, extension];
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:endOfPath];

	//Logging
	//NSLog(@"%@\n",appFile);

	//Write data to the file
	return [data writeToFile:appFile atomically:YES];

}




//Check if the file given by fileName and extension in the directoryName of the Documents directory already exists
+ (BOOL)checkIfFileAlreadyExists:(NSString *)directoryName:(NSString *)fileName:(NSString *)extension {
	
	//Get the path to the Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//Construct the full path of the file to be written (in the directory directoryName, located in the Documents directory)
	NSString *endOfPath = [NSString stringWithFormat:@"%@/%@.%@",directoryName, fileName, extension];
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:endOfPath];
	
	//Logging
	//NSLog(@"%@\n",appFile);
	
	//Write data to the file
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:appFile isDirectory:NO];
	
}




//Delete the file pointed by fileName and extension in the directoryName of the Documents directory
+ (BOOL)deleteFileInDirectory:(NSString *)directoryName:(NSString *)fileName:(NSString *)extension {
	
	//Get the path to the Documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//Construct the full path of the file to be written (in the directory directoryName, located in the Documents directory)
	NSString *endOfPath = [NSString stringWithFormat:@"%@/%@.%@",directoryName, fileName, extension];
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:endOfPath];
	
	//Logging
	//NSLog(@"%@\n",appFile);
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return[fileManager removeItemAtPath:appFile error:nil];
	
}




//List all files in a given folder and returns an array containing these files without the extension
+(NSArray*)arrayOfFilesInFolder:(NSString*) folder {
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray* files = [fm contentsOfDirectoryAtPath:folder error:nil];
	//Attention: the list is bounded to 10!
	NSMutableArray *fileList = [[NSMutableArray alloc] init];
	
	for(NSString *file in files) {
		NSLog(@"%@\n",file);
		NSString *path = [folder stringByAppendingPathComponent:file];
		BOOL isDir = NO;
	
		[fm fileExistsAtPath:path isDirectory:(&isDir)];
		
		if(!isDir) {
			
			//Remove extension before putting file name in the array
			NSArray *components = [file componentsSeparatedByString:@"."];
			NSString *newString = [components objectAtIndex:0];
			
			[fileList addObject:newString];
		}
		
	}
	
	return [fileList autorelease];
}




/**********************************************************************************************************************/




//Generates a new user ID
+ (NSInteger)generateUserID {
	NSArray *userIDs = [DataAccess listOfAllUserIDs];
	
	NSInteger max = 0;
	
	for (int i=0; i < [userIDs count]; i++ ) {
		NSInteger currentElement = [[userIDs objectAtIndex:i] intValue];
		NSLog(@"NSInteger value :%d", currentElement);
		//NSLog(@" max :%d", max);
		//NSLog(@" current element :%d", [currentElement intValue]);
		if (currentElement > max) {
			max = currentElement;
		}
	}
	
	max++;
	
	NSLog(@"NSInteger max :%d", max);
	return max;
}




//Creates a new user
+ (BOOL)createUser:(NSInteger)ID:(NSString *)name:(NSString *)password {
	
	NSString *userAndPassword = [[name stringByAppendingString:@"."] stringByAppendingString:password];
	char *saves = (char *)[userAndPassword UTF8String];
	NSData *data = [[NSData alloc] initWithBytes:saves length:userAndPassword.length]; 
	
	return [DataAccess writeToFileInDirectory:data:@"users":[NSString stringWithFormat:@"%d", ID]:@"txt"];
}




//Checks if a user already exists
+ (BOOL)checkIfUserAlreadyExists:(NSInteger)ID {
	return [DataAccess checkIfFileAlreadyExists:@"users":[NSString stringWithFormat:@"%d", ID]:@"txt"];
}




//List all user IDs
+(NSArray*)listOfAllUserIDs {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"/users"];
	return [self arrayOfFilesInFolder:appFile];
}




//Get a user name based on its ID
+(NSString*)getUserName:(NSInteger)ID {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"/users/"];
	appFile = [appFile stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", ID]];
	appFile = [appFile stringByAppendingString:@".txt"];
	
	NSLog(@"%@\n",appFile);
	
	//Read the content of the file
	if (appFile) {  
		NSString *myText = [NSString stringWithContentsOfFile:appFile encoding:NSUTF8StringEncoding error:nil];  
		if (myText) { 
			
			NSArray *components = [myText componentsSeparatedByString:@"."];
			//NSLog(@"%@\n",@"test");
			NSLog(@"%@\n",myText);
			//NSLog(@"%@\n",[components objectAtIndex:0]);
			return [components objectAtIndex:0];
			
		}  
	}
	return nil;
}




//Get a user password based on its ID
+(NSString*)getUserPassword:(NSInteger)ID {
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"/users/"];
	appFile = [appFile stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", ID]];
	appFile = [appFile stringByAppendingString:@".txt"];
	
	NSLog(@"%@\n",appFile);
	
	//Read the content of the file
	if (appFile) {  
		NSString *myText = [NSString stringWithContentsOfFile:appFile encoding:NSUTF8StringEncoding error:nil];  
		if (myText) { 
			
			NSArray *components = [myText componentsSeparatedByString:@"."];
			/*NSLog(@"%@\n",@"test");
			NSLog(@"%@\n",myText);
			NSLog(@"%@\n",[components objectAtIndex:0]);*/
			return [components objectAtIndex:1];
			
		}  
	}
	return nil;
}





//Set a new user name to a user
+(BOOL)setUserName:(NSInteger)ID:(NSString *)newName {
	
	NSString *newData = [[newName stringByAppendingString:@"."] stringByAppendingString:[DataAccess getUserPassword:ID]];
	NSLog(@"%@\n",newData);
	char *saves = (char *)[newData UTF8String];
	NSData *data = [[NSData alloc] initWithBytes:saves length:newData.length]; 
	return [DataAccess writeToFileInDirectory:data:@"users":[NSString stringWithFormat:@"%i", ID]:@"txt"];
	//return YES;
}





//Set a new password to a user
+(BOOL)setUserPassword:(NSInteger)ID:(NSString *)newPassword {
	
	NSString *newData = [[[DataAccess getUserName:ID] stringByAppendingString:@"."] stringByAppendingString:newPassword];
	
	char *saves = (char *)[newData UTF8String];
	NSData *data = [[NSData alloc] initWithBytes:saves length:newData.length]; 
	return [DataAccess writeToFileInDirectory:data:@"users":[NSString stringWithFormat:@"%i", ID]:@"txt"];
	
}





//Deletes a user
+(BOOL)deleteUser:(NSInteger)ID {
	
	return [DataAccess deleteFileInDirectory:@"users":[NSString stringWithFormat:@"%i", ID]:@"txt"];
	
}




@end
