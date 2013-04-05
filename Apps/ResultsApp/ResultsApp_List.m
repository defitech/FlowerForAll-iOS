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
#import "Month.h"

@implementation ResultsApp_List

@synthesize dayStatisticListViewController, exerciseDays, exerciseMonthes, currentMonth, statisticListTableView, currentlySelectedRow, modifyButton;


#pragma mark -
#pragma mark Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    NSLog(@"StatListViewController initWithNibName");
	if (self) {
		// Custom initialization; init modifyButton and add it to the navigation bar
        modifyButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Modify", @"ResultsApp", @"Label of the modify table button") style:UIBarButtonItemStylePlain target:self action:@selector(modifyTable)];
        self.navigationItem.rightBarButtonItem = modifyButton;
	}
	return self;
}


#pragma mark -
#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"StatListViewController didload");
    self.title = NSLocalizedStringFromTable(@"Results",@"ResultsApp",nil);
}


- (void)refreshData {
    //Fetch list of all exercise days from the DB
	self.exerciseDays = [DB getDays:currentMonth];
    if (currentMonth == nil) {
        exerciseMonthes = [DB getMonthes:YES]; // refreshes monthes informations
    } else {
        exerciseMonthes = nil;
    }
	[self.statisticListTableView reloadData];
}

//Called when popping a child view controller. Ensure table is correctly reloaded.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
    [self refreshData];
}



//The editing style of the table is always the delete style
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //if ([indexPath row] < [exerciseDays count]) { 
        return UITableViewCellEditingStyleDelete;
    //}
    
    //    return UITableViewCellEditingStyleNone;
}


//Called when the user confirms deletion of a row
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    
    int row_month = row - [exerciseDays count];
    
    if (row_month >= 0) {
        [DB deleteMonth:(Month*)[exerciseMonthes objectAtIndex:row_month]];
        [exerciseMonthes removeObjectAtIndex:row_month];
    } else {
        
        if ([indexPath row] < [exerciseDays count]) { 
            [DB deleteDay:(ExerciseDay*)[exerciseDays objectAtIndex:row]];
            
            //Update the model here (necessary to avoid inconsistency exception)
            [exerciseDays removeObjectAtIndex:row];
        }
    }
    
    
    //Remove row from the table view
    [statisticListTableView beginUpdates];
    [statisticListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [statisticListTableView endUpdates];
}


//Called when the user pushes the modify button
- (void)modifyTable {
	
    //Set the table in edit mode or, in the contrary, in non-edit mode
	if (statisticListTableView.editing == NO) {
        [statisticListTableView setEditing:YES animated:YES];
		modifyButton.style = UIBarButtonItemStyleDone;
        modifyButton.title = NSLocalizedStringFromTable(@"Done",@"ResultsApp",@"Label of the modify table button in edit mode");
	}
	else {
        [statisticListTableView setEditing:NO animated:YES];
		modifyButton.style = UIBarButtonItemStylePlain;
        modifyButton.title = NSLocalizedStringFromTable(@"Delete",@"ResultsApp",@"Label of the modify table button");
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
    int count = [exerciseDays count];
    if (exerciseMonthes != nil) count += [exerciseMonthes count];
   
    return count;
}


//Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"StarOnRightCell";
    
    NSUInteger row = [indexPath row];
    int row_month = row - [exerciseDays count];
    if (row_month >= 0) {
        
        UITableViewCell *cellS = [tableView dequeueReusableCellWithIdentifier:@"monthCell"];
        
        
        
        //If the cell is nil, create it, otherwise remove all its subviews
        if (cellS == nil) {
            cellS = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"monthCell"] autorelease];
        }
        Month* m = (Month*) [exerciseMonthes objectAtIndex:row_month];
        cellS.textLabel.text = m.strDate;
        cellS.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%i exercices", @"ResultsApp", @"Comment in the Month list cell"),m.count];
        cellS.imageView.image = [ UIImage imageNamed:@"ResultsApp-Box.png" ]; 
        cellS.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        

        
        return cellS;
    }
    

    
    //Get the day corresponding to the current cell
    ExerciseDay* day = [exerciseDays objectAtIndex:row];
    
    
    
    //Labels in the cell
    UILabel *date;
    UILabel *number;
    UILabel *plus;
    
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //Get cell dimensions. All elements placed in the cell will then be placed relatively to those dimensions
    float cellHeight = cell.frame.size.height;
    float cellWidth = 320.0;  // ugly hack to fix the police change (instead of cell.frame.size.width;)
    
    //Place and format labels
    date = [[[UILabel alloc] initWithFrame:CGRectMake(cellWidth/21.33, cellHeight/4.88, cellWidth/2.28, cellHeight/1.76)] autorelease];
    date.font = [UIFont boldSystemFontOfSize:cellWidth/16.0];
    date.textAlignment = UITextAlignmentLeft;
    date.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:date];
    
    number = [[[UILabel alloc] initWithFrame:CGRectMake(cellWidth/2.1, cellHeight/4.88, cellWidth/16.0, cellHeight/1.76)] autorelease];
    number.font = [UIFont boldSystemFontOfSize:cellWidth/20.0];
    number.textColor = [UIColor grayColor];
    number.textAlignment = UITextAlignmentLeft;
    number.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:number];
    
    plus = [[[UILabel alloc] initWithFrame:CGRectMake(cellWidth/1.16, cellHeight/5.5, cellWidth/16.0, cellHeight/1.76)] autorelease];
    plus.font = [UIFont boldSystemFontOfSize:cellWidth/17.77];
    plus.textColor = [UIColor grayColor];
    plus.textAlignment = UITextAlignmentLeft;
    plus.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:plus];
    
    //The code below draws the stars (up to five)
    
    //Determines the number of stars (maximum is 5)
    int max = day.order.length > 5 ? 5 : day.order.length;
    
    //Determine how many good exercises in the first 5 (or low if there is less than 5 exercises)
    int localGoodCount = 0;
    for(int i=0; i < max; i++){
        unichar c = [day.order characterAtIndex:i];
        if (c == '1')
            localGoodCount++;
    }
    
    //Draw the stars (gold for a good ex, blue for a bad). All gold stars are drawn en the lef (before the blue)
    for(int i=0; i < max; i++){
        
        int starLength = cellWidth/20.0;
        int offset = cellWidth/1.66;
        
        UIImageView* star = [UIImageView alloc];
        
        CGRect frame = CGRectMake(offset+starLength*i, cellHeight/5.5, cellWidth/16.0, cellHeight/1.76);
        
        [star initWithFrame:frame];
        
        [cell.contentView addSubview:star];
        
        NSString *imagePath;
        if (i < localGoodCount)
            imagePath = [[NSBundle mainBundle] pathForResource:@"ResultsApp-gold_star" ofType:@"png"];
        else
            imagePath = [[NSBundle mainBundle] pathForResource:@"ResultsApp-blue_star" ofType:@"png"];
        
        UIImage *theImage = [UIImage imageWithContentsOfFile:imagePath];
        
        star.image = theImage;
    }
    
    //Set text in the labels
    date.text = day.formattedDate;
    number.text = [NSString stringWithFormat:@"%i", day.order.length];
    
    //Add the plus if there are more than 5 exercises
    if (day.order.length > 5)
        plus.text = @"+";
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate
//Push a ResultsApp_Day controller when the user touches a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSInteger row = [indexPath row];

	//Update self.currentlySelectedRow field
	self.currentlySelectedRow = row;
  
	if (row < [exerciseDays count]) {

        ExerciseDay* day = [exerciseDays objectAtIndex:row];

		//if (dayStatisticListViewController == nil){
        dayStatisticListViewController = [[ResultsApp_Day alloc] initWithNibName:@"ResultsApp_List" bundle:nil extraParameter:day.formattedDate];
		//}
		
		[[self navigationController] pushViewController:dayStatisticListViewController animated:YES];
        return; 
	}
    
	int row_month = row - [exerciseDays count];
    if (row_month >= 0) {
        ResultsApp_List* rapl = [[[ResultsApp_List alloc] initWithNibName:@"ResultsApp_List" bundle:[NSBundle mainBundle]] autorelease];
        rapl.currentMonth = (Month*) [exerciseMonthes objectAtIndex:row_month];
       [[self navigationController] pushViewController:rapl animated:YES];
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