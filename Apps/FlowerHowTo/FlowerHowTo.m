//
//  FlowerHowTo.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 07.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerHowTo.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define STATUSBAR_HEIGHT 20

@implementation FlowerHowTo

# pragma mark FlowerApp overriding

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    return NSLocalizedStringFromTable(@"Setup instructions",@"FlowerHowTo",@"App Title");
}

/**
 * Override FlowerHowTo, we do not need events
 */
-(void)addObservers { }

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    player = nil;
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString *fpath = [[NSBundle mainBundle] pathForResource:@"FlowerHowTo-index" ofType:@"html"];
    NSString *fileText = [NSString stringWithContentsOfFile:fpath encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@ %@",baseURL,fpath);
    //NSLog(@"%@",fileText);
    if SYSTEM_VERSION_LESS_THAN(@"7.0") {
      // Make sure the webview is correctly displayed when there's a forced status bar
      webView.frame = CGRectMake(webView.frame.origin.x,
                                 webView.frame.origin.y - STATUSBAR_HEIGHT,
                                 webView.frame.size.width,
                                 webView.frame.size.height + STATUSBAR_HEIGHT);
    }
    [webView loadHTMLString:fileText baseURL:baseURL];
    [webView setDelegate:self];

}


- (void)playVideo
{
    if (player != nil) return ; // already playing
    
    NSString *url = [[NSBundle mainBundle] 
                     pathForResource:@"FlowerHowTo" 
                     ofType:@"m4v"];
    
    player = 
    [[MPMoviePlayerController alloc] 
     initWithContentURL:[NSURL fileURLWithPath:url]];
    [player setUseApplicationAudioSession:YES];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self
     selector:@selector(movieFinishedCallback:)                                                 
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    
    
    //---play partial screen---
    player.view.frame =  CGRectMake(0, 0, webView.frame.size.height, webView.frame.size.width);
    player.view.center = CGPointMake(webView.frame.size.width/2 + webView.frame.origin.x,
                                     webView.frame.size.height/2 + webView.frame.origin.y);
    player.view.transform = CGAffineTransformMakeRotation(M_PI/ 2);
    
   
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                           forView:self.view
                             cache:YES];

    
    
    [self.view addSubview:player.view];
    
    [UIView commitAnimations];
    
    //---play movie---
    [player play];    
    NSLog(@"FlowerHowTo_VideoPlayer Playing %@",url);   
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (player.isFullscreen != true) {
        [self stopVideo];
        [super viewWillDisappear:animated];
    }
}

- (void)stopVideo {
    if (player == nil) {
        NSLog(@"in stopVideo: player not running");
        return ; // not playing
    }
    [[NSNotificationCenter defaultCenter] 
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];    
    [player pause];
    [player.view removeFromSuperview];  
    [player release];
    player = nil;
    NSLog(@"FlowerHowTo_VideoPlayer Finished Playing"); 

}

// stop from button
- (void) stopVideoPressed:(id)sender {
     [self stopVideo];
}

// called when video end
- (void) movieFinishedCallback:(NSNotification*) aNotification {
    [self stopVideo];
}



//CAPTURE USER LINK-CLICK.
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* url = [[request URL] absoluteString];
    NSLog(@"Clicked: %@",url);
    if ([@"action://playvideo" isEqualToString:url]) {
        [self playVideo];
         return NO;
    }
    return YES;   
}

- (void)viewWillAppear:(BOOL)animated
{
    // stop video if in course
    [self stopVideo];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    webView = nil;
    player = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
