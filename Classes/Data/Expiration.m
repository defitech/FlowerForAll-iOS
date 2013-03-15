//
//  Expiration.m
//  FlutterApp2
//
//  Created by Dev on 18.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  Implementation of the Expiration class


#import "Expiration.h"

@implementation Expiration

@synthesize expirationId, exerciseId, deltaTime, inTargetDuration, outOfTargetDuration, goodPercentage;



//Used to initialize a User object. Simply copies the values passed as parameters to the instance fields
-(id)init:(NSInteger)_expirationId :(NSInteger)_exerciseId :(NSInteger)_deltaTime :(NSInteger)_inTargetDuration :(NSInteger)_outOfTargetDuration :(double)_goodPercentage {
	self.expirationId = _expirationId;
	self.exerciseId = _exerciseId;
	self.deltaTime = _deltaTime;
	self.inTargetDuration = _inTargetDuration;
	self.outOfTargetDuration = _outOfTargetDuration;
	self.goodPercentage = _goodPercentage;
	return self;
}


@end
