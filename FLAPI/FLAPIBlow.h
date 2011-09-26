//
//  FLAPIBlow.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLAPIBlow : NSObject {
    double timestamp;
    double duration;
    double in_range_duration; 
    double medianFrequency; // statistical
    double medianTolerance; // statistical
    BOOL goal;
}

@property (readwrite) double timestamp, duration, in_range_duration, medianFrequency, medianTolerance;
@property (nonatomic) BOOL goal;

- (id)initWith:(double)atimestamp duration:(double)alength in_range_duration:(double)air_length goal:(BOOL)good medianFrequency:(BOOL)median_frequency;

@end
