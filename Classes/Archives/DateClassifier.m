//
//  DateClassifier.m
//  FlutterApp2
//
//  Created by Dev on 24.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  Implementation of the DateClassifier class


#import "DateClassifier.h"

#import "DateClassificationResult.h"


//Static variables
static NSMutableArray *pastYears;
static NSMutableArray *pastMonths;


@implementation DateClassifier




//Returns the current year in yyyy format (example: 2011)
+(NSInteger) getCurrentYear {
	
	NSDate *now = [NSDate date];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"yyyy"];
	return [[formatter stringFromDate:now] intValue];
	
}



//Returns the current month in MM format (example: 7 = July)
+(NSInteger) getCurrentMonth {
	
	//NSDate *now = [NSDate date];
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"MM"];
	//return [[formatter stringFromDate:now] intValue];
	//On simule le mois de juillet:
	return 7;
}




//Performs the initial classification for a given date
//Initial classification means that the method checks whether a date belongs to the current month and year,
//to the past months within the current year (in this case it will be stored in the array pastMonths), or
//to the past years (in this case it will be stores in the array pastYears).
//This method then calls 2 other methods, classifyMonth and classifyYear, which behaves recursively.
//The overall behavior looks like a decision tree (see separate documentation).
+(void) initialClassification:(NSInteger)date {
	
	NSInteger currentYear = [DateClassifier getCurrentYear];
	NSString *beginningOfYearString = [[NSString stringWithFormat:@"%i", currentYear] stringByAppendingString:@"-01-01 00:00:00 +0100"];
	//NSLog(@"beginningOfYearString: %@", beginningOfYearString);
	NSDate *beginningOfYearDate = [NSDate dateWithString:beginningOfYearString];
	NSDate *thisDate = [NSDate dateWithTimeIntervalSince1970:date];
	
	NSComparisonResult result = [beginningOfYearDate compare:thisDate];
	
	//NSLog(@"begin year: %f", [beginningOfYearDate timeIntervalSince1970]);
	//NSLog(@"this date: %f", [thisDate timeIntervalSince1970]);
	
	switch (result) {
		case NSOrderedAscending:
			[DateClassifier classifyMonth:thisDate:[DateClassifier getCurrentMonth]];
			break;
		case NSOrderedDescending:
			//NSLog(@"Before this year");
			[DateClassifier classifyYear:thisDate:currentYear-1];
			break;
		default:
			NSLog(@"Error: dates are the same");
			break;
	}
	
}




//Recursive method which decides to which year a date belongs to (assuming it does not belong to the
//current year, but to a past year)
+(void) classifyYear:(NSDate *)date:(NSInteger)year {

	NSString *beginningOfYearString = [[NSString stringWithFormat:@"%i", year] stringByAppendingString:@"-01-01"];
	
    NSLog(@"beginningOfYearString: %@", beginningOfYearString);
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease]; 
    dateFormatter.dateFormat = @"yyyy-MM-dd";
	NSDate *beginningOfYearDate =  [dateFormatter dateFromString:beginningOfYearString];
	
	NSComparisonResult result = [beginningOfYearDate compare:date];
	
	
	switch (result) {
		case NSOrderedAscending:
			//NSLog(@"This year: %i", year);
			if (year != [DateClassifier getCurrentYear] && ![pastYears containsObject:[NSString stringWithFormat:@"%i", year]]) {
				[pastYears addObject:[NSString stringWithFormat:@"%i", year]];
			}
			break;
		case NSOrderedDescending:
			//NSLog(@"Before this year");
			[DateClassifier classifyYear:date:year-1];
			break;
		default:
			NSLog(@"Error: dates are the same");
			break;
	}
}




//Recursive method which decides to which month a date belongs to (assuming it does not belong to the
//current month, but to a past month of the current year)
+(void) classifyMonth:(NSDate *)date:(NSInteger)month {
	
	NSString *beginningOfMonthString = [[NSString stringWithFormat:@"%i", [DateClassifier getCurrentYear]] stringByAppendingString:@"-"];
	beginningOfMonthString = [beginningOfMonthString stringByAppendingString:[NSString stringWithFormat:@"%i", month]];
	beginningOfMonthString = [beginningOfMonthString stringByAppendingString:@"-01"];
	
	NSLog(@"beginningOfMonthString: %@", beginningOfMonthString);
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease]; 
    dateFormatter.dateFormat = @"yyyy-MM-dd";

	NSDate *beginningOfMonthDate = [dateFormatter dateFromString:beginningOfMonthString];
	
	NSComparisonResult result = [beginningOfMonthDate compare:date];
	
	
	switch (result) {
		case NSOrderedAscending:
			//NSLog(@"This month: %i", month);
			if (month != [DateClassifier getCurrentMonth] && ![pastMonths containsObject:[NSString stringWithFormat:@"%i", month]]) {
				[pastMonths addObject:[NSString stringWithFormat:@"%i", month]];
			}
			break;
		case NSOrderedDescending:
			//NSLog(@"Before this month");
			[DateClassifier classifyMonth:date:month-1];
			break;
		default:
			NSLog(@"Error: dates are the same");
			break;
	}
}





//Returns the month (as an integer) corresponding to the given date
+(NSInteger) getMonthGivenAdate:(NSInteger)dateTime {
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateTime];
	NSTimeZone * tz = [NSTimeZone localTimeZone];
	CFAbsoluteTime at = CFDateGetAbsoluteTime((CFDateRef)date);
	int month = CFAbsoluteTimeGetGregorianDate(at, (CFTimeZoneRef)tz).month;
	return month;
}





//Use the above methods (notably initialClassification) to make a decision for all 
//dates in the given array and put the result in a DateClassificationResult structure,
//then returns it.
+(DateClassificationResult*)classifyDates:(NSArray *)dates {
	
	pastYears = [[[NSMutableArray alloc] init] autorelease];
	pastMonths = [[[NSMutableArray alloc] init] autorelease];
	
	for (int i=0; i < [dates count]; i++) {
		[DateClassifier initialClassification:[[dates objectAtIndex:i] intValue]];
	}
	
	[DateClassifier printResults];
	
	DateClassificationResult *result = [[DateClassificationResult alloc] init];
	result.pastYears = pastYears;
	result.pastMonths = pastMonths;
	
	return [result autorelease];
	//return nil;
}




//A utility print method
+(void)printResults {
	
	for (int i=0; i < [pastYears count]; i++) {
		NSLog(@"Year: %@", [pastYears objectAtIndex:i]);
	}
	
	for (int i=0; i < [pastMonths count]; i++) {
		NSLog(@"Month: %@", [pastMonths objectAtIndex:i]);
	}
	
}




//Returns the name of a month as a string, given the month number
+(NSString*)getMonthName:(NSInteger)month {
	switch (month) {
		case 1:
			return NSLocalizedString(@"January", @"January");
			break;
		case 2:
			return NSLocalizedString(@"February", @"February");
			break;
		case 3:
			return NSLocalizedString(@"March", @"March");
			break;
		case 4:
			return NSLocalizedString(@"April", @"April");
			break;
		case 5:
			return NSLocalizedString(@"May", @"May");
			break;
		case 6:
			return NSLocalizedString(@"June", @"June");
			break;
		case 7:
			return NSLocalizedString(@"July", @"July");
			break;
		case 8:
			return NSLocalizedString(@"August", @"August");
			break;
		case 9:
			return NSLocalizedString(@"September", @"September");
			break;
		case 10:
			return NSLocalizedString(@"October", @"October");
			break;
		case 11:
			return NSLocalizedString(@"November", @"November");
			break;
		case 12:
			return NSLocalizedString(@"December", @"December");
			break;
		default:
			NSLog(@"Error: month number not between 1 and 12");
			return @"Error";
			break;
	}
}


@end
