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
    int frequency;
    BOOL blowing;
}


@property (nonatomic) BOOL running;
@property (nonatomic) int frequency;
@property (nonatomic) BOOL blowing;

- (BOOL) Start;
- (BOOL) Stop;

- (void) SetTargetFrequency:(int)target_frequency frequency_tolerance:(int)tolerance;

// EVENTS
- (void) EventLevel:(float) level;
- (void) EventFrequency:(int) frequency;

- (void) EventBlowStart:(double)timestamp;
- (void) EventBlowEnd:(double)timestamp duration:(double)length in_range_duration:(double)ir_length;

@end
