//
//  CalibrationApp.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 12.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalibrationApp.h"
#import "FlowerController.h"
#import "ParametersManager.h"

@interface CalibrationApp (PrivateMethods)
- (void)valueChangedForDoubleSlider:(DoubleSlider *)slider;
- (void)editingEndForDoubleSlider:(DoubleSlider *)slider;
@end

@implementation CalibrationApp

@synthesize targetFrequencyRangeLabel, minLabel, maxLabel;

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
    double toleranceH =  [[FlowerController currentFlapix] frequenceTolerance] / 2;
    
	[slider setSelectedValues:(target - toleranceH) maxValue:(target+ toleranceH)];
    
	
	//get the initial values
    //slider.transform = CGAffineTransformRotate(slider.transform, 90.0/180*M_PI);      //make it vertical
	[self valueChangedForDoubleSlider:slider];

}

#pragma mark Control Event Handlers

- (void)valueChangedForDoubleSlider:(DoubleSlider *)aSlider
{
	minLabel.text = [NSString stringWithFormat:@"%1.1f Hz", aSlider.minSelectedValue];
	maxLabel.text = [NSString stringWithFormat:@"%1.1f Hz", aSlider.maxSelectedValue];
    
    double target = (aSlider.minSelectedValue + aSlider.maxSelectedValue) / 2;
    double tolerance =  aSlider.maxSelectedValue - aSlider.minSelectedValue;
    
    [[FlowerController currentFlapix] SetTargetFrequency:target frequency_tolerance:tolerance];
    
}



- (void)editingEndForDoubleSlider:(DoubleSlider *)aSlider
{
	[self valueChangedForDoubleSlider:aSlider];
    
    double target = (aSlider.minSelectedValue + aSlider.maxSelectedValue) / 2;
    double tolerance =  aSlider.maxSelectedValue - aSlider.minSelectedValue;
    
    [ParametersManager saveFrequency:target tolerance:tolerance];
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
