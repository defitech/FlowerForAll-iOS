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

// open an initialize Db if needed
+(sqlite3*) db {
    if (database == nil) {
        // Get path to db File file.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dbFilePath = [documentsDirectory stringByAppendingPathComponent:@"FlutterApp2Database.sql"];
        
        // Get pointer to file manager.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // If the file does not exist, copy it from the app bundle.
        if(![fileManager fileExistsAtPath:dbFilePath])
        {
            NSString* initDbFilePath = [[NSBundle mainBundle] pathForResource:@"FlutterApp2Database" ofType:@"sql"];
            NSError *error;
            if (! [fileManager copyItemAtPath:initDbFilePath toPath:dbFilePath error:&error]) {
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            }
             NSLog(@"DB INITIALIZED");
        }
        
        if(![fileManager fileExistsAtPath:dbFilePath])
        {
            NSAssert1(0, @"cannot find database '%@'.", dbFilePath);
        }
       
        if(sqlite3_open([dbFilePath UTF8String], &database) == SQLITE_OK){
            NSLog(@"DB OPEN %@", dbFilePath);
            NSLog(@"DB VERSION: %@", [DataAccessDB getInfoValueForKey:@"db_version"] );
            NSLog(@"MAX USER ID: %@", [DataAccessDB getSingletValue:@"SELECT MAX(id) FROM users"] );
        } else {
            NSAssert1(0, @"** FAILED ** DB OPEN %@", dbFilePath);
        }
        [fileManager release];
        
        
        //Create the main user (with ID 0) if it does not already exist
        if ([DataAccessDB getUserName:0] == nil) {
            NSString *ownerName = NSLocalizedString(@"OwnerUserName", @"Name of the owner user");
            NSString *ownerPassword = NSLocalizedString(@"OwnerUserPassword", @"Password of the owner user");
            [DataAccessDB createUser:0:ownerName:ownerPassword];
        }
    }
    return database;
}

+(void) close {
    if (database != nil) {
        sqlite3_close(database);
        NSLog(@"close database");
    }
}

//Execute a statement 
+(void)execute:(NSString*)sqlStatement {
    NSLog(@"execute: %@",sqlStatement);
    sqlite3_stmt *statement = [DataAccessDB genCompiledStatement:sqlStatement];
    if (sqlite3_step(statement) != SQLITE_DONE)
    {
        NSLog( @"**ERROR*DB:Execute: %@\n\r\t%s", sqlStatement, sqlite3_errmsg(database) );
    } 
    sqlite3_finalize(statement);
}

+(void)executeWithFormat:(NSString*)sqlStatementFormat, ... {
    va_list ap;
    va_start(ap, sqlStatementFormat);
    NSString *sqlStatement = [[[NSString alloc] initWithFormat:sqlStatementFormat arguments:ap] autorelease];
    va_end(ap);
    [DataAccessDB execute:sqlStatement];
}


/**
 * Create Statement from NSTRing
 * !! don't forget to finalize it!
 */
+(sqlite3_stmt*) genCompiledStatement:(NSString*)sqlStatement {
    NSLog(@"genCompiledStatement: %@",sqlStatement);
    sqlite3_stmt *compiledStatement;
    int res = sqlite3_prepare_v2([DataAccessDB db], [sqlStatement UTF8String], -1, &compiledStatement, NULL);
    if(res == SQLITE_OK) {
        return compiledStatement;
    } else {
        NSLog( @"**ERROR %i *DB:genCompiledStatement: %@\n\r\t%s",res, sqlStatement, sqlite3_errmsg(database) );
    }
    return NULL;
}

/**
 * Usefull to check an ID or if stuff exists in a DB
 */
+ (BOOL)checkIfStatementReturnRows:(NSString*)sqlStatement {
    sqlite3_stmt *compiledStatement = [DataAccessDB genCompiledStatement:sqlStatement];
    if (sqlite3_step(compiledStatement) == SQLITE_ROW) { // at least one row
        sqlite3_finalize(compiledStatement); 
        return YES;
    }
    sqlite3_finalize(compiledStatement);
	return NO;
}

/**
 * shortcut to get a single value
 * ex: "SELECT value FROM infos WHERE key = 'db_version'";
 */
+(NSString*) getSingletValue:(NSString*)sqlStatement {
    NSString *result = nil;
    sqlite3_stmt *compiledStatement = [DataAccessDB genCompiledStatement:sqlStatement];
    if (sqlite3_step(compiledStatement) == SQLITE_ROW) { // at least one row
        result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
    }
    sqlite3_finalize(compiledStatement);
	return result;
}

+(NSString*) getInfoValueForKey:(NSString*)key {
    return [DataAccessDB getSingletValue:[NSString stringWithFormat:@"SELECT value FROM infos WHERE key = '%@'",key]];
}

/*************************************************** USERS ***************************************************/


//Generates a user ID
+ (NSInteger)generateUserID {
    NSString *maxId = [DataAccessDB getSingletValue:@"SELECT MAX(id) FROM users"] ;
    NSInteger nextId = 0;
    if (maxId != nil) {
        nextId = [maxId intValue] + 1;
    }
    return  nextId;
}

//Creates a user
+ (void)createUser:(NSInteger)ID:(NSString *)name:(NSString *)password {
    [DataAccessDB executeWithFormat:@"insert into users (id, name, password) values (%i, '%@', '%@')",ID,name,password];
    
}

//Lists all user IDs
+(NSArray*)listOfAllUserIDs {
    NSMutableArray *userIDs = [[NSMutableArray alloc] init];

    sqlite3_stmt *compiledStatement = [DataAccessDB genCompiledStatement:@"SELECT id FROM users"];
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            [userIDs addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]];
        }
    sqlite3_finalize(compiledStatement);
	
	return [userIDs autorelease];
}

//Get a user name besed on its ID
+(NSString*)getUserName:(NSInteger)ID {
	return [DataAccessDB getSingletValue:[NSString stringWithFormat:@"select name from users where id = %i",ID]];
}

//Get a user password besed on its ID
+(NSString*)getUserPassword:(NSInteger)ID {
    return [DataAccessDB getSingletValue:[NSString stringWithFormat:@"select password from users where id = %i",ID]];
}

//Set a new name to a user
+(void)setUserName:(NSInteger)ID:(NSString *)newName {
	[DataAccessDB executeWithFormat:@"UPDATE users SET NAME='%@' WHERE id=%i",newName,ID];
}

//Set a new password to a user
+(void)setUserPassword:(NSInteger)ID:(NSString *)newPassword {
    [DataAccessDB executeWithFormat:@"update users set password='%@' where id=%i",newPassword,ID] ;
}

//Deletes a user
+(void)deleteUser:(NSInteger)ID {
    [DataAccessDB executeWithFormat:@"delete from users where id=%i",ID];
}


/*************************************************** EXERCISES ***************************************************/


//Lists all the exercises of a user based on its ID
+(NSArray*)listOfUserExercises:(NSInteger)ID {
	NSLog(@"listOfUserExercises");
	NSMutableArray *exercises = [[NSMutableArray alloc] init];

		sqlite3_stmt *compiledStatement = 
        [DataAccessDB genCompiledStatement:@"select * from exercises where localUserId =? order by dateTime desc"];

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
		
		sqlite3_finalize(compiledStatement);

    return [exercises autorelease];
}





//Lists all the exercises of a user (based on its ID) for the specified month and year
+(NSArray*)listOfUserExercisesInMonthAndYear:(NSInteger)ID:(NSInteger)month:(NSInteger)year {
    NSLog(@"listOfUserExercisesInMonthAndYear");
	NSMutableArray *exercises = [[NSMutableArray alloc] init];
	
	
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
	
	
	
		sqlite3_stmt *compiledStatement = [DataAccessDB genCompiledStatement:@"select * from exercises where (localUserId =? and dateTime >=? and dateTime <?) order by dateTime desc"];

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
		
		sqlite3_finalize(compiledStatement);

	
	return [exercises autorelease];
}






//Get all dateTimes a user's exercises
//This is used in order to be able to classify the exercises on a time base:
//Which exercice have been done in the current month, which have been done in past months but still in the year,
//and which have been done in the past years. (This is used to hierarchically display exercise data to the user,
//depending on when the exercises have been done. See the classes StatisticListViewController, MonthStatisticListViewController
//and YearStatisticListViewController.)
+(NSArray*)listOfUserExerciseDates:(NSInteger)ID {
    NSLog(@"listOfUserExerciseDates");
	NSMutableArray *dateTimes = [[NSMutableArray alloc] init];
	

     sqlite3_stmt *compiledStatement = [DataAccessDB genCompiledStatement:@"select dateTime from exercises where localUserId =? order by dateTime desc"];
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *dateTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				
				//NSLog(@"wwwwwwwwwwwwwwwwwwwwwww: %@",dateTime);
				
				[dateTimes addObject:dateTime];
			
			}
		
		sqlite3_finalize(compiledStatement);

	
	return [dateTimes autorelease];
}





//Lists all dateTimes of a user's exercise (based on its ID) for the specified year
//This is used by the class YearStatisticListViewController
+(NSArray*)listOfUserExerciseDatesInYear:(NSInteger)ID:(NSInteger)year {
    NSLog(@"listOfUserExerciseDatesInYear");
		NSMutableArray *dateTimes = [[NSMutableArray alloc] init];
	
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
	

    sqlite3_stmt *compiledStatement = [DataAccessDB genCompiledStatement:@"select dateTime from exercises where (localUserId =? and dateTime >=? and dateTime <=?) order by dateTime desc"];
			sqlite3_bind_int( compiledStatement, 1, ID);
			sqlite3_bind_int( compiledStatement, 2, beginningOfYearInt);
			sqlite3_bind_int( compiledStatement, 3, endOfYearInt);
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *dateTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				
				//NSLog(@"wwwwwwwwwwwwwwwwwwwwwww: %@",dateTime);
				
				[dateTimes addObject:dateTime];
				
			}
		
		sqlite3_finalize(compiledStatement);

	
	return [dateTimes autorelease];
}






//Deletes an exercise
+(void)deleteExercise:(NSInteger)exerciseID {
    NSLog(@"deleteExercise");
    [DataAccessDB execute:[NSString stringWithFormat:@"delete from exercises where id=%i",exerciseID]];
}






//Delete all exercises of a user for the specified month and year
+(void)deleteUserExercisesInMonthAndYear:(NSInteger)userID:(NSInteger)month:(NSInteger)year {
    NSLog(@"deleteUserExercisesInMonthAndYear");
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
	
     [DataAccessDB execute:
      [NSString stringWithFormat:@"delete from exercises where (localUserId =%i and dateTime >=%i and dateTime <%i)",userID,beginningOfMonthInt,endOfMonthInt]];
}






//Delete all exercises of a user for the specified year
+(void)deleteUserExercisesInYear:(NSInteger)userID:(NSInteger)year {
	NSLog(@"deleteUserExercisesInYear");
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
	
    [DataAccessDB execute:
     [NSString stringWithFormat:@"delete from exercises where (localUserId =%i and dateTime >=%i and dateTime <=%i)",userID,beginningOfYearInt,endOfYearInt]];
}






/*************************************************** EXPIRATIONS ***************************************************/






//List all expirations of an exercise based on its ID
+(NSArray*)listOfExerciseExpirations:(NSInteger)ID {
    NSLog(@"listOfExerciseExpirations");
	NSMutableArray *expirations = [[NSMutableArray alloc] init];
	
		
		sqlite3_stmt *compiledStatement = [DataAccessDB genCompiledStatement:@"select inTargetDuration, outOfTargetDuration from expirations where exerciseId =? order by deltaTime asc"];
		
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
		
		sqlite3_finalize(compiledStatement);
	
	
	return [expirations autorelease];
}



@end
