//
//  Profil.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 20.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "Profil.h"
#import "DB.h"
#import "ParametersManager.h"


@implementation Profil


@synthesize pid, name, frequency_target_hz, frequency_tolerance_hz, duration_expiration_s, duration_exercice_s;


-(id)initWidth:(int)_pid name:(NSString*)_name
frequency_target_hz:(double)_frequency_target_hz 
frequency_tolerance_hz:(double)_frequency_tolerance_hz
duration_expiration_s:(double)_duration_expiration_s
duration_exercice_s:(double)_duration_exercice_s {
    self = [super init];
    if (self != nil) {
        self.pid = _pid;
        self.name = _name;
        self.frequency_target_hz = _frequency_target_hz;
        self.frequency_tolerance_hz = _frequency_tolerance_hz;
        self.duration_expiration_s = _duration_expiration_s;
        self.duration_exercice_s = _duration_exercice_s;
    }
    return self;
}

-(void)save {
    [DB executeWF:@"REPLACE INTO profils (pid, name, frequency_target_hz, frequency_tolerance_hz, duration_expiration_s, duration_exercice_s) \
        VALUES (%i, '%@', %f, %f, %f, %f)",self.pid, self.name, self.frequency_target_hz, self.frequency_tolerance_hz, self.duration_expiration_s, self.duration_exercice_s];
}

static Profil* currentProfil;
/** set the current profil **/
+(void)setCurrentS:(Profil*)profil {
    if (currentProfil != profil) {
        currentProfil = profil;
        [DB setInfoValueForKey:@"currentProfile" value:[NSString stringWithFormat:@"%i",currentProfil.pid]];
    }
}

-(void)setCurrent {
    [Profil setCurrentS:self];
    [ParametersManager loadParameters:nil];
    NSLog(@"Profil set to: %@",self.name);
}

-(BOOL)isCurrent {
    return (self.pid == [Profil current].pid);
}

/** convenience tool to get min from target and tolerance **/
-(double)frequenceMin {
    return self.frequency_target_hz - self.frequency_tolerance_hz;
}
/** convenience tool to get max from target and tolerance **/
-(double)frequenceMax {
    return self.frequency_target_hz + self.frequency_tolerance_hz;
}


/** get the current profil **/
+(Profil*)current {
   
    if (currentProfil == nil) {
        // get the currentProfileId
        int currentProfileID = [[DB getInfoValueForKey:@"currentProfile"] intValue];
        if (currentProfileID < 0) currentProfileID = 0; 
        currentProfil = [Profil getFromId:currentProfileID];
        [currentProfil retain];
    }    
    return currentProfil;
}

/** get for ID **/
+(Profil*)getFromId:(int)profil_id {
    sqlite3_stmt *cs = 
    [DB genCStatementWF:@"SELECT pid, name, frequency_target_hz, frequency_tolerance_hz, duration_expiration_s, duration_exercice_s  FROM profils WHERE pid = %i",profil_id];
    Profil* profile = nil;
    if(sqlite3_step(cs) == SQLITE_ROW) {
    profile = [[[Profil alloc] initWidth:[DB colI:cs index:0] 
                                              name:[DB colS:cs index:1] 
                               frequency_target_hz:[DB colD:cs index:2] 
                            frequency_tolerance_hz:[DB colD:cs index:3] 
                             duration_expiration_s:[DB colD:cs index:4] 
                               duration_exercice_s:[DB colD:cs index:5]] autorelease] ;
    }
    sqlite3_finalize(cs);
    return profile;
}

/** get All profiles **/
+(NSArray*)getAll {
    sqlite3_stmt *cs = 
    [DB genCStatementWF:@"SELECT pid, name, frequency_target_hz, frequency_tolerance_hz, duration_expiration_s, duration_exercice_s  FROM profils"];
    NSMutableArray* profils = [[NSMutableArray alloc] init ];
    while(sqlite3_step(cs) == SQLITE_ROW) {
        [profils addObject:[[Profil alloc] initWidth:[DB colI:cs index:0] 
                                        name:[DB colS:cs index:1] 
                         frequency_target_hz:[DB colD:cs index:2] 
                      frequency_tolerance_hz:[DB colD:cs index:3] 
                       duration_expiration_s:[DB colD:cs index:4] 
                         duration_exercice_s:[DB colD:cs index:5]]] ;
    }
    sqlite3_finalize(cs);
    return profils;

}

@end
