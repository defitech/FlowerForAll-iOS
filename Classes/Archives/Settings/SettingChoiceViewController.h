//
//  SettingChoiceViewController.h
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the table view controller for the settings list.


#import <UIKit/UIKit.h>


@class UserListViewController;
@class ParametersApp;


@interface SettingChoiceViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	
	//The table view
	IBOutlet UITableView *settingChoiceTableView;
	
	//Array used to store the different settings
	NSMutableArray *settingsArray;
	
	//Child view controllers
	UserListViewController *userListViewController;
	ParametersApp *gameParametersViewController;
	
}


//Properties
@property (nonatomic, retain) NSMutableArray *settingsArray;
@property (nonatomic, retain) UserListViewController *userListViewController;
@property (nonatomic, retain) ParametersApp *gameParametersViewController;

- (void) pushGameParametersViewController:(BOOL)animated;

@end
