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

NSString * const FLAPIX_EVENT_MICROPHONE_STATE = @"FlapixEventMicrophoneState";

@implementation FLAPIX

@synthesize running, frequency, blowing, lastlevel;

- (id)init
{
    NSLog(@"FLAPIX init");
    self = [super init];
    if (self)
    {
        self.running = NO; // set the running flag to STOPPED
        FLAPI_SUBSYS_IOS_init_and_registerFLAPIX(self); // register this object for events callbacks
       
        // Init Values
        gParams.frequency_max				= 30;
        gParams.frequency_min				= 4;
        FLAPI_SetTargetBlowingDuration(1500);
        FLAPI_SetTargetFrequency(14.0f, 4.0f);
        FLAPI_SetThreshold(10.0f);
        UpdateAudioInfo();
        
        
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
    // Start App If Mic is In
    checkMicrophonePluggedIn();
}


- (void) SetTargetFrequency:(double)target_frequency frequency_tolerance:(double)tolerance {
    if ((target_frequency - tolerance) < gParams.frequency_min || 
        (target_frequency + tolerance) > gParams.frequency_max) {
        FLAPI_SetTargetFrequency((gParams.frequency_max - gParams.frequency_min) * 0.9, (gParams.frequency_max - gParams.frequency_min) * 0.1);
        return ;
    }
    FLAPI_SetTargetFrequency(target_frequency,tolerance);
    NSLog(@"SetTargetFrequency %1.1f   tol: %1.1f",target_frequency,tolerance);
}


- (void) SetTargetExpirationDuration:(float)durations_s {
    gParams.target_duration = (int) (durations_s * 1000);
}


- (void) SetPlayBackVolume:(float) volume {
    FLAPI_SUBSYS_IOS_SET_PlayBackVolume(volume);
}

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
    return FLAPI_GetTargetBlowingDuration() / 1000.0f;
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


- (double) frequenceTolerance { return FLAPI_GetFrequencyTolerance(); }

- (double) frequenceTarget { return FLAPI_GetTargetFrequency();  }


BOOL demo_mode = NO;
- (void) SetDemo:(BOOL)on {
    if (! self.running && on) [self Start];
    
    if (demo_mode == on) return;
    
    // debug -- read from file
    const char* toread = nil;
    
    if (on) { toread = [[[[NSBundle mainBundle] resourcePath] 
                         stringByAppendingPathComponent: @"Mix.raw"] UTF8String]; }

    FLAPI_SUBSYS_IOS_file_dev(toread,true);
    demo_mode = on;
    
    // Check if Microphone is Plugged.. if not Stop
    if (! demo_mode && ! checkMicrophonePluggedIn()) {
        [self Stop];
    }
}

- (BOOL) IsDemo {
    return demo_mode;
}

- (BOOL) Start {
    if (self.running) return NO;
    if (FLAPI_SUCCESS != FLAPI_Start()) return NO; // This does start the sound recording and processing
    self.running = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAPIX_EVENT_START  object:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; // Prevent app sleeping
    return YES;
}

- (BOOL) Stop {
    NSLog(@"Stop");
    [self SetDemo:NO]; // we must quit Demo before we stop;
    [self exerciceStop]; // maybe an exerice is going on
    
    if (! self.running) return NO;
    if (FLAPI_SUCCESS != FLAPI_Stop()) return NO; // This does stop the sound recording and processing
    self.running = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAPIX_EVENT_STOP  object:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO]; // App can sleep if no action from the user
    return YES;
}

// --------------- Event CallBacks

- (void) EventLevel:(float) level {
   // NSLog(@"New Level %f",level);
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     lastlevel = level / FLAPI_GetLevelMax() ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FLAPIX_EVENT_LEVEL  object:self];
    [pool drain]; 
}

/** contain the frequencies list of cuurent blow **/
NSMutableArray *blowFrequencies; 
- (void) EventFrequency:(double) freq {
    //    NSLog(@"New Frequency %i",freq);
    frequency = freq;
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (current_exercice != nil) {
        current_exercice.current_blow_in_range_duration_s = FLAPI_SUBSYS_IOS_get_current_blow_in_range_duration();
    } 
    //NSLog(@"FLAPIX %1.2f %1.2f %1.2f", [current_exercice percent_done], [current_exercice duration_exercice_done_s],FLAPI_SUBSYS_IOS_get_current_blow_in_range_duration() );
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
    
    
    BOOL goal = (ir_length >= [self expirationDurationTarget]);
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
    lastBlow = blow;
    
    
    // we do always save blows..
    [DB saveBlow:blow];
    
    // WE MUST SEND END BLOW EVENT BEFORE _ END EXERCICE EVENT
    // BUT! WE NEED TO ADD BLOWS TO EXERCICES BEFORE END BLOW EVENT
    //      FOR APPS READING duration_exercice_done_s ON EXERCICE
    if ([self exerciceInCourse]) {
 
        // exercice management
        [[self currentExercice] addBlow:blow];
        [[NSNotificationCenter defaultCenter] 
            postNotificationName:FLAPIX_EVENT_BLOW_STOP object:blow];
        if ([[self currentExercice] percent_done] >= 1) {
            [self exerciceStop];
        }
    } else {
        [[NSNotificationCenter defaultCenter] 
         postNotificationName:FLAPIX_EVENT_BLOW_STOP object:blow];
    }
    
    
    [blow autorelease];
    
    [pool drain]; 
}

- (void) EventMicrophonePlugged:(BOOL)on {
    // Simulate ON when in demo mode
    if ([self IsDemo]) on = YES;
    
    // here we start or stop FLAPI if needed
    if (running == on ) return; // nothing to do if running and on, or stopped and off;
    if (on == YES) { 
        [self Start]; 
    } else {
        [self Stop];
    }
    
    
    NSLog(@"EventMicrophonePlugged %i",on);
}

# pragma mark lastBlow
-(FLAPIBlow*) lastBlow {
    if (lastBlow == nil) {
        lastBlow = [[FLAPIBlow alloc] initWith:0 
                                      duration:[self expirationDurationTarget] 
                             in_range_duration:[self expirationDurationTarget] 
                                          goal:YES 
                               medianFrequency:[self frequenceTarget]];
        lastBlow.medianTolerance = [self frequenceTolerance];
    }
    return lastBlow;
}


# pragma mark EXERCICE LOGIC
// --------------- Exercice Logic
- (void)exerciceStop {
    if (current_exercice == nil) return;
    if ([current_exercice inCourse])  [current_exercice stop:self];
    FLAPIExercice *temp = current_exercice;
    
    
    [DB saveExercice:current_exercice];
    current_exercice = nil;
    
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:FLAPIX_EVENT_EXERCICE_STOP  object:temp];
     [temp release];
}

/** start Exercice **/
- (FLAPIExercice*)exerciceStart {
    [self exerciceStop];
    // not possible if not running
    if (! self.running) {
        NSLog(@"!!! FLAPIX exerciceStart called while not running");
        return nil;
    }
    
    if ((current_exercice == nil) || (! [current_exercice inCourse])) {
        current_exercice = [[FLAPIExercice alloc] initWithFlapix:self];
    }
    // start FLAPIX if needed
    
    
    [[NSNotificationCenter defaultCenter] 
     postNotificationName:FLAPIX_EVENT_EXERCICE_START  object:current_exercice];
    
    return current_exercice;
}

- (FLAPIExercice*)currentExercice {
    if (current_exercice == nil) {
        NSLog(@"currentExerice called and is NULL!!");
    }
    return current_exercice;
}

- (BOOL)exerciceInCourse {
    return (current_exercice != nil);
}

# pragma mark MEMORY

// --------------- Dealloc 

- (void)dealloc {
    [self Stop]; // just in case it's running
    FLAPI_Exit();
    [super dealloc];
}

@end
