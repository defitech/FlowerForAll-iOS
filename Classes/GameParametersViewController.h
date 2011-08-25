//
//  GameParametersViewController.h
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the view controller for the game parameters view


#import <UIKit/UIKit.h>
#import "DoubleSlider.h"

@interface GameParametersViewController : UIViewController {
	
	//Widgets
	IBOutlet UILabel *mainLabel;
	IBOutlet UILabel *minLabel;
	IBOutlet UILabel *maxLabel;
	IBOutlet UILabel *exerciseTimeLabel;
	IBOutlet UILabel *expirationTimeLabel;
	IBOutlet UILabel *hoursLabel;
	IBOutlet UILabel *minutesLabel;
	IBOutlet UILabel *secondsLabel;
	IBOutlet UIButton *personalValuesButton;
    
    //double Slide
    IBOutlet DoubleSlider *slider;
    
    //two labels to show the currently selected values
	UILabel *leftLabel;
	UILabel *rightLabel;
	
}


//Properties
@property (nonatomic, retain) UILabel *mainLabel;
@property (nonatomic, retain) UILabel *minLabel;
@property (nonatomic, retain) UILabel *maxLabel;
@property (nonatomic, retain) UILabel *exerciseTimeLabel;
@property (nonatomic, retain) UILabel *expirationTimeLabel;
@property (nonatomic, retain) UILabel *hoursLabel;
@property (nonatomic, retain) UILabel *minutesLabel;
@property (nonatomic, retain) UILabel *secondsLabel;
@property (nonatomic, retain) UIButton *personalValuesButton;


@end
