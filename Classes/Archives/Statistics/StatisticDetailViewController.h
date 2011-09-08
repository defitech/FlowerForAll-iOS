//
//  StatisticDetailViewController.h
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	This class defines the view controller for the user detail view. It uses the library Core-Plot for plotting the graph.


#import <UIKit/UIKit.h>

#import "CorePlot-CocoaTouch.h"


@interface StatisticDetailViewController : UIViewController <CPPlotDataSource, CPPlotSpaceDelegate> {

	//The graph
	CPXYGraph *barChart;
	
	//Arrays storing in target and out of target times for all expirations
	NSMutableArray *inTargetExpirationTimes;
	NSMutableArray *outOfTargetExpirationTimes;
	
	//Stores the ID of the exercise currently being displayed
	NSInteger currentExerciseID;
	
}


//Properties
@property (nonatomic, retain) CPXYGraph *barChart;

@property (nonatomic, retain) NSMutableArray *inTargetExpirationTimes;
@property (nonatomic, retain) NSMutableArray *outOfTargetExpirationTimes;

@property NSInteger currentExerciseID;


//Initialize the field self.currentExerciseID with the parameter currentExerciseID
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSInteger)_currentExerciseID;

	
@end
