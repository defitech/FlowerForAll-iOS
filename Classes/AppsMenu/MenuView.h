//
//  MenuView.h
//  FlutterApp2
//
//  Created by Dev on 24.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the view controller for the game view. It handles notably a scroll view, allowing the user to scroll between the different games.


#import <UIKit/UIKit.h>
#import "VolcanoApp.h"

#import "RSPageControl.h"


@interface MenuView : UIViewController <UIScrollViewDelegate, UIWebViewDelegate>{

	//The sub views include mainly the scroll view, which will include game1ChoiceView and game2ChoiceView (for the moment there are 2 games)
	IBOutlet UIScrollView *scrollView;
    
    //Page 2
    IBOutlet UIView *page2;
    IBOutlet UIWebView *web;
    
    // Activities
    VolcanoApp *volcanoGame;
    UIView *videoPlayerView;
	
	//The buttons inside each of the game sub views
    IBOutlet UILabel *volcanoLabel, *videoPlayerLabel, *settingsLabel, *resultsLabel;

	
	//There is no navigation controller here. So we add a navigation bar individually.
	IBOutlet UINavigationBar *navigationBar;
	
	//Page control for the ScrollView
	IBOutlet RSPageControl *pageControl;
	
    UIBarButtonItem* backItem;
}


//Properties
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) UIBarButtonItem *backItem;

@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) RSPageControl *pageControl;
@property(nonatomic,retain) UIView *page2;
@property(nonatomic,retain) UIWebView *web;

//Activities Properties

@property(nonatomic,retain) UILabel *volcanoLabel, *videoPlayerLabel, *settingsLabel, *resultsLabel;

- (IBAction) volcanoTouch:(id) sender;
- (IBAction) flowerHowTo:(id) sender;
- (IBAction) settingsTouch:(id) sender;
- (IBAction) calibrationTouch:(id) sender;
- (IBAction) resultsTouch:(id) sender;

- (IBAction) pageControlDidChangeValue:(id) sender;

-(void)backToMenu ;

@end
