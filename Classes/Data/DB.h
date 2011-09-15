//
//  DataAccess2.h
//  FlutterApp2
//
//  Created by Dev on 18.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This class defines an interface for accessing data on the SQLite database.


#import <Foundation/Foundation.h>

#import <sqlite3.h>
#import "FLAPIBlow.h"
#import "FLAPIExercice.h"


@interface DB : NSObject {
	
}
/** return an open db.. and initialize it if needed **/
+(sqlite3*) db;

+(void) close;

//Execute a statement 
+(void)execute:(NSString*)sqlStatement;
/** execute With Format **/
+(void)executeWF:(NSString*)sqlStatementFormat, ...;// NS_FORMAT_FUNCTION(1,2);  // sugar implementation

/**
 * Create Statement from NSTRing
 * !! don't forget to finalize it!
 */
+(sqlite3_stmt*) genCStatement:(NSString*)sqlStatement;
/** genCStatement With Format **/
+(sqlite3_stmt*) genCStatementWF:(NSString*)sqlStatementFormat, ...;// NS_FORMAT_FUNCTION(1,2); // sugar implementation

/**
 * shortcut to get a single value
 * ex: "SELECT value FROM infos WHERE key = 'db_version'";
 */
+(NSString*) getSingleValue:(NSString*)sqlStatement;
/** getSingleValue With Format **/
+(NSString*) getSingleValueWF:(NSString*)sqlStatementFormat, ...;// NS_FORMAT_FUNCTION(1,2); // sugar implementation

/** get values from the db info table **/
+(NSString*) getInfoValueForKey:(NSString*)key;

/** set info value for this (unique) key*/
+(void) setInfoValueForKey:(NSString*)key value:(NSString*)value;


/** convenience shortcut to get a String at a defined index in a row **/
+(NSString*) colS:(sqlite3_stmt*)cStatement index:(int)index;

/** convenience shortcut to get an integer at a defined index in a row **/
+(int) colI:(sqlite3_stmt*)cStatement index:(int)index;

/** convenience shortcut to get a double at a defined index in a row **/
+(double) colD:(sqlite3_stmt*)cStatement index:(int)index;

/** convenience shortcut to get a BOOLEAN at a defined index in a row  (test if == 0 )**/
+(BOOL) colB:(sqlite3_stmt*)cStatement index:(int)index ;

/*************************************************** USERS ***************************************************/



//Generates a user ID
+ (NSInteger)generateUserID;

//Creates a user
+ (void)createUser:(NSInteger)ID:(NSString *)name:(NSString *)password;

//Lists all user IDs
+(NSArray*)listOfAllUserIDs;

//Get a user name besed on its ID
+(NSString*)getUserName:(NSInteger)ID;

//Get a user password besed on its ID
+(NSString*)getUserPassword:(NSInteger)ID;

//Set a new name to a user
+(void)setUserName:(NSInteger)ID:(NSString *)newName;

//Set a new password to a user
+(void)setUserPassword:(NSInteger)ID:(NSString *)newPassword;

//Deletes a user
+(void)deleteUser:(NSInteger)ID;


/*************************************************** Exercice *******************************************************/
+ (void) saveExercice:(FLAPIExercice*)exercice;  

/*************************************************** BLOWS *******************************************************/
+ (void) saveBlow:(FLAPIBlow*)blow;  

/** fill **/
+ (void) fillWithBlows:(NSMutableArray*)history fromTimestamp:(double)timestamp;




@end
