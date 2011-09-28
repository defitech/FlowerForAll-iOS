//
//  UserPicker.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 24.08.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "FlutterApp2AppDelegate.h"

#import "UserPicker.h"

#import "DB.h"


#define kUserPickerOffScreen CGRectMake(0, 416, 325, 250)
#define kUserPickerOnScreen CGRectMake(0, 170, 325, 250)



@implementation UserPicker

@synthesize myPickerView, usernamesArray, userIDsArray, labelAndPickerView, pickerLabel, selectedRow, passwordTextField;

- (id)showOnView:(UIViewController*)myController
{
    self = [super init];
    if (self) {
        
        //Construct an array of user names based on the array of user IDs, and store into instance variables
        self.userIDsArray = [DB listOfAllUserIDs];
        
        NSMutableArray *users = [[NSMutableArray alloc] init];
        [users addObject:[NSString string]]; //Add an empty row
        
        for (NSInteger i=0; i < [self.userIDsArray count]; i++ ) {
            //NSLog(@"test: %@", [DB getUserName:[[self.userIDsArray objectAtIndex:i] intValue]]);
            [users addObject:[DB getUserName:[[self.userIDsArray objectAtIndex:i] intValue]]];
        }
        
        self.usernamesArray = users;
        
        [users release];
        
        
        //Case where there is more than 1 user
        if ([self.userIDsArray count] > 1) {
            
            //Disable UI elements
            //scrollView.userInteractionEnabled = NO;
            
            //Create and set labelAndPickerView, myPickerView, pickerLabel
            labelAndPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
            
            myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 30, 320, 170)];
            myPickerView.delegate = self;
            myPickerView.dataSource = self;
            myPickerView.showsSelectionIndicator = YES;
            //myPickerView.frame = kUserPickerOffScreen;
            
            pickerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
            pickerLabel.font = [UIFont boldSystemFontOfSize:20];
            pickerLabel.textAlignment = UITextAlignmentCenter;
            pickerLabel.backgroundColor = [UIColor grayColor];
            pickerLabel.textColor = [UIColor whiteColor];
            //pickerLabel.shadowColor = [UIColor whiteColor];
            //pickerLabel.shadowOffset = CGSizeMake (0,1)
            pickerLabel.text = NSLocalizedString(@"UserChoiceLabel", @"Label asking to choose the current user");
            
            //Add myPickerView and pickerLabel to labelAndPickerView
            [labelAndPickerView addSubview:pickerLabel];
            [labelAndPickerView addSubview:myPickerView];
            
            [myController.view addSubview:labelAndPickerView];
            
            //Put labelAndPickerView off screen
            labelAndPickerView.frame = kUserPickerOffScreen;
            
        }

        
        labelAndPickerView.frame = kUserPickerOnScreen;
    }
    
    return self;
}



//Returns 1 because we only need one column
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView { // This method needs to be used. It asks how many columns will be used in the UIPickerView
	return 1;
}

//We will need the amount of rows that we used in the pickerViewArray, so we will return the count of the array.
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component { // This method also needs to be used. This asks how many rows the UIPickerView will have.
	return [self.usernamesArray count];
}

//We will set a new row for every string used in the array.
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component { // This method asks for what the title or label of each row will be.
	return [self.usernamesArray objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component { // And now the final part of the UIPickerView, what happens when a row is selected.
	if(row != 0) { //Disabled for the first empty row
        //Stores the currently selected row in self.selectedRow
        self.selectedRow = row;
        
        //Creates an alert for the user to enter his password
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PasswordAlertLabel", @"Label of the password alert") message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"PasswordAlertCancelButtonLabel", @"Label of the cancel button label on the password alert") otherButtonTitles:NSLocalizedString(@"PasswordAlertOKButtonLabel", @"Label of the OK button label on the password alert"), nil];
        self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        [self.passwordTextField setBackgroundColor:[UIColor whiteColor]];
        self.passwordTextField.secureTextEntry = YES;
        [myAlertView addSubview:self.passwordTextField];
        [myAlertView show];
        [myAlertView release];
	}
}






//Check password if clicked on OK button
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1){
		
		if ( self.passwordTextField.text.length != 0 ) {
			// -1 to remove the empty row
			NSInteger userID = [[self.userIDsArray objectAtIndex:self.selectedRow] intValue] - 1;
			NSString *password = [DB getUserPassword:userID];
			
			if ([password isEqualToString:self.passwordTextField.text]) {
				
				//Set current user ID on the delegate
				FlutterApp2AppDelegate *delegate = (FlutterApp2AppDelegate *)[[UIApplication sharedApplication] delegate];
				delegate.currentUserID = userID;
				
				
				[UIView beginAnimations:@"Transition" context:nil];
				[UIView setAnimationDuration:0.3];
				
				//Put labelAndPickerView off screen
				labelAndPickerView.frame = kUserPickerOffScreen;
				
				[UIView commitAnimations];
				
				//Re-enable UI elements
				//scrollView.userInteractionEnabled = YES;
				//delegate.tabBarController.tabBar.userInteractionEnabled = YES;
				
			}
			else {
				
				UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IdentificationFailedAlertLabel", @"Label of the identification failed alert") message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
				[myAlertView show];
				[myAlertView release];
				
			}
            
		}
	}
}

@end
