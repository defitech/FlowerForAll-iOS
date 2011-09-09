//
//  FLAPIExercice.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 05.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FLAPIExercice.h"
#import "FLAPIX.h"

@implementation FLAPIExercice

@synthesize start_ts, stop_ts, frequency_target_hz, frequency_tolerance_hz, duration_expiration_s, duration_exercice_s, duration_exercice_done_s, blow_count, blow_star_count;

- (id)initWithFlapix:(FLAPIX*)flapix
{
    self = [super init];
    if (self) {
         [self copyParams:flapix];
        start_ts = CFAbsoluteTimeGetCurrent();
        stop_ts = 0;
        blow_count = 0;
        duration_exercice_done_s = 0;
        blow_star_count = 0;
    }
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:FLAPIX_EVENT_EXERCICE_START  object:self];
    return self;
}

-(void)stop:(FLAPIX*)flapix {
    [self copyParams:flapix];
    stop_ts = CFAbsoluteTimeGetCurrent();
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:FLAPIX_EVENT_EXERCICE_STOP  object:self];
}

-(void)copyParams:(FLAPIX*)flapix {
    frequency_target_hz = [flapix frequenceTarget];
    frequency_tolerance_hz = [flapix frequenceTolerance];
    duration_expiration_s = [flapix expirationDurationTarget];
    duration_exercice_s = [flapix exerciceDurationTarget];
}

-(void)addBlow:(FLAPIBlow*)blow {
    blow_count++;
    if ([blow goal]) blow_star_count++;
    duration_exercice_done_s += [blow in_range_duration];
}

-(float)percent_done {
    double temp = duration_exercice_done_s / duration_exercice_s;
    return (temp > 1) ? 1 : temp;
}

-(BOOL) inCourse {
    return stop_ts == 0;
}

@end
