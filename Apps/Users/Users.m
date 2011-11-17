//
//  Users.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Users.h"
#import "UserManager.h"
#import "Users_CellView.h"
#import "Users_TextCell.h"
#import "Users_Editor.h"

@implementation Users

@synthesize navController, usersListTableView;

Users_TextCell *cellh;

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    if ([UserManager currentUser] == nil || [[UserManager currentUser] uid] == 0) {
        return NSLocalizedStringFromTable(@"Users",@"Users",@"App Title");
    }
    return [[UserManager currentUser] name];
}


/** plus button touched **/
- (IBAction)plusButtonTouch:(id)sender {
    if ([UserManager currentUser] != nil && [[UserManager currentUser] uid] == 0) {
        [UserManager createUser:NSLocalizedStringFromTable(@"New user",@"Users",@"Name of a newly created user") password:@""];  
    }
    [usersListTableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

//Only 1 section in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


//The table contains the exercises days
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    int c = [[UserManager listAllUser] count];
    if (c == 1) return 0;
    return c;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     NSUInteger section = [indexPath section];
    if (section == 0) return [cellh height];
    return 44;
}

//Customize the appearance of table view cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    NSUInteger section = [indexPath section];
    if (section == 0) return cellh; // header
     
    NSUInteger row = [indexPath row];
        
        
    static NSString *CellIdentifier = @"userCell";
    
    Users_CellView *cell = (Users_CellView *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //If the cell is nil, create it, otherwise remove all its subviews
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Users_CellView" owner:self options:nil];
        cell = (Users_CellView *)[nib objectAtIndex:0];
    }
    
    User* user = (User*)[[UserManager listAllUser] objectAtIndex:row];
    if (user.uid == 0) {
        cell.myLabel.text = [NSString stringWithFormat:@"%@ ★",user.name];
    } else {
        cell.myLabel.text = user.name;
    }
    
    
    cell.selectedButton.hidden = [UserManager currentUser] == nil || 
                                 (user.uid != [UserManager currentUser].uid); 
    
    if ([UserManager currentUser].uid == 0 || [UserManager currentUser].uid == user.uid)  {
        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    User* user = (User*)[[UserManager listAllUser] objectAtIndex:row];
	
    [[self navController] pushViewController:[[Users_Editor alloc] initWithUser:user] animated:YES];

}

- (IBAction) userDataChangeEvent:(id)sender {
    [self.usersListTableView reloadData];
}

#pragma mark -
#pragma mark Table view delegate
//Push a ResultsApp_Day controller when the user touches a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSInteger row = [indexPath row];
     NSLog(@"Select %i",row);
		
}



#pragma mark - View lifecycle





- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Users_TextCell" owner:self options:nil];
    cellh = (Users_TextCell *)[nib objectAtIndex:0];
    
    navController.view.frame = CGRectMake(0,0,
                            self.view.frame.size.width,
                            self.view.frame.size.height);
    [self.view addSubview:navController.view];
    
    // register user name change events
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userDataChangeEvent:)
     name: @"userDataChangeEvent"
     object: nil];
    
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
