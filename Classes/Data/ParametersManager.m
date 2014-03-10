//
//  ParametersManager.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 25.08.11.
//  Copyright 2011 fondation Defitech All rights reserved.
//

#import "ParametersManager.h"
#import "DB.h"
#import "FLAPIX.h"
#import "FlowerController.h"
#import "Profil.h"

@implementation ParametersManager

+(void) saveFrequency:(double)target tolerance:(double)tolerance {
    [[Profil current] setFrequency_target_hz:target];
    [[Profil current] setFrequency_tolerance_hz:tolerance];
    [[Profil current] save];
}

+(void) loadParameters:(FLAPIX*)flapix  {
    if (flapix == nil) {
        if (flapix == nil) {
            NSLog(@"***!!***loadParameters: Something went bad flapix is nil");
            return;
        }
    }
    
    Profil* profil = [Profil current];


    BOOL saveProfil = false;
    if ( ([profil frequenceMin] < [flapix frequenceMin]) || 
         ([profil frequenceMax] > [flapix frequenceMax] )) {
         NSLog(@"loadParameters: invalid frequency parameters target:%f tolerance:%tolerance reseting to defaults",profil.frequency_target_hz,profil.frequency_tolerance_hz );
         profil.frequency_target_hz = ([flapix frequenceMax] + [flapix frequenceMin]) / 2;
         profil.frequency_tolerance_hz = 2.0f;
        saveProfil = true;
    }
    [flapix SetTargetFrequency:profil.frequency_target_hz frequency_tolerance:profil.frequency_tolerance_hz];
    
    if (profil.duration_expiration_s < 0.5f || profil.duration_expiration_s > 12.0f) {
         NSLog(@"loadParameters: invalid expiration duration:%f parameter reseting to defaults",profil.duration_expiration_s );
        profil.duration_expiration_s = 1.0f;
        saveProfil = true;
    }
    [flapix SetTargetExpirationDuration:profil.duration_expiration_s];
    

    if (profil.duration_exercice_s < 5.0f || profil.duration_exercice_s > 1000.0f) {
        NSLog(@"loadParameters: invalid exercice duration:%f parameter reseting to defaults",profil.duration_exercice_s );
        profil.duration_exercice_s = 20.0f;
        saveProfil = true;
    }
    [flapix SetTargetExerciceDuration:profil.duration_exercice_s];
    if (saveProfil) {
        [profil save];
    }
    
    [flapix SetPlayBackVolume:[[DB getInfoValueForKey:@"playBackVolume"] floatValue]];
}


+(void) savePlayBackVolume:(float)volume {
    [DB setInfoValueForKey:@"playBackVolume" value:[NSString stringWithFormat:@"%f",volume]];
}

+(void) saveExpirationDuration:(float)duration {
    [[Profil current] setDuration_expiration_s:(double)duration];
    [[Profil current] save];
    [[FlowerController currentFlapix] SetTargetExpirationDuration:duration];
}

+(void) saveExerciceDuration:(float)duration {
    [[Profil current] setDuration_exercice_s:(double)duration];
    [[Profil current] save];
    [[FlowerController currentFlapix] SetTargetExerciceDuration:duration];
}

@end
