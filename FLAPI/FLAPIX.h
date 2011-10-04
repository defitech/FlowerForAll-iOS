//
//  FLAPIX.h
//  FLAPI
//
//  Created by Pierre-Mikael Legris (Perki) on 20.05.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//  
//  Simple Interface to 

#import <Foundation/Foundation.h>
#import "FLAPIExercice.h"


#ifndef __HEADER_H__
#define __HEADER_H__

extern NSString * const FLAPIX_EVENT_START;
extern NSString * const FLAPIX_EVENT_STOP;
extern NSString * const FLAPIX_EVENT_BLOW_START;
extern NSString * const FLAPIX_EVENT_BLOW_STOP;
extern NSString * const FLAPIX_EVENT_EXERCICE_START;
extern NSString * const FLAPIX_EVENT_EXERCICE_STOP;
extern NSString * const FLAPIX_EVENT_LEVEL;
extern NSString * const FLAPIX_EVENT_FREQUENCY;


#endif

@interface FLAPIX : NSObject {    
    BOOL running;
    double frequency;
    float lastlevel;
    BOOL blowing;
    FLAPIExercice* current_exercice;
    FLAPIBlow* lastBlow;
    
    
}


@property (nonatomic) BOOL running;
@property (nonatomic) double frequency;

@property (nonatomic) float lastlevel;
@property (nonatomic) BOOL blowing;

// Exercice !!
- (BOOL) Start;
- (BOOL) Stop;

- (void) SetTargetFrequency:(double)target_frequency frequency_tolerance:(double)tolerance;
- (void) SetTargetExpirationDuration:(float)durations_s;
- (void) SetTargetExerciceDuration:(float)durations_s;

// Custom  PlayBack Stop
- (void) SetPlayBackVolume:(float) volume;
- (float) playBackVolume;

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


// Get last blow.. 
- (FLAPIBlow*) lastBlow;


// EXERCICES
- (void)exerciceStop;
- (FLAPIExercice*)exerciceStart;

/** Current Exercice return nil if not in course **/
- (FLAPIExercice*)currentExercice;

/** test if exerice is in course (! nil)**/
- (BOOL)exerciceInCourse;


@end
