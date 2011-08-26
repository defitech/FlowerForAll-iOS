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
	IBOutlet UILabel *targetFrequencyRangeLabel;
	IBOutlet UILabel *minLabel;
	IBOutlet UILabel *maxLabel;
    
	IBOutlet UILabel *expirationLabel;
	IBOutlet UILabel *expirationTimeLabel;
    
    IBOutlet UISlider *durationSlider;
    
    //double Slide
    IBOutlet DoubleSlider *slider;
    
    //two labels to show the currently selected values
	UILabel *leftLabel;
	UILabel *rightLabel;
	
}



//Properties
@property (nonatomic, retain) UISlider *durationSlider;
@property (nonatomic, retain) UILabel *targetFrequencyRangeLabel;
@property (nonatomic, retain) UILabel *minLabel;
@property (nonatomic, retain) UILabel *maxLabel;
@property (nonatomic, retain) UILabel *expirationLabel;
@property (nonatomic, retain) UILabel *expirationTimeLabel;



@end
