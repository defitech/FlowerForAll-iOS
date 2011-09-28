//
//  FLAPIX.m
//  FLAPI
//
//  Created by Pierre-Mikael Legris (Perki) on 20.05.11.
//  Copyright 2011 fondation Defitech All rights reserved.
//

#import "FLAPIX.h"

#include "flapi.h"
#include "subsys_ios.h"
#import "DB.h"
#import "FLAPIBlow.h"



NSString * const FLAPIX_EVENT_START = @"FlapixEventStart";
NSString * const FLAPIX_EVENT_STOP = @"FlapixEventStop";
NSString * const FLAPIX_EVENT_BLOW_START = @"FlapixEventBlowStart";
NSString * const FLAPIX_EVENT_BLOW_STOP = @"FlapixEventBlowStop";
NSString * const FLAPIX_EVENT_EXERCICE_START = @"FlapixEventExerciceStart";
NSString * const FLAPIX_EVENT_EXERCICE_STOP = @"FlapixEventExerciceStop";
NSString * const FLAPIX_EVENT_LEVEL = @"FlapixEventLevel";
NSString * const FLAPIX_EVENT_FREQUENCY = @"FlapixEventFrequency";


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
       
        // Init Values
        gParams.frequency_max				= 26;
        gParams.frequency_min				= 4;
        gParams.target_frequency			= 18.0f;
        gParams.frequency_tolerance			= 4.0f;
        gParams.target_duration				= 1500;
        
        UpdateAudioInfo();
        
        printf("gParams frequency_max:%i frequency_min:%i\n",gParams.frequency_max,gParams.frequency_min);
        // -- write your own code here to do some more init stuff
        
        current_exercice = nil;
        
        
        // register to Active Events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification 
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification 
                                                   object:nil];
        
    }
    return self;
}

#pragma mark application activity

- (void)applicationWillResignActive:(NSNotification *)notification {
    NSLog(@"FLAPIX resign active");
    FLAPI_SUBSYS_IOS_Pause();
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    NSLog(@"FLAPIX become active");
    FLAPI_SUBSYS_IOS_UnPause();
}


- (void) SetTargetFrequency:(double)target_frequency frequency_tolerance:(double)tolerance {
    gParams.target_frequency	= target_frequency;
	gParams.frequency_tolerance	= tolerance;
}


- (void) SetTargetExpirationDuration:(float)durations_s {
    gParams.target_duration = (int) (durations_s * 1000);
}


- (void) SetPlayBackVolume:(float) volume {
    FLAPI_SUBSYS_IOS_SET_PlayBackVolume(volume);
};

- (float) playBackVolume {
    return FLAPI_SUBSYS_IOS_GET_PlayBackVolume();
}

// duration of an exerice
double exerice_duration_s = -1.0f;

- (void) SetTargetExerciceDuration:(float)durations_s {
    exerice_duration_s = (double) durations_s;
}

// return durationTarget(s)
- (double) expirationDurationTarget {
    return (double)gParams.target_duration / 1000.0f;
}

// return durationTarget(s)
- (double) exerciceDurationTarget {
    if (exerice_duration_s < -1.0f) exerice_duration_s = 10.0f;
    return (double) exerice_duration_s;
}

// return maxFrequence
- (double) frequenceMax {
    return (double) gParams.frequency_max;
}
// return minFrequence
- (double) frequenceMin {
    return (double) gParams.frequency_min;
}


- (double) frequenceTolerance { return gParams.frequency_tolerance; }

- (double) frequenceTarget { return gParams.target_frequency; }


BOOL demo_mode = NO;
- (void) SetDemo:(BOOL)on {
    if (! self.running) [self Start];
    if (demo_mode == on) return;
    
    // debug -- read from file
    const char* toread = nil;
    
    if (on) { toread = [[[[NSBundle mainBundle] resourcePath] 
                         stringByAppendingPathComponent: @"FLAPIrecorded.raw"] UTF8String]; }

    FLAPI_SUBSYS_IOS_file_dev(toread,true);
    demo_mode = on;
}

- (BOOL) IsDemo {
    return demo_mode;
}

- (BOOL) Start {
    if (self.running) return NO;
    [self exerciceStart]; // will start a new exercice
    if (FLAPI_SUCCESS != FLAPI_Start()) return NO; // This does start the sound recording and processing
    self.running = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAPIX_EVENT_START  object:self];
    return YES;
}

- (BOOL) Stop {
    NSLog(@"Stop");
    [self SetDemo:NO]; // we must quit Demo before we stop;
    [self exerciceStop];
    if (! self.running) return NO;
    if (FLAPI_SUCCESS != FLAPI_Stop()) return NO; // This does stop the sound recording and processing
    self.running = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAPIX_EVENT_STOP  object:self];
    return YES;
}

// --------------- Event CallBacks

- (void) EventLevel:(float) level {
   // NSLog(@"New Level %f",level);
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     lastlevel = level / gParams.mic_calibration ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAPIX_EVENT_LEVEL  object:self];
    [pool drain]; 
}

/** contain the frequencies list of cuurent blow **/
NSMutableArray *blowFrequencies; 
- (void) EventFrequency:(double) freq {
//    NSLog(@"New Frequency %i",freq);
    frequency = freq;
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
     if (blowFrequencies != nil) { [blowFrequencies addObject:[NSNumber numberWithDouble:freq]] ; }
     [[NSNotificationCenter defaultCenter] postNotificationName:FLAPIX_EVENT_FREQUENCY  object:self];
    
    [pool drain]; 
}


- (void) EventBlowStart:(double)timestamp {
  
    
//    NSLog(@"Start Blow %f ",timestamp);
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (blowFrequencies != nil) { [blowFrequencies release]; blowFrequencies = nil; }
    blowFrequencies = [[NSMutableArray alloc] init];
    
    blowing = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAPIX_EVENT_BLOW_START  object:self];
    [pool drain]; 
}

- (void) EventBlowEnd:(double)timestamp duration:(double)length in_range_duration:(double)ir_length {
    // Seems there is no pool for this thread.. (I must read more about this)
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    
    BOOL goal = ir_length >= [self expirationDurationTarget];
    blowing = false;
    
    //calculate MedianFrequency
    double medianFrequency = 0;
    double medianTolerance = 0;
    if (blowFrequencies != nil && [blowFrequencies count] > 0) { 
        NSArray *sorted = [blowFrequencies sortedArrayUsingSelector:@selector(compare:)];
        medianFrequency = [(NSNumber*)[sorted objectAtIndex:(int)([sorted count] / 2)] doubleValue];
        
        // remove all the values that have a differnce of more that 20%
        double max = 0.0f;
        double min = 1000.0f;
        double v = 0.0f;
        if (medianFrequency != 0)
        for (id object in sorted) {
            v = [(NSNumber*)object doubleValue];
            if (v > max) max = v;
            if (v < min) min = v;
        }
        medianTolerance = (max-min)*0.8/2;
    }
    // send messages
    FLAPIBlow* blow = [[FLAPIBlow alloc] initWith:timestamp duration:length in_range_duration:ir_length goal:goal medianFrequency:medianFrequency];
    blow.medianTolerance = medianTolerance;
    
    [DB saveBlow:blow];
    
    
    // exercice management
    [[self currentExercice] addBlow:blow];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAPIX_EVENT_BLOW_STOP object:blow];
    

    if ([[self currentExercice] percent_done] >= 1) {
        [self Stop];
    }
    [blow autorelease];
    
    [pool drain]; 
}


# pragma mark EXERCICE LOGIC
// --------------- Exercice Logic
- (void)exerciceStop {
    if (current_exercice == nil) return;
    if ([current_exercice inCourse])  [current_exercice stop:self];
    [DB saveExercice:current_exercice];
    [current_exercice release];
    current_exercice = nil;
}

/** start Exercice **/
- (FLAPIExercice*)exerciceStart {
    [self exerciceStop];
    if ((current_exercice == nil) || (! [current_exercice inCourse])) {
        current_exercice = [[FLAPIExercice alloc] initWithFlapix:self];
    }
    return current_exercice;
}

- (FLAPIExercice*)currentExercice {
    if (current_exercice == nil) {
        NSLog(@"currentExerice called and is NULL!!");
    }
    return current_exercice;
}

# pragma mark MEMORY

// --------------- Dealloc 

- (void)dealloc {
    [self Stop]; // just in case it's running
    FLAPI_Exit();
    [super dealloc];
}

@end
