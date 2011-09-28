//
//  ResultsApp.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 28.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultsApp.h"


@implementation ResultsApp

@synthesize controllerView, toolbar;


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
    

    
    statViewController = [[ResultsApp_Nav alloc] init];
    statViewController.view.frame = CGRectMake(0,0,
                                               self.controllerView.frame.size.width,
                                               self.controllerView.frame.size.height);
    [self.controllerView addSubview:statViewController.view];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    controllerView = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
