//
//  ParametersManager.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 25.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLAPIX.h"

@interface ParametersManager : NSObject

+(void) saveFrequency:(double)target tolerance:(double)tolerance;
+(void) saveDuration:(float)duration;

+(void) loadParameters:(FLAPIX*)flapix;

@end
