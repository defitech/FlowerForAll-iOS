//
//  ResultApp_MailerOptions.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultsApp_MailerOptions.h"



@implementation ResultsApp_MailerOptions

ResultsApp* delegate;

- (id)initWithResultsApp:(ResultsApp*)_delegate
{   
    if (self == nil) {
        self = [super init];
    }
    delegate = _delegate;
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
