//
//  Profil.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 20.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profil : NSObject {
    int pid;
    NSString* name;
    double frequency_target_hz, frequency_tolerance_hz, duration_expiration_s, duration_exercice_s;
}

@property int pid;
@property (retain) NSString* name;
@property (nonatomic ) double frequency_target_hz, frequency_tolerance_hz, duration_expiration_s, duration_exercice_s;

-(id)initWidth:(int)_pid name:(NSString*)_name
    frequency_target_hz:(double)_frequency_target_hz 
    frequency_tolerance_hz:(double)_frequency_tolerance_hz
    duration_expiration_s:(double)_duration_expiration_s
    duration_exercice_s:(double)_duration_exercice_s;




/** get the current profil **/
+(Profil*)current;

/** get the current profil **/
+(Profil*)getFromId:(int)profil_id;

/** get All profiles **/
+(NSArray*)getAll;

/** save to DB **/
-(void)save ;

/** set the current profile **/
-(void)setCurrent;

/** return true is this profile is the current profile **/
-(BOOL)isCurrent;

/** convenience tool to get min from target and tolerance **/
-(double)frequenceMin;
/** convenience tool to get max from target and tolerance **/
-(double)frequenceMax;



@end
