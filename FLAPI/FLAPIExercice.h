//
//  FLAPIExercice.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 05.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLAPIBlow.h"

@class FLAPIX;

@interface FLAPIExercice : NSObject {
    double start_ts;
    double stop_ts;
    double frequency_target_hz;
    double frequency_tolerance_hz;
    double duration_expiration_s;
    double duration_exercice_s;
    double duration_exercice_done_s;
    int blow_count;
    int blow_star_count;
}

@property (nonatomic) double start_ts, stop_ts, frequency_target_hz, frequency_tolerance_hz, 
                             duration_expiration_s, duration_exercice_s,duration_exercice_done_s;
@property (nonatomic) int blow_count, blow_star_count;

- (id)initWithFlapix:(FLAPIX*)flapix;
- (void)copyParams:(FLAPIX*)flapix;
- (void)stop:(FLAPIX*)flapix;
- (void)addBlow:(FLAPIBlow*)blow;


- (float)percent_done;

- (BOOL)inCourse;

@end
