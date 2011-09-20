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
    //NSLog(@"genCStatement: %@",sqlStatement);
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
    return [NSString stringWithUTF8String:(char *)sqlite3_column_text(cStatement, index)];
}

+(int) colI:(sqlite3_stmt*)cStatement index:(int)index {
     return sqlite3_column_int(cStatement, index);
}

+(double) colD:(sqlite3_stmt*)cStatement index:(int)index {
    return sqlite3_column_double(cStatement, index);
}


+(BOOL) colB:(sqlite3_stmt*)cStatement index:(int)index {
    return (sqlite3_column_int(cStatement, index) != 0);
}

/******************************************** EXERCICES ****************************************************/

+ (void) saveExercice:(FLAPIExercice*)e {
    [DB executeWF:@"INSERT INTO exercices (start_ts,stop_ts,frequency_target_hz, frequency_tolerance_hz, \
     duration_expiration_s, duration_exercice_s, duration_exercice_done_p , blow_count, blow_star_count , profile_name) \
        VALUES ('%f', '%f', '%f', '%f', '%f', '%f','%f','%i','%i','%@')",
        e.start_ts, e.stop_ts, e.frequency_target_hz, e.frequency_tolerance_hz, e.duration_expiration_s, e.duration_exercice_s, [e percent_done], e.blow_count, e.blow_star_count, [Profil current].name];
    
}

/*************************************************** BLOWS ***************************************************/

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
