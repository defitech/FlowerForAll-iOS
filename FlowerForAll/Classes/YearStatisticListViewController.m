//
//  StatisticListViewController.m
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the StatisticListViewController


#import "FlutterApp2AppDelegate.h"

#import "YearStatisticListViewController.h"
#import "MonthStatisticListViewController.h"
#import "StatisticCell.h"

#import "DataAccessDB.h"

#import "DateClassifier.h"
#import "DateClassificationResult.h"

#import "Exercise.h"

//#import <QuartzCore/QuartzCore.h>


@implementation YearStatisticListViewController


@synthesize switchToDeleteMode, statisticListTableView, currentlySelectedRow, months, currentYear, monthStatisticListViewController, currentUserID, dateTimes;




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




//Initializes a MonthStatisticListViewController with parameter currentYear (store it in corresponding instance fields)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSInteger)_currentYear{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization.
		//Init the YearStatisticListViewController with the current year
		self.currentYear = _currentYear;
	}
	return self;
}




#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	//Set title, disable scrolling (at least for the moment)
	self.title = [NSString stringWithFormat:@"%i", self.currentYear];
	statisticListTableView.scrollEnabled = NO;
	//self.switchToDeleteMode = NO;
	
	
	//Get the app delegate in order to get the current user ID
	FlutterApp2AppDelegate *delegate = (FlutterApp2AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.currentUserID = delegate.currentUserID;
	
	
	//Get the dateTimes of all user exercises in the current year
	self.dateTimes = [DataAccessDB listOfUserExerciseDatesInYear:self.currentUserID:self.currentYear];
	
	
	//Pop the actual view controller if all rows have been deleted
	if ([self.dateTimes count] == 0) {
		[[FlowerController getStatisticsViewController] popViewControllerAnimated:YES];
	}
	
	
	//Get all months that do actually have exercise during the year 
	//Put them in the self.months array (test before if they already exist in the array, to avoid multiple occurrences)
	self.months = [[[NSMutableArray alloc] init] autorelease];
	for (int i=0; i <[dateTimes count]; i++) {
		NSString *monthStr = [NSString stringWithFormat:@"%i", [DateClassifier getMonthGivenAdate:[[dateTimes objectAtIndex:i] intValue]]];
		if (![self.months containsObject: monthStr]) {
			[self.months addObject:monthStr];
		}
	}
	
	
	//Add the delete button with a different style depending on if we are in delete mode or not
	UIBarButtonItem *anotherButton; 
	if (switchToDeleteMode == NO) {
		anotherButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DeleteStatisticButtonLabel", @"Label of the delete statistic button") style:UIBarButtonItemStylePlain target:self action:@selector(deleteExercise)];
	}
	else {
		anotherButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DeleteStatisticButtonLabel", @"Label of the delete statistic button") style:UIBarButtonItemStyleDone target:self action:@selector(deleteExercise)];
	}
	self.navigationItem.rightBarButtonItem = anotherButton;
	[anotherButton release];
	
}







//Called when the user pushes the Delete button. The method then switches between delete and normal modes, and reloads the table data.
- (void)deleteExercise {
	
	if (switchToDeleteMode == NO) {
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
		switchToDeleteMode = YES;
		[self.statisticListTableView reloadData];
	}
	else {
		self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
		switchToDeleteMode = NO;
		[self.statisticListTableView reloadData];
	}
	
	
}






//Need to implement this method because of the following case: if the last exercise in the child controller has been deleted,
//the view has to be refreshed in order to not display again the month that contains no more exercise.
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/*if ([self.dateTimes count] == 0) {
		FlutterApp2AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate.statisticsViewController popViewControllerAnimated:YES];
	}*/
	
	[self viewDidLoad];
	[self.statisticListTableView reloadData];
}





 /*- (void)viewDidAppear:(BOOL)animated {
	 [super viewDidAppear:animated];
	 self.dateTimes = [DataAccessDB listOfUserExerciseDatesInYear:self.currentUserID:self.currentYear];
	 NSLog(@"yeahyeahyeah1111111111");
	 NSLog(@"self date times count: %i", [self.dateTimes count]);
	 if ([self.dateTimes count] == 0) {
		 NSLog(@"yeahyeahyeah222222222");
		 FlutterApp2AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		 [delegate.statisticsViewController popViewControllerAnimated:YES];
	 }
 }*/
 
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


//The table contains only the exercises for the current month and year
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.months count];
}





// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //Use statistic cell instead of standard UITableViewCell
	StatisticCell *cell = (StatisticCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		cell = [[[StatisticCell alloc] initWithFrame:CGRectZero reuseIdentifier: CellIdentifier] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
	
    // Configure the cell...
	
	NSUInteger row = [indexPath row];
	
		
	cell.primaryLabel.text = [DateClassifier getMonthName:[[self.months objectAtIndex:row] intValue]];
	[cell.aSwitch setHidden:YES];
		

	//Set the color of the cell depending on whether we are in delete mode or not	
	if (switchToDeleteMode == YES) {

		[cell.contentView setBackgroundColor:[UIColor lightGrayColor]];
		[cell.primaryLabel setBackgroundColor:[UIColor lightGrayColor]];
		[cell.secondaryLabel setBackgroundColor:[UIColor lightGrayColor]];
		[cell.thirdLabel setBackgroundColor:[UIColor lightGrayColor]];
			
	}
	else {
			
		[cell.contentView setBackgroundColor:[UIColor whiteColor]];
		[cell.primaryLabel setBackgroundColor:[UIColor whiteColor]];
		[cell.secondaryLabel setBackgroundColor:[UIColor whiteColor]];
		[cell.thirdLabel setBackgroundColor:[UIColor whiteColor]];
			
	}
		
	
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
	
	NSInteger row = [indexPath row];
	
	//Stores the currently selected row
	self.currentlySelectedRow = row;
	
	//If we are in delete mode, ask the user a confirmation before deleting the corresponding row
	if (switchToDeleteMode == YES) {
		
		UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteExerciseAlertLabel", @"Label of the delete exercise alert") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DeleteExerciseAlertCancelButtonLabel", @"Label of the cancel button label on the delete exercise alert") otherButtonTitles:NSLocalizedString(@"DeleteExerciseAlertOKButtonLabel", @"Label of the OK button label on the delete exercise alert"), nil];
		[myAlertView show];
		[myAlertView release];
		
	}
	//Else, push a StatisticDetailViewController
	else {
		
		BOOL popTwoTimes;
		if ([self.months count] == 1) {
			popTwoTimes = YES;
		}
		else {
			popTwoTimes = NO;
		}

		//if (self.userDetailViewController == nil){														/////ATTENTION!!!!
		MonthStatisticListViewController *aMonthStatisticList = [[MonthStatisticListViewController alloc] initWithNibName:@"StatisticListView" bundle:nil extraParameter:[[self.months objectAtIndex:row] intValue]:self.currentYear:popTwoTimes];
		self.monthStatisticListViewController = aMonthStatisticList;
		[aMonthStatisticList release];
		//}
		
		monthStatisticListViewController.title = [DateClassifier getMonthName:[[self.months objectAtIndex:row] intValue]];
		
        [[FlowerController getStatisticsViewController] pushViewController:monthStatisticListViewController animated:YES];
	
	}

}





//Delete the exercise when confirmed by the user (by pushing the OK button)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1){
		
		[DataAccessDB deleteUserExercisesInMonthAndYear:self.currentUserID:[[self.months objectAtIndex:(self.currentlySelectedRow)] intValue]:self.currentYear ];
		
		[self viewDidLoad];
		[self.statisticListTableView reloadData];
		
	}
	
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
	[monthStatisticListViewController release];
    [super dealloc];
}




//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}


@end

