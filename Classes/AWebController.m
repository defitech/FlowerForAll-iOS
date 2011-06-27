//
//  AWebController.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 24.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AWebController.h"

#define ACTION_SEARCH  1
#define ACTION_URL  2

@implementation AWebController

@synthesize toolBar, webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (IBAction) search:(id)sender {
    [self modalTextfield:NSLocalizedString(@"Google Search", @"Label of search modal box")
                                          message:nil 
                                           nextAction:ACTION_SEARCH];
}


UITextField *myTextField; // used for modalTextfield
int nextAction = 0; // used for modalTextfield

-(void) modalTextfield:(NSString*)title message:(NSString*)message nextAction:(int)actionID {
    nextAction = actionID;
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:title message:@"Dummy" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil]; 
    myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
    CGAffineTransform myTransform = CGAffineTransformMakeTranslation(00.0, 0.0); 
    [myAlertView setTransform:myTransform]; 
    [myTextField setBackgroundColor:[UIColor whiteColor]]; 
    [myAlertView addSubview:myTextField]; 
    [myAlertView show]; 
    [myAlertView release];
}
// get results from modalTextfield calls
- (void)alertView:(UIAlertView *)myAlertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (nextAction == 1) {
        NSString *searchString = [myTextField text];
        NSString *url = [NSString stringWithFormat:@"http://www.google.com/search?q=%@",[searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
        NSLog(@"Search %@ %@",[myTextField text],url);
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
	
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
    NSString *urlAddress = @"http://www.google.com";
    
    //Create a URL object.
    NSURL *url = [NSURL URLWithString:urlAddress];
    
    //URL Requst Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    
    //Load the request in the UIWebView.
    [webView loadRequest:requestObj];
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
