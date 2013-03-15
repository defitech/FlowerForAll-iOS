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
		// Custom initialization. Initialize formattedDate, date and time formatters and modifyButton
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


//The editing style of the table is always the delete style
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


//Called when the user confirms deletion of a row
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //Remove exercises of the given day
        [DB deleteExercise:(Exercise*)[exercises objectAtIndex:row]];
        
        //Update the model here (necessary to avoid inconsistency exception)
        [exercises removeObjectAtIndex:row];
        
        //Remove row from the table view
        [statisticListTableView beginUpdates];
        [statisticListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [statisticListTableView endUpdates];
        
        //If all exercises of the day are deleted, pop the view controller
        if ([exercises count] == 0) {
            [[self navigationController] popViewControllerAnimated:YES];
        }
    }
}


//Called when the user pushes the modify button
- (void)modifyTable {
	
    //Set the table in edit mode or, in the contrary, in non-edit mode
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


//Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    
    //Get the exercise corresponding to the current cell
    Exercise* ex = [self.exercises objectAtIndex:row];
    
    static NSString *CellIdentifier = @"PercentOnRightCell";
    
    //Labels in the cell
    UILabel *time;
    UILabel *duration;
    UILabel *percent;
    UILabel *profile;
    UILabel *blow;
    UILabel *blowRatio;
    UILabel *avgFrequency;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //If the cell is nil, create it, otherwise remove all its subviews
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    else {
        for(UIView* subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    
    //Get cell dimensions. All elements placed in the cell will then be placed relatively to those dimensions
    float cellHeight = 44.0; //to keep the police size on the ipad when scrolling
    float cellWidth = 320.0; //to keep the police size on the ipad when scrolling
    
    float starAlignment = cellWidth/21.33;
    float timeAlignment = cellWidth/4.57;
    
    float blowAlignment;
    //Change blowAlignment if the current language is french 
    NSString* currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([currentLanguage isEqualToString:@"fr"]){
        blowAlignment = cellWidth/2.1;
    }
    else{
        blowAlignment = cellWidth/1.96;
    }
    
    float profileAlignment = cellWidth/1.18;
    
    //Place and format labels
    time = [[[UILabel alloc] initWithFrame:CGRectMake(timeAlignment, cellHeight/14.66, cellWidth/4.0, cellHeight/2.2)] autorelease];
    time.font = [UIFont systemFontOfSize:cellWidth/16.0];
    time.textAlignment = UITextAlignmentLeft;
    time.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:time];
    
    duration = [[[UILabel alloc] initWithFrame:CGRectMake(timeAlignment, cellHeight/1.63, cellWidth/4.0, cellHeight/4.4)] autorelease];
    duration.font = [UIFont systemFontOfSize:cellWidth/26.66];
    duration.textAlignment = UITextAlignmentLeft;
    duration.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:duration];
    
    if (ex.duration_exercice_done_ps < 1.0){
        percent = [[[UILabel alloc] initWithFrame:CGRectMake(starAlignment, cellHeight/1.76, cellWidth/10.66, cellHeight/2.93)] autorelease];
        percent.font = [UIFont systemFontOfSize:cellWidth/26.66];
        percent.textAlignment = UITextAlignmentLeft;
        percent.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:percent];
    }
    
    blow = [[[UILabel alloc] initWithFrame:CGRectMake(blowAlignment, cellHeight/7.33, cellWidth/3.3, cellHeight/4.4)] autorelease];
    blow.font = [UIFont boldSystemFontOfSize:cellWidth/26.66];
    blow.textColor = [UIColor grayColor];
    blow.textAlignment = UITextAlignmentLeft;
    blow.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:blow];
    
    blowRatio = [[[UILabel alloc] initWithFrame:CGRectMake(blowAlignment, cellHeight/2.2, cellWidth/5.33, cellHeight/2.75)] autorelease];
    blowRatio.font = [UIFont systemFontOfSize:cellWidth/20.0];
    blowRatio.textAlignment = UITextAlignmentLeft;
    blowRatio.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:blowRatio];
    
    
    avgFrequency = [[[UILabel alloc] initWithFrame:CGRectMake(profileAlignment, cellHeight/2.2, cellWidth/5.33, cellHeight/2.75)] autorelease];
    avgFrequency.font = [UIFont systemFontOfSize:cellWidth/26.6];
    avgFrequency.textAlignment = UITextAlignmentLeft;
    avgFrequency.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:avgFrequency];
    
    profile = [[[UILabel alloc] initWithFrame:CGRectMake(profileAlignment, cellHeight/7.33, cellWidth/4.57, cellHeight/4.4)] autorelease];
    profile.font = [UIFont boldSystemFontOfSize:cellWidth/26.66];
    profile.textColor = [UIColor grayColor];
    profile.textAlignment = UITextAlignmentLeft;
    profile.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:profile];
    
    //Place stars on the left of the screen: a blue star (with the exercise percentage) if the exercise is below 100%;
    //A gold star (without percentage) if the exercise is at 100%
    UIImageView* star = [UIImageView alloc];
    NSString *imagePath;
    if (ex.duration_exercice_done_ps >= 1.0){
        CGRect frame = CGRectMake(starAlignment, cellHeight/5.5, cellWidth/16.0, cellHeight/1.76);
        [star initWithFrame:frame];
        [cell.contentView addSubview:star];
        imagePath = [[NSBundle mainBundle] pathForResource:@"ResultsApp-gold_star" ofType:@"png"];
    }
    else{
        CGRect frame = CGRectMake(starAlignment, cellHeight/22.0, cellWidth/16.0, cellHeight/1.76);
        [star initWithFrame:frame];
        [cell.contentView addSubview:star];
        imagePath = [[NSBundle mainBundle] pathForResource:@"ResultsApp-blue_star" ofType:@"png"];
    }
    UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
    star.image = theImage;
    
    //Set text in the labels
    NSDate* exerciseDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:ex.start_ts];
    NSString *formattedTime = [self.timeFormatter stringFromDate:exerciseDate];
    time.text = formattedTime;
    
    duration.text = [NSString stringWithFormat:@"%i%@", (int)(ex.stop_ts - ex.start_ts), @"s"];
    if (ex.duration_exercice_done_ps < 1.0){
        percent.text = [NSString stringWithFormat:@"%i%@",(int)(ex.duration_exercice_done_ps * 100.0), @"%"];
    }

    blow.text = NSLocalizedStringFromTable(@"Good Blows",@"ResultsApp",nil);
    blowRatio.text = [NSString stringWithFormat:@"%i %@ %i", ex.blow_star_count, NSLocalizedStringFromTable(@"over",@"ResultsApp",nil), ex.blow_count];
    profile.text = ex.profile_name;
    
    
    avgFrequency.text = [NSString stringWithFormat:@"%1.1f Hz", ex.avg_median_frequency_hz];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate
//Do nothing if the user touches a row
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