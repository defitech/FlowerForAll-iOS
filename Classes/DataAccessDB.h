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


@interface DataAccessDB : NSObject {
	
}




+(sqlite3*) db;

+(void) close;

//Execute a statement 
+(void)execute:(NSString*)sqlStatement;

//Execute a statement With text FOrmat
+(void)executeWithFormat:(NSString*)sqlStatement, ... NS_FORMAT_FUNCTION(1,2);

/**
 * Create Statement from NSTRing
 * !! don't forget to finalize it!
 */
+(sqlite3_stmt*) genCompiledStatement:(NSString*)sqlStatement;

/**
 * Usefull to check an ID or if stuff exists in a DB
 */
+ (BOOL)checkIfStatementReturnRows:(NSString*)sqlStatement;

/**
 * shortcut to get a single value
 * ex: "SELECT value FROM infos WHERE key = 'db_version'";
 */
+(NSString*) getSingletValue:(NSString*)sqlStatement ;

/** get values from the db info table **/
+(NSString*) getInfoValueForKey:(NSString*)key;

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
