//
//  SettingChoiceViewController.m
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	Implementation of the SettingChoiceViewController class


#import "FlutterApp2AppDelegate.h"

#import "SettingChoiceViewController.h"
#import "UserListViewController.h"
#import "GameParametersViewController.h"

#import "FlowerController.h"


@implementation SettingChoiceViewController


@synthesize settingsArray, userListViewController, gameParametersViewController;



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

	//Set the title and disable scrolling (at least for the moment)
	self.title = NSLocalizedString(@"SettingChoiceViewTitle", @"Title of the setting choice view");
	settingChoiceTableView.scrollEnabled = NO;
	
	//Set self.settingsArray with the different settings
	NSMutableArray *array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"UsersEntryLabel", @"Label of the Users entry in the settings table"), NSLocalizedString(@"ParametersEntryLabel",@"Label of the Parameters entry in the settings table"), nil];
	self.settingsArray = array;
	[array release];
	
    [self pushGameParametersViewController:NO];
}





/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
    // Return the number of sections.
    return 1;
}


//The table contains only the settings
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.settingsArray count];
}




// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
	
	//Get the cell text from self.settingsArray
	cell.textLabel.text = [settingsArray objectAtIndex:row];
	
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Setting Choice View Controller row:",indexPath);
	NSInteger row = [indexPath row];
	
	//If the first row is selected, then push a UserListViewController...
	if (row == 0){
	
		if (self.userListViewController == nil){
			UserListViewController *aUserList = [[UserListViewController alloc] initWithNibName:@"UserListView" bundle:nil];
			self.userListViewController = aUserList;
			[aUserList release];
		}

		userListViewController.title = [NSString stringWithFormat:@"%@", [settingsArray objectAtIndex:row]];

		[[FlowerController getSettingsViewController] pushViewController:userListViewController animated:YES];
		
	}
	
	//...otherwise if the second row is selected, push a GameParametersViewController.
	else if (row ==1){
		[self pushGameParametersViewController:YES];
	}

}

- (void) pushGameParametersViewController:(BOOL)animated {
    if (self.gameParametersViewController == nil){
        self.gameParametersViewController = [[GameParametersViewController alloc] initWithNibName:@"GameParametersView" bundle:nil];
        self.gameParametersViewController.title = NSLocalizedString(@"ParametersEntryLabel",@"Label of the Parameters entry in the settings table");
    }
    
    [[FlowerController getSettingsViewController] pushViewController:self.gameParametersViewController animated:animated];
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
	[userListViewController release];
	[gameParametersViewController release];
    [super dealloc];
}



//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}



@end

