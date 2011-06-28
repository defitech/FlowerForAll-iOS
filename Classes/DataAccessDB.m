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



@implementation DataAccessDB


static sqlite3 *database;


+(sqlite3*) db {
    if (database == nil) {
        NSString* databasePath = [[NSBundle mainBundle] pathForResource:@"FlutterApp2Database" ofType:@"sql"] ;
        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK){
            NSLog(@"DB OPEN %@", databasePath);
        } else {
            NSLog(@"** FAILED ** DB OPEN %@", databasePath);
        }
    }
    return database;
}

+(void) close {
    if (database != nil) {
        sqlite3_close(database);
    }
}

//Execute a statement 
+(void)execute:(NSString*)sqlStatement {
    sqlite3_stmt  *statement;
    const char *insert_stmt = [sqlStatement UTF8String];
    
    sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
    if (sqlite3_step(statement) == SQLITE_DONE)
    {
        NSLog( @"**ERROR*DB:Execute: %@\n\r\t%s", sqlStatement, sqlite3_errmsg(database) );
    } 
    sqlite3_finalize(statement);
}

/**
 * Create Statement from NSTRing
 * !! don't forget to finalize it!
 */
+(sqlite3_stmt*) genCompiledStatement:(NSString*)sqlStatement {
    const char *sqlStatementC = [sqlStatement UTF8String];
    sqlite3_stmt *compiledStatement;
    if(sqlite3_prepare_v2(database, sqlStatementC, -1, &compiledStatement, NULL) == SQLITE_OK) {
        return compiledStatement;
    }
    return NULL;
}

/**
 * Usefull to check an ID or if stuff exists in a DB
 */
+ (BOOL)checkIfStatementReturnRows:(NSString*)sqlStatement {

    sqlite3_stmt *compiledStatement = [DataAccessDB genCompiledStatement:sqlStatement];
    if (sqlite3_step(compiledStatement) == SQLITE_ROW) { // at least one row
        return YES;
    }
    sqlite3_finalize(compiledStatement);
	return NO;
}



/*************************************************** USERS ***************************************************/





//Generates a user ID
+ (NSInteger)generateUserID {
    NSMutableArray *userIDs = [[NSMutableArray alloc] init];
	
    const char *sqlStatement = "select id from users";
    
    sqlite3_stmt *compiledStatement;
    if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            // Read the data from the result row
            NSString *aID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
            [userIDs addObject:aID];
        }
    }
    sqlite3_finalize(compiledStatement);
	
	
	
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
			NSLog( @"Insert into row id = %lld", sqlite3_last_insert_rowid(database));
		}		
		sqlite3_finalize(compiledStatement);
	
}



//Checks if a user already exists
+ (BOOL)checkIfUserAlreadyExists:(NSInteger)ID {
	
	
	NSArray *userIDs = [DataAccessDB listOfAllUserIDs];
 
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
    NSMutableArray *userIDs = [[NSMutableArray alloc] init];
	
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
	
	return [userIDs autorelease];
}




//Get a user name besed on its ID
+(NSString*)getUserName:(NSInteger)ID {
	
	NSString *name = nil;
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
	
	return name;
}




//Get a user password besed on its ID
+(NSString*)getUserPassword:(NSInteger)ID {
	NSString *password = nil;
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
		return password;
}





//Set a new name to a user
+(void)setUserName:(NSInteger)ID:(NSString *)newName {
	
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
			NSLog( @"Insert into row id = %lld", sqlite3_last_insert_rowid(database));
		}		
		sqlite3_finalize(compiledStatement);
}





//Set a new password to a user
+(void)setUserPassword:(NSInteger)ID:(NSString *)newPassword {
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





//Deletes a user
+(void)deleteUser:(NSInteger)ID {
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
