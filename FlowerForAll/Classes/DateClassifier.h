//
//  DateClassifier.h
//  FlutterApp2
//
//  Created by Dev on 24.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This utility class defines some utility time related methods, notably to decide if a date belongs to the current month
//  to the past months in the current year, or to the past years.


#import <Foundation/Foundation.h>

#import "DateClassificationResult.h"


@interface DateClassifier : NSObject {

}


//Returns the current year in yyyy format (example: 2011)
+(NSInteger) getCurrentYear;

//Returns the current month in MM format (example: 7 = July)
+(NSInteger) getCurrentMonth;

//Performs the initial classification for a given date
//Initial classification means that the method checks whether a date belongs to the current month and year,
//to the past months within the current year (in this case it will be stored in the array pastMonths), or
//to the past years (in this case it will be stores in the array pastYears).
//This method then calls 2 other methods, classifyMonth and classifyYear, which behaves recursively.
//The overall behavior looks like a decision tree (see separate documentation).
+(void) initialClassification:(NSInteger)date;

//Recursive method which decides to which year a date belongs to (assuming it does not belong to the
//current year, but to a past year)
+(void) classifyYear:(NSDate *)date:(NSInteger)year;

//Recursive method which decides to which month a date belongs to (assuming it does not belong to the
//current month, but to a past month of the current year)
+(void) classifyMonth:(NSDate *)date:(NSInteger)month;

//Returns the month (as an integer) corresponding to the given date
+(NSInteger) getMonthGivenAdate:(NSInteger)dateTime;

//Use the above methods (notably initialClassification) to make a decision for all 
//dates in the given array and put the result in a DateClassificationResult structure,
//then returns it.
+(DateClassificationResult*) classifyDates:(NSArray *)dates;

//A utility print method
+(void)printResults;

//Returns the name of a month as a string, given the month number
+(NSString*)getMonthName:(NSInteger)month;
	
	
@end
