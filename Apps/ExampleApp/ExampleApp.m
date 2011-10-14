//
//  ExampleApp.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.10.11.
//  Copyright 2011 fondation Defitech All rights reserved.
//
//   Skeleton App to Use as reference for Game Developper

#import "ExampleApp.h"

@implementation ExampleApp

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    return NSLocalizedStringFromTable(@"Example App ",@"ExampleApp",@"App Title");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Do your init stuff
    }
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
