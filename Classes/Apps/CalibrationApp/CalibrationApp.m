//
//  CalibrationApp.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 12.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 * TODO:
 * - Init last values with last FLAPIBlow object values.
 * - Fix rules target for last value and keep it even for calibration blow.
 * - Rotate needle with calibration blow.
 * - Set InRange duration.
 */

#import "CalibrationApp.h"
#import "FlowerController.h"
#import "ParametersManager.h"

@interface CalibrationApp (PrivateMethods)
- (void)valueChangedForDoubleSlider:(DoubleSlider *)slider;
- (void)editingEndForDoubleSlider:(DoubleSlider *)slider;
@end

@implementation CalibrationApp

@synthesize targetFrequencyRangeLabel, minLabel, maxLabel, lastFreqLabel, inRangeLabel, lastDurationTextLabel, lastDurationValueLabel, calibrationTextLabel, calibrationValueLabel, calibrationMinusButton, calibrationPlusButton;

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	targetFrequencyRangeLabel.text = 
    [CalibrationApp translate:@"TargetFrequencyRangeLabel" comment:@"Target Frequency Range"];
    
    
    
	//DoubleSlider setup
	[slider addTarget:self action:@selector(valueChangedForDoubleSlider:) 
     forControlEvents:UIControlEventValueChanged];
    
    [slider addTarget:self action:@selector(editingEndForDoubleSlider:) 
     forControlEvents:UIControlEventEditingDidEnd];
    
    
    
    double target = [[FlowerController currentFlapix] frequenceTarget];
    double toleranceH =  [[FlowerController currentFlapix] frequenceTolerance] ;
    
	[slider setSelectedValues:(target - toleranceH) maxValue:(target+ toleranceH)];
    
	
	//get the initial values
    //slider.transform = CGAffineTransformRotate(slider.transform, 90.0/180*M_PI);      //make it vertical
	[self valueChangedForDoubleSlider:slider];
    
    lastFreqLabel.text = [NSString stringWithFormat:@"%1.1f Hz", target];

}

#pragma mark Control Event Handlers

- (void)valueChangedForDoubleSlider:(DoubleSlider *)aSlider
{
	minLabel.text = [NSString stringWithFormat:@"%1.1f Hz", aSlider.minSelectedValue];
	maxLabel.text = [NSString stringWithFormat:@"%1.1f Hz", aSlider.maxSelectedValue];
    
    double target = (aSlider.minSelectedValue + aSlider.maxSelectedValue) / 2;
    double tolerance =  (aSlider.maxSelectedValue - aSlider.minSelectedValue) / 2;
    
    [[FlowerController currentFlapix] SetTargetFrequency:target frequency_tolerance:tolerance];
    
    [needle setNeedsDisplay];
}



- (void)editingEndForDoubleSlider:(DoubleSlider *)aSlider
{
	[self valueChangedForDoubleSlider:aSlider];
    
    double target = (aSlider.minSelectedValue + aSlider.maxSelectedValue) / 2;
    double tolerance =  (aSlider.maxSelectedValue - aSlider.minSelectedValue) / 2;
    
    [ParametersManager saveFrequency:target tolerance:tolerance];
}


- (void)flapixEventFrequency:(double)frequency in_target:(BOOL)good {    
    [needle calcRotation:frequency];
    [needle setNeedsDisplay];
}

- (void)flapixEventBlowStop:(FLAPIBlow *)blow {
    
}

- (void)flapixEventExerciceStart:(FLAPIExercice *)exercice {
    
}

- (void)flapixEventExerciceStop:(FLAPIExercice *)exercice {
    
}

- (IBAction) pressCalibrationMinus:(id) sender {
    NSLog(@"pressCalibrationMinus");
}

- (IBAction) pressCalibrationPlus:(id) sender {
    NSLog(@"pressCalibrationPlus");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.targetFrequencyRangeLabel = nil;
	self.minLabel = nil;
	self.maxLabel = nil;
    
    //double Slider
    [slider release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
