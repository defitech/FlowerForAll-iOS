//
//  UserPicker.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 24.08.11.
//  Copyright 2011 Fondation Defitech http://defitech.ch All rights reserved.
//
// Moved the code for the User Picker From GameView to a Neater place
// Maybe this code will be Abandonned

#import <Foundation/Foundation.h>

@interface UserPicker : NSObject  <UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate> {
    //The picker view that is displayed for selecting the user in case of multiple users utilisation
	UIView *labelAndPickerView;
	UIPickerView *myPickerView;
	UILabel *pickerLabel;
    
    //Arrays containing the user informations (for the display and selection of users)
	NSArray *userIDsArray;
	NSArray *usernamesArray;
	
	//Stores the currently selected row in the picker view
	NSInteger selectedRow;
	
	//The password text field
	UITextField *passwordTextField;
}

- (id)showOnView:(UIViewController*)myController;

@property (nonatomic, retain) UIView *labelAndPickerView;
@property (nonatomic, retain) UIPickerView *myPickerView;
@property (nonatomic, retain) UILabel *pickerLabel;


@property (nonatomic, retain) NSArray *userIDsArray;
@property (nonatomic, retain) NSArray *usernamesArray;
@property NSInteger selectedRow;
@property (nonatomic, retain) UITextField *passwordTextField;


@end
