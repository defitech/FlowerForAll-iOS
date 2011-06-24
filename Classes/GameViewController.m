//
//  GameViewController.m
//  FlutterApp2
//
//  Created by Dev on 24.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the GameViewController class


#import "FlutterApp2AppDelegate.h"

#import "GameViewController.h"

#import "DataAccess.h"
#import "DataAccessDB.h"

#import "FlowerController.h"
#import "AWebController.h"

#define kDatePickerOffScreen CGRectMake(0, 416, 325, 250)
#define kDatePickerOnScreen CGRectMake(0, 170, 325, 250)


@implementation GameViewController


@synthesize scrollView, game1ChoiceView, game2ChoiceView, myPickerView, usernamesArray, userIDsArray, labelAndPickerView, pickerLabel, selectedRow, passwordTextField, game1Button, game2Button, navigationBar, pageControl;





/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

AWebController *webController;

- (IBAction) game1Touch:(id) sender {
    if (webController == nil) {
        webController = [[AWebController alloc] initWithNibName:@"AWebController" bundle:[NSBundle mainBundle]];
    }
    [FlowerController setCurrentMainController:webController];
}
     


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];

	//Set title of the navigation bar
	navigationBar.topItem.title = NSLocalizedString(@"GameViewTitle", @"Title of the game view");
	
	//Set title of game buttons for all states
	[game1Button.titleLabel setTextAlignment:UITextAlignmentCenter];
	[game2Button.titleLabel setTextAlignment:UITextAlignmentCenter];
	[game1Button setTitle:NSLocalizedString(@"GameButton1Text", @"Text of the first game button") forState:UIControlStateNormal];
	[game1Button setTitle:NSLocalizedString(@"GameButton1Text", @"Text of the first game button") forState:UIControlStateHighlighted];
	[game1Button setTitle:NSLocalizedString(@"GameButton1Text", @"Text of the first game button") forState:UIControlStateDisabled];
	[game1Button setTitle:NSLocalizedString(@"GameButton1Text", @"Text of the first game button") forState:UIControlStateSelected];
	[game2Button setTitle:NSLocalizedString(@"GameButton2Text", @"Text of the second game button") forState:UIControlStateNormal];
	[game2Button setTitle:NSLocalizedString(@"GameButton2Text", @"Text of the second game button") forState:UIControlStateHighlighted];
	[game2Button setTitle:NSLocalizedString(@"GameButton2Text", @"Text of the second game button") forState:UIControlStateDisabled];
	[game2Button setTitle:NSLocalizedString(@"GameButton2Text", @"Text of the second game button") forState:UIControlStateSelected];
	
	//Add games views inside the scroll view
	game1ChoiceView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 367.0f);
	game2ChoiceView.frame = CGRectMake(320.0f, 0.0f, 320.0f, 367.0f);
	
	//Set scroll view content size
	scrollView.contentSize = CGSizeMake(640.0,0.0);
	
	//Set scroll view zoom scale
	scrollView.maximumZoomScale = 3.0;
	scrollView.minimumZoomScale = 0.2;
	
	//Set scroll view delegate
	scrollView.delegate = self;
	
	//Set scroll view paging enabled
	scrollView.pagingEnabled = YES;
	
	//Add game1ChoiceView and game2ChoiceView inside the scroll view
	[scrollView addSubview:game1ChoiceView];
	[scrollView addSubview:game2ChoiceView];
	
	
	
	//Construct an array of user names based on the array of user IDs, and store into instance variables
	self.userIDsArray = [DataAccessDB listOfAllUserIDs];
	
    NSMutableArray *users = [[NSMutableArray alloc] init];
    [users addObject:[NSString string]]; //Add an empty row
	
	for (NSInteger i=0; i < [self.userIDsArray count]; i++ ) {
		//NSLog(@"test: %@", [DataAccessDB getUserName:[[self.userIDsArray objectAtIndex:i] intValue]]);
		[users addObject:[DataAccessDB getUserName:[[self.userIDsArray objectAtIndex:i] intValue]]];
	}
	
	self.usernamesArray = users;
	
	[users release];
	
	
	//Case where there is more than 1 user
	if ([self.userIDsArray count] > 1) {
		
		//Disable UI elements
		scrollView.userInteractionEnabled = NO;
        
        //Create and set labelAndPickerView, myPickerView, pickerLabel
		labelAndPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, 320, 200)];
		
		myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 30, 320, 170)];
		myPickerView.delegate = self;
		myPickerView.dataSource = self;
		myPickerView.showsSelectionIndicator = YES;
		//myPickerView.frame = kDatePickerOffScreen;
		
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
		
		[self.view addSubview:labelAndPickerView];
		
		//Put labelAndPickerView off screen
		labelAndPickerView.frame = kDatePickerOffScreen;
		
	}
	
	
	//Make the labelAndPickerView appear on screen animatedly as the view loads
	[UIView beginAnimations:@"Transition" context:nil];
	[UIView setAnimationDuration:0.3];

	labelAndPickerView.frame = kDatePickerOnScreen;

	[UIView commitAnimations];
	
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
			
			NSInteger userID = [[self.userIDsArray objectAtIndex:self.selectedRow] intValue];
			NSString *password = [DataAccessDB getUserPassword:userID];
			
			if ([password isEqualToString:self.passwordTextField.text]) {
				
				//Set current user ID on the delegate
				FlutterApp2AppDelegate *delegate = (FlutterApp2AppDelegate *)[[UIApplication sharedApplication] delegate];
				delegate.currentUserID = userID;
				
				
				[UIView beginAnimations:@"Transition" context:nil];
				[UIView setAnimationDuration:0.3];
				
				//Put labelAndPickerView off screen
				labelAndPickerView.frame = kDatePickerOffScreen;
				
				[UIView commitAnimations];
				
				//Re-enable UI elements
				scrollView.userInteractionEnabled = YES;
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






- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [webController release];
}





- (void)scrollViewDidScroll:(UIScrollView *)sender {	
    //Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = 320.0f;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1;
    pageControl.currentPage = page;
	//[pageControl updateCurrentPageDisplay];
	
}




- (void)dealloc {
	[scrollView release];
	//[loginView release];
	[game1ChoiceView release];
	[game2ChoiceView release];
    [super dealloc];
}



//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}


@end
