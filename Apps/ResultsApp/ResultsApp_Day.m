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

//#import "ResultsApp_DayCell.h"

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
    
    NSUInteger row = [indexPath row];
    
    Exercise* ex = [self.exercises objectAtIndex:row];
    
    static NSString *CellIdentifier = @"PercentOnRightCell";
    
    UILabel *time;
    UILabel *duration;
    UILabel *percent;
    UILabel *profile;
    UILabel *blow;
    UILabel *blowRatio;
    
    int starAlignment = 15;
    int timeAlignment = 70;
    int blowAlignment = 163;
    int profileAlignment = 270;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    } else {
        for(UIView* subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    
    time = [[[UILabel alloc] initWithFrame:CGRectMake(timeAlignment, 3.0, 80.0, 20.0)] autorelease];
    time.font = [UIFont systemFontOfSize:20];
    time.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:time];
    
    duration = [[[UILabel alloc] initWithFrame:CGRectMake(timeAlignment, 27.0, 80.0, 10.0)] autorelease];
    duration.font = [UIFont systemFontOfSize:12];
    duration.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:duration];
    
    if (ex.duration_exercice_done_ps < 1.0){
        percent = [[[UILabel alloc] initWithFrame:CGRectMake(starAlignment, 25.0, 30.0, 15.0)] autorelease];
        percent.font = [UIFont systemFontOfSize:12];
        percent.textAlignment = UITextAlignmentLeft;
        [cell.contentView addSubview:percent];
    }
    
    blow = [[[UILabel alloc] initWithFrame:CGRectMake(blowAlignment, 6.0, 70.0, 10.0)] autorelease];
    blow.font = [UIFont boldSystemFontOfSize:12];
    blow.textColor = [UIColor grayColor];
    blow.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:blow];
    
    blowRatio = [[[UILabel alloc] initWithFrame:CGRectMake(blowAlignment, 20.0, 60.0, 16.0)] autorelease];
    blowRatio.font = [UIFont systemFontOfSize:16];
    blowRatio.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:blowRatio];
    
    profile = [[[UILabel alloc] initWithFrame:CGRectMake(profileAlignment, 6.0, 70.0, 10.0)] autorelease];
    profile.font = [UIFont boldSystemFontOfSize:12];
    profile.textColor = [UIColor grayColor];
    profile.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:profile];
    
    UIImageView* star = [UIImageView alloc];
    NSString *imagePath;
    if (ex.duration_exercice_done_ps >= 1.0){
        CGRect frame = CGRectMake(starAlignment, 8, 20, 25);
        [star initWithFrame:frame];
        [cell.contentView addSubview:star];
        imagePath = [[NSBundle mainBundle] pathForResource:@"ResultsApp-gold_star" ofType:@"png"];
    }
    else{
        CGRect frame = CGRectMake(starAlignment, 2, 20, 25);
        [star initWithFrame:frame];
        [cell.contentView addSubview:star];
        imagePath = [[NSBundle mainBundle] pathForResource:@"ResultsApp-blue_star" ofType:@"png"];
    }
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    star.image = theImage;
    

    NSDate* exerciseDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:ex.start_ts];
    NSString *formattedTime = [self.timeFormatter stringFromDate:exerciseDate];
    time.text = formattedTime;
    
    duration.text = [NSString stringWithFormat:@"%i%@", (int)(ex.stop_ts - ex.start_ts), @"s"];
    if (ex.duration_exercice_done_ps < 1.0){
        percent.text = [NSString stringWithFormat:@"%i%@",(int)(ex.duration_exercice_done_ps * 100.0), @"%"];
    }

    blow.text = NSLocalizedStringFromTable(@"Good Blows",@"ResultsApp",nil);
    blowRatio.text = [NSString stringWithFormat:@"%i %@ %i", ex.blow_star_count, NSLocalizedStringFromTable(@"Over",@"ResultsApp",nil), ex.blow_count];
    profile.text = ex.profile_name;
    
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