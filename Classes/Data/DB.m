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

#import "User.h"
#import "Exercise.h"
#import "Expiration.h"
#import "Profil.h"

#import "FLAPIBlow.h"
#import "FLAPIExercice.h"
#import "ParametersManager.h"

#import "ExerciseDay.h"


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
      
                
        // Open the database
        if(sqlite3_open([dbFilePath UTF8String], &database) == SQLITE_OK){
            NSLog(@"DB OPEN %@", dbFilePath);
            
            NSString* actualVersion = [DB getInfoValueForKey:@"db_version"];
            
            if (actualVersion == nil) {
                [DB execute:@"CREATE TABLE infos(key TEXT PRIMARY KEY, value TEXT);"];
                [DB execute:@"CREATE TABLE profils(pid INTEGER PRIMARY KEY AUTOINCREMENT, \
                                                 name TEXT NOT NULL, \
                                                 frequency_target_hz NUM, \
                                                 frequency_tolerance_hz NUM, \
                                                 duration_expiration_s NUM, \
                                                 duration_exercice_s NUM);"];
                [DB executeWF:@"INSERT INTO profils VALUES (0,'%@',16,6,3,40)",
                    NSLocalizedString(@"Normal", @"Name of the standard Profile")];
                [DB executeWF:@"INSERT INTO profils VALUES (1,'%@',16,8,3,30)",
                    NSLocalizedString(@"Easy", @"Name of the easy Profile")];
                [DB executeWF:@"INSERT INTO profils VALUES (2,'%@',18,4,10,100)",
                    NSLocalizedString(@"Difficult", @"Name of the difficult Profile")];
                
                [DB execute:@"CREATE TABLE blows(timestamp NUM PRIMARY KEY, duration NUM, ir_duration NUM, goal INTEGER DEFAULT 0) ;"];
                [DB execute:@"CREATE TABLE exercices(start_ts NUM PRIMARY KEY, stop_ts NUM, \
                                    frequency_target_hz NUM, frequency_tolerance_hz NUM, \
                                    duration_expiration_s NUM, duration_exercice_s NUM, \
                                    duration_exercice_done_p NUM, blow_count NUM, blow_star_count NUM , profile_name TEXT) ;"];
                actualVersion = @"4";
                [DB setInfoValueForKey:@"db_version" value:actualVersion];
            } 
            
            // update from 1 to 2
            if ([actualVersion isEqualToString:@"1"]) {
                [DB execute:@"ALTER TABLE blows ADD COLUMN goal INTEGER DEFAULT 0;"];
                [DB execute:@"UPDATE  blows SET goal = 0;"];
                [DB executeWF:@"UPDATE blows SET goal = 1 WHERE ir_duration >= %f;",1.1f ];
                actualVersion = @"2";
                [DB setInfoValueForKey:@"db_version" value:actualVersion];
            }
            
            // update from 2 to 3
            if ([actualVersion isEqualToString:@"2"]) {
                [DB execute:@"CREATE TABLE exercices(start_ts NUM PRIMARY KEY, stop_ts NUM, \
                                                    frequency_target_hz NUM, frequency_tolerance_hz NUM, \
                                                    duration_expiration_s NUM, duration_exercice_s NUM, \
                                                    duration_exercice_done_p NUM, blow_count NUM, blow_star_count NUM) ;"];
                 actualVersion = @"3";
                [DB setInfoValueForKey:@"db_version" value:actualVersion];
            }
            
            
            // update from 3 to 4
            if ([actualVersion isEqualToString:@"3"]) {
                [DB execute:@"CREATE TABLE profils(pid INTEGER PRIMARY KEY AUTOINCREMENT, \
                 name TEXT NOT NULL, \
                 frequency_target_hz NUM, \
                 frequency_tolerance_hz NUM, \
                 duration_expiration_s NUM, \
                 duration_exercice_s NUM);"];
                [DB executeWF:@"INSERT INTO profils VALUES (0,'%@',16,6,3,40)",
                 NSLocalizedString(@"Normal", @"Name of the standard Profile")];
                [DB executeWF:@"INSERT INTO profils VALUES (1,'%@',16,8,3,30)",
                 NSLocalizedString(@"Easy", @"Name of the easy Profile")];
                [DB executeWF:@"INSERT INTO profils VALUES (2,'%@',18,4,10,100)",
                 NSLocalizedString(@"Difficult", @"Name of the difficult Profile")];
                
                [DB execute:@"ALTER TABLE exercices ADD COLUMN profile_name TEXT DEFAULT 'Unkown';"];
                
                actualVersion = @"4";
                [DB setInfoValueForKey:@"db_version" value:actualVersion];
            }
            NSLog(@"DB VERSION: %@", [DB getInfoValueForKey:@"db_version"] );
        } else {
            NSAssert1(0, @"** FAILED ** DB OPEN %@", dbFilePath);
        }
    }
    return database;
}

+(void) close {
    if (database != nil) {
        sqlite3_close(database);
        database = nil;
        NSLog(@"close database");
    }
}

//Execute a statement 
+(void)execute:(NSString*)sqlStatement {
   // NSLog(@"execute: %@",sqlStatement);
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
   // NSLog(@"genCStatement: %@",sqlStatement);
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

+(void) setInfoValueForKey:(NSString*)key value:(NSString*)value {
   [DB executeWF:@"REPLACE INTO infos (key, value) VALUES ('%@', '%@')",key,value];
}

// convenience shortcut to get a String at a defined index in a row
+(NSString*) colS:(sqlite3_stmt*)cStatement index:(int)index {
    if (sqlite3_column_text(cStatement, index) == nil) return @"";
    return [NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, index)];
}

+(int) colI:(sqlite3_stmt*)cStatement index:(int)index {
    if (sqlite3_column_text(cStatement, index) == nil) return 0;
     return sqlite3_column_int(cStatement, index);
}

+(double) colD:(sqlite3_stmt*)cStatement index:(int)index {
     if (sqlite3_column_text(cStatement, index) == nil) return 0.0f;
    return sqlite3_column_double(cStatement, index);
}


+(BOOL) colB:(sqlite3_stmt*)cStatement index:(int)index {
    if (sqlite3_column_text(cStatement, index) == nil) return FALSE;
    return (sqlite3_column_int(cStatement, index) != 0);
}

+(NSDate*) colT:(sqlite3_stmt*)cStatement index:(int)index {
    return [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[DB colD:cStatement index:index]] autorelease];
}

// look at colTDF to reuuse your own NSDateFormatter
+(NSString*) colTWF:(sqlite3_stmt*)cStatement index:(int)index format:(NSString*)format {
    NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:[DB colT:cStatement index:index]];
}
            
+(NSString*) colTDF:(sqlite3_stmt*)cStatement index:(int)index format:(NSDateFormatter*)dateFormatter {
    return [dateFormatter stringFromDate:[DB colT:cStatement index:index]];
}

/******************************************** EXERCICES ****************************************************/

+ (void) saveExercice:(FLAPIExercice*)e {
    [DB executeWF:@"INSERT INTO exercices (start_ts,stop_ts,frequency_target_hz, frequency_tolerance_hz, \
     duration_expiration_s, duration_exercice_s, duration_exercice_done_p , blow_count, blow_star_count , profile_name) \
        VALUES ('%f', '%f', '%f', '%f', '%f', '%f','%f','%i','%i','%@')",
        e.start_ts, e.stop_ts, e.frequency_target_hz, e.frequency_tolerance_hz, e.duration_expiration_s, e.duration_exercice_s, [e percent_done], e.blow_count, e.blow_star_count, [Profil current].name];
    
}


/**
 * Computes all days that contains exercises in the DB and return an array of ExerciseDay objects.
 * The algorithm first fetches all exercises (only start_ts and duration_exercice_done_p columns),
 * ordering by start_ts desc, in order to get exercise in the right order.
 * Then it uses 2 objects: currentDay and lastDay. The loop iterates over all exercises and at each
 * iteration, it checks if the current exercise belongs to the same day as the previous one.
 * If it is not the case, it adds a new exercise day in the array. In all cases, it
 * increments the day's good count if the exercise is successfull, the day's bad count otherwise.
 */
+(NSMutableArray*) getDays {
	NSLog(@"Get all days");
	
    //Array to store results
    NSMutableArray *days = [[NSMutableArray alloc] init];
    
    //Objects used by the algorithm: the day of the current exercise (currentDay) and the last added day in the array (lastDay)
    ExerciseDay* currentDay = nil;
    ExerciseDay* lastDay = nil;
    
    sqlite3_stmt *cStatement = 
    [DB genCStatementWF:@"SELECT start_ts, duration_exercice_done_p FROM exercices ORDER BY start_ts DESC"];
    
    //Iterate over the result set
    while(sqlite3_step(cStatement) == SQLITE_ROW) {
        
        //Get data from the current row of the result set
        double start_ts = [DB colD:cStatement index:0];
        double duration_exercice_done_p = [DB colD:cStatement index:1];
        
        //Initialize currentDay with the start_ts of the current exercise
        currentDay = [[ExerciseDay alloc] init:start_ts];
        
        //Case where the current day is a new day (not already in the array)
        if (lastDay == nil || ![lastDay.formattedDate isEqualToString:currentDay.formattedDate]) {
            //Check if the current exercise is successfull, then increment the day's bad or good count,
            //and concatenate "0" or "1" to the day's order string.
            if (duration_exercice_done_p >= 1.0f){
                currentDay.good++;
                currentDay.order = [currentDay.order stringByAppendingString:@"1"];
            }
            else{
                currentDay.bad++;
                currentDay.order = [currentDay.order stringByAppendingString:@"0"];
            }
            lastDay = currentDay;
            //add the new day to the array
            [days addObject:currentDay];
        }
        
        //Case where the current day is NOT a new day (already in the array)
        else {
            //Check if the current exercise is successfull, then increment the day's bad or good count,
            //and concatenate "0" or "1" to the day's order string.
            if (duration_exercice_done_p >= 1.0f){
                lastDay.good++;
                lastDay.order = [lastDay.order stringByAppendingString:@"1"];
            }
            else{
                lastDay.bad++;
                lastDay.order = [lastDay.order stringByAppendingString:@"0"];
            }
        }
        
    }
    sqlite3_finalize(cStatement);
    [currentDay release];
    return days;
}


/**
 * Retrieves all exercises in the given day and returns an array of Exercise objects.
 * The input parametter day is the day formatted as a string (ex: 12.10.2011)
 */
+(NSMutableArray*) getExercisesInDay:(NSString*) day {
	
    //Create a date formatter for date and time
    NSDateFormatter* dateAndTimeFormatter = [[NSDateFormatter alloc] init];
    [dateAndTimeFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateAndTimeFormatter setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    
    //Create 2 NSDate for the beginning and the end of the day
    NSDate *dayBegin = [dateAndTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",day, @"00:00:00"]];
    NSDate *dayEnd = [dateAndTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",day, @"23:59:59"]];
    
    //Convert the NSDates to absolute time
    double dayBeginAbsoluteTime = [dayBegin timeIntervalSinceReferenceDate];
    double dayEndAbsoluteTime = [dayEnd timeIntervalSinceReferenceDate];
    
    NSMutableArray *exercises = [[NSMutableArray alloc] init];
    
    //Execute query using dayBeginAbsoluteTime and dayEndAbsoluteTime as bounds
    sqlite3_stmt *cStatement = 
    [DB genCStatementWF:@"SELECT start_ts, stop_ts, frequency_target_hz, frequency_tolerance_hz, duration_expiration_s, duration_exercice_s, duration_exercice_done_p, blow_count, blow_star_count, profile_name FROM exercices WHERE start_ts >= '%f' AND start_ts <= '%f' ORDER BY start_ts DESC", dayBeginAbsoluteTime, dayEndAbsoluteTime];
    
    //Add all exercises in the result set to the result's array
    while(sqlite3_step(cStatement) == SQLITE_ROW) {
        
        Exercise *exercise = [[[Exercise alloc] init:[DB colD:cStatement index:0]:[DB colD:cStatement index:1]:[DB colD:cStatement index:2]:[DB colD:cStatement index:3]:[DB colD:cStatement index:4]:[DB colD:cStatement index:5]:[DB colD:cStatement index:6]:[DB colD:cStatement index:7]:[DB colD:cStatement index:8]:[DB colS:cStatement index:9]] autorelease];
        
        [exercises addObject:exercise];
    }
    sqlite3_finalize(cStatement);
    [dateAndTimeFormatter release];
    return exercises;
}


/**
 * Delete all exercises in the given day.
 * The input parametter day is the day formatted as a string (ex: 12.10.2011)
 */
+(void) deleteDay:(NSString*)day {
	NSLog(@"Delete exercises in the given day");
	
    //Create a date formatter for date and time
    NSDateFormatter* dateAndTimeFormatter = [[NSDateFormatter alloc] init];
    [dateAndTimeFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateAndTimeFormatter setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    
    //Create 2 NSDate for the beginning and the end of the day
    NSDate *dayBegin = [dateAndTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",day, @"00:00:00"]];
    NSDate *dayEnd = [dateAndTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",day, @"23:59:59"]];
    
    //Convert the NSDates to absolute time
    double dayBeginAbsoluteTime = [dayBegin timeIntervalSinceReferenceDate];
    double dayEndAbsoluteTime = [dayEnd timeIntervalSinceReferenceDate];
    
    //Execute query using dayBeginAbsoluteTime and dayEndAbsoluteTime as bounds
    [DB executeWF:@"DELETE FROM exercices WHERE (start_ts >= '%f' AND start_ts <= '%f')", dayBeginAbsoluteTime, dayEndAbsoluteTime];

    [dateAndTimeFormatter release];
}


/**
 * Delete the exercises given by its start_ts.
 */
+(void) deleteExercise:(double)start_ts {
	NSLog(@"Delete exercise");
    
    [DB executeWF:@"DELETE FROM exercices WHERE start_ts = '%f'", start_ts];
}

/******************************************* EXERCICES DATA ***********************************/
# pragma mark  EXERCICES DATA

/*************************************************** BLOWS ***************************************************/
# pragma mark  BLOWS

+ (void) saveBlow:(FLAPIBlow*)blow {
    [DB executeWF:@"INSERT INTO blows (timestamp, duration, ir_duration, goal) VALUES ('%f', '%f', '%f', '%i')",
     blow.timestamp,blow.duration,blow.in_range_duration,blow.goal];
}


/** fill **/
+ (void) fillWithBlows:(NSMutableArray*)history fromTimestamp:(double)timestamp {
    
    sqlite3_stmt *cStatement = 
    [DB genCStatementWF:@"SELECT timestamp, duration, ir_duration, goal FROM blows WHERE timestamp >= %f",timestamp];
    while(sqlite3_step(cStatement) == SQLITE_ROW) {
        [history addObject:[[[FLAPIBlow alloc] initWith:[DB colD:cStatement index:0] duration:[DB colD:cStatement index:1] in_range_duration:[DB colD:cStatement index:2] goal:[DB colB:cStatement index:3] medianFrequency:0.0] autorelease] ];
    }
    sqlite3_finalize(cStatement);
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


@end
