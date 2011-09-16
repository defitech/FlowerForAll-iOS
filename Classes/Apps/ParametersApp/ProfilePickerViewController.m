//
//  ProfilePickerViewController.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 15.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfilePickerViewController.h"




@implementation ProfilePickerViewController

//@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) viewDidLoad {
    [self.navigationItem setTitle:[ParametersApp translate:@"ProfilManagementTitle" comment:@"Profil Management Title"]];
    [self.navigationItem setLeftBarButtonItem:[
                        [UIBarButtonItem alloc] initWithTitle:[ParametersApp translate:@"AppTitle" comment:@"Back Button for Title management"] style:UIBarButtonItemStyleBordered target:self 
                        action:@selector(returnToParamWindow:)]]; 
}

- (void)returnToParamWindow:(id)sender {
    NSLog(@"bye");
}



- (void)ProfilePickerViewController:(ProfilePickerViewController*)ProfilePickerViewController didFinishWithSelection:(NSInteger)selection
{
    // Do something with selection here
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



@end
