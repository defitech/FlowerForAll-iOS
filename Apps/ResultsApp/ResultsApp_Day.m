//
//  StatisticListViewController.m
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	Implementation of the StatisticListViewController class

#import "ResultsApp_Day.h"

#import "DB.h"
#import "Exercise.h"

#import "ResultsApp_DayCell.h"

@implementation ResultsApp_Day

@synthesize formattedDate,dateFormatter,timeFormatter, exercises, statisticListTableView, currentlySelectedRow, modifyButton;


#pragma mark -
#pragma mark Initialization
//Initializes with extra parameter formattedDate
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSString*)_formattedDate{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    NSLog(@"DayStatListViewController initWithNibName");
	if (self) {
		// Custom initialization.
        formattedDate = _formattedDate;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [dateFormatter setDateFormat:@"dd.MM.yyyy"];
        
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [timeFormatter setDateFormat:@"HH:mm"];
        
        modifyButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Modify", @"ResultsApp", @"Label of the modify table button") style:UIBarButtonItemStylePlain target:self action:@selector(modifyTable)];
        self.navigationItem.rightBarButtonItem = modifyButton;
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
	
    [super viewDidLoad];
    NSLog(@"DayStatListViewController didload");
	
	self.title = formattedDate;
	
    //Fetch exercises of the day from the DB
	exercises = [DB getExercisesInDay:formattedDate];
	
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
        Exercise* ex = [exercises objectAtIndex:row];
        [DB deleteExercise:ex.start_ts];
        
        //Update the model here (necessary to avoid inconsistency exception)
        [exercises removeObjectAtIndex:row];
        
        //Remove row from the table view
        [statisticListTableView beginUpdates];
        [statisticListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [statisticListTableView endUpdates];
        
        if ([exercises count] == 0) {
            [[self navigationController] popViewControllerAnimated:YES];
        }
    }
}


//Called when the user pushes the modify button
- (void)modifyTable {
	
    //Set the table in edit mode or in non-edit mode
	if (statisticListTableView.editing == NO) {
        [statisticListTableView setEditing:YES animated:YES];
		modifyButton.style = UIBarButtonItemStyleDone;
        modifyButton.title = NSLocalizedStringFromTable(@"OK",@"ResultsApp",@"Label of the modify table button in edit mode");
	}
	else {
        [statisticListTableView setEditing:NO animated:YES];
		modifyButton.style = UIBarButtonItemStylePlain;
        modifyButton.title = NSLocalizedStringFromTable(@"Modify",@"ResultsApp",@"Label of the modify table button");
	}
    
}



#pragma mark -
#pragma mark Table view data source
//Only 1 section in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


//The table contains the exercises
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [exercises count];
}


// Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	//Use statistic cell instead of standard UITableViewCell
	ResultsApp_DayCell *cell = (ResultsApp_DayCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		cell = [[[ResultsApp_DayCell alloc] initWithFrame:CGRectZero reuseIdentifier: CellIdentifier] autorelease];
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSUInteger row = [indexPath row];
    
	if (row < [exercises count]) {
        
        //Format the actual time of the exercise
        Exercise* ex = [self.exercises objectAtIndex:row];
        double startTime = ex.start_ts;
        NSDate* exerciseDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:startTime];
        NSString *formattedTime = [self.timeFormatter stringFromDate:exerciseDate];
        
		cell.primaryLabel.text = formattedTime;
        cell.thirdLabel.text = [NSString stringWithFormat:@"%i%@",(int)(ex.duration_exercice_done_ps * 100.0), @"%"];
		
	}
    return cell;
}


#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger row = [indexPath row];
	
	//Update currentlySelectedRow field
	currentlySelectedRow = row;
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
	[exercises release];
    [super dealloc];
}


//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}


@end