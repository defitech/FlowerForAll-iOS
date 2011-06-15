//
//  UserListViewController.h
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the table view controller for the user list.


#import <UIKit/UIKit.h>


@class UserDetailViewController;


@interface UserListViewController : UITableViewController <UITableViewDelegate, UIAlertViewDelegate, UITableViewDataSource> {
	
	//The table view
	IBOutlet UITableView *userListTableView;
	
	//Arrays used to store the user data
	NSArray *usersIDArray;
	NSMutableArray *usersArray;
	
	//Child view controller
	UserDetailViewController *userDetailViewController;
	
	//Text field used in case of adding a new user
	UITextField *newUserTextField;
}


//Properties
@property (nonatomic, retain) UITableView *userListTableView;
@property (nonatomic, retain) NSArray *usersIDArray;
@property (nonatomic, retain) NSMutableArray *usersArray;
@property (nonatomic, retain) UserDetailViewController *userDetailViewController;
@property (nonatomic, retain) UITextField *newUserTextField;


@end
