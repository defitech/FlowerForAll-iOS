//
//  FLAPIX.h
//  FLAPI
//
//  Created by Pierre-Mikael Legris on 20.05.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//  
//  Simple Interface to 

#import <Foundation/Foundation.h>
#import "FLAPIExercice.h"


#ifndef __HEADER_H__
#define __HEADER_H__

extern NSString * const FLAPIX_EVENT_START;

#endif

@interface FLAPIX : NSObject {    
    BOOL running;
    double frequency;
    float lastlevel;
    BOOL blowing;
    FLAPIExercice* current_exercice;
    
    
    
}


@property (nonatomic) BOOL running;
@property (nonatomic) double frequency;

@property (nonatomic) float lastlevel;
@property (nonatomic) BOOL blowing;

- (BOOL) Start;
- (BOOL) Stop;

- (void) SetTargetFrequency:(double)target_frequency frequency_tolerance:(double)tolerance;
- (void) SetTargetExpirationDuration:(float)durations_s;
- (void) SetTargetExerciceDuration:(float)durations_s;

- (void) SetDemo:(BOOL)on;
- (BOOL) IsDemo;

// return durationTarget(s)
- (double) expirationDurationTarget;
// return durationTarget(s)
- (double) exerciceDurationTarget;

// return maxFrequence
- (double) frequenceMax;
// return minFrequence
- (double) frequenceMin;



// return actual frequence Target
- (double) frequenceTarget;

// return actual frequency Tolerance value
- (double) frequenceTolerance;

// EVENTS
- (void) EventLevel:(float) level;
- (void) EventFrequency:(double) frequency;

- (void) EventBlowStart:(double)timestamp;
- (void) EventBlowEnd:(double)timestamp duration:(double)length in_range_duration:(double)ir_length;



// EXERCICES
- (void)exerciceStop;
- (FLAPIExercice*)exerciceStart;

/** Current Exercice return nil if not in course **/
- (FLAPIExercice*)currentExercice;



@end
