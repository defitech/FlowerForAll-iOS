//
//  GameParametersViewController.m
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the GameParametersViewController class


#import "GameParametersViewController.h"
#import "DoubleSlider.h"
#import "FlowerController.h"
#import "ParametersManager.h"

@interface GameParametersViewController (PrivateMethods)
- (void)valueChangedForDoubleSlider:(DoubleSlider *)slider;
- (void)editingEndForDoubleSlider:(DoubleSlider *)slider;
- (void)valueChangedForDurationSlider:(UISlider *)slider;
- (void)editingEndForDurationSlider:(UISlider *)slider;
@end


@implementation GameParametersViewController


@synthesize targetFrequencyRangeLabel, minLabel, maxLabel, durationLabel,
expirationLabel, expirationTimeLabel, expirationSlider,
exerciceLabel, exerciceTimeLabel, exerciceSlider;



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
	
	targetFrequencyRangeLabel.text = NSLocalizedString(@"TargetFrequencyRangeLabel", @"Target Frequency Range");
	durationLabel.text = NSLocalizedString(@"DurationLabel", @"DurationExplanantion");
	
    
    //Expiration slider
    expirationLabel.text = NSLocalizedString(@"ExpirationLabel", @"Expiration duration target");
    [expirationSlider addTarget:self action:@selector(valueChangedForExpirationSlider:) 
             forControlEvents:UIControlEventValueChanged];
    
    [expirationSlider addTarget:self action:@selector(editingEndForExpirationSlider:) 
             forControlEvents:UIControlEventTouchUpInside];
    
    [expirationSlider setMinimumValue:0.2f];
    [expirationSlider setMaximumValue:5.0f];
    [expirationSlider setValue:[[FlowerController currentFlapix] expirationDurationTarget]];
    
    
    //Exercice slider
     exerciceLabel.text = NSLocalizedString(@"ExerciceLabel", @"Exerice duration target");
    [exerciceSlider addTarget:self action:@selector(valueChangedForExericeSlider:) 
               forControlEvents:UIControlEventValueChanged];
    
    [exerciceSlider addTarget:self action:@selector(editingEndForExericeSlider:) 
               forControlEvents:UIControlEventTouchUpInside];
    
    [exerciceSlider setMinimumValue:0.0f];
    [exerciceSlider setMaximumValue:1.0f];
    [exerciceSlider setValue:[[FlowerController currentFlapix] expirationDurationTarget]];
    
    
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
    
    expirationTimeLabel.text = [NSString stringWithFormat:@"%1.1f s", aSlider.value];
    
}

- (void)editingEndForExpirationSlider:(UISlider *)aSlider
{
    [self   valueChangedForExpirationSlider:aSlider];
    float duration =  aSlider.value;
    [ParametersManager saveExpirationDuration:duration];
    
}

- (void)valueChangedForExericeSlider:(UISlider *)aSlider
{
    int duration = 10 + (int)70* aSlider.value;
    exerciceTimeLabel.text = [NSString stringWithFormat:@"%i s", duration];
    
}

- (void)editingEndForExericeSlider:(UISlider *)aSlider
{
    [self   valueChangedForExericeSlider:aSlider];
     int duration = 10 + (int)70* aSlider.value;
    [ParametersManager saveExerciceDuration:(float)duration];
    
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




//Allows view to autorotate in all directions
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}


@end
