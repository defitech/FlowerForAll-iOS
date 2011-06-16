//
//  StatisticListViewController.m
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	Implementation of the StatisticListViewController class


#import "FlutterApp2AppDelegate.h"

#import "StatisticListViewController.h"
#import "StatisticDetailViewController.h"
#import "MonthStatisticListViewController.h"
#import "YearStatisticListViewController.h"

#import "DataAccessDB.h"
#import "DateClassifier.h"
#import "DateClassificationResult.h"

#import "Exercise.h"

#import "StatisticCell.h"

//#import <QuartzCore/QuartzCore.h>


@implementation StatisticListViewController


@synthesize datesArray, timesArray, goodPercentagesArray, transferStatusesArray, switchToDeleteMode, statisticDetailViewController, statisticListTableView, currentlySelectedRow, exercisesIDArray, pastYears, pastMonths, monthStatisticListViewController, yearStatisticListViewController, currentUserID;



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
	self.title = NSLocalizedString(@"StatisticListViewTitle", @"Title of the statistic list view");
	statisticListTableView.scrollEnabled = NO;
	//self.switchToDeleteMode = NO;
	
	
	//Get the app delegate in order to get the current user ID
	FlutterApp2AppDelegate *delegate = (FlutterApp2AppDelegate *)[[UIApplication sharedApplication] delegate];
	self.currentUserID = delegate.currentUserID;
	
	
	//Get all dateTimes in order to organize them hierarchically
	NSArray *dateTimes = [DataAccessDB listOfUserExerciseDates:self.currentUserID];
	DateClassificationResult *dateClassificationResult = [DateClassifier classifyDates:dateTimes];
	self.pastYears = dateClassificationResult.pastYears;
	self.pastMonths = dateClassificationResult.pastMonths;
	
	
	//Get the list of all exercises for the current user FOR THE CURRENT MONTH AND YEAR, in order to display them (because the others have been classified in past months and past years, and will be displayed by child controllers, not here).
	NSArray *exercises = [DataAccessDB listOfUserExercisesInMonthAndYear:self.currentUserID:[DateClassifier getCurrentMonth]:[DateClassifier getCurrentYear]];
	
	
	//Fill arrays with exercise data just obtained from the DB (for current month and year only)
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
	
	
	//Delete button
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






//Called when popping a child view controller. Ensure table is correctly reloaded.
- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	
	[self viewDidLoad];
	[self.statisticListTableView reloadData];
	
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
    // Return the number of sections.
    return 1;
}


//The table contains the exercises of the current month and year, the past months, and the past years that do have exercises for the current user.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.datesArray count]+[self.pastYears count]+[self.pastMonths count];
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
	
	
	//Exercises for the current month and year
	if (row < [self.datesArray count]) {
		
		cell.primaryLabel.text = [datesArray objectAtIndex:row];
		cell.secondaryLabel.text = [timesArray objectAtIndex:row];
		cell.thirdLabel.text = [[goodPercentagesArray objectAtIndex:row] stringByAppendingString:@"%"];
	
		if ([[transferStatusesArray objectAtIndex:row] intValue] == 0) {
			[cell.aSwitch setOn:NO animated:NO];
		}
		else if ([[transferStatusesArray objectAtIndex:row] intValue] == 1){
			[cell.aSwitch setOn:YES animated:NO];
		}
	
		if (switchToDeleteMode == YES) {
			//[UIView beginAnimations:@"test" context:nil];
			//[UIView setAnimationDuration:1];
		
			//For some reason, it seems that the background color property of a uilabel view cannot be animated without using the QuartzCore framework
			[cell.contentView setBackgroundColor:[UIColor lightGrayColor]];
			[cell.primaryLabel setBackgroundColor:[UIColor lightGrayColor]];
			[cell.secondaryLabel setBackgroundColor:[UIColor lightGrayColor]];
			[cell.thirdLabel setBackgroundColor:[UIColor lightGrayColor]];
		
			//[UIView commitAnimations];
		
			/*[UIView beginAnimations:@"test" context:nil];
			 [UIView setAnimationDuration:1];
			 cell.primaryLabel.layer.backgroundColor = [UIColor yellowColor].CGColor;
			 [UIView commitAnimations];*/
		
			/*cell.primaryLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
		
			 [UIView animateWithDuration:2.0 animations:^{
				cell.primaryLabel.layer.backgroundColor = [UIColor yellowColor].CGColor;
			 } completion:NULL];*/
		
		}
		else {
		
			[cell.contentView setBackgroundColor:[UIColor whiteColor]];
			[cell.primaryLabel setBackgroundColor:[UIColor whiteColor]];
			[cell.secondaryLabel setBackgroundColor:[UIColor whiteColor]];
			[cell.thirdLabel setBackgroundColor:[UIColor whiteColor]];
		
		}

		
	}
	
	//Past months
	else if(row < [self.datesArray count] + [self.pastMonths count]){

		cell.primaryLabel.text = [DateClassifier getMonthName:[[self.pastMonths objectAtIndex:(row - [self.datesArray count])] intValue]];
		cell.secondaryLabel.text = @"";
		cell.thirdLabel.text = @"";
		[cell.aSwitch setHidden:YES];
		
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
		
	}
	
	//Past years
	else if(row < [self.datesArray count] + [self.pastMonths count] + [self.pastYears count]){
		
		cell.primaryLabel.text = [self.pastYears objectAtIndex:(row - [self.datesArray count] - [self.pastMonths count])];
		cell.secondaryLabel.text = @"";
		cell.thirdLabel.text = @"";
		[cell.aSwitch setHidden:YES];
		
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
	
	//Update self.currentlySelectedRow field
	self.currentlySelectedRow = row;
	
	//Exercises for the current month and year
	if (row < [self.datesArray count]) {
	
		if (switchToDeleteMode == YES) {
		
			UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteExerciseAlertLabel", @"Label of the delete exercise alert") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DeleteExerciseAlertCancelButtonLabel", @"Label of the cancel button label on the delete exercise alert") otherButtonTitles:NSLocalizedString(@"DeleteExerciseAlertOKButtonLabel", @"Label of the OK button label on the delete exercise alert"), nil];
			[myAlertView show];
			[myAlertView release];
		
		}
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
	
	//Past months
	else if(row < [self.datesArray count] + [self.pastMonths count]){
		
		if (switchToDeleteMode == YES) {
			
			UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteExerciseAlertLabel", @"Label of the delete exercise alert") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DeleteExerciseAlertCancelButtonLabel", @"Label of the cancel button label on the delete exercise alert") otherButtonTitles:NSLocalizedString(@"DeleteExerciseAlertOKButtonLabel", @"Label of the OK button label on the delete exercise alert"), nil];
			[myAlertView show];
			[myAlertView release];
			
		}
		else {
			
			//if (self.userDetailViewController == nil){														/////ATTENTION!!!!
			MonthStatisticListViewController *aMonthStatisticList = [[MonthStatisticListViewController alloc] initWithNibName:@"StatisticListView" bundle:nil extraParameter:[[self.pastMonths objectAtIndex:(row - [self.datesArray count])] intValue]:[DateClassifier getCurrentYear]:NO];
			self.monthStatisticListViewController = aMonthStatisticList;
			[aMonthStatisticList release];
			//}
			
			monthStatisticListViewController.title = [DateClassifier getMonthName:[[self.pastMonths objectAtIndex:(row - [self.datesArray count])] intValue]];
			
			
			[[FlowerController getStatisticsViewController]  pushViewController:monthStatisticListViewController animated:YES];
			
		}

	}
	
	//Past years
	else if(row < [self.datesArray count] + [self.pastMonths count] + [self.pastYears count]){
		
		if (switchToDeleteMode == YES) {
			
			UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteExerciseAlertLabel", @"Label of the delete exercise alert") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"DeleteExerciseAlertCancelButtonLabel", @"Label of the cancel button label on the delete exercise alert") otherButtonTitles:NSLocalizedString(@"DeleteExerciseAlertOKButtonLabel", @"Label of the OK button label on the delete exercise alert"), nil];
			[myAlertView show];
			[myAlertView release];
			
		}
		else {
		
			//if (self.userDetailViewController == nil){														/////ATTENTION!!!!
			YearStatisticListViewController *aYearStatisticList = [[YearStatisticListViewController alloc] initWithNibName:@"StatisticListView" bundle:nil extraParameter:[[self.pastYears objectAtIndex:(row - [self.datesArray count] - [self.pastMonths count])] intValue]];
			self.yearStatisticListViewController = aYearStatisticList;
			[aYearStatisticList release];
			//}
		
			yearStatisticListViewController.title = [NSString stringWithFormat:@"i", [[self.pastYears objectAtIndex:(row - [self.datesArray count] - [self.pastMonths count])] intValue] ] ;
		
			[[FlowerController getStatisticsViewController]  pushViewController:yearStatisticListViewController animated:YES];
	
		}
	}
}






//Delete the exercise (or the corresponding set of exercises, if the deleted cell is a past month or a past year) when clicked on the OK button
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1){
		
		//Exercises for the current month and year
		if (self.currentlySelectedRow < [self.datesArray count]) {
		
			//Delete the exercise
			NSInteger exerciseId = [[exercisesIDArray objectAtIndex:self.currentlySelectedRow] intValue];
		
			[DataAccessDB deleteExercise:exerciseId];
		
			[self viewDidLoad];
			[self.statisticListTableView reloadData];
		
		}
		
		//Past months
		else if(self.currentlySelectedRow < [self.datesArray count] + [self.pastMonths count]){
			
			[DataAccessDB deleteUserExercisesInMonthAndYear:self.currentUserID:[[self.pastMonths objectAtIndex:(self.currentlySelectedRow - [self.datesArray count])] intValue]:[DateClassifier getCurrentYear] ];
			
			[self viewDidLoad];
			[self.statisticListTableView reloadData];
			
		}
		
		//Past years
		else if(self.currentlySelectedRow < [self.datesArray count] + [self.pastMonths count] + [self.pastYears count]){
			
			[DataAccessDB deleteUserExercisesInYear:self.currentUserID:[[self.pastYears objectAtIndex:(self.currentlySelectedRow - [self.datesArray count] - [self.pastMonths count])] intValue] ];
			
			[self viewDidLoad];
			[self.statisticListTableView reloadData];
			
		}
		
	}
	
}


-(void)lineStyleDidChange:(CPLineStyle *)lineStyle {
    NSLog(@"StatDetailView lineStyleDidChange.. what does this stand for??");
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
	[transferStatusesArray release];
	[statisticDetailViewController release];
    [super dealloc];
}



//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}


@end

