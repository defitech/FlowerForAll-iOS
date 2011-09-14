//
//  ParametersApp.m
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the ParametersApp class


#import "ParametersApp.h"
#import "FlowerController.h"
#import "ParametersManager.h"

@interface ParametersApp (PrivateMethods)
- (void)valueChangedForDurationSlider:(UISlider *)slider;
- (void)editingEndForDurationSlider:(UISlider *)slider;
@end


@implementation ParametersApp


@synthesize  durationLabel,
expirationLabel, expirationTimeLabel, expirationSlider,
exerciceLabel, exerciceTimeLabel, exerciceSlider;


# pragma mark utilities for non-linear progression of the exercice duration

float maxExerciceDuration_s = 120.0;
float minExerciceDuration_s = 7.0;

- (float)exericeDurationSliderToSystem:(float)sliderValue {
    return roundf(sliderValue*sliderValue*(maxExerciceDuration_s-minExerciceDuration_s)+minExerciceDuration_s);
}

- (float)exericeDurationSystemToSlider:(float)systemValue {
    return sqrtf((systemValue-minExerciceDuration_s)/(maxExerciceDuration_s-minExerciceDuration_s));
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];

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
 }



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    self.durationLabel = nil;
    self.expirationLabel = nil;
	self.expirationTimeLabel = nil;
    self.expirationSlider = nil;
    self.exerciceLabel = nil;
	self.exerciceTimeLabel = nil;
    self.exerciceSlider = nil;
}


- (void)dealloc {
    [super dealloc];
}




//Allows view to autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


@end
