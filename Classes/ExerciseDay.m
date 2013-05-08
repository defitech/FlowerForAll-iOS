//
//  ExerciseDay.m
//  FlowerForAll
//
//  Created by dev on 20/09/11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "ExerciseDay.h"

@implementation ExerciseDay

@synthesize date, formattedDate, order, good, bad;

- (id)init:(double)start_ts
{
    self = [super init];
    if (self) {
        //Init the date field
        NSDate *dateForExercise = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:start_ts];
        self.date = dateForExercise;
        [dateForExercise release];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
        
         //Init the formattedDate field
        self.formattedDate = [dateFormatter stringFromDate:self.date];
        
        [dateFormatter release];
        
        //Init the order field
        self.order = @"";
    }
    
    return self;
}

- (void)dealloc {
    [date release];
    [formattedDate release];
    [order release];
    [super dealloc];
}

@end
