//
//  Expiration.h
//  FlutterApp2
//
//  Created by Dev on 18.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This class defines fields that mapps whith the column of the database table 'expirations'.
//  The role of this class is to map with the database table in order to easily fetch data from this table.


#import <Foundation/Foundation.h>


@interface Expiration : NSObject {
	NSInteger expirationId;
	NSInteger exerciseId;
	NSInteger deltaTime;
	NSInteger inTargetduration;
	NSInteger outOfTargetduration;
	double goodPercentage;
}


//Properties
@property NSInteger expirationId;
@property NSInteger exerciseId;
@property NSInteger deltaTime;
@property NSInteger inTargetDuration;
@property NSInteger outOfTargetDuration;
@property double goodPercentage;


//Used to initialize a User object. Simply copies the values passed as parameters to the instance fields
-(id)init:(NSInteger)_expirationId:(NSInteger)_exerciseId:(NSInteger)_deltaTime:(NSInteger)_inTargetDuration:(NSInteger)_outOfTargetDuration:(double)_goodPercentage; 


@end
