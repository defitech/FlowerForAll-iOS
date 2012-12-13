//
//  UserChooserViewController.h
//  FlowerForAll
//
//  Created by adherent on 10.10.12.
//
//

#import <UIKit/UIKit.h>

@interface UserChooserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

    UINavigationController* navController;
    
    //The table view
	UITableView *usersListTableView;
    
    UINavigationItem *navItem;
    
}

@property (nonatomic, retain)  IBOutlet UINavigationController* navController;

@property (nonatomic, retain) IBOutlet UITableView *usersListTableView;

@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;


- (void) showUserChooser ;


/** show the user picker on top of FLowerController view **/
+(void)show;

- (void) hideUserChooser ;

- (IBAction) userchooserDataChangeEvent:(id)sender;

- (void) close:(id)sender;

@end
