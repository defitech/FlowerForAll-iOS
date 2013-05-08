//
//  UserChooserViewController.m
//  FlowerForAll
//
//  Created by adherent on 10.10.12.
//
//

#import "UserChooserViewController.h"
#import "FlowerController.h"
#import "Users_CellView.h"
#import "UserChooser_TextCell.h"
#import "Users_Editor.h"
#import "UserPicker.h"
#import "UserManager.h"

#import "Users.h"

@implementation UserChooserViewController

@synthesize navController, usersListTableView, navItem, userArrayforChooser, passwordTextFieldforChooser, namesArrayforChooser, passwordsArrayforChooser;

UserChooser_TextCell *cellh;
int IndexforUserinChooser;
NSArray *tempArray;

static BOOL showing = false;
/** show the user picker on top of FLowerController view **/
+(void)show {
    if (! showing) {
        showing = true;
        [[[UserChooserViewController alloc] init] showUserChooser];
    } else {
        // NSLog(@"UserPicker:already showing");
    }
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    tempArray = [UserManager listAllUser];
    self.userArrayforChooser = tempArray;
    NSMutableArray *tempnamesArray = [[NSMutableArray alloc] init];
    self.namesArrayforChooser = tempnamesArray;
    [tempnamesArray release];
    NSMutableArray *temppasswordsArray = [[NSMutableArray alloc] init];
    self.passwordsArrayforChooser = temppasswordsArray;
    [temppasswordsArray release];
    for (int i = 0; i < [tempArray count]; i++) {
        [tempnamesArray addObject:[[tempArray objectAtIndex:i] name]];
        [temppasswordsArray addObject:[[tempArray objectAtIndex:i] password]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    navController = nil;
    navItem = nil;
    usersListTableView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) showUserChooser {
    [super viewDidLoad];
    NSLog(@"SHOW USERCHOOSER");
    [[FlowerController currentFlower].view addSubview:self.view];
    self.view.frame = [FlowerController currentFlower].view.bounds;
    
    navController.view.frame = CGRectMake(0,0,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
    //[self.view addSubview:navController.view];
    [self.view addSubview:navController.view];
    /*navItem.leftBarButtonItem = [[UIBarButtonItem alloc]
     initWithTitle:NSLocalizedStringFromTable(@"Menu",@"UserChooser",@"Left nav Button")
     style:UIBarButtonItemStyleBordered
     target:self
     action:@selector(close:)];*/
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(userchooserDataChangeEvent:)
     name: @"userchooserDataChangeEvent"
     object: nil];
    
}

- (void) close:(id)sender {
    if ([UserManager currentUser] != nil) {
        [self hideUserChooser];
    }
    [tempArray release];
}
- (void) hideUserChooser {
    NSLog(@"HIDE USERCHOOSER");
    
    [self.view removeFromSuperview];
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
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"UserChooser_TextCell" owner:self options:nil];
    cellh = (UserChooser_TextCell *)[nib objectAtIndex:0];
    NSUInteger section = [indexPath section];
    NSLog(@"cellh:%f", [cellh height]);
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
    
    /*if ([UserManager currentUser].uid == 0 || [UserManager currentUser].uid == user.uid)  {
     [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
     } else {
     [cell setAccessoryType:UITableViewCellAccessoryNone];
     }*/
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    User* user = (User*)[[UserManager listAllUser] objectAtIndex:row];
	NSLog(@"Users.m, user: %@:",user.description);
    [[self navController] pushViewController:[[Users_Editor alloc] initWithUser:user] animated:YES];
    
}

- (IBAction) userchooserDataChangeEvent:(id)sender {
    //[self.usersListTableView reloadData];
    [self.view removeFromSuperview];
}

- (void) showPasswordSheet:(NSString*)extraMessage {
    
    //Creates an alert for the user to enter his password
    UIAlertView *myAlertView = [[UIAlertView alloc]
                                initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Enter password for %@", @"Label of the password alert"),[namesArrayforChooser objectAtIndex:IndexforUserinChooser]]
                                message:[NSString stringWithFormat:@"%@\n\n",extraMessage]
                                delegate:self
                                cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    
    self.passwordTextFieldforChooser = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 70.0, 260.0, 25.0)];
    [self.passwordTextFieldforChooser setBackgroundColor:[UIColor whiteColor]];
    self.passwordTextFieldforChooser.secureTextEntry = YES;
    [self.passwordTextFieldforChooser setKeyboardType:UIKeyboardTypeNumberPad];
    
    [self.passwordTextFieldforChooser becomeFirstResponder];
    [myAlertView addSubview:self.passwordTextFieldforChooser];
    [myAlertView show];
    [myAlertView release];
    
}

- (User*) selectedUser {
    return [self.userArrayforChooser objectAtIndex:IndexforUserinChooser];
    NSLog(@"Problem: could not find user in UserPicker.m, function selectedUser");
    return [self.userArrayforChooser objectAtIndex:0];
}

//Check password if clicked on OK button
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1){
        if ([[passwordsArrayforChooser objectAtIndex:IndexforUserinChooser] isEqualToString:self.passwordTextFieldforChooser.text]) {
            [self dismissAndPickSelectedUser];
            showing = false;
        } else {
            [self showPasswordSheet:NSLocalizedString(@"Wrong password please retry.", @"Message to display in the alert box.")];
        }
        
	} else {
        showing = false;
    }
}

-(void)askPasswordFor:(User*)user {
    showing = true;
    for (int i = 0; i < [self.userArrayforChooser count]; i++) {
        if ([[self.userArrayforChooser objectAtIndex:i] uid] == [user uid]) IndexforUserinChooser = i;
    }
    [self showPasswordSheet:@""];
}
- (void) dismissAndPickSelectedUser {
    [UserManager setCurrentUser:[[self selectedUser] uid]];
    showing = false;
}

#pragma mark -
#pragma mark Table view delegate
//Push a ResultsApp_Day controller when the user touches a row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //User* user = (User*)[[UserManager listAllUser] objectAtIndex:[indexPath row]];
	[self askPasswordFor:[self.userArrayforChooser objectAtIndex:[indexPath row]]];
}

#pragma mark - View lifecycle



@end

