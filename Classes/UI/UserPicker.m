//
//  UserPicker.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 24.08.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "FlutterApp2AppDelegate.h"

#import "UserPicker.h"
#import "UserManager.h"
#import "User.h"
#import "FlowerController.h"

#define kUserPickerOffScreen CGRectMake(0, 416, 325, 250)
#define kUserPickerOnScreen CGRectMake(0, 170, 325, 250)



@implementation UserPicker

@synthesize  userArray,  selectedRow, passwordTextField;

 static BOOL showing = false;
/** show the user picker on top of FLowerController view **/
+(void)show {
    if (! showing) {
        showing = true;
        NSLog(@"UserPicker:show");
        [[[UserPicker alloc] init] showUserPicker];
    } else {
         NSLog(@"UserPicker:already showing");
    }
}


- (void) dismissAndPickSelectedUser {
    [UserManager setCurrentUser:[[self selectedUser] uid]];
    showing = false;
}

UIActionSheet* actionSheet;

- (id)init
{
    self = [super init];
    if (self) {
        
        //Construct an array of user names based on the array of user IDs, and store into instance variables
        self.userArray = [UserManager listAllUser];

    }
    
    return self;
}

- (void) showUserPicker {
    if (actionSheet != nil) {
        NSLog(@"UserPicker: showUserPicker actionSheet is not nil.. strange situation" );
    }
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
                                              delegate:nil
                                     cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    
    [actionSheet addSubview:pickerView];
    [pickerView release];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedString(@"Done", @"Button to validate user selection")]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];
    [actionSheet setTitle:NSLocalizedString(@"Pick your profile name", @"Title of the user chooser")];
    [closeButton release];
    
    [actionSheet showInView:[FlowerController currentFlower].view];
    
    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];        
    
}
 

-(IBAction)dismissActionSheet:(id)sender {
    // hiden picker
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [actionSheet release];
    actionSheet = nil;
    
    if ([[[self selectedUser] password] isEqualToString:@""]) {
        [self dismissAndPickSelectedUser];
        return;
    }
    
    [self showPasswordSheet:@""];
}


- (void) showPasswordSheet:(NSString*)extraMessage {
    
    //Creates an alert for the user to enter his password
    UIAlertView *myAlertView = [[UIAlertView alloc] 
                                initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Enter password for %@", @"Label of the password alert"),[[self selectedUser] name]] 
                                message:[NSString stringWithFormat:@"%@\n\n",extraMessage]
                                delegate:self 
                                cancelButtonTitle:NSLocalizedString(@"Cancel", @"Label of the cancel button label on the password alert") 
                                otherButtonTitles:NSLocalizedString(@"OK", @"Label of the OK button label on the password alert"), nil];
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 70.0, 260.0, 25.0)];
    [self.passwordTextField setBackgroundColor:[UIColor whiteColor]];
    self.passwordTextField.secureTextEntry = YES;
    [self.passwordTextField setKeyboardType:UIKeyboardTypeNumberPad];
    [myAlertView addSubview:self.passwordTextField];
    [myAlertView show];
    [myAlertView release];
    
}

//Returns 1 because we only need one column
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView { // This method needs to be used. It asks how many columns will be used in the UIPickerView
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.userArray count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)componen { 
	return [(User*)[self.userArray objectAtIndex:row] name];
}


- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component { //
    self.selectedRow = row;
}


- (User*) selectedUser {
    return (User*)[self.userArray objectAtIndex:self.selectedRow];
}


//Check password if clicked on OK button
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1){
        if ([[[self selectedUser] password] isEqualToString:self.passwordTextField.text]) {
            
            NSLog(@"Choose User %@",[[self selectedUser] name] );
            [self dismissAndPickSelectedUser];
            showing = false;
        } else {
            NSLog(@"Password for User %@ is %@",[[self selectedUser] name],[[self selectedUser] password]);
            [self showPasswordSheet:NSLocalizedString(@"Wrong password please retry.", @"Message to display in the alert box.")];
        }
        
	} else {
        //[self showUserPicker];
         showing = false;
    }
}

@end
