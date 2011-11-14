//
//  Users.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Users.h"
#import "Users_CellView.h"

@implementation Users

@synthesize navController, usersListTableView;

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    return NSLocalizedStringFromTable(@"Users",@"Users",@"App Title");
}


/** plus button touched **/
- (IBAction)plusButtonTouch:(id)sender {
    NSLog(@"plus touched");
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
    return 2;
}


//Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];

    static NSString *CellIdentifier = @"userCell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //If the cell is nil, create it, otherwise remove all its subviews
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Users_CellView" owner:self options:nil];
        cell = (UITableViewCell *)[nib objectAtIndex:0];
    }
    else {
        for(UIView* subview in [cell.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }

    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate
//Push a ResultsApp_Day controller when the user touches a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSInteger row = [indexPath row];
    
		
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    navController.view.frame = CGRectMake(0,0,
                            self.view.frame.size.width,
                            self.view.frame.size.height);
    [self.view addSubview:navController.view];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
