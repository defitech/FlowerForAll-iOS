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
	IBOutlet UILabel *lastFreqLabel;
    
    IBOutlet UILabel *inRangeLabel;
    
    IBOutlet UILabel *lastDurationTextLabel;
	IBOutlet UILabel *lastDurationValueLabel;

    IBOutlet UILabel *calibrationTextLabel;
	IBOutlet UILabel *calibrationValueLabel;
	IBOutlet UIButton *calibrationMinusButton;
	IBOutlet UIButton *calibrationPlusButton;

    //double Slide
    IBOutlet DoubleSlider *slider;
    
    IBOutlet CalibrationApp_NeedleView *needle;

}



@property (nonatomic, retain) UILabel *targetFrequencyRangeLabel;
@property (nonatomic, retain) UILabel *minLabel;
@property (nonatomic, retain) UILabel *maxLabel;
@property (nonatomic, retain) UILabel *lastFreqLabel;

@property (nonatomic, retain) UILabel *inRangeLabel;

@property (nonatomic, retain) UILabel *lastDurationTextLabel;
@property (nonatomic, retain) UILabel *lastDurationValueLabel;

@property (nonatomic, retain) UILabel *calibrationTextLabel;
@property (nonatomic, retain) UILabel *calibrationValueLabel;
@property (nonatomic, retain) UIButton *calibrationMinusButton;
@property (nonatomic, retain) UIButton *calibrationPlusButton;

- (IBAction) pressCalibrationMinus:(id) sender;
- (IBAction) pressCalibrationPlus:(id) sender;

@end
