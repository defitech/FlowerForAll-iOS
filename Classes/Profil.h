//
//  Profil.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 20.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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

/** save to DB **/
-(void)save ;
@end
