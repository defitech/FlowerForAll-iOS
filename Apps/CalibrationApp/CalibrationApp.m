//
//  CalibrationApp.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 12.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
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

@synthesize targetFrequencyRangeLabel, minLabel, maxLabel, lastFreqLabelValue, targetFreqLabelValue, lastFreqLabelTitle, goToDurationButton, slider;

# pragma mark FlowerApp overriding

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    return NSLocalizedStringFromTable(@"Calibration",@"CalibrationApp",@"CalibrationApp Title");
}


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	targetFrequencyRangeLabel.text = 
    NSLocalizedStringFromTable(@"Range of frequencies",@"CalibrationApp",@"Target Frequency Range");
    lastFreqLabelTitle.text = 
    NSLocalizedStringFromTable(@"Last Blow's frequency",@"CalibrationApp",@"Last Blow's frequency");
    [goToDurationButton setTitle:NSLocalizedStringFromTable(@"Duration settings",@"CalibrationApp",@"go to duration settings") forState:UIControlStateNormal];
    
	    
    
    double target = [[FlowerController currentFlapix] frequenceTarget];
    double toleranceH =  [[FlowerController currentFlapix] frequenceTolerance] ;
    
    
	targetFreqLabelValue.text = [NSString stringWithFormat:@"%1.1f Hz",target];     //????
    lastFreqLabelValue.text = [NSString stringWithFormat:@"%1.1f Hz", target];
    
    [self.slider setSelectedValues:(target - toleranceH) maxValue:(target + toleranceH)];
    
	
	//get the initial values
    //slider.transform = CGAffineTransformRotate(slider.transform, 90.0/180*M_PI);      //make it vertical
	[self valueChangedForDoubleSlider:slider];
    
    
    //DoubleSlider setup
	[slider addTarget:self action:@selector(valueChangedForDoubleSlider:) 
     forControlEvents:UIControlEventValueChanged];
    
    [self.slider addTarget:self action:@selector(editingEndForDoubleSlider:)
     forControlEvents:UIControlEventEditingDidEnd];
    
    // set last values
    [self flapixEventBlowStop: [[FlowerController currentFlapix] lastBlow]]; 
}

#pragma mark Control Event Handlers

- (void)valueChangedForDoubleSlider:(DoubleSlider *)aSlider
{
    dispatch_async(dispatch_get_main_queue(), ^{            // this block will run on the main thread
	minLabel.text = [NSString stringWithFormat:@"%1.1f Hz", aSlider.minSelectedValue];
	maxLabel.text = [NSString stringWithFormat:@"%1.1f Hz", aSlider.maxSelectedValue];
    
    double target = (aSlider.minSelectedValue + aSlider.maxSelectedValue) / 2;
    double tolerance =  (aSlider.maxSelectedValue - aSlider.minSelectedValue) / 2;
    targetFreqLabelValue.text = [NSString stringWithFormat:@"%1.1f Hz", target];
    [[FlowerController currentFlapix] SetTargetFrequency:target frequency_tolerance:tolerance];
    
    [needle setNeedsDisplay];
    });
}



- (void)editingEndForDoubleSlider:(DoubleSlider *)aSlider
{
	[self valueChangedForDoubleSlider:aSlider];
    
    double target = (aSlider.minSelectedValue + aSlider.maxSelectedValue) / 2;
    double tolerance =  (aSlider.maxSelectedValue - aSlider.minSelectedValue) / 2;
    
    [ParametersManager saveFrequency:target tolerance:tolerance];
}


- (void)flapixEventFrequency:(double)frequency in_target:(BOOL)good current_exercice:(double)percent_done {    
    //[needle setNeedsDisplay];
}

- (void)flapixEventBlowStop:(FLAPIBlow *)blow {
    dispatch_async(dispatch_get_main_queue(), ^{            // this block will run on the main thread
    lastFreqLabelValue.text = [NSString stringWithFormat:@"%1.1f Hz", blow.medianFrequency];
    NSArray* marks = [[[NSArray alloc] 
                        initWithObjects:[NSNumber numberWithFloat:(blow.medianFrequency - blow.medianTolerance)], 
                              [NSNumber numberWithFloat:(blow.medianFrequency + blow.medianTolerance)],
                              nil] autorelease];
    [self.slider setMarks:marks];
    });
}

- (void)flapixEventExerciceStart:(FLAPIExercice *)exercice {
    
}

- (void)flapixEventExerciceStop:(FLAPIExercice *)exercice {
    
}


- (IBAction) goToDurationAction:(id) sender {
    [FlowerController pushApp:@"ParametersApp" withUIViewAnimation:UIViewAnimationTransitionFlipFromLeft];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    id temp1 = targetFreqLabelValue;
    targetFreqLabelValue = nil;
    [temp1 release];
    id temp2 = targetFrequencyRangeLabel;
    targetFrequencyRangeLabel = nil;
    [temp2 release];
    id temp3 = maxLabel;
    maxLabel = nil;
    [temp3 release];
    id temp4 = minLabel;
    minLabel = nil;
    [temp4 release];
    
    //double Slider
    id temp5 = slider;
    slider = nil;
    [temp5 release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
