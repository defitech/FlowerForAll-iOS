//
//  Exercise.m
//  FlutterApp2
//
//  Created by Dev on 18.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  Implementation of the Exercise class


#import "Exercise.h"

@implementation Exercise

@synthesize exerciseId, dateTime, appVersion, localUserId, globalUserId, gameId, targetFrequency, targetFrequencyTolerance, targetBlowingDuration, targetDuration, goodPercentage, transferStatus;


//Used to initialize an Exercise object. Simply copies the values passed as parameters to the instance fields
-(id)init:(NSInteger)_exerciseId:(NSInteger)_dateTime:(NSString *)_appVersion:(NSInteger)_localUserId:(NSInteger)_globalUserId:(NSInteger)_gameId:(double) _targetFrequency:(double) _targetFrequencyTolerance:(NSInteger)_targetBlowingDuration:(NSInteger)_targetDuration:(double)_goodPercentage:(NSInteger)_transferStatus {
	self.exerciseId = _exerciseId;
	self.dateTime = _dateTime;
	self.appVersion = _appVersion;
	self.localUserId = _localUserId;
	self.globalUserId = _globalUserId;
	self.gameId = _gameId;
	self.targetFrequency = _targetFrequency;
	self.targetFrequencyTolerance = _targetFrequencyTolerance;
	self.targetBlowingDuration = _targetBlowingDuration;
	self.targetDuration = _targetDuration;
	self.goodPercentage = _goodPercentage;
	self.transferStatus = _transferStatus;
	return self;
}

@end
