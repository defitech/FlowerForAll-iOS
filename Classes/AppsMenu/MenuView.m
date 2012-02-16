//
//  MenuView.m
//  FlutterApp2
//
//  Created by Dev on 24.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the MenuView class


#import "FlutterApp2AppDelegate.h"

#import "MenuView.h"

#import "DataAccess.h"
#import "DB.h"

#import "FlowerController.h"
#import "FlowerHowTo.h"
#import "ParametersApp.h"
#import "ResultsApp.h"
#import "CalibrationApp.h"
#import "Users.h"

@implementation MenuView


@synthesize page2, web, scrollView, backItem, navigationBar, pageControl,  volcanoLabel, videoPlayerLabel, settingsLabel, resultsLabel, usersLabel, calibrationLabel;


- (IBAction)usersTouch:(id) sender {
    [FlowerController pushApp:@"Users"];
}

- (IBAction) volcanoTouch:(id) sender {
    [FlowerController pushApp:@"VolcanoApp"];
}

- (IBAction) settingsTouch:(id) sender {
    [FlowerController pushApp:@"ParametersApp" ];
}

- (IBAction) calibrationTouch:(id) sender {
    [FlowerController pushApp:@"CalibrationApp" ];
}

- (IBAction) resultsTouch:(id) sender {
    [FlowerController pushApp:@"ResultsApp"];
}

FlowerHowTo *flowerHowTo;
- (IBAction) flowerHowTo:(id) sender {
    NSLog(@"flowerHowToTouch: %@",[flowerHowTo class]);
    if (flowerHowTo == nil) {
        flowerHowTo = [[FlowerHowTo alloc] initWithNibName:@"FlowerHowTo" bundle:[NSBundle mainBundle]];
    }
    [FlowerController setCurrentMainController:flowerHowTo];
}




-(void)backToMenu {
    CGPoint offset;
    offset.x = 0;                                                                                               
    offset.y = 0;
    [scrollView setContentOffset:offset animated:YES];
}
 

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];

	//Set title of the navigation bar
	navigationBar.topItem.title = NSLocalizedString(@"Flower breath", @"Menu Title");
	
	//Set title of game buttons for all states
    [volcanoLabel setText:[VolcanoApp appTitle]];
    [videoPlayerLabel setText:[FlowerHowTo appTitle]];
    [settingsLabel setText:[ParametersApp appTitle]];
    [resultsLabel setText:[ResultsApp appTitle]];
    [usersLabel setText:[Users  appTitle]];
    [calibrationLabel setText:[CalibrationApp appTitle]];
	
    int nb_pages = 2;
	//scrollView.contentSize = CGSizeMake(960.0,0.0);
    [scrollView setContentSize:CGSizeMake(320.0 * nb_pages,335.0)];
	
    [pageControl setNumberOfPages:nb_pages];
    
    //add pages
    page2.frame = CGRectMake(320.0f, 0.0f, 320.0f, 367.0f);
    [scrollView addSubview:page2];
    
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString *fpath = [[NSBundle mainBundle] pathForResource:@"FlowerForAll" ofType:@"html"];
    NSString *fileText = [NSString stringWithContentsOfFile:fpath encoding:NSUTF8StringEncoding error:nil];
    [web loadHTMLString:fileText baseURL:baseURL];
    [web setDelegate:self];
    
	//Set scroll view zoom scale
	scrollView.maximumZoomScale = 3.0;
	scrollView.minimumZoomScale = 0.2;
	
	//Set scroll view delegate
	scrollView.delegate = self;
	
	//Set scroll view paging enabled
	scrollView.pagingEnabled = YES;

	
	//Make the labelAndPickerView appear on screen animatedly as the view loads
	[UIView beginAnimations:@"Transition" context:nil];
	[UIView setAnimationDuration:0.3];

	[UIView commitAnimations];

	
    UIButton* backButton = [UIButton buttonWithType:101]; // left-pointing shape
    [backButton addTarget:self action:@selector(backToMenu) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:NSLocalizedString(@"Back To Menu", @"Back To Menu") forState:UIControlStateNormal];
    
    // create button item
    backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}






- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [flowerHowTo release];
}





- (void)scrollViewDidScroll:(UIScrollView *)sender {	
    //Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = 320.0f;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1;
    pageControl.currentPage = page;
	[pageControl updateCurrentPageDisplay];
	
    //Set title of the navigation bar
    if ( page == 1) {
        navigationBar.topItem.title = NSLocalizedString(@"About Flower breath", @"About Title Page");
        
        // add the back button to navigation bar
        navigationBar.topItem.leftBarButtonItem = backItem;
    } else {
        navigationBar.topItem.title = NSLocalizedString(@"Flower breath", @"Menu Title");
        
        // remove the back button to navigation bar
        navigationBar.topItem.leftBarButtonItem = nil;
    }
}



//Called when the user touches the PageControl, so that its value changes, to scroll the ScrollView
- (IBAction) pageControlDidChangeValue:(id) sender{
    [self.pageControl drawFancyPageIcon];
    
    int page = pageControl.currentPage;
    
    //From Apple's PageControl example, to fix the "flashing" of the PageControl
    //However, seems that we must extend the ContentController to use this code
    /*[self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];*/
    
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    
    [scrollView scrollRectToVisible:frame animated:YES];
    
}

//CAPTURE USER LINK-CLICK.
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* url = [[request URL] absoluteString];
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"mailto:"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        return NO;
    }
    return YES;
}




- (void)dealloc {
    [backItem release];
	[scrollView release];
	[volcanoGame release];
	[videoPlayerView release];
    [super dealloc];
}



//Allows view to autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


@end
