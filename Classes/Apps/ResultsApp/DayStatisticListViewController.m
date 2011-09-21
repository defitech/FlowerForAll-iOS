//
//  StatisticListViewController.m
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	Implementation of the StatisticListViewController class

#import "DayStatisticListViewController.h"

#import "DB.h"
#import "Exercise.h"

#import "StatisticCell.h"

@implementation DayStatisticListViewController

@synthesize formattedDate,dateFormatter,timeFormatter, exercises, statisticListTableView, currentlySelectedRow;


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
        [timeFormatter setDateFormat:@"HH:mm:ss"];
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
	
    [super viewDidLoad];
    NSLog(@"DayStatListViewController didload");
	
	//Set title, disable scrolling (at least for the moment)
	self.title = formattedDate;
	statisticListTableView.scrollEnabled = NO;
	
    //Fetch exercises of the day from the DB
	exercises = [DB getExercisesInDay:formattedDate];
	
}


//Called when popping a child view controller. Ensure table is correctly reloaded.
- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	
	[self viewDidLoad];
	[self.statisticListTableView reloadData];
	
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
	StatisticCell *cell = (StatisticCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		cell = [[[StatisticCell alloc] initWithFrame:CGRectZero reuseIdentifier: CellIdentifier] autorelease];
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
        cell.thirdLabel.text = [NSString stringWithFormat:@"%.2f%@", ex.duration_exercice_done_ps, @"%"];
		
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