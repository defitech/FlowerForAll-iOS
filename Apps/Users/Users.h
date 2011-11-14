//
//  Users.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerApp.h"

@interface Users : FlowerApp  <UITableViewDelegate, UITableViewDataSource>  {
    IBOutlet UINavigationController* navController;
    
    //The table view
	IBOutlet UITableView *usersListTableView;
    
    

}

@property (nonatomic, retain)  IBOutlet UINavigationController* navController;  

@property (nonatomic, retain) IBOutlet UITableView *usersListTableView;

- (IBAction) plusButtonTouch:(id)sender;

@end
