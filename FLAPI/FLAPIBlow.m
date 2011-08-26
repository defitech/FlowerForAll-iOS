//
//  FLAPIBlow.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FLAPIBlow.h"

@implementation FLAPIBlow

@synthesize timestamp, duration, in_range_duration;

- (id)initWith:(double)atimestamp duration:(double)alength in_range_duration:(double)air_length
{
    self = [super init];
    if (self) {
        timestamp = atimestamp;
        duration = alength;
        in_range_duration = air_length;
    }
    
    return self;
}

@end
