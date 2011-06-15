//
//  MonthStatisticListViewController.h
//  FlutterApp2
//
//  Created by Dev on 25.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This class is the table view controller for the month statistic list.
//  It is similar to StatisticListViewController, except that it is responsible for diplaying the statistics for a given month
//  in a given year.


#import <UIKit/UIKit.h>

#import "DateClassificationResult.h"


@class StatisticDetailViewController;


@interface MonthStatisticListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
	
	//The table view
	IBOutlet UITableView *statisticListTableView;
	
	//Arrays used to store the exercises data that are displayed in this table view
	NSMutableArray *exercisesIDArray;
	NSMutableArray *datesArray;
	NSMutableArray *timesArray;
	NSMutableArray *goodPercentages;
	NSMutableArray *transferStatusesArray;
	
	//Stores the row that has been currently selected
	NSInteger currentlySelectedRow;
	
	//Stores the current year and month of which we are currently displaying the exercises
	NSInteger currentMonth;
	NSInteger currentYear;
	
	//Indicate if we are in delete mode (in this case it is YES, otherwise NO)
	BOOL switchToDeleteMode;
	
	//Indicates whether this MonthStatisticListViewController is directly embedded in the main StatisticListViewController,
	//or if it is embedded in a YearStatisticListViewController.
	//In fact, it is important if there is only one exercise left in the table, and if the user deletes it, then we should
	//know if we have to pop out 2 controllers from the nav controller, or only one.
	BOOL popTwoTimes;
	
	//Child controller
	StatisticDetailViewController *statisticDetailViewController;
}


//Properties
@property (nonatomic, retain) IBOutlet UITableView *statisticListTableView;

@property (nonatomic, retain) NSMutableArray *exercisesIDArray;
@property (nonatomic, retain) NSMutableArray *datesArray;
@property (nonatomic, retain) NSMutableArray *timesArray;
@property (nonatomic, retain) NSMutableArray *goodPercentagesArray;
@property (nonatomic, retain) NSMutableArray *transferStatusesArray;

@property NSInteger currentlySelectedRow;
@property NSInteger currentMonth;
@property NSInteger currentYear;

@property BOOL switchToDeleteMode;
@property BOOL popTwoTimes;

@property (nonatomic, retain) StatisticDetailViewController *statisticDetailViewController;


//Initializes a MonthStatisticListViewController with parameters currentMonth, currentYear and popTwoTimes (store them in corresponding instance fields)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSInteger)_currentMonth:(NSInteger)_currentYear:(BOOL)_popTwoTimes;


@end