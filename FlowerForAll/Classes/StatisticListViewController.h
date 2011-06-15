//
//  StatisticListViewController.h
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the table view controller for the main statistic list.


#import <UIKit/UIKit.h>


@class StatisticDetailViewController;
@class MonthStatisticListViewController;
@class YearStatisticListViewController;


@interface StatisticListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
	
	//The table view
	IBOutlet UITableView *statisticListTableView;
	
	//Arrays used to store the exercises data that are displayed in this table view (i.e., for current month and year)
	NSMutableArray *exercisesIDArray;
	NSMutableArray *datesArray;
	NSMutableArray *timesArray;
	NSMutableArray *goodPercentages;
	NSMutableArray *transferStatusesArray;
	
	//Arrays used to store the past months within the current year, and the past years that do contain exercises for the current user
	NSArray *pastYears;
	NSArray *pastMonths;
	
	//Stores the currently selected row in the table
	NSInteger currentlySelectedRow;
	
	//Stores the ID of the current user
	NSInteger currentUserID;
	
	//Indicate if we are in delete mode (in this case it is YES, otherwise NO)
	BOOL switchToDeleteMode;
	
	//Child view controllers
	StatisticDetailViewController *statisticDetailViewController;
	MonthStatisticListViewController *monthStatisticListViewController;
	YearStatisticListViewController *yearStatisticListViewController;
	
}


//Properties
@property (nonatomic, retain) IBOutlet UITableView *statisticListTableView;

@property (nonatomic, retain) NSMutableArray *exercisesIDArray;
@property (nonatomic, retain) NSMutableArray *datesArray;
@property (nonatomic, retain) NSMutableArray *timesArray;
@property (nonatomic, retain) NSMutableArray *goodPercentagesArray;
@property (nonatomic, retain) NSMutableArray *transferStatusesArray;
@property (nonatomic, retain) NSArray *pastYears;
@property (nonatomic, retain) NSArray *pastMonths;

@property NSInteger currentlySelectedRow;
@property NSInteger currentUserID;

@property BOOL switchToDeleteMode;

@property (nonatomic, retain) StatisticDetailViewController *statisticDetailViewController;
@property (nonatomic, retain) MonthStatisticListViewController *monthStatisticListViewController;
@property (nonatomic, retain) YearStatisticListViewController *yearStatisticListViewController;



@end
