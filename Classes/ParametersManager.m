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

+(void) saveFrequency:(int)target tolerance:(int)tolerance {
    [DB setInfoValueForKey:@"frequencyTarget" value:[NSString stringWithFormat:@"%i",target]];
    [DB setInfoValueForKey:@"frequencyTolerance" value:[NSString stringWithFormat:@"%i",tolerance]];
}

+(void) loadFrequency:(FLAPIX*)flapix  {
    
    float target=[[DB getInfoValueForKey:@"frequencyTarget"] intValue];
    float tolerance=[[DB getInfoValueForKey:@"frequencyTolerance"] intValue];
    if (target > 0 && tolerance > 0 ) {
          
    }
}

@end
