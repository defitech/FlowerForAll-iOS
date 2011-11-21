//
//  UserPicker.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 24.08.11.
//  Copyright 2011 Fondation Defitech http://defitech.ch All rights reserved.
//
// Moved the code for the User Picker From MenuView to a Neater place
// Maybe this code will be Abandonned

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserPicker : NSObject  <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate> {
    //Arrays containing the user informations (for the display and selection of users)
	NSArray *userArray;
	
	//Stores the currently selected row in the picker view
	NSInteger selectedRow;
	
	//The password text field
	UITextField *passwordTextField;
}

/** show the user picker on top of FLowerController view **/
+(void)show;

/** show the password test on top of FLowerController view **/
+(void)askPasswordFor:(User*)user;

- (void) showUserPicker ;

- (void) dismissAndPickSelectedUser;


-(IBAction)dismissActionSheet:(id)sender;

- (User*) selectedUser;

- (void) showPasswordSheet:(NSString*)extraMessage ;


@property (nonatomic, retain) NSArray *userArray;
@property NSInteger selectedRow;
@property (nonatomic, retain) UITextField *passwordTextField;


@end
