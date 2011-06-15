//
//  Exercise.h
//  FlutterApp2
//
//  Created by Dev on 18.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This class defines fields that mapps whith the column of the database table 'exercises'.
//  The role of this class is to map with the database table in order to easily fetch data from this table.


#import <Foundation/Foundation.h>


@interface Exercise : NSObject {
	NSInteger exerciseId;
	NSInteger dateTime;
	NSString *appVersion;
	NSInteger localUserId;
	NSInteger globalUserId;
	NSInteger gameId;
	double targetFrequency;
	double targetFrequencyTolerance;
	NSInteger targetBlowingDuration;
	NSInteger targetDuration;
	double goodPercentage;
	NSInteger transferStatus;
}

-(id)init:(NSInteger)_exerciseId:(NSInteger)_dateTime:(NSString *)_appVersion:(NSInteger)_localUserId:(NSInteger)_globalUserId:(NSInteger)_gameId:(double) _targetFrequency:(double) _targetFrequencyTolerance:(NSInteger)_targetBlowingDuration:(NSInteger)_targetDuration:(double)_goodPercentage:(NSInteger)_transferStatus;


//Properties
@property  NSInteger exerciseId;
@property  NSInteger dateTime;
@property (nonatomic, retain) NSString *appVersion;
@property  NSInteger localUserId;
@property  NSInteger globalUserId;
@property  NSInteger gameId;
@property  double targetFrequency;
@property  double targetFrequencyTolerance;
@property  NSInteger targetBlowingDuration;
@property  NSInteger targetDuration;
@property double goodPercentage;
@property  NSInteger transferStatus;



@end
