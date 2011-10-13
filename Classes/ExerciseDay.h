//
//  ExerciseDay.h
//  FlowerForAll
//
//  Created by dev on 20/09/11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExerciseDay : NSObject{
    
    //The current day as an NSDate object
    NSDate* date;
    
    //The current day as a formatted String (ex: 12.10.2011)
    NSString* formattedDate;
    
    //A string representing successfull and unsuccessfull exercises of the day, in the right order.
    //"1" for a successfull ex, "0" for an unsuccessfull ex. Example: "100101"
    NSString* order;
    
    //The number of good exercises in the day
    NSInteger good;
    
    //The number of bad exercises in the day
    NSInteger bad;
    
}

//Properties
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) NSString* formattedDate;
@property (nonatomic, retain) NSString* order;
@property (nonatomic) NSInteger good;
@property (nonatomic) NSInteger bad;

//Init method
- (id)init:(double)start_ts;

@end
