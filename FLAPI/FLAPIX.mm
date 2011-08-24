//
//  FLAPIX.m
//  FLAPI
//
//  Created by Pierre-Mikael Legris on 20.05.11.
//  Copyright 2011 fondation Defitech All rights reserved.
//

#import "FLAPIX.h"

#include "flapi.h"
#include "subsys_ios.h"
#import "DB.h"

@implementation FLAPIX

@synthesize running, frequency, blowing, lastlevel;

/**
 * init 
 */ 
- (id)init
{
    NSLog(@"FLAPIX init");
    self = [super init];
    if (self)
    {
        self.running = NO; // set the running flag to STOPPED
        FLAPI_SUBSYS_IOS_init_and_registerFLAPIX(self); // register this object for events callbacks
        
        // -- write your own code here to do some more init stuff
        
    }
    return self;
}


- (void) SetTargetFrequency:(int)target_frequency frequency_tolerance:(int)tolerance {
    gParams.target_frequency	= target_frequency;
	gParams.frequency_tolerance	= tolerance;
}

- (int) frequenceTolerance { return gParams.frequency_tolerance; }

- (int) frequenceTarget { return gParams.target_frequency; }

- (BOOL) Start {
    if (self.running) return NO;
    // debug -- read from file
    const char* toread = [[[[NSBundle mainBundle] resourcePath] 
                                stringByAppendingPathComponent: @"FLAPIrecorded.raw"] UTF8String];
    FLAPI_SUBSYS_IOS_file_dev(toread,true);
    // end of debug
    
    if (FLAPI_SUCCESS != FLAPI_Start()) return NO; // This does start the sound recording and processing
    self.running = YES;
    return YES;
}

- (BOOL) Stop {
    NSLog(@"Stop");
    if (! self.running) return NO;
    if (FLAPI_SUCCESS != FLAPI_Stop()) return NO; // This does stop the sound recording and processing
    self.running = NO;
    return YES;
}

// --------------- Event CallBacks

- (void) EventLevel:(float) level {
   // NSLog(@"New Level %f",level);
    lastlevel = level / gParams.mic_calibration ;
}

- (void) EventFrequency:(int) freq {
//    NSLog(@"New Frequency %i",freq);
    frequency = freq;
}

- (void) EventBlowStart:(double)timestamp {
//    NSLog(@"Start Blow %f ",timestamp);
    blowing = true;
}

- (void) EventBlowEnd:(double)timestamp duration:(double)length in_range_duration:(double)ir_length {
    // NSLog(@"End Blow %f %f %f",timestamp,length,ir_length);
    // Seems there is no pool for this thread.. (I must read more about this)
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    
    [DB saveBlow:timestamp duration:length in_range_duration:ir_length];
    
    
    [pool drain]; 
    blowing = false;
}

// --------------- Dealloc 

- (void)dealloc {
    [self Stop]; // just in case it's running
    FLAPI_Exit();
    [super dealloc];
}

@end
