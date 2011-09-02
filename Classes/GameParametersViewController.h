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
    
    
    IBOutlet UILabel *durationLabel;
    
	IBOutlet UILabel *expirationLabel;
	IBOutlet UILabel *expirationTimeLabel;
    IBOutlet UISlider *expirationSlider;
    
    IBOutlet UILabel *exerciceLabel;
	IBOutlet UILabel *exerciceTimeLabel;
    IBOutlet UISlider *exerciceSlider;
    
    //double Slide
    IBOutlet DoubleSlider *slider;
    
    //two labels to show the currently selected values
	UILabel *leftLabel;
	UILabel *rightLabel;
	
}



//Properties

@property (nonatomic, retain) UILabel *targetFrequencyRangeLabel;
@property (nonatomic, retain) UILabel *minLabel;
@property (nonatomic, retain) UILabel *maxLabel;

@property (nonatomic, retain) UILabel *durationLabel;

@property (nonatomic, retain) UILabel *expirationLabel;
@property (nonatomic, retain) UILabel *expirationTimeLabel;
@property (nonatomic, retain) UISlider *expirationSlider;


@property (nonatomic, retain) UILabel *exerciceLabel;
@property (nonatomic, retain) UILabel *exerciceTimeLabel;
@property (nonatomic, retain) UISlider *exerciceSlider;



- (void)valueChangedForExpirationSlider:(UISlider *)aSlider;
- (void)valueChangedForExericeSlider:(UISlider *)aSlider;

@end
