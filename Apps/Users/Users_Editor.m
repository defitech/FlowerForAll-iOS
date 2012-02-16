//
//  Users_Editor.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 16.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Users_Editor.h"
#import "UserManager.h"

@implementation Users_Editor

@synthesize nameField, nameLabel, nameTipLabel, passwordField, passwordLabel, deleteButton, me;

- (id) initWithUser:(User *)user {
    [super initWithNibName:@"Users_Editor" bundle:nil];
    self.me = user;
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTable(@"Edit user",@"Users",@"Edit User page title");
    
    [nameLabel setText:NSLocalizedStringFromTable(@"Name",@"Users",@"Label of the name entry field")];
    [nameTipLabel setText:NSLocalizedStringFromTable(@"In a medical environnement choose a username that preserves anonymity.",@"Users",@"Tip for th label of the name entry field")];
    
    [passwordLabel setText:NSLocalizedStringFromTable(@"Password",@"Users",@"Label of the password entry field")];
    [passwordField setPlaceholder:NSLocalizedStringFromTable(@"Leave empty for no password",@"Users",@"Tip for the password entry field")];
    
    
    [nameField setText:[me name]];
    [passwordField setText:[me password]];
    
    [deleteButton setTitle:NSLocalizedStringFromTable(@"Delete",@"Users",@"Label of delete button") forState:UIControlStateNormal];
    if (me.uid == 0 || [UserManager currentUser].uid != 0) {
        [deleteButton setHidden:YES];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    nameLabel = nil;
    nameField = nil;
    passwordField = nil;
    passwordLabel = nil;
    deleteButton = nil;
    me = nil;
    
}

- (IBAction) nameFieldEditingEnd:(id)sender {
    NSLog(@"nameFieldEditingEnd");
    [sender resignFirstResponder];
    nameField.text = [nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([nameField.text length] == 0) nameField.text = [NSString stringWithFormat:@"U %i",me.uid];
    [me changeName:nameField.text];
    
}
- (IBAction) passwordFieldEditingEnd:(id)sender {
    NSLog(@"passwordFieldEditingEnd");
    [sender resignFirstResponder];
    [me changePassword:passwordField.text];
}

- (IBAction) buttonDeletePressed: (id)sender {
    
    // Show the confirmation.
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:NSLocalizedStringFromTable(@"Delete",@"Users",nil)
                          message:NSLocalizedStringFromTable(@"Do you want to delete all the data for this user?",@"Users",@"message")
                          delegate: self
                          cancelButtonTitle: NSLocalizedStringFromTable(@"Cancel",@"Users",nil)
                          otherButtonTitles: NSLocalizedStringFromTable(@"Delete",@"Users",nil), nil];
    [alert show];
    [alert release];
}

// Called when an alertview button is touched
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if  (buttonIndex == 1) {
        [[self navigationController] popViewControllerAnimated:YES];
        [UserManager dropUser:me.uid];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
