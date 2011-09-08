//
//  DateClassificationResult.h
//  FlutterApp2
//
//  Created by Dev on 24.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This class is a utility class used as a structure to store the result of date classifications.


#import <Foundation/Foundation.h>


@interface DateClassificationResult : NSObject {
	
	//Arrays containing, for a set of dates, the dates belonging to the past years, and the dates belonging
	//to the past months of the current year.
	//Data are stored int integer form: example for months: 1, 2, 3, 4...; example for years: 2011, 2010, ...
	NSArray *pastYears;
	NSArray *pastMonths;
	
}


//Properties
@property (nonatomic, retain) NSArray *pastYears;
@property (nonatomic, retain) NSArray *pastMonths;


@end
