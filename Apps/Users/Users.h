//
//  Users.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerApp.h"

@interface Users : FlowerApp  <UITableViewDelegate, UITableViewDataSource>  {
    UINavigationController* navController;
    
    //The table view
	UITableView *usersListTableView;
    
    UINavigationItem *navItem;
    
    // to keep a ref when hidding
    UIBarButtonItem *plusButton;
}

@property (nonatomic, retain)  IBOutlet UINavigationController* navController;  

@property (nonatomic, retain) IBOutlet UITableView *usersListTableView;

@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;

- (IBAction) plusButtonTouch:(id)sender;


- (IBAction) userDataChangeEvent:(id)sender;

- (void)refreshPlusButton;

@end
