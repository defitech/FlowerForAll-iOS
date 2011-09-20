//
//  ProfilePickerViewController.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 15.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "PickerEditor.h"




@implementation PickerEditor

@synthesize delegate;


-(id)initWithDelegate:(id<PickerEditorDelegate>)_delegate {
    delegate = _delegate;
    return [self init]; 
}
-(void)showOnTopOfView:(UIView*)onView {
    nav = [[UINavigationController alloc] initWithRootViewController:self];
    nav.view.frame = CGRectMake(0,onView.frame.size.height,onView.frame.size.width,onView.frame.size.height);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    nav.view.frame = CGRectMake(0,0,onView.frame.size.width,onView.frame.size.height);
    [onView addSubview:nav.view];
    [UIView commitAnimations];
}


- (void) viewDidLoad {
    [self.navigationItem setTitle:[delegate pickerEditorTitle:self]];
    [self.navigationItem setLeftBarButtonItem:[
                                               [UIBarButtonItem alloc] initWithTitle:[delegate pickerEditorEndButtonTitle:self] 
                                               style:UIBarButtonItemStyleBordered target:self 
                        action:@selector(returnToParamWindow:)]]; 
}

- (void)returnToParamWindow:(id)sender {
    [self close];
    [delegate pickerEditorIsDone:self];
}

-(void)close {
    // animation not working
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.75];
    nav.view.frame = CGRectMake(0,nav.view.superview.frame.size.height, nav.view.superview.frame.size.width,nav.view.superview.frame.size.height);
    [UIView commitAnimations];
    [nav.view removeFromSuperview];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {  
    return 1;  
}   

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {  
    return [delegate pickerEditorSize:self];  
}   

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {   
    static NSString *CellIdentifier = @"Cell";  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];   
    if (cell == nil) {  
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];  
    }   
    [cell.textLabel setText:[delegate pickerEditorValue:self index:indexPath.row]];   
    if ([delegate pickerEditorIsSelected:self index:indexPath.row]) {
         [cell setAccessoryType:UITableViewCellAccessoryCheckmark]; 
    } else {
         [cell setAccessoryType:UITableViewCellAccessoryNone]; 
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView* backgroundView = [ [ [ UIView alloc ] initWithFrame:CGRectZero ] autorelease ];
	backgroundView.backgroundColor = (indexPath.row % 2) ? [ UIColor lightGrayColor ] : [ UIColor clearColor ];
	cell.backgroundView = backgroundView;
    [[cell textLabel] setBackgroundColor:backgroundView.backgroundColor];
    [[cell detailTextLabel] setBackgroundColor:backgroundView.backgroundColor];
    return cell;   
    
}  



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([delegate pickerEditorIsSelected:self index:indexPath.row]) return;
    [delegate pickerEditorSelectionChange:self index:indexPath.row];
    [tableView reloadData];
}




-(void)viewDidUnload {
    nav = nil;
    [super viewDidUnload];
}


@end
