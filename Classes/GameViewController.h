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


@interface GameViewController : UIViewController <UIScrollViewDelegate>{

	//The sub views include mainly the scroll view, which will include game1ChoiceView and game2ChoiceView (for the moment there are 2 games)
	IBOutlet UIScrollView *scrollView;
    FLAPIview *flapiView;
	IBOutlet UIView *game1ChoiceView; // WebBrowser
	IBOutlet UIView *game2ChoiceView;
	
	//The buttons inside each of the game sub views
	IBOutlet UIButton *game1Button; // WebBrowser
	IBOutlet UIButton *game2Button;
	
	
	
	//There is no navigation controller here. So we add a navigation bar individually.
	IBOutlet UINavigationBar *navigationBar;
	
	//Page control for the ScrollView
	IBOutlet UIPageControl *pageControl;
	
}


//Properties
@property(nonatomic,retain) UIScrollView *scrollView;
@property(nonatomic,retain) FLAPIview *flapiView;
@property(nonatomic,retain) UIView *game1ChoiceView;
@property(nonatomic,retain) UIView *game2ChoiceView;

@property(nonatomic,retain) UIButton *game1Button;
@property(nonatomic,retain) UIButton *game2Button;


@property (nonatomic, retain) UINavigationBar *navigationBar;

@property (nonatomic, retain) UIPageControl *pageControl;

- (IBAction) game1Touch:(id) sender;
- (IBAction) game2Touch:(id) sender;


@end
