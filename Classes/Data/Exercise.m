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

@synthesize start_ts, stop_ts, frequency_target_hz, frequency_tolerance_hz, duration_expiration_s, duration_exercice_s, duration_exercice_done_ps, blow_count, blow_star_count, profile_name, avg_median_frequency_hz;


//Used to initialize an Exercise object. Simply copies the values passed as parameters to the instance fields
-
(id)init:(double)_start_ts :(double)_stop_ts :(double)_frequency_target_hz :(double)_frequency_tolerance_hz :(double)_duration_expiration_s :(double)_duration_exercice_s :(double)_duration_exercice_done_ps :(NSInteger)_blow_count :(NSInteger)_blow_star_count :(NSString*)_profile_name :(double)_avg_median_frequency_hz {
	self.start_ts = _start_ts;
	self.stop_ts = _stop_ts;
	self.frequency_target_hz = _frequency_target_hz;
	self.frequency_tolerance_hz = _frequency_tolerance_hz;
    self.duration_expiration_s = _duration_expiration_s;
	self.duration_exercice_s = _duration_exercice_s;
	self.duration_exercice_done_ps = _duration_exercice_done_ps;
	self.blow_count = _blow_count;
	self.blow_star_count = _blow_star_count;
    self.profile_name = _profile_name;
    self.avg_median_frequency_hz = _avg_median_frequency_hz;
	return self;
}

@end
