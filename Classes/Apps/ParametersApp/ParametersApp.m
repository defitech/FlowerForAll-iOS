//
//  ParametersApp.m
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the ParametersApp class


#import "ParametersApp.h"
#import "DoubleSlider.h"
#import "FlowerController.h"
#import "ParametersManager.h"

@interface ParametersApp (PrivateMethods)
- (void)valueChangedForDoubleSlider:(DoubleSlider *)slider;
- (void)editingEndForDoubleSlider:(DoubleSlider *)slider;
- (void)valueChangedForDurationSlider:(UISlider *)slider;
- (void)editingEndForDurationSlider:(UISlider *)slider;
@end


@implementation ParametersApp


@synthesize targetFrequencyRangeLabel, minLabel, maxLabel, durationLabel,
expirationLabel, expirationTimeLabel, expirationSlider,
exerciceLabel, exerciceTimeLabel, exerciceSlider;


# pragma mark utilities for non-linear progression of the exercice duration

float maxExecriceDuration_s = 120.0;
float minExecriceDuration_s = 7.0;

- (float)exericeDurationSliderToSystem:(float)sliderValue {
    return roundf(sliderValue*sliderValue*(maxExecriceDuration_s-minExecriceDuration_s)+minExecriceDuration_s);
}

- (float)exericeDurationSystemToSlider:(float)systemValue {
    return sqrtf((systemValue-minExecriceDuration_s)/(maxExecriceDuration_s-minExecriceDuration_s));
}



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	targetFrequencyRangeLabel.text = 
        [ParametersApp translate:@"TargetFrequencyRangeLabel" comment:@"Target Frequency Range"];
	durationLabel.text = 
        [ParametersApp translate:@"DurationLabel" comment:@"DurationExplanantion"];
	
    
    //Expiration slider
    expirationLabel.text = 
        [ParametersApp translate:@"ExpirationLabel" comment:@"Expiration duration target"];
    
    [expirationSlider addTarget:self action:@selector(valueChangedForExpirationSlider:) 
             forControlEvents:UIControlEventValueChanged];
    
    [expirationSlider addTarget:self action:@selector(editingEndForExpirationSlider:) 
             forControlEvents:UIControlEventTouchUpInside];
    
    [expirationSlider setMinimumValue:0.2f];
    [expirationSlider setMaximumValue:5.0f];
    [expirationSlider setValue:[[FlowerController currentFlapix] expirationDurationTarget]];
    
    
    //Exercice slider
    exerciceLabel.text = 
        [ParametersApp translate:@"ExerciceLabel" comment:@"Exerice duration target"];
    
    [exerciceSlider addTarget:self action:@selector(valueChangedForExericeSlider:) 
               forControlEvents:UIControlEventValueChanged];
    
    [exerciceSlider addTarget:self action:@selector(editingEndForExericeSlider:) 
               forControlEvents:UIControlEventTouchUpInside];
    
    [exerciceSlider setMinimumValue:0.0f];
    [exerciceSlider setMaximumValue:1.0f];
    [exerciceSlider setValue:[self exericeDurationSystemToSlider:[[FlowerController currentFlapix] exerciceDurationTarget]]];
    
    
    [self  valueChangedForExpirationSlider:expirationSlider];
    [self  valueChangedForExericeSlider:exerciceSlider];
    
    
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



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/



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

- (void)valueChangedForExpirationSlider:(UISlider *)aSlider
{
    
    expirationTimeLabel.text = [NSString stringWithFormat:@"%1.1f s",(float) aSlider.value];
    
}

- (void)editingEndForExpirationSlider:(UISlider *)aSlider
{
    [self   valueChangedForExpirationSlider:aSlider];
    [ParametersManager saveExpirationDuration:(float)aSlider.value];
    
}

- (void)valueChangedForExericeSlider:(UISlider *)aSlider
{
    exerciceTimeLabel.text = [NSString stringWithFormat:@"%1.1f s",[self exericeDurationSliderToSystem:(float) aSlider.value]];
    
}

- (void)editingEndForExericeSlider:(UISlider *)aSlider
{
    [self   valueChangedForExericeSlider:aSlider];
    [ParametersManager saveExerciceDuration:[self exericeDurationSliderToSystem:(float) aSlider.value]];
    
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}




//Allows view to autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


@end
