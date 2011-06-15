//
//  DataAccess2.m
//  FlutterApp2
//
//  Created by Dev on 18.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  Implementation of the DataAccess DB class


#import "FlutterApp2AppDelegate.h"

#import "DataAccessDB.h"

#import "DateClassifier.h"

#import "User.h"
#import "Exercise.h"
#import "Expiration.h"



//Static variables to store database name and path on the device file system
static NSString *databaseName;
static NSString *databasePath;



@implementation DataAccessDB




//Initializes the static variables
+(void)initDBParameters{
	
	//This code is redundant with the code in the app delegate, but it is necessary because the commented code below do not always work, for a reason that is unknown yet
	databaseName = @"FlutterApp2Database.sql";
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
	
	/*FlutterApp2AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	 
	 NSLog(@"init delegate databaseName: %@", delegate.databaseName);
	 NSLog(@"init delegate databasePath: %@", delegate.databasePath);
	 
	 databaseName = delegate.databaseName;
	 databasePath = delegate.databasePath;*/
}





/*************************************************** USERS ***************************************************/





//Generates a user ID
+ (NSInteger)generateUserID {
	
	sqlite3 *database;
	NSMutableArray *userIDs = [[NSMutableArray alloc] init];
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select id from users";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *aID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				
				//NSLog(@"ID: %@",aID);
				
				[userIDs addObject:aID];
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	
	NSInteger max = 0;
	
	for (int i=0; i < [userIDs count]; i++ ) {
		NSInteger currentElement = [[userIDs objectAtIndex:i] intValue];
		NSLog(@" max :%d", max);

		if (currentElement > max) {
			max = currentElement;
		}
	}
	
	[userIDs release];
	
	max++;
	
	NSLog(@"NSInteger max :%d", max);
	return max;
}





//Creates a user
+ (void)createUser:(NSInteger)ID:(NSString *)name:(NSString *)password {
	sqlite3 *database;
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "insert into users (id, name, password) values (?, ?, ?)";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {

			sqlite3_bind_int( compiledStatement, 1, ID);
			sqlite3_bind_text( compiledStatement, 2, [name UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text( compiledStatement, 3, [password UTF8String], -1, SQLITE_TRANSIENT);
				
		}
		if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
			NSLog( @"Error: %s", sqlite3_errmsg(database) );
		}
		else {
			NSLog( @"Insert into row id = %d", sqlite3_last_insert_rowid(database));
		}		
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}





//Checks if a user already exists
+ (BOOL)checkIfUserAlreadyExists:(NSInteger)ID {
	
	sqlite3 *database;
	NSMutableArray *userIDs = [[NSMutableArray alloc] init];
 
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select id from users";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *aID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
 
				//NSLog(@"ID: %@",aID);
 
				[userIDs addObject:aID];
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
 
 
	for (int i=0; i < [userIDs count]; i++ ) {
		NSInteger currentElement = [[userIDs objectAtIndex:i] intValue];
 
		if (currentElement == ID) {
			[userIDs release];
			return YES;
		}
	}
 
	[userIDs release];
	return NO;
}





//Lists all user IDs
+(NSArray*)listOfAllUserIDs {
	sqlite3 *database;
	NSMutableArray *userIDs = [[NSMutableArray alloc] init];
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select id from users";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *aID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				
				//NSLog(@"ID: %@",aID);
				
				[userIDs addObject:aID];
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return [userIDs autorelease];
}




//Get a user name besed on its ID
+(NSString*)getUserName:(NSInteger)ID {
	
	sqlite3 *database;
	
	NSString *name = nil;
	
	[DataAccessDB initDBParameters];
	
	/*NSLog(@"1 databaseName: %@", databaseName);
	NSLog(@"1 databasePath: %@", databasePath);*/
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select name from users where id = ?";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			sqlite3_bind_int( compiledStatement, 1, ID);
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				
				//NSLog(@"ID: %@",aID);
				
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return name;
}




//Get a user password besed on its ID
+(NSString*)getUserPassword:(NSInteger)ID {
	
	sqlite3 *database;
	
	NSString *password = nil;
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select password from users where id = ?";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			sqlite3_bind_int( compiledStatement, 1, ID);
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				password = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				
				//NSLog(@"ID: %@",aID);
				
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return password;
}





//Set a new name to a user
+(void)setUserName:(NSInteger)ID:(NSString *)newName {
	sqlite3 *database;
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "update users set name=? where id=?";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
			sqlite3_bind_text( compiledStatement, 1, [newName UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int( compiledStatement, 2, ID);
			
		}
		if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
			NSLog( @"Error: %s", sqlite3_errmsg(database) );
		}
		else {
			NSLog( @"Insert into row id = %d", sqlite3_last_insert_rowid(database));
		}		
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}





//Set a new password to a user
+(void)setUserPassword:(NSInteger)ID:(NSString *)newPassword {
	sqlite3 *database;
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "update users set password=? where id=?";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
			sqlite3_bind_text( compiledStatement, 1, [newPassword UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_int( compiledStatement, 2, ID);
			
		}
		if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
			NSLog( @"Error: %s", sqlite3_errmsg(database) );
		}
		else {
			NSLog( @"Insert into row id = %d", sqlite3_last_insert_rowid(database));
		}		
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}





//Deletes a user
+(void)deleteUser:(NSInteger)ID {
	sqlite3 *database;
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "delete from users where id=?";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
			sqlite3_bind_int( compiledStatement, 1, ID);
			
		}
		if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
			NSLog( @"Error: %s", sqlite3_errmsg(database) );
		}
		else {
			NSLog( @"Insert into row id = %d", sqlite3_last_insert_rowid(database));
		}		
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}


 




/*************************************************** EXERCISES ***************************************************/






//Lists all the exercises of a user based on its ID
+(NSArray*)listOfUserExercises:(NSInteger)ID {
	sqlite3 *database;
	NSMutableArray *exercises = [[NSMutableArray alloc] init];
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select * from exercises where localUserId =? order by dateTime desc";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			sqlite3_bind_int( compiledStatement, 1, ID);
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSInteger aID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
				NSInteger dateTime = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] intValue];
				NSString *appVersion = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
				NSInteger localUserId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)] intValue];
				NSInteger globalUserId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)] intValue];
				NSInteger gameId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)] intValue];
				double targetFrequency = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)] doubleValue];
				double targetFrequencyTolerance = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)] doubleValue];
				NSInteger targetBlowingDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)] intValue];
				NSInteger targetDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)] intValue];
				double goodPercentage = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)] doubleValue];
				NSInteger transferStatus = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 11)] intValue];

				
				//NSLog(@"ID: %@",aID);
				
				Exercise *exercise = [Exercise alloc];
				[exercise init:aID:dateTime:appVersion:localUserId:globalUserId:gameId:targetFrequency:targetFrequencyTolerance:targetBlowingDuration:targetDuration:goodPercentage:transferStatus];
				
				[exercises addObject:exercise];
				
				[exercise release];
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return [exercises autorelease];
}





//Lists all the exercises of a user (based on its ID) for the specified month and year
+(NSArray*)listOfUserExercisesInMonthAndYear:(NSInteger)ID:(NSInteger)month:(NSInteger)year {
	sqlite3 *database;
	NSMutableArray *exercises = [[NSMutableArray alloc] init];
	
	[DataAccessDB initDBParameters];
	
	
	//Get current month beginning as an integer (in seconds)
	NSString *beginningOfMonthString = [[NSString stringWithFormat:@"%i", year] stringByAppendingString:@"-"];
	beginningOfMonthString = [beginningOfMonthString stringByAppendingString:[NSString stringWithFormat:@"%i", month]];
	beginningOfMonthString = [beginningOfMonthString stringByAppendingString:@"-01 00:00:00 +0100"];
	NSDate *beginningOfMonthDate = [NSDate dateWithString:beginningOfMonthString];
	NSInteger beginningOfMonthInt = ((NSInteger)[beginningOfMonthDate timeIntervalSince1970]);
	
	
	//Get current month end as an integer (in seconds). In fact, we take the beginning of the following month (easier, always the 1st day :-) )
	NSInteger nextMonth;
	NSInteger nextYear;
	if (month == 12) {
		nextMonth = 1;
		nextYear = year + 1;
	}
	else {
		nextMonth = month + 1;
		nextYear = year;
	}

	NSString *endOfMonthString = [[NSString stringWithFormat:@"%i", nextYear] stringByAppendingString:@"-"];
	endOfMonthString = [endOfMonthString stringByAppendingString:[NSString stringWithFormat:@"%i", nextMonth]];
	endOfMonthString = [endOfMonthString stringByAppendingString:@"-01 00:00:00 +0100"];
	NSDate *endOfMonthDate = [NSDate dateWithString:endOfMonthString];
	NSInteger endOfMonthInt = ((NSInteger)[endOfMonthDate timeIntervalSince1970]);
	
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select * from exercises where (localUserId =? and dateTime >=? and dateTime <?) order by dateTime desc";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			sqlite3_bind_int( compiledStatement, 1, ID);
			sqlite3_bind_int( compiledStatement, 2, beginningOfMonthInt);
			sqlite3_bind_int( compiledStatement, 3, endOfMonthInt);
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSInteger aID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
				NSInteger dateTime = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] intValue];
				NSString *appVersion = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
				NSInteger localUserId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)] intValue];
				NSInteger globalUserId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)] intValue];
				NSInteger gameId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)] intValue];
				double targetFrequency = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)] doubleValue];
				double targetFrequencyTolerance = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 7)] doubleValue];
				NSInteger targetBlowingDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)] intValue];
				NSInteger targetDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 9)] intValue];
				double goodPercentage = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 10)] doubleValue];
				NSInteger transferStatus = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 11)] intValue];
				
				
				//NSLog(@"ID: %@",aID);
				
				Exercise *exercise = [Exercise alloc];
				[exercise init:aID:dateTime:appVersion:localUserId:globalUserId:gameId:targetFrequency:targetFrequencyTolerance:targetBlowingDuration:targetDuration:goodPercentage:transferStatus];
				
				[exercises addObject:exercise];
				
				[exercise release];
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return [exercises autorelease];
}






//Get all dateTimes a user's exercises
//This is used in order to be able to classify the exercises on a time base:
//Which exercice have been done in the current month, which have been done in past months but still in the year,
//and which have been done in the past years. (This is used to hierarchically display exercise data to the user,
//depending on when the exercises have been done. See the classes StatisticListViewController, MonthStatisticListViewController
//and YearStatisticListViewController.)
+(NSArray*)listOfUserExerciseDates:(NSInteger)ID {
	sqlite3 *database;
	NSMutableArray *dateTimes = [[NSMutableArray alloc] init];
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select dateTime from exercises where localUserId =? order by dateTime desc";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			sqlite3_bind_int( compiledStatement, 1, ID);
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *dateTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				
				//NSLog(@"wwwwwwwwwwwwwwwwwwwwwww: %@",dateTime);
				
				[dateTimes addObject:dateTime];
			
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return [dateTimes autorelease];
}





//Lists all dateTimes of a user's exercise (based on its ID) for the specified year
//This is used by the class YearStatisticListViewController
+(NSArray*)listOfUserExerciseDatesInYear:(NSInteger)ID:(NSInteger)year {
	sqlite3 *database;
	NSMutableArray *dateTimes = [[NSMutableArray alloc] init];
	
	[DataAccessDB initDBParameters];
	
	
	//Get current year beginning as an integer (in seconds)
	NSString *beginningOfYearString = [[NSString stringWithFormat:@"%i", year] stringByAppendingString:@"-"];
	beginningOfYearString = [beginningOfYearString stringByAppendingString:@"01-01 00:00:00 +0100"];
	NSDate *beginningOfYearDate = [NSDate dateWithString:beginningOfYearString];
	NSInteger beginningOfYearInt = ((NSInteger)[beginningOfYearDate timeIntervalSince1970]);
	
	
	//Get current year end as an integer (in seconds)
	NSString *endOfYearString = [[NSString stringWithFormat:@"%i", year] stringByAppendingString:@"-"];
	endOfYearString = [endOfYearString stringByAppendingString:@"12-31 23:59:59 +0100"];
	NSDate *endOfYearDate = [NSDate dateWithString:endOfYearString];
	NSInteger endOfYearInt = ((NSInteger)[endOfYearDate timeIntervalSince1970]);
	
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select dateTime from exercises where (localUserId =? and dateTime >=? and dateTime <=?) order by dateTime desc";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			sqlite3_bind_int( compiledStatement, 1, ID);
			sqlite3_bind_int( compiledStatement, 2, beginningOfYearInt);
			sqlite3_bind_int( compiledStatement, 3, endOfYearInt);
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *dateTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				
				//NSLog(@"wwwwwwwwwwwwwwwwwwwwwww: %@",dateTime);
				
				[dateTimes addObject:dateTime];
				
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return [dateTimes autorelease];
}






//Deletes an exercise
+(void)deleteExercise:(NSInteger)exerciseID {
	sqlite3 *database;
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "delete from exercises where id=?";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
			sqlite3_bind_int( compiledStatement, 1, exerciseID);
			
		}
		if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
			NSLog( @"Error: %s", sqlite3_errmsg(database) );
		}
		else {
			NSLog( @"Insert into row id = %d", sqlite3_last_insert_rowid(database));
		}		
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}






//Delete all exercises of a user for the specified month and year
+(void)deleteUserExercisesInMonthAndYear:(NSInteger)userID:(NSInteger)month:(NSInteger)year {
	sqlite3 *database;
	
	[DataAccessDB initDBParameters];
	
	
	//Get current month beginning as an integer (in seconds)
	NSString *beginningOfMonthString = [[NSString stringWithFormat:@"%i", year] stringByAppendingString:@"-"];
	beginningOfMonthString = [beginningOfMonthString stringByAppendingString:[NSString stringWithFormat:@"%i", month]];
	beginningOfMonthString = [beginningOfMonthString stringByAppendingString:@"-01 00:00:00 +0100"];
	NSDate *beginningOfMonthDate = [NSDate dateWithString:beginningOfMonthString];
	NSInteger beginningOfMonthInt = ((NSInteger)[beginningOfMonthDate timeIntervalSince1970]);
	
	
	//Get current month end as an integer (in seconds). In fact, we take the beginning of the following month (easier, always the 1st day :-) )
	NSInteger nextMonth;
	NSInteger nextYear;
	if (month == 12) {
		nextMonth = 1;
		nextYear = year + 1;
	}
	else {
		nextMonth = month + 1;
		nextYear = year;
	}
	
	NSString *endOfMonthString = [[NSString stringWithFormat:@"%i", nextYear] stringByAppendingString:@"-"];
	endOfMonthString = [endOfMonthString stringByAppendingString:[NSString stringWithFormat:@"%i", nextMonth]];
	endOfMonthString = [endOfMonthString stringByAppendingString:@"-01 00:00:00 +0100"];
	NSDate *endOfMonthDate = [NSDate dateWithString:endOfMonthString];
	NSInteger endOfMonthInt = ((NSInteger)[endOfMonthDate timeIntervalSince1970]);
	
	
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "delete from exercises where (localUserId =? and dateTime >=? and dateTime <?)";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
			sqlite3_bind_int(compiledStatement, 1, userID);
			sqlite3_bind_int(compiledStatement, 2, beginningOfMonthInt);
			sqlite3_bind_int(compiledStatement, 3, endOfMonthInt);
			
		}
		if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
			NSLog( @"Error: %s", sqlite3_errmsg(database) );
		}
		else {
			NSLog( @"Insert into row id = %d", sqlite3_last_insert_rowid(database));
		}		
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}






//Delete all exercises of a user for the specified year
+(void)deleteUserExercisesInYear:(NSInteger)userID:(NSInteger)year {
	sqlite3 *database;
	
	[DataAccessDB initDBParameters];
	
	
	//Get current year beginning as an integer (in seconds)
	NSString *beginningOfYearString = [[NSString stringWithFormat:@"%i", year] stringByAppendingString:@"-"];
	beginningOfYearString = [beginningOfYearString stringByAppendingString:@"01-01 00:00:00 +0100"];
	NSDate *beginningOfYearDate = [NSDate dateWithString:beginningOfYearString];
	NSInteger beginningOfYearInt = ((NSInteger)[beginningOfYearDate timeIntervalSince1970]);
	
	
	//Get current year end as an integer (in seconds)
	NSString *endOfYearString = [[NSString stringWithFormat:@"%i", year] stringByAppendingString:@"-"];
	endOfYearString = [endOfYearString stringByAppendingString:@"12-31 23:59:59 +0100"];
	NSDate *endOfYearDate = [NSDate dateWithString:endOfYearString];
	NSInteger endOfYearInt = ((NSInteger)[endOfYearDate timeIntervalSince1970]);
	
	
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "delete from exercises where (localUserId =? and dateTime >=? and dateTime <=?)";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			
			sqlite3_bind_int(compiledStatement, 1, userID);
			sqlite3_bind_int(compiledStatement, 2, beginningOfYearInt);
			sqlite3_bind_int(compiledStatement, 3, endOfYearInt);
			
		}
		if(sqlite3_step(compiledStatement) != SQLITE_DONE ) {
			NSLog( @"Error: %s", sqlite3_errmsg(database) );
		}
		else {
			NSLog( @"Insert into row id = %d", sqlite3_last_insert_rowid(database));
		}		
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}






/*************************************************** EXPIRATIONS ***************************************************/






//List all expirations of an exercise based on its ID
+(NSArray*)listOfExerciseExpirations:(NSInteger)ID {
	sqlite3 *database;
	NSMutableArray *expirations = [[NSMutableArray alloc] init];
	
	[DataAccessDB initDBParameters];
	
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
		const char *sqlStatement = "select inTargetDuration, outOfTargetDuration from expirations where exerciseId =? order by deltaTime asc";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			sqlite3_bind_int( compiledStatement, 1, ID);
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSInteger inTargetDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)] intValue];
				NSInteger outOfTargetDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)] intValue];
				
				//NSLog(@"ID: %@",aID);
				
				Expiration *expiration = [Expiration alloc];
				[expiration init:nil:nil:nil:inTargetDuration:outOfTargetDuration:0.0];
				
				[expirations addObject:expiration];
				
				[expiration release];
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	
	return [expirations autorelease];
}



@end
