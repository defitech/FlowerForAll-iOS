//
//  YearStatisticListViewController.h
//  FlutterApp2
//
//  Created by Dev on 25.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This class is the table view controller for the year statistic list.
//  It is similar to StatisticListViewController, except that it is responsible for diplaying the statistics for a given year.
//  Important: this implies that the list will never contain directly the exercises, but only the months of year that will
//  themselves contain the exercise.


#import <UIKit/UIKit.h>

#import "DateClassificationResult.h"


@class MonthStatisticListViewController;


@interface YearStatisticListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
	
	//The table view
	IBOutlet UITableView *statisticListTableView;
	
	//Arrays storing the required data
	NSArray *dateTimes;
	NSMutableArray *months;
	
	//Indicate if we are in delete mode (in this case it is YES, otherwise NO)
	BOOL switchToDeleteMode;
	
	//Stores the row that has been currently selected
	NSInteger currentlySelectedRow;
	
	//Stores the current year
	NSInteger currentYear;
	
	//Stores the current user ID
	NSInteger currentUserID;

	//Child view controller
	MonthStatisticListViewController *monthStatisticListViewController;

}


//Properties
@property (nonatomic, retain) IBOutlet UITableView *statisticListTableView;

@property (nonatomic, retain) NSArray *dateTimes;
@property (nonatomic, retain) NSMutableArray *months;

@property BOOL switchToDeleteMode;

@property NSInteger currentYear;
@property NSInteger currentlySelectedRow;
@property NSInteger currentUserID;

@property (nonatomic, retain) MonthStatisticListViewController *monthStatisticListViewController;


//Initializes a MonthStatisticListViewController with parameter currentYear (store it in corresponding instance fields)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSInteger)_currentYear;


@end
