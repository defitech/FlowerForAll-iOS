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
#import "Month.h"
#import "Exercise.h"
#import "ExerciseDay.h"

@interface DB : NSObject {
	
}

/** return the number of seconds between system seconds and db unix time **/
+(float) deltaSecond ;

/** return an open db.. and initialize it if needed **/
+(sqlite3*) db;

+(void) close;

//Execute a statement 
+(void)execute:(NSString*)sqlStatement;
/** execute With Format **/
+(void)executeWF:(NSString*)sqlStatementFormat, ... NS_FORMAT_FUNCTION(1,2);  // sugar implementation

/**
 * Create Statement from NSTRing
 * !! don't forget to finalize it!
 */
+(sqlite3_stmt*) genCStatement:(NSString*)sqlStatement;
/** genCStatement With Format **/
+(sqlite3_stmt*) genCStatementWF:(NSString*)sqlStatementFormat, ... NS_FORMAT_FUNCTION(1,2); // sugar implementation

/**
 * shortcut to get a single value
 * ex: "SELECT value FROM infos WHERE key = 'db_version'";
 */
+(NSString*) getSingleValue:(NSString*)sqlStatement;
/** getSingleValue With Format **/
+(NSString*) getSingleValueWF:(NSString*)sqlStatementFormat, ... NS_FORMAT_FUNCTION(1,2); // sugar implementation


/** get values from the db info table **/
+(NSString*) getInfoValueForKey:(NSString*)key;

/** set info value for this (unique) key*/
+(void) setInfoValueForKey:(NSString*)key value:(NSString*)value;
/** shortcut to use the info system with BOOL **/
+(BOOL) getInfoBOOLForKey:(NSString*)key;
/** shortcut to use the info system with BOOL **/
+(void) setInfoBOOLForKey:(NSString*)key value:(BOOL)value;

/** shortcut to use the info system with NSDate **/
+(NSDate*) getInfoNSDateForKey:(NSString*)key defaultValue:(NSDate*)defaultDate;
/** shortcut to use the info system with NSDate **/
+(void) setInfoNSDateForKey:(NSString*)key value:(NSDate*)value;

/** convenience shortcut to get a String at a defined index in a row **/
+(NSString*) colS:(sqlite3_stmt*)cStatement index:(int)index;

/** convenience shortcut to get an integer at a defined index in a row **/
+(int) colI:(sqlite3_stmt*)cStatement index:(int)index;


/** convenience shortcut to get a double at a defined index in a row **/
+(double) colD:(sqlite3_stmt*)cStatement index:(int)index;

/** convenience shortcut to get a BOOLEAN at a defined index in a row  (test if == 0 )**/
+(BOOL) colB:(sqlite3_stmt*)cStatement index:(int)index ;


/** 
 * convenience shortcut to get an NSDate at a defined index in a row  (test if == 0 )
 * look at colTDF to reuse yor own NSDateFormatter
 **/
+(NSString*) colTWF:(sqlite3_stmt*)cStatement index:(int)index format:(NSString*)format;

/** convenience shortcut to get an NSDate Formated Strinf at a defined index in a row  (test if == 0 )**/
+(NSString*) colTDF:(sqlite3_stmt*)cStatement index:(int)index format:(NSDateFormatter*)dateFormatter;

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


+(NSMutableArray*) getDays:(Month*)month;

+(NSMutableArray*) getMonthes:(BOOL)refreshCache;

+(NSMutableArray*) getExercisesInDay:(NSString*) day;

+(void) deleteDay:(ExerciseDay*) day;

+(void) deleteExercise:(Exercise*)exercise;

+(void) deleteMonth:(Month*)month;

/** get the date of the first exercice **/
+(NSDate*) firstExerciceDate ;

/** get the number of exercices between two dates **/
+(int) exercicesCountBetween:(NSDate*)start and:(NSDate*)end;
    
/*************************************************** BLOWS *******************************************************/
+ (void) saveBlow:(FLAPIBlow*)blow;  

/** fill **/
+ (void) fillWithBlows:(NSMutableArray*)history fromTimestamp:(double)timestamp;




@end
