//
//  StatisticListViewController.h
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the table view controller for the main statistic list.


#import <UIKit/UIKit.h>


@class ResultsApp_Day;


@interface ResultsApp_List : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	
	//The table view
	IBOutlet UITableView *statisticListTableView;
	
	//Arrays used to store exercises days
    NSMutableArray* exerciseDays;
    
	//Stores the currently selected row in the table
	NSInteger currentlySelectedRow;
	
	//Child view controller
    ResultsApp_Day *dayStatisticListViewController;
    
    //Bar button item to switch to edit mode
    UIBarButtonItem *modifyButton;
	
}


//Properties
@property (nonatomic, retain) IBOutlet UITableView *statisticListTableView;

@property (nonatomic, retain) NSMutableArray *exerciseDays;

@property NSInteger currentlySelectedRow;

@property (nonatomic, retain) ResultsApp_Day *dayStatisticListViewController;

@property (nonatomic, retain) UIBarButtonItem *modifyButton;


@end
