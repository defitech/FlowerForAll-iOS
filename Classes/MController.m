//
//  MController.m
//  OpenGL_ES_tuto1
//
//  Created by Pierre-Mikael Legris on 11.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MController.h"
#import "EAGLView.h"

@implementation MController

@synthesize glView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/**
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}**/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/**
- (void)viewDidLoad {
 NSLog(@"Yo");
// glView = [[EAGLView alloc] initWithFrame:CGRectMake(30.0f, 30.0f,  90.0f, 70.0f)];
 //theEAGLView.backgroundColor = [UIColor redColor];

    [super viewDidLoad];
}
 **/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
