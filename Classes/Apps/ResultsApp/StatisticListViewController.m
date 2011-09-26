//
//  StatisticListViewController.m
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	Implementation of the StatisticListViewController class

#import "DayStatisticListViewController.h"
#import "StatisticListViewController.h"

#import "DB.h"
#import "ExerciseDay.h"

#import "StatisticCell.h"

@implementation StatisticListViewController

@synthesize dayStatisticListViewController, exerciseDays, statisticListTableView, currentlySelectedRow, modifyButton;


#pragma mark -
#pragma mark Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    NSLog(@"StatListViewController initWithNibName");
	if (self) {
		// Custom initialization.
        modifyButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"ModifyTableButtonLabel", @"ResultsApp", @"Label of the modify table button") style:UIBarButtonItemStylePlain target:self action:@selector(modifyTable)];
        self.navigationItem.rightBarButtonItem = modifyButton;
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLog(@"StatListViewController didload");
	
    self.title = NSLocalizedStringFromTable(@"StatisticListViewTitle",@"ResultsApp",@"Title of the statistic list view");
	
	//Fetch list of all days from the DB
	exerciseDays = [DB getDays];
    
}


//Called when popping a child view controller. Ensure table is correctly reloaded.
- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	
	[self viewDidLoad];
	[self.statisticListTableView reloadData];
	
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
        return UITableViewCellEditingStyleDelete;
}


//Called when the user confirms deletion of a row
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //Remove exercises of the given day
        ExerciseDay* day = [exerciseDays objectAtIndex:row];
        [DB deleteDay:day.formattedDate];
        
        //Update the model here (necessary to avoid inconsistency exception)
        [exerciseDays removeObjectAtIndex:row];
        
        //Remove row from the table view
        [statisticListTableView beginUpdates];
        [statisticListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [statisticListTableView endUpdates];
    }
}



//Called when the user pushes the modify button
- (void)modifyTable {
	
    //Set the table in edit mode or in non-edit mode
	if (statisticListTableView.editing == NO) {
        [statisticListTableView setEditing:YES animated:YES];
		modifyButton.style = UIBarButtonItemStyleDone;
        modifyButton.title = NSLocalizedStringFromTable(@"ModifyTableButtonLabelInEditMode",@"ResultsApp",@"Label of the modify table button in edit mode");
	}
	else {
        [statisticListTableView setEditing:NO animated:YES];
		modifyButton.style = UIBarButtonItemStylePlain;
        modifyButton.title = NSLocalizedStringFromTable(@"ModifyTableButtonLabel",@"ResultsApp",@"Label of the modify table button");
	}
    
}



#pragma mark -
#pragma mark Table view data source

//Only 1 section in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


//The table contains the exercises days
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [exerciseDays count];
}


// Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	//Use statistic cell instead of standard UITableViewCell
	StatisticCell *cell = (StatisticCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		cell = [[[StatisticCell alloc] initWithFrame:CGRectZero reuseIdentifier: CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSUInteger row = [indexPath row];
	
	//Exercises for the current month and year
	if (row < [exerciseDays count]) {
        ExerciseDay* day = [exerciseDays objectAtIndex:row];
		cell.primaryLabel.text = day.formattedDate;
		
	}
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSInteger row = [indexPath row];

	//Update self.currentlySelectedRow field
	self.currentlySelectedRow = row;

	//Exercises for the current month and year
	if (row < [exerciseDays count]) {

        ExerciseDay* day = [exerciseDays objectAtIndex:row];

		//if (dayStatisticListViewController == nil){
        dayStatisticListViewController = [[DayStatisticListViewController alloc] initWithNibName:@"StatisticListView" bundle:nil extraParameter:day.formattedDate];
		//}
		
		[[self navigationController] pushViewController:dayStatisticListViewController animated:YES];
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
	[exerciseDays release];
    [dayStatisticListViewController release];
    [super dealloc];
}


//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}


@end