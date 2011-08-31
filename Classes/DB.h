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


@interface DB : NSObject {
	
}
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


/*************************************************** BLOWS *******************************************************/
+ (void) saveBlow:(double)timestamp duration:(double)length in_range_duration:(double)ir_length goal:(BOOL)good;  

/** fill **/
+ (void) fillWithBlows:(NSMutableArray*)history fromTimestamp:(double)timestamp;

/*************************************************** EXERCISES ***************************************************/



//Lists all the exercises of a user based on its ID
+(NSArray*)listOfUserExercises:(NSInteger)ID;

//Lists all the exercises of a user (based on its ID) for the specified month and year
+(NSArray*)listOfUserExercisesInMonthAndYear:(NSInteger)ID:(NSInteger)month:(NSInteger)year;

//Get all dateTimes a user's exercises
//This is used in order to be able to classify the exercises on a time base:
//Which exercice have been done in the current month, which have been done in past months but still in the year,
//and which have been done in the past years. (This is used to hierarchically display exercise data to the user,
//depending on when the exercises have been done. See the classes StatisticListViewController, MonthStatisticListViewController
//and YearStatisticListViewController.)
+(NSArray*)listOfUserExerciseDates:(NSInteger)ID;

//Lists all dateTimes of a user's exercise (based on its ID) for the specified year
//This is used by the class YearStatisticListViewController
+(NSArray*)listOfUserExerciseDatesInYear:(NSInteger)ID:(NSInteger)year;

//Deletes an exercise
+(void)deleteExercise:(NSInteger)exerciseID;

//Delete all exercises of a user for the specified month and year
+(void)deleteUserExercisesInMonthAndYear:(NSInteger)userID:(NSInteger)month:(NSInteger)year;

//Delete all exercises of a user for the specified year
+(void)deleteUserExercisesInYear:(NSInteger)userID:(NSInteger)year;



/*************************************************** EXPIRATIONS ***************************************************/



//List all expirations of an exercise based on its ID
+(NSArray*)listOfExerciseExpirations:(NSInteger)ID;


@end
