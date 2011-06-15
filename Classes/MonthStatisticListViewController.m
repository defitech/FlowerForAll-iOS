//
//  MonthStatisticListViewController.m
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the MonthStatisticListViewController class


#import "FlutterApp2AppDelegate.h"

#import "MonthStatisticListViewController.h"
#import "StatisticDetailViewController.h"
#import "StatisticsViewController.h"
#import "FlowerController.h"

#import "DataAccessDB.h"

#import "DateClassifier.h"
#import "DateClassificationResult.h"

#import "StatisticCell.h"

#import "Exercise.h"

//#import <QuartzCore/QuartzCore.h>



@implementation MonthStatisticListViewController


@synthesize datesArray, timesArray, goodPercentagesArray, transferStatusesArray, switchToDeleteMode, statisticDetailViewController, statisticListTableView, currentlySelectedRow, exercisesIDArray, currentMonth, currentYear, popTwoTimes;




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




//Initializes a MonthStatisticListViewController with parameters currentMonth, currentYear and popTwoTimes (store them in corresponding instance fields)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSInteger)_currentMonth:(NSInteger)_currentYear:(BOOL)_popTwoTimes{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization.
		self.currentMonth = _currentMonth;
		self.currentYear = _currentYear;
		self.popTwoTimes = _popTwoTimes;
	}
	return self;
}




#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	//Set title, disable scrolling (at least for the moment)
	self.title = [DateClassifier getMonthName:self.currentMonth];
	statisticListTableView.scrollEnabled = NO;
	//self.switchToDeleteMode = NO;
	
	
	//Get the app delegate in order to get the current user ID
	FlutterApp2AppDelegate *delegate = (FlutterApp2AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSInteger currentUserID = delegate.currentUserID;
	
	
	//Get the list of all exercises for the current user and for the current month and year
	NSArray *exercises = [DataAccessDB listOfUserExercisesInMonthAndYear:currentUserID:self.currentMonth:self.currentYear];

	
	//Pop the actual view controller if all rows have been deleted
	if ([exercises count] == 0) {
		
		//If this MonthStatisticListViewController is embedded in the main StatisticListViewController (popTwoTimes == NO),
		//then pop only one time.
		if (popTwoTimes == NO) {
			[[FlowerController getStatisticsViewController] popViewControllerAnimated:YES];
		}
		//If this MonthStatisticListViewController is embedded in a YearStatisticListViewController (popTwoTimes == YES),
		//then pop two times.
		else {
			//int count = [delegate.statisticsViewController.viewControllers count];
			//NSLog(@"view controller count: %i", count);
			[[FlowerController getStatisticsViewController] 
                popToViewController:[[FlowerController getStatisticsViewController].viewControllers objectAtIndex:0] animated:YES];
		}

	}
	
	
	//Fill arrays (instance fields) with exercise data just obtained from the DB
	self.exercisesIDArray = [[NSMutableArray alloc] init];
	self.datesArray = [[NSMutableArray alloc] init];
	self.timesArray = [[NSMutableArray alloc] init];
	self.goodPercentagesArray = [[NSMutableArray alloc] init];
	self.transferStatusesArray = [[NSMutableArray alloc] init];
	
	for (NSInteger i=0; i < [exercises count]; i++ ) {
		Exercise *ex = [exercises objectAtIndex:i];
		
		NSTimeInterval timeInt = ex.dateTime;
		NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:timeInt];
		
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateFormat:@"dd.MM.yyyy"];
		
		NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[timeFormatter setDateFormat:@"HH:mm:ss"];
		
		NSString *formattedDate = [dateFormatter stringFromDate:dateTime];
		NSString *formattedTime = [timeFormatter stringFromDate:dateTime];
		
		[self.exercisesIDArray addObject:[NSString stringWithFormat:@"%i", ex.exerciseId]];
		[self.datesArray addObject:[NSString stringWithFormat:@"%@", formattedDate]];
		[self.timesArray addObject:[NSString stringWithFormat:@"%@", formattedTime]];
		[self.goodPercentagesArray addObject:[NSString stringWithFormat:@"%g", ex.goodPercentage*100.0]];
		[self.transferStatusesArray addObject:[NSString stringWithFormat:@"%i", ex.transferStatus]];
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







/*- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	[self viewDidLoad];
	[self.statisticListTableView reloadData];
 
}*/

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


//The table contains only the exercises for the current month and year
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.datesArray count];
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
	
	//Set texts of the cells
	cell.primaryLabel.text = [datesArray objectAtIndex:row];
	cell.secondaryLabel.text = [timesArray objectAtIndex:row];
	cell.thirdLabel.text = [[goodPercentagesArray objectAtIndex:row] stringByAppendingString:@"%"];
	
	//Set the switch of the cell
	if ([[transferStatusesArray objectAtIndex:row] intValue] == 0) {
		[cell.aSwitch setOn:NO animated:NO];
	}
	else if ([[transferStatusesArray objectAtIndex:row] intValue] == 1){
		[cell.aSwitch setOn:YES animated:NO];
	}
	
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
	
	if (row < [self.datesArray count]) {
		
		//If we are in delete mode, ask the user a confirmation before deleting the corresponding row
		if (switchToDeleteMode == YES) {
			
			self.currentlySelectedRow = row;
			
			UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteExerciseAlertLabel", @"Label of the delete exercise alert") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DeleteExerciseAlertCancelButtonLabel", @"Label of the cancel button label on the delete exercise alert") otherButtonTitles:NSLocalizedString(@"DeleteExerciseAlertOKButtonLabel", @"Label of the OK button label on the delete exercise alert"), nil];
			[myAlertView show];
			[myAlertView release];
			
		}
		//Else, push a StatisticDetailViewController
		else {
			
			//if (self.statisticDetailViewController == nil){
			StatisticDetailViewController *aStatisticDetail = [[StatisticDetailViewController alloc] initWithNibName:@"StatisticDetailView" bundle:nil extraParameter:[[self.exercisesIDArray objectAtIndex:row] intValue] ];
			self.statisticDetailViewController = aStatisticDetail;
			[aStatisticDetail release];
			//}
			
			statisticDetailViewController.title = [NSString stringWithFormat:@"%@", [datesArray objectAtIndex:row]];
			
			
			
			[[FlowerController getStatisticsViewController] pushViewController:statisticDetailViewController animated:YES];
			
		}
		
	}
	

}





//Delete the exercise when confirmed by the user (by pushing the OK button)
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1){
		
		//Delete the exercise
		NSInteger exerciseId = [[exercisesIDArray objectAtIndex:self.currentlySelectedRow] intValue];
		
		[DataAccessDB deleteExercise:exerciseId];
		
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
	[exercisesIDArray release];
	[datesArray release];
	[timesArray release];
	[goodPercentagesArray release];
	[transferStatusesArray release];
	[statisticDetailViewController release];
    [super dealloc];
}




//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}


@end

