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
}

@property (nonatomic) double timestamp;
@property (nonatomic) double duration;
@property (nonatomic) double in_range_duration;

- (id)initWith:(double)atimestamp duration:(double)alength in_range_duration:(double)air_length;

@end
