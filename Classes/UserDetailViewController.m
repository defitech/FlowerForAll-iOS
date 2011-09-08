//
//  UserDetailViewController.m
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	Implementation of the UserDetailViewController class


#import "FlutterApp2AppDelegate.h"

#import "UserDetailViewController.h"

#import "DB.h"


@implementation UserDetailViewController


@synthesize userID, usernameField, passwordField, loginButton, usernameLabel, passwordLabel;




// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}*/




//Initialize the field self.userID with the parameter userID
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSInteger)_userID{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization.
		self.userID = _userID;
	}
	return self;
}





/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

//Add delete button to the navigation bar, and link it to the deleteUser function
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	
	 //Set texts of the labels and button
	usernameLabel.text = NSLocalizedString(@"UsernameLabel", @"Text of the username label");
	passwordLabel.text = NSLocalizedString(@"PasswordLabel", @"Text of the password label");
	[loginButton setTitle:NSLocalizedString(@"ModifyButtonText", @"Text of the modify button") forState:UIControlStateNormal];
	[loginButton setTitle:NSLocalizedString(@"ModifyButtonText", @"Text of the modify button") forState:UIControlStateHighlighted];
	[loginButton setTitle:NSLocalizedString(@"ModifyButtonText", @"Text of the modify button") forState:UIControlStateDisabled];
	[loginButton setTitle:NSLocalizedString(@"ModifyButtonText", @"Text of the modify button") forState:UIControlStateSelected];
	
	
	FlutterApp2AppDelegate *delegate = (FlutterApp2AppDelegate *)[[UIApplication sharedApplication] delegate];
	
	//Special treatment if the ID of the user actually using the application is 0.
	//Be careful of not being confused between the user that is currently using the app, and the user we are displaying the details of.
	if (delegate.currentUserID == 0){
		
		//If it is the case, check if the ID of the user we are displaying the details of is 0.
		if (self.userID == 0){
			//If it is the case, disable the username field. We do not want the name of the user with ID 0 (the main user) to be changeable.
			self.usernameField.enabled = NO;
			self.usernameField.textColor = [UIColor grayColor];
		}
		else {
			//Add delete button only is the user being currently diplayed is not the main user, because the main user must not be deleted.
			UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DeleteUserButtonLabel", @"Label of the delete user button") style:UIBarButtonItemStylePlain target:self action:@selector(deleteUser)];          
			self.navigationItem.rightBarButtonItem = anotherButton;
			[anotherButton release];
		}
		
	}	
	
	
	//Set the text of the username and password fields
	usernameField.text = [DB getUserName:self.userID];
	passwordField.text = [DB getUserPassword:self.userID];
		
}





//Display an alert to ask user a confirmation before deleting
- (void)deleteUser {
	
	UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteUserAlertLabel", @"Label of the delete user alert") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DeleteUserAlertCancelButtonLabel", @"Label of the cancel button label on the delete user alert") otherButtonTitles:NSLocalizedString(@"DeleteUserAlertOKButtonLabel", @"Label of the OK button label on the delete user alert"), nil];
	[myAlertView show];
	[myAlertView release];
	
}





//Delete the user (remove it from the DB) if clicked on the OK button
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1){
		
		//Delete the user
		[DB deleteUser:self.userID];
			
		[[FlowerController getSettingsViewController] popViewControllerAnimated:YES];
		
	}
	
}




//Action for the modify button; set username and password in the username and password fields to be the new ones (i.e., store them in the DB)
//Don't be confused by the name: it is not really a login; the correct name should be "modify"
- (IBAction) login: (id) sender {
	
	if ( self.usernameField.text.length != 0 && self.passwordField.text.length != 0) {
		
		[DB setUserName:self.userID:self.usernameField.text];
		[DB setUserPassword:self.userID:self.passwordField.text];
	
		UIAlertView *alert;	
		alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UserPasswordChangedAlertLabel", @"Label of the user or password changed alert") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"UserPasswordChangedAlertOKButtonLabel", @"Label of the OK button label on the user or password changed alert") otherButtonTitles:nil] autorelease];
		[alert show];
		
	}
}





//Hide the keyboard when return is hit
- (IBAction) doneButtonOnKeyboardPressed: (id)sender{
	[sender resignFirstResponder];
}





- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}



//Allows view to autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}



@end
