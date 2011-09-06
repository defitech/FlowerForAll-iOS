//
//  GameViewController.h
//  FlutterApp2
//
//  Created by Dev on 24.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the view controller for the game view. It handles notably a scroll view, allowing the user to scroll between the different games.


#import <UIKit/UIKit.h>
#import "FLAPIview.h"

#import "RSPageControl.h"


@interface GameViewController : UIViewController <UIScrollViewDelegate>{

	//The sub views include mainly the scroll view, which will include game1ChoiceView and game2ChoiceView (for the moment there are 2 games)
	IBOutlet UIScrollView *scrollView;
    
    // Activities
    FLAPIview *volcanoGame;
    UIView *webBrowserView; 
    UIView *videoPlayerView;
	
	//The buttons inside each of the game sub views
    IBOutlet UILabel *volcanoLabel, *webBrowserLabel, *videoPlayerLabel, *settingsLabel;

	
	//There is no navigation controller here. So we add a navigation bar individually.
	IBOutlet UINavigationBar *navigationBar;
	
	//Page control for the ScrollView
	IBOutlet RSPageControl *pageControl;
	
}


//Properties
@property(nonatomic,retain) UIScrollView *scrollView;

@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) RSPageControl *pageControl;

//Activities Properties

@property(nonatomic,retain) UILabel *volcanoLabel, *webBrowserLabel, *videoPlayerLabel, *settingsLabel;

- (IBAction) volcanoTouch:(id) sender;
- (IBAction) webBrowserTouch:(id) sender;
- (IBAction) videoPlayerTouch:(id) sender;
- (IBAction) settingsTouch:(id) sender;

- (IBAction) pageControlDidChangeValue:(id) sender;


@end
