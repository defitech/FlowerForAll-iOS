//
//  FLAPIX.h
//  FLAPI
//
//  Created by Pierre-Mikael Legris on 20.05.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//  
//  Simple Interface to 

#import <Foundation/Foundation.h>


@interface FLAPIX : NSObject {    
    BOOL running;
    double frequency;
    float lastlevel;
    BOOL blowing;
}


@property (nonatomic) BOOL running;
@property (nonatomic) double frequency;

@property (nonatomic) float lastlevel;
@property (nonatomic) BOOL blowing;

- (BOOL) Start;
- (BOOL) Stop;

- (void) SetTargetFrequency:(double)target_frequency frequency_tolerance:(double)tolerance;
- (void) SetTargetBlowingDuration:(float)durations_s;

// return durationTarget(s)
- (double) durationTarget;

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

@end
