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
#import "AWebController.h"
#import "AVideoPlayer.h"

@implementation GameViewController


@synthesize scrollView, flapiView, game1ChoiceView, game2ChoiceView, game1Button, game2Button, navigationBar, pageControl;





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

AWebController *webController;

- (IBAction) game1Touch:(id) sender {
    if (webController == nil) {
        webController = [[AWebController alloc] initWithNibName:@"AWebController" bundle:[NSBundle mainBundle]];
    }
    [FlowerController setCurrentMainController:webController];
}

AVideoPlayer *videoPlayer;

- (IBAction) game2Touch:(id) sender {
    if (videoPlayer == nil) {
        videoPlayer = [[AVideoPlayer alloc] initWithNibName:@"AVideoPlayer" bundle:[NSBundle mainBundle]];
    }
    [FlowerController setCurrentMainController:videoPlayer];
}
 

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];

	//Set title of the navigation bar
	navigationBar.topItem.title = NSLocalizedString(@"GameViewTitle", @"Title of the game view");
	
	//Set title of game buttons for all states
	[game1Button.titleLabel setTextAlignment:UITextAlignmentCenter];
	[game2Button.titleLabel setTextAlignment:UITextAlignmentCenter];
	[game1Button setTitle:NSLocalizedString(@"GameButton1Text", @"Text of the first game button") forState:UIControlStateNormal];
	[game1Button setTitle:NSLocalizedString(@"GameButton1Text", @"Text of the first game button") forState:UIControlStateHighlighted];
	[game1Button setTitle:NSLocalizedString(@"GameButton1Text", @"Text of the first game button") forState:UIControlStateDisabled];
	[game1Button setTitle:NSLocalizedString(@"GameButton1Text", @"Text of the first game button") forState:UIControlStateSelected];
	[game2Button setTitle:NSLocalizedString(@"GameButton2Text", @"Text of the second game button") forState:UIControlStateNormal];
	[game2Button setTitle:NSLocalizedString(@"GameButton2Text", @"Text of the second game button") forState:UIControlStateHighlighted];
	[game2Button setTitle:NSLocalizedString(@"GameButton2Text", @"Text of the second game button") forState:UIControlStateDisabled];
	[game2Button setTitle:NSLocalizedString(@"GameButton2Text", @"Text of the second game button") forState:UIControlStateSelected];
	
	//Add games views inside the scroll view
    
    flapiView = [[FLAPIview alloc] initWithNibName:@"FLAPIview" bundle:[NSBundle mainBundle]];
    flapiView.view.frame = CGRectMake(0.0f, 0.0f, 320.0f, 367.0f);
    
	
	game1ChoiceView.frame = CGRectMake(320.0f, 0.0f, 320.0f, 367.0f);
	game2ChoiceView.frame = CGRectMake(640.0f, 0.0f, 320.0f, 367.0f);
    
	//Set scroll view content size
    //Warning: to be able to scroll the view by touching the PageContol (see method pageControlDidChangeValue), both dimensions of the content size of the scrollview have to be nonzero.
	//scrollView.contentSize = CGSizeMake(960.0,0.0);
    [scrollView setContentSize:CGSizeMake(960.0,335.0)];
	
	//Set scroll view zoom scale
	scrollView.maximumZoomScale = 3.0;
	scrollView.minimumZoomScale = 0.2;
	
	//Set scroll view delegate
	scrollView.delegate = self;
	
	//Set scroll view paging enabled
	scrollView.pagingEnabled = YES;
	
	//Add game1ChoiceView and game2ChoiceView inside the scroll view
    
    
    [scrollView addSubview:flapiView.view];
	[scrollView addSubview:game1ChoiceView];
	[scrollView addSubview:game2ChoiceView];
	
	
		
	
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
    [webController release];
    [videoPlayer release];
}





- (void)scrollViewDidScroll:(UIScrollView *)sender {	
    //Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = 320.0f;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth)+1;
    pageControl.currentPage = page;
	[pageControl updateCurrentPageDisplay];
	
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
	
	[game1ChoiceView release];
	[game2ChoiceView release];
    [super dealloc];
}



//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}


@end
