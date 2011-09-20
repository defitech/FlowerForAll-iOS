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
    [delegate pickerEditorIsDone:self didFinishWithSelection:@"BOB"];
    NSLog(@"bye");
}



- (void)ProfilePickerViewController:(PickerEditor*)ProfilePickerViewController didFinishWithSelection:(NSInteger)selection
{
    // Do something with selection here
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



@end
