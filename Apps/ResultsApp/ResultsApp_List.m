//
//  StatisticListViewController.m
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	Implementation of the StatisticListViewController class

#import "ResultsApp_Day.h"
#import "ResultsApp_List.h"

#import "DB.h"
#import "ExerciseDay.h"

@implementation ResultsApp_List

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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    
    ExerciseDay* day = [exerciseDays objectAtIndex:row];
    
    static NSString *CellIdentifier = @"StarOnRightCell";
    
    UILabel *mainLabel;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    } else {
        
        for(UIView* subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
        
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    mainLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20.0, 8.0, 140.0, 25.0)] autorelease];
    mainLabel.font = [UIFont boldSystemFontOfSize:20];
    mainLabel.textAlignment = UITextAlignmentLeft;
    [cell.contentView addSubview:mainLabel];
    
    
    int max = day.order.length > 5 ? 5 : day.order.length;
    
    for(int i=0; i < max; i++){
        UIImageView* star2 = [UIImageView alloc];
        
        unichar c = [day.order characterAtIndex:i];
        
        int starLength = 20;
        int offset = 170;
        
        CGRect frame2;
        
        switch (max){
            case 1:
                frame2= CGRectMake(offset+2*starLength ,8, 20, 25);
                break;
            case 2:
                frame2= CGRectMake(offset+1.5*starLength+starLength*i ,8, 20, 25);
                break;
            case 3:
                frame2= CGRectMake(offset+starLength+starLength*i ,8, 20, 25);
                break;
            case 4:
                frame2= CGRectMake(offset+0.5*starLength+starLength*i ,8, 20, 25);
                break;
            case 5:
                frame2= CGRectMake(offset+starLength*i ,8, 20, 25);
                break;
            default:
                break;
        }
        
        [star2 initWithFrame:frame2];
        
        [cell.contentView addSubview:star2];
        
        NSString *imagePath;
        if (c == '0')
            imagePath = [[NSBundle mainBundle] pathForResource:@"ResultsApp-grey_star" ofType:@"png"];
        else
            imagePath = [[NSBundle mainBundle] pathForResource:@"ResultsApp-black_star" ofType:@"png"];
        
        UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
        
        star2.image = theImage;
        
    }
    
    mainLabel.text = day.formattedDate;
    
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
        dayStatisticListViewController = [[ResultsApp_Day alloc] initWithNibName:@"StatisticListView" bundle:nil extraParameter:day.formattedDate];
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