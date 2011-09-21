//
//  ExerciseDay.h
//  FlowerForAll
//
//  Created by dev on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExerciseDay : NSObject{
    
    NSDate* date;
    NSString* formattedDate;
    NSInteger good;
    NSInteger bad;
    
}

@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) NSString* formattedDate;
@property (nonatomic) NSInteger good;
@property (nonatomic) NSInteger bad;

- (id)init:(double)start_ts;

@end
