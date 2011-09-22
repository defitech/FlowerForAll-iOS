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
#import "PickerEditor.h"
#import "Profil.h"

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
   
    
    
    //Exercice slider
    exerciceLabel.text = 
        [ParametersApp translate:@"ExerciceLabel" comment:@"Exerice duration target"];
    
    [exerciceSlider addTarget:self action:@selector(valueChangedForExericeSlider:) 
               forControlEvents:UIControlEventValueChanged];
    
    [exerciceSlider addTarget:self action:@selector(editingEndForExericeSlider:) 
               forControlEvents:UIControlEventTouchUpInside];
    
    [exerciceSlider setMinimumValue:0.0f];
    [exerciceSlider setMaximumValue:1.0f];
    
    
    [self reloadValues];
   
 }


- (void)reloadValues {
    [expirationSlider setValue:[[FlowerController currentFlapix] expirationDurationTarget] animated:true];
    [exerciceSlider setValue:[self exericeDurationSystemToSlider:[[FlowerController currentFlapix] exerciceDurationTarget]] animated:true];
    [self  valueChangedForExpirationSlider:expirationSlider];
    [self  valueChangedForExericeSlider:exerciceSlider];
}

- (void)viewWillAppear:(BOOL)animated {
     [self reloadValues];
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

# pragma mark profilPicker

- (void)showOptionView
{
    NSLog(@"ProfilPicker SHOW");
    PickerEditor* optionViewController = [[PickerEditor alloc] initWithDelegate:self];
    [optionViewController showOnTopOfView:self.view];
}

- (IBAction)profileButtonPushed:(id)sender {
    [self showOptionView];
}


- (void)pickerEditorIsDone:(PickerEditor*)sender {
    [self reloadValues];
}


-(NSString*)pickerEditorTitle:(PickerEditor*)sender {
    return [ParametersApp translate:@"ProfilManagementTitle" comment:@"Profil Management Title"];
}

-(NSString*)pickerEditorEndButtonTitle:(PickerEditor*)sender {
    return [ParametersApp translate:@"Done" comment:@"Back Button for Title management"];
}

NSArray* myProfils;
-(NSArray*)profils {
    if (myProfils == nil) {
        myProfils = [Profil getAll];
    }
    return myProfils;
}

/** return the number of choices **/
-(int)pickerEditorSize:(PickerEditor*)sender {
    return [[self profils] count];
}

/** return the true if the object at this index is selected **/
-(BOOL)pickerEditorIsSelected:(PickerEditor*)sender index:(int)index {
    return [(Profil*)[[self profils] objectAtIndex:index] isCurrent];
}

/** return the text to display for this element **/
-(NSString*)pickerEditorValue:(PickerEditor*)sender index:(int)index {
    return [(Profil*)[[self profils] objectAtIndex:index] name];
}

/** called when selection change on an element **/
-(void)pickerEditorSelectionChange:(PickerEditor*)sender index:(int)index {
    if ([self pickerEditorIsSelected:sender index:index]) return;
    [(Profil*)[[self profils] objectAtIndex:index] setCurrent];
    NSLog(@"Selected profil:%i",index);  
}

# pragma mark profilPicker

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
