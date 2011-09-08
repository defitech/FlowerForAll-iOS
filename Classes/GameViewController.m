//
//  GameViewController.m
//  FlutterApp2
//
//  Created by Dev on 24.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the GameViewController class


#import "FlutterApp2AppDelegate.h"

#import "GameViewController.h"

#import "DataAccess.h"
#import "DB.h"

#import "FlowerController.h"
#import "AVideoPlayer.h"

@implementation GameViewController


@synthesize page2, web, scrollView, navigationBar, pageControl,  volcanoLabel, videoPlayerLabel, settingsLabel;





/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (IBAction) volcanoTouch:(id) sender {
    if (volcanoGame == nil) {
        volcanoGame = [[FLAPIview alloc] initWithNibName:@"FLAPIview" bundle:[NSBundle mainBundle]];
    }
    [FlowerController setCurrentMainController:volcanoGame];
}

- (IBAction) settingsTouch:(id) sender {
    [FlowerController setCurrentMainController:[FlowerController getSettingsViewController]];
}

AVideoPlayer *videoPlayer;
- (IBAction) videoPlayerTouch:(id) sender {
    NSLog(@"videoPlayerTouch: %@",[videoPlayer class]);
    if (videoPlayer == nil) {
        videoPlayer = [[AVideoPlayer alloc] initWithNibName:@"AVideoPlayer" bundle:[NSBundle mainBundle]];
    }
    [FlowerController setCurrentMainController:videoPlayer];
}



 

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];

	//Set title of the navigation bar
	navigationBar.topItem.title = NSLocalizedString(@"Menu", @"Menu");
	
	//Set title of game buttons for all states
    [volcanoLabel setText:NSLocalizedString(@"Game Volcano", @"Icon Title")];
    [videoPlayerLabel setText:NSLocalizedString(@"Setup Video", @"Icon Title")];
    [settingsLabel setText:NSLocalizedString(@"Settings", @"Icon Title")];
	
    int nb_pages = 2;
	//scrollView.contentSize = CGSizeMake(960.0,0.0);
    [scrollView setContentSize:CGSizeMake(320.0 * nb_pages,335.0)];
	
    [pageControl setNumberOfPages:nb_pages];
    
    //add pages
    page2.frame = CGRectMake(320.0f, 0.0f, 320.0f, 367.0f);
    [scrollView addSubview:page2];
    [web loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"FlowerForAll" ofType:@"html"]isDirectory:NO]]];
    
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
	
}






- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [videoPlayer release];
}





- (void)scrollViewDidScroll:(UIScrollView *)sender {	
    //Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = 320.0f;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1;
    pageControl.currentPage = page;
	[pageControl updateCurrentPageDisplay];
	
    //Set title of the navigation bar
    if ( page == 1) {
        navigationBar.topItem.title = NSLocalizedString(@"FFA", @"Flower For All");
    } else {
        navigationBar.topItem.title = NSLocalizedString(@"Menu", @"Menu");
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




- (void)dealloc {
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
