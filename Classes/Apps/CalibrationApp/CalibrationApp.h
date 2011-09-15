//
//  CalibrationApp.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 12.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerApp.h"
#import "DoubleSlider.h"
#import "CalibrationApp_NeedleView.h"

@interface CalibrationApp : FlowerApp {
    IBOutlet UILabel *targetFrequencyRangeLabel;
	IBOutlet UILabel *minLabel;
	IBOutlet UILabel *maxLabel;
    
    IBOutlet UILabel *inRangeTextLabel;
	IBOutlet UILabel *inRangeValueLabel;
	IBOutlet UIButton *inRangeMinusButton;
	IBOutlet UIButton *inRangePlusButton;
    
    IBOutlet UILabel *durationTextLabel;
	IBOutlet UILabel *durationValueLabel;
	IBOutlet UIButton *durationMinusButton;
	IBOutlet UIButton *durationPlusButton;

    //double Slide
    IBOutlet DoubleSlider *slider;
    
    IBOutlet CalibrationApp_NeedleView *needle;

}



@property (nonatomic, retain) UILabel *targetFrequencyRangeLabel;
@property (nonatomic, retain) UILabel *minLabel;
@property (nonatomic, retain) UILabel *maxLabel;

@property (nonatomic, retain) UILabel *inRangeTextLabel;
@property (nonatomic, retain) UILabel *inRangeValueLabel;
@property (nonatomic, retain) UIButton *inRangeMinusButton;
@property (nonatomic, retain) UIButton *inRangePlusButton;

@property (nonatomic, retain) UILabel *durationTextLabel;
@property (nonatomic, retain) UILabel *durationValueLabel;
@property (nonatomic, retain) UIButton *durationMinusButton;
@property (nonatomic, retain) UIButton *durationPlusButton;

- (IBAction) pressInRangeMinus:(id) sender;
- (IBAction) pressInRangePlus:(id) sender;
- (IBAction) pressDurationMinus:(id) sender;
- (IBAction) pressDurationPlus:(id) sender;

@end
