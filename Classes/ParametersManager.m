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
         NSLog(@"loadParameters: invalid duration:%f parameter reseting to defaults",duration );
        duration = 2.0f;
        
    }
    [flapix SetTargetBlowingDuration:duration];
}

+(void) saveDuration:(float)duration {
    [DB setInfoValueForKey:@"expirationDuration" value:[NSString stringWithFormat:@"%1.1f",duration]];
}

@end
