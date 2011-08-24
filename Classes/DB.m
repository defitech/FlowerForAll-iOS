//
//  DataAccess2.m
//  FlutterApp2
//
//  Created by Dev on 18.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  Implementation of the DataAccess DB class


#import "FlutterApp2AppDelegate.h"

#import "DB.h"
#import "UserManager.h"
#import "DataAccess.h"

#import "DateClassifier.h"

#import "User.h"
#import "Exercise.h"
#import "Expiration.h"



@implementation DB


static sqlite3 *database;

// open an initialize Db if needed
+(sqlite3*) db {
    if (database == nil) {
        if ([UserManager currentUser] == nil) {
            NSLog(@"DB CANNOT BE INITIALIZED UNTIL A USER IS SET");
            return nil;
        }
        
        // Get path to db File file.
        NSString *dbFilePath = [NSString stringWithFormat:@"%@/%@/db.sql",
            [DataAccess docDirectory],
            [UserManager uDir:[[UserManager currentUser] uid]]];
        
        // Get pointer to file manager.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // If the file does not exist, copy it from the app bundle.
        if(![fileManager fileExistsAtPath:dbFilePath])
        {
            NSString* initDbFilePath = [[NSBundle mainBundle] pathForResource:@"FlutterApp2Database" 
                                                ofType:@"sql" inDirectory:@"sqlite_database"];
            NSError *error;
            if (! [fileManager copyItemAtPath:initDbFilePath toPath:dbFilePath error:&error]) {
                NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
            }
            // Check DB
            if(![fileManager fileExistsAtPath:dbFilePath])
            {
                NSAssert1(0, @"cannot find database '%@'.", dbFilePath);
            }
             NSLog(@"DB INITIALIZED");
        }
        [fileManager release];
        
        // Open the database
        if(sqlite3_open([dbFilePath UTF8String], &database) == SQLITE_OK){
            NSLog(@"DB OPEN %@", dbFilePath);
            NSLog(@"DB VERSION: %@", [DB getInfoValueForKey:@"db_version"] );
        } else {
            NSAssert1(0, @"** FAILED ** DB OPEN %@", dbFilePath);
        }

        //Create the main user (with ID 0) if it does not already exist
        if ([DB getUserName:0] == nil) {
            NSString *ownerName = NSLocalizedString(@"OwnerUserName", @"Name of the owner user");
            NSString *ownerPassword = NSLocalizedString(@"OwnerUserPassword", @"Password of the owner user");
            [DB createUser:0:ownerName:ownerPassword];
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
    sqlite3_stmt *statement = [DB genCStatement:sqlStatement];
    if (sqlite3_step(statement) != SQLITE_DONE)
    {
        NSLog( @"**ERROR*DB:Execute: %@\n\r\t%s", sqlStatement, sqlite3_errmsg(database) );
    } 
    sqlite3_finalize(statement);
}

+(void)executeWF:(NSString*)sqlStatementFormat, ... {
    va_list ap;
    va_start(ap, sqlStatementFormat);
    NSString *sqlStatement = [[[NSString alloc] initWithFormat:sqlStatementFormat arguments:ap] autorelease];
    va_end(ap);
    [DB execute:sqlStatement];
}


/**
 * Create Statement from NSTRing
 * !! don't forget to finalize it!
 */
+(sqlite3_stmt*) genCStatement:(NSString*)sqlStatement {
    NSLog(@"genCStatement: %@",sqlStatement);
    sqlite3_stmt *cStatement;
    int res = sqlite3_prepare_v2([DB db], [sqlStatement UTF8String], -1, &cStatement, NULL);
    if(res == SQLITE_OK) {
        return cStatement;
    } else {
        NSLog( @"**ERROR %i *DB:genCStatement: %@\n\r\t%s",res, sqlStatement, sqlite3_errmsg(database) );
    }
    return NULL;
}


+(sqlite3_stmt*) genCStatementWF:(NSString*)sqlStatementFormat, ...  {
    va_list ap;
    va_start(ap, sqlStatementFormat);
    NSString *sqlStatement = [[[NSString alloc] initWithFormat:sqlStatementFormat arguments:ap] autorelease];
    va_end(ap);
    return [DB genCStatement:sqlStatement];
}

/**
 * shortcut to get a single value
 * ex: "SELECT value FROM infos WHERE key = 'db_version'";
 */
+(NSString*) getSingleValue:(NSString*)sqlStatement {
    NSString *result = nil;
    sqlite3_stmt *cStatement = [DB genCStatement:sqlStatement];
    if (sqlite3_step(cStatement) == SQLITE_ROW) { // at least one row
        result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 0)];
    }
    sqlite3_finalize(cStatement);
	return result;
}

+(NSString*) getSingleValueWF:(NSString*)sqlStatementFormat, ... {
    va_list ap;
    va_start(ap, sqlStatementFormat);
    NSString *sqlStatement = [[[NSString alloc] initWithFormat:sqlStatementFormat arguments:ap] autorelease];
    va_end(ap);
    return [DB getSingleValue:sqlStatement];
}
    
+(NSString*) getInfoValueForKey:(NSString*)key {
    return [DB getSingleValueWF:@"SELECT value FROM infos WHERE key = '%@'",key];
}

// convenience shortcut to get a String at a defined index in a row
+(NSString*) colS:(sqlite3_stmt*)cStatement index:(int)index {
    return [NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, index)];
}

+(int) colI:(sqlite3_stmt*)cStatement index:(int)index {
     return sqlite3_column_int(cStatement, index);
}

+(double) colD:(sqlite3_stmt*)cStatement index:(int)index {
    return sqlite3_column_double(cStatement, index);
}

/*************************************************** USERS ***************************************************/


//Generates a user ID
+ (NSInteger)generateUserID {
    NSString *maxId = [DB getSingleValue:@"SELECT MAX(id) FROM users"] ;
    NSInteger nextId = 0;
    if (maxId != nil) {
        nextId = [maxId intValue] + 1;
    }
    return  nextId;
}

//Creates a user
+ (void)createUser:(NSInteger)ID:(NSString *)name:(NSString *)password {
    [DB executeWF:@"INSERT INTO users (id, name, password) VALUES (%i, '%@', '%@')",ID,name,password];
    
}

//Lists all user IDs
+(NSArray*)listOfAllUserIDs {
    NSMutableArray *userIDs = [[NSMutableArray alloc] init];

    sqlite3_stmt *cStatement = [DB genCStatement:@"SELECT id FROM users"];
        while(sqlite3_step(cStatement) == SQLITE_ROW) {
            [userIDs addObject:[DB colS:cStatement index:0]];
        }
    sqlite3_finalize(cStatement);
	
	return [userIDs autorelease];
}

//Get a user name besed on its ID
+(NSString*)getUserName:(NSInteger)ID {
	return [DB getSingleValueWF:@"SELECT name FROM users WHERE id = %i",ID];
}

//Get a user password besed on its ID
+(NSString*)getUserPassword:(NSInteger)ID {
    return [DB getSingleValueWF:@"SELECT password FROM users WHERE id = %i",ID];
}

//Set a new name to a user
+(void)setUserName:(NSInteger)ID:(NSString *)newName {
	[DB executeWF:@"UPDATE users SET NAME='%@' WHERE id=%i",newName,ID];
}

//Set a new password to a user
+(void)setUserPassword:(NSInteger)ID:(NSString *)newPassword {
    [DB executeWF:@"UPDATE users SET password='%@' WHERE id=%i",newPassword,ID] ;
}

//Deletes a user
+(void)deleteUser:(NSInteger)ID {
    [DB executeWF:@"DELETE FROM users WHERE id=%i",ID];
}


/*************************************************** EXERCISES ***************************************************/


//Lists all the exercises of a user based on its ID
+(NSArray*)listOfUserExercises:(NSInteger)ID {
	NSLog(@"listOfUserExercises");
	NSMutableArray *exercises = [[NSMutableArray alloc] init];

		sqlite3_stmt *cStatement = 
    [DB genCStatementWF:@"select * from exercises where localUserId = %i order by dateTime desc",ID];
    
			while(sqlite3_step(cStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSInteger aID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 0)] intValue];
				NSInteger dateTime = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 1)] intValue];
				NSString *appVersion = [NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 2)];
				NSInteger localUserId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 3)] intValue];
				NSInteger globalUserId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 4)] intValue];
				NSInteger gameId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 5)] intValue];
				double targetFrequency = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 6)] doubleValue];
				double targetFrequencyTolerance = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 7)] doubleValue];
				NSInteger targetBlowingDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 8)] intValue];
				NSInteger targetDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 9)] intValue];
				double goodPercentage = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 10)] doubleValue];
				NSInteger transferStatus = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 11)] intValue];

				
				//NSLog(@"ID: %@",aID);
				
				Exercise *exercise = [Exercise alloc];
				[exercise init:aID:dateTime:appVersion:localUserId:globalUserId:gameId:targetFrequency:targetFrequencyTolerance:targetBlowingDuration:targetDuration:goodPercentage:transferStatus];
				
				[exercises addObject:exercise];
				
				[exercise release];
			}
		
		sqlite3_finalize(cStatement);

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
	
	
	
		sqlite3_stmt *cStatement = 
        [DB genCStatementWF:@"select * from exercises where (localUserId = %i and dateTime >= %i and dateTime < %i) order by dateTime desc", ID, beginningOfMonthInt, endOfMonthInt];
    
			while(sqlite3_step(cStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSInteger aID = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 0)] intValue];
				NSInteger dateTime = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 1)] intValue];
				NSString *appVersion = [NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 2)];
				NSInteger localUserId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 3)] intValue];
				NSInteger globalUserId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 4)] intValue];
				NSInteger gameId = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 5)] intValue];
				double targetFrequency = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 6)] doubleValue];
				double targetFrequencyTolerance = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 7)] doubleValue];
				NSInteger targetBlowingDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 8)] intValue];
				NSInteger targetDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 9)] intValue];
				double goodPercentage = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 10)] doubleValue];
				NSInteger transferStatus = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 11)] intValue];
				
				
				//NSLog(@"ID: %@",aID);
				
				Exercise *exercise = [Exercise alloc];
				[exercise init:aID:dateTime:appVersion:localUserId:globalUserId:gameId:targetFrequency:targetFrequencyTolerance:targetBlowingDuration:targetDuration:goodPercentage:transferStatus];
				
				[exercises addObject:exercise];
				
				[exercise release];
			}
		
		sqlite3_finalize(cStatement);

	
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
	
     sqlite3_stmt *cStatement = [DB genCStatementWF:@"select dateTime from exercises where localUserId = %i order by dateTime desc",ID];
    
			while(sqlite3_step(cStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *dateTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 0)];
				
				//NSLog(@"wwwwwwwwwwwwwwwwwwwwwww: %@",dateTime);
				
				[dateTimes addObject:dateTime];
			
			}
		
		sqlite3_finalize(cStatement);

	
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
	

    sqlite3_stmt *cStatement = [DB genCStatementWF:@"select dateTime from exercises where (localUserId =%i and dateTime >= %i and dateTime <= %i) order by dateTime desc", ID, beginningOfYearInt, endOfYearInt];
    
			while(sqlite3_step(cStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSString *dateTime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 0)];
				
				//NSLog(@"wwwwwwwwwwwwwwwwwwwwwww: %@",dateTime);
				
				[dateTimes addObject:dateTime];
				
			}
		
		sqlite3_finalize(cStatement);

	
	return [dateTimes autorelease];
}






//Deletes an exercise
+(void)deleteExercise:(NSInteger)exerciseID {
    [DB executeWF:@"delete from exercises where id=%i",exerciseID];
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
	
    [DB executeWF:@"delete from exercises where (localUserId =%i and dateTime >=%i and dateTime <%i)",userID,beginningOfMonthInt,endOfMonthInt];
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
	
    [DB executeWF:@"delete from exercises where (localUserId =%i and dateTime >=%i and dateTime <=%i)",userID,beginningOfYearInt,endOfYearInt];
}






/*************************************************** EXPIRATIONS ***************************************************/


//List all expirations of an exercise based on its ID
+(NSArray*)listOfExerciseExpirations:(NSInteger)ID {
    NSLog(@"listOfExerciseExpirations");
	NSMutableArray *expirations = [[NSMutableArray alloc] init];
	
		
    sqlite3_stmt *cStatement = [DB genCStatementWF:@"select inTargetDuration, outOfTargetDuration from expirations where exerciseId = %i order by deltaTime asc", ID];
    
			while(sqlite3_step(cStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSInteger inTargetDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 0)] intValue];
				NSInteger outOfTargetDuration = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, 1)] intValue];
				
				//NSLog(@"ID: %@",aID);
				
				Expiration *expiration = [Expiration alloc];
				[expiration init:nil:nil:nil:inTargetDuration:outOfTargetDuration:0.0];
				
				[expirations addObject:expiration];
				
				[expiration release];
			}
		
		sqlite3_finalize(cStatement);
	
	
	return [expirations autorelease];
}



@end
