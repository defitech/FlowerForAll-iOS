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
    
    //The password text field
	UITextField *passwordTextFieldforChooser;
    
    //Arrays containing the user informations (for the display and selection of users)
	NSArray *userArrayforChooser;
    NSMutableArray *namesArrayforChooser;
    NSMutableArray *passwordsArrayforChooser;
}

@property (nonatomic, retain)  IBOutlet UINavigationController* navController;
@property (nonatomic, retain) IBOutlet UITableView *usersListTableView;
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) UITextField *passwordTextFieldforChooser;
@property (nonatomic, retain) NSArray *userArrayforChooser;
@property (nonatomic, retain) NSMutableArray *namesArrayforChooser;
@property (nonatomic, retain) NSMutableArray *passwordsArrayforChooser;

- (void) showUserChooser ;


/** show the user picker on top of FLowerController view **/
+(void)show;

- (void) hideUserChooser ;

- (IBAction) userchooserDataChangeEvent:(id)sender;

- (void) close:(id)sender;

@end

