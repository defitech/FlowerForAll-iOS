//
//  ParametersManager.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 25.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParametersManager.h"
#import "DB.h"
#import "FLAPIX.h"
#import "FlowerController.h"

@implementation ParametersManager

+(void) saveFrequency:(double)target tolerance:(double)tolerance {
    [DB setInfoValueForKey:@"frequencyTarget" value:[NSString stringWithFormat:@"%1.1f",target]];
    [DB setInfoValueForKey:@"frequencyTolerance" value:[NSString stringWithFormat:@"%1.1f",tolerance]];
}

+(void) loadParameters:(FLAPIX*)flapix  {
    double target=[[DB getInfoValueForKey:@"frequencyTarget"] doubleValue];
    double tolerance=[[DB getInfoValueForKey:@"frequencyTolerance"] doubleValue];
    if ( ((target - (tolerance / 2)) < [flapix frequenceMin]) || 
         ((target + (tolerance / 2)) > [flapix frequenceMax] )) {
         NSLog(@"loadParameters: invalid frequency parameters target:%f tolerance:%tolerance reseting to defaults",target,tolerance );
         target = ([flapix frequenceMax] + [flapix frequenceMin]) / 2;
         tolerance = ([flapix frequenceMax] - [flapix frequenceMin]) * 0.2;
       
    }
    [flapix SetTargetFrequency:target frequency_tolerance:tolerance];
    
    
    float duration = [[DB getInfoValueForKey:@"expirationDuration"] floatValue];
    if (duration < 0.5f || duration > 12.0f) {
         NSLog(@"loadParameters: invalid expiration duration:%f parameter reseting to defaults",duration );
        duration = 2.0f;
        
    }
    [flapix SetTargetExpirationDuration:duration];
    
    
    duration = [[DB getInfoValueForKey:@"exerciceDuration"] floatValue];
    if (duration < 5.0f || duration > 1000.0f) {
        NSLog(@"loadParameters: invalid exerice duration:%f parameter reseting to defaults",duration );
        duration = 50.0f;
        
    }
    [flapix SetTargetExerciceDuration:duration];
}

+(void) saveExpirationDuration:(float)duration {
    [DB setInfoValueForKey:@"expirationDuration" value:[NSString stringWithFormat:@"%1.1f",duration]];
    [[FlowerController currentFlapix] SetTargetExpirationDuration:duration];
}

+(void) saveExerciceDuration:(float)duration {
    [DB setInfoValueForKey:@"exerciceDuration" value:[NSString stringWithFormat:@"%1.1f",duration]];
    [[FlowerController currentFlapix] SetTargetExerciceDuration:duration];
}

@end
