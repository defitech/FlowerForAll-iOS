//
//  StatisticListViewController.h
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the table view controller for the main statistic list.


#import <UIKit/UIKit.h>

#import "CorePlot-CocoaTouch.h"


@interface DayStatisticListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	
	//The table view
	IBOutlet UITableView *statisticListTableView;
    
    //The exercises
    NSMutableArray* exercises;
    
    //The date of the current day formatted as a string
    NSString* formattedDate;
    
    //Date and time formatters
    NSDateFormatter *dateFormatter;
    NSDateFormatter *timeFormatter;
	
	//Stores the currently selected row in the table
	NSInteger currentlySelectedRow;
	
    //Bar button item to switch to edit mode
    UIBarButtonItem *modifyButton;
	
}


//Properties
@property (nonatomic, retain) IBOutlet UITableView *statisticListTableView;

@property (nonatomic, retain) NSMutableArray *exercises;

@property (nonatomic, retain) NSString* formattedDate;

@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSDateFormatter *timeFormatter;

@property NSInteger currentlySelectedRow;

@property (nonatomic, retain) UIBarButtonItem *modifyButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSString*)_formattedDate;

@end
