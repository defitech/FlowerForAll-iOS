//
//  UserListViewController.m
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the UserListViewController class


#import "FlutterApp2AppDelegate.h"

#import "UserListViewController.h"
#import "UserDetailViewController.h"

#import "DataAccessDB.h"


@implementation UserListViewController


@synthesize usersArray, usersIDArray, userDetailViewController, newUserTextField, userListTableView;




#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/





#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	
	//Set title, disable scrolling (at least for the moment)
	self.title = NSLocalizedString(@"UserListViewTitle", @"Title of the user list view");
	userListTableView.scrollEnabled = NO;
	
	
	//Get an array of all user IDs from the DB, and assign it to self.usersIDArray
	self.usersIDArray = [DataAccessDB listOfAllUserIDs];
	
	
	//Construct an array of user names based on the array of user IDs (by querying them in the DB), and assign it to self.usersArray
	NSMutableArray *users = [[NSMutableArray alloc] init];

	for (NSInteger i=0; i < [self.usersIDArray count]; i++ ) {
		[users addObject:[DataAccessDB getUserName:[[self.usersIDArray objectAtIndex:i] intValue]]];
	}
	
	self.usersArray = users;

	[users release];
	
	
	//Create Add user button and bind it to addUser method. Add the button to the UI only if the current user is the main user (with 0 ID).
	FlutterApp2AppDelegate *delegate = (FlutterApp2AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSInteger currentUserID = delegate.currentUserID;
	
	if (currentUserID == 0) {
		UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"AddUserbuttonLabel",@"Label of the add user button") style:UIBarButtonItemStylePlain target:self action:@selector(addUser)];          
		self.navigationItem.rightBarButtonItem = anotherButton;
		[anotherButton release];
	}
	
}





//Display an alert view when the user pushes on the add button
- (void)addUser {
	
	UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AddUserAlertLabel", @"Label of the add user alert") message:@"this gets covered" delegate:self cancelButtonTitle:NSLocalizedString(@"AddUserAlertCancelButtonLabel", @"Label of the cancel button label on the add user alert") otherButtonTitles:NSLocalizedString(@"AddUserAlertOKButtonLabel", @"Label of the OK button label on the add user alert"), nil];
	self.newUserTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
	[self.newUserTextField setBackgroundColor:[UIColor whiteColor]];
	[myAlertView addSubview:self.newUserTextField];
	[myAlertView show];
	[myAlertView release];
}





//Create the new user if clicked on the OK button of the alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1){

		if ( self.newUserTextField.text.length != 0 ) {
		
			NSInteger newID = [DataAccessDB generateUserID];
			//NSLog(@"NSInteger value userlist ctrl :%i", newID);
			[DataAccessDB createUser:newID:self.newUserTextField.text:self.newUserTextField.text];
		
			[self viewDidLoad];
			[self.userListTableView reloadData];
			
		}
	}
}





//Reload table data when view appears
- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	[self viewDidLoad];
	[self.userListTableView reloadData];

}






/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/






#pragma mark -
#pragma mark Table view data source

//Only 1 section in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



//The table contains the users
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.usersArray count];
}




// Customize the appearance of table view cells.

//Fill the cells using self.usersArray array. The appearance of the cells have to depend on the current user actually using the application:
//The main user (with ID 0) has access to all users, which means all cells are enabled.
//The other users have only access to their own users (i.e., the corresponding cell only is enabled)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	
	NSUInteger row = [indexPath row];
    
	//Get current userID
	FlutterApp2AppDelegate *delegate = (FlutterApp2AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSInteger currentUserID = delegate.currentUserID;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		//Check if the actual user is the main one
		if (currentUserID != 0) {
			//If it is not the case, and if the cell does not correspond to the actual user, then the cell is disabled
			if (currentUserID != [[usersIDArray objectAtIndex:row] intValue]) {
				cell.userInteractionEnabled = NO;
				cell.textLabel.textColor = [UIColor grayColor];
			}
			//If it is not the case, and if the cell does correspond to the actual user, then the cell is enabled normally
			else {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
		//If it is the case, all cells are enabled normally.
		else {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}

    }
    
	
    // Configure the cell...
	cell.textLabel.text = [usersArray objectAtIndex:row];
	
	
    return cell;
}





/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/






#pragma mark -
#pragma mark Table view delegate

//Pushed the user detail view when a row is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger row = [indexPath row];
	
	//if (self.userDetailViewController == nil){
	UserDetailViewController *aUserDetail = [[UserDetailViewController alloc] initWithNibName:@"UserDetailView" bundle:nil extraParameter:[[usersIDArray objectAtIndex:row] intValue]];
	self.userDetailViewController = aUserDetail;
	[aUserDetail release];
	//}
	
	userDetailViewController.title = [NSString stringWithFormat:@"%@", [usersArray objectAtIndex:row]];
	
	[[FlowerController getSettingsViewController]  pushViewController:userDetailViewController animated:YES];
	
}




#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[userDetailViewController release];
    [super dealloc];
}



//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}



@end

