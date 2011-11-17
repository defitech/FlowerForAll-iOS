//
//  Users_Editor.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 16.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Users_Editor.h"

@implementation Users_Editor

@synthesize nameField, nameLabel, passwordField, passwordLabel, deleteButton, me;

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
    [passwordLabel setText:NSLocalizedStringFromTable(@"Password",@"Users",@"Label of the password entry field")];
    [passwordField setPlaceholder:NSLocalizedStringFromTable(@"Leave empty for no password",@"Users",@"Tip for the password entry field")];
    [deleteButton setTitle:NSLocalizedStringFromTable(@"Delete",@"Users",@"Label of delete button") forState:UIControlStateNormal];
    
    [nameField setText:[me name]];
    [passwordField setText:[me password]];
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

- (IBAction)backgroundTouched:(id)sender {
    [sender resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
