//
//  FLAPIBlow.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 26.08.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "FLAPIBlow.h"

@implementation FLAPIBlow

@synthesize timestamp, duration, in_range_duration, goal, medianFrequency,medianTolerance;

- (id)initWith:(double)atimestamp duration:(double)alength in_range_duration:(double)air_length goal:(BOOL)good  medianFrequency:(BOOL)median_frequency
{
    self = [super init];
    if (self) {
        timestamp = atimestamp;
        duration = alength;
        in_range_duration = air_length;
        goal = good;
        medianFrequency = median_frequency;
    }
    
    return self;
}

@end
