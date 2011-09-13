//
//  UserDetailViewController.h
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class defines the view controller for the user detail view.


#import <UIKit/UIKit.h>


@interface UserDetailViewController : UIViewController <UIAlertViewDelegate> {
	
	//Widgets
	IBOutlet UILabel *usernameLabel;
	IBOutlet UILabel *passwordLabel;
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UIButton *loginButton;
	
	//The ID of the user of whom we are currently displaying the details
	NSInteger userID;
	
}


//Properties
@property (nonatomic, retain) UILabel *usernameLabel;
@property (nonatomic, retain) UILabel *passwordLabel;
@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UIButton *loginButton;

@property NSInteger userID;


//IB actions
- (IBAction) login: (id) sender;
- (IBAction) doneButtonOnKeyboardPressed: (id)sender;


//Initialize the field self.userID with the parameter userID
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSInteger)_userID;

@end
