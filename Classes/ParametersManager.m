//
//  ParametersManager.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 25.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ParametersManager.h"
#import "DB.h"

@implementation ParametersManager

+(void) saveFrequency:(double)target tolerance:(double)tolerance {
    [DB setInfoValueForKey:@"frequencyTarget" value:[NSString stringWithFormat:@"%1.1f",target]];
    [DB setInfoValueForKey:@"frequencyTolerance" value:[NSString stringWithFormat:@"%1.1f",tolerance]];
}

+(void) loadFrequency:(FLAPIX*)flapix  {
    double target=[[DB getInfoValueForKey:@"frequencyTarget"] doubleValue];
    double tolerance=[[DB getInfoValueForKey:@"frequencyTolerance"] doubleValue];
    if (target > 0 && tolerance > 0 ) {
          
    }
}

@end
