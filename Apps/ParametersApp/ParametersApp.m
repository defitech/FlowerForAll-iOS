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
#import "ParametersAppPickerProfileCell.h"
#import <PryvApiKit/PryvApiKit.h>
#import "PryvAccess.h"

@interface ParametersApp (PrivateMethods) <PYWebLoginDelegate>
- (void)valueChangedForDurationSlider:(UISlider *)slider;
- (void)editingEndForDurationSlider:(UISlider *)slider;
@end


@implementation ParametersApp


@synthesize  durationLabel, playBackLabel, playBackSlider,
expirationLabel, expirationTimeLabel, expirationSlider,
exerciceLabel, exerciceTimeLabel, exerciceSlider, buttonProfile, goToCalibrationButton, buttonPryvLogin;

# pragma mark FlowerApp overriding

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    return NSLocalizedStringFromTable(@"Settings",@"ParametersApp",@"ParametersApp Title");
}


# pragma mark utilities for non-linear progression of the exercice duration

float maxExerciceDuration_s = 480.0;
float minExerciceDuration_s = 7.0;

- (float)exerciceDurationSliderToSystem:(float)sliderValue {
    return roundf(sliderValue*sliderValue*(maxExerciceDuration_s-minExerciceDuration_s)+minExerciceDuration_s);
}

- (float)exerciceDurationSystemToSlider:(float)systemValue {
    return sqrtf((systemValue-minExerciceDuration_s)/(maxExerciceDuration_s-minExerciceDuration_s));
}




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];

	durationLabel.text = 
         NSLocalizedStringFromTable(@"Durations: periods when the Flutter® VRP1 vibrates in the targeted range of frequencies.",@"ParametersApp",@"DurationExplanantion");
	
    
    //Volume slider
    playBackLabel.text = 
     NSLocalizedStringFromTable(@"PlayBack Volume",@"ParametersApp",@"PlayBack Volume");
    
    [playBackSlider addTarget:self action:@selector(valueChangedForPlayBackSlider:) 
               forControlEvents:UIControlEventValueChanged];
    
    [playBackSlider addTarget:self action:@selector(editingEndForPlayBackSlider:) 
               forControlEvents:UIControlEventTouchUpInside];
    
    [playBackSlider setMinimumValue:0.0f];
    [playBackSlider setMaximumValue:1.0f];
    
    //Expiration slider
    expirationLabel.text = 
       NSLocalizedStringFromTable(@"Blow duration target",@"ParametersApp",@"Blow duration target");
    
    [expirationSlider addTarget:self action:@selector(valueChangedForExpirationSlider:) 
             forControlEvents:UIControlEventValueChanged];
    
    [expirationSlider addTarget:self action:@selector(editingEndForExpirationSlider:) 
             forControlEvents:UIControlEventTouchUpInside];
    
    [expirationSlider setMinimumValue:0.2f];
    [expirationSlider setMaximumValue:25.0f];
   
    
    
    //Exercice slider
    exerciceLabel.text = 
        NSLocalizedStringFromTable(@"Exercice duration target",@"ParametersApp",@"Exercice duration target");
    
    [exerciceSlider addTarget:self action:@selector(valueChangedForExerciceSlider:) 
               forControlEvents:UIControlEventValueChanged];
    
    [exerciceSlider addTarget:self action:@selector(editingEndForExerciceSlider:) 
               forControlEvents:UIControlEventTouchUpInside];
    
    [exerciceSlider setMinimumValue:0.0f];
    [exerciceSlider setMaximumValue:1.0f];
    
    [goToCalibrationButton setTitle:NSLocalizedStringFromTable(@"Calibration",@"ParametersApp",@"go to calibration settings") forState:UIControlStateNormal];

    
    [self reloadValues];
    [self refreshPryvButton];
   
 }


- (void)reloadValues {
    [expirationSlider setValue:[[FlowerController currentFlapix] expirationDurationTarget] animated:true];
    [exerciceSlider setValue:[self exerciceDurationSystemToSlider:[[FlowerController currentFlapix] exerciceDurationTarget]] animated:true];
    [playBackSlider setValue:[[FlowerController currentFlapix] playBackVolume] animated:true];
    [self  valueChangedForExpirationSlider:expirationSlider];
    [self  valueChangedForExerciceSlider:exerciceSlider];
    
    [buttonProfile setTitle:[NSString stringWithFormat:@"%@ : %@",NSLocalizedStringFromTable(@"Profile",@"ParametersApp",@" Profile Button with title"),[[Profil current] name ]] forState:UIControlStateNormal];
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


- (void)valueChangedForPlayBackSlider:(UISlider *)aSlider
{
    [[FlowerController currentFlapix] SetPlayBackVolume:(float) aSlider.value];
}

- (void)editingEndForPlayBackSlider:(UISlider *)aSlider
{
    [ParametersManager savePlayBackVolume:(float) aSlider.value];
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

- (void)valueChangedForExerciceSlider:(UISlider *)aSlider
{
    int s = (int)[self exerciceDurationSliderToSystem:(float) aSlider.value];
    int m = (int) (s/60);
    s = s - (60 * m);
    //NSLog(@"%i m %i s",m,s);
    
    exerciceTimeLabel.text = [NSString stringWithFormat:@"%i m %i s",m,s];
    
}

- (void)editingEndForExerciceSlider:(UISlider *)aSlider
{
    [self   valueChangedForExerciceSlider:aSlider];
    [ParametersManager saveExerciceDuration:[self exerciceDurationSliderToSystem:(float) aSlider.value]];
    
}


# pragma mark Pryv

- (void)pryvButtonPushed:(id)sender {
    PryvAccess* pryv = [PryvAccess current];
    if (pryv) { // logout
        [PryvAccess disconnect];
        [self refreshPryvButton];
        return;
    }
    
    
    NSArray *permissions = @[ @{ kPYAPIConnectionRequestStreamId: @"flowerBreath",
                                 @"defaultName": @"FlowerBreath",
                                 kPYAPIConnectionRequestLevel: kPYAPIConnectionRequestManageLevel}];
    
    //[PYClient setDefaultDomainStaging];
    
    __unused
    PYWebLoginViewController *webLoginController =
    [PYWebLoginViewController requestConnectionWithAppId:@"defitech-flowerbreath"
                                          andPermissions:permissions
                                                delegate:self];
}



- (UIViewController *)pyWebLoginGetController {
    return self;
}

- (void)pyWebLoginSuccess:(PYConnection*)pyAccess {
    NSLog(@"Signin With Success %@ %@", pyAccess.userID, pyAccess.accessToken);
   [pyAccess synchronizeTimeWithSuccessHandler:nil errorHandler:nil];
   [PryvAccess setCurrent:pyAccess];
   [self refreshPryvButton];
}

- (void)pyWebLoginAborted:(NSString*)reason {
    NSLog(@"Signin Aborted: %@",reason);
}

- (void) pyWebLoginError:(NSError*)error {
    NSLog(@"Signin Error: %@",error);
}


- (void) refreshPryvButton {
    PryvAccess* pryv = [PryvAccess current];
    if (pryv) { // logout
        [self.buttonPryvLogin setTitle:[NSString stringWithFormat:@"%@ %@",NSLocalizedStringFromTable(@"Logout from Pryv:",@"ParametersApp",@" Pryv logout indicator"), [pryv userName]] forState:UIControlStateNormal];
    } else {
         [self.buttonPryvLogin setTitle:NSLocalizedStringFromTable(@"Use Pryv to save data",@"ParametersApp",@" Pryv login indicator") forState:UIControlStateNormal];
    }
    
}


# pragma mark profilPicker

- (void)showOptionView
{
    PickerEditor* optionViewController = [[PickerEditor alloc] initWithDelegate:self useCellNib:@"ParametersAppPickerProfileCell"];
    [optionViewController showOnTopOfView:self.view];
}

- (IBAction)profileButtonPushed:(id)sender {
    [self showOptionView];
}


- (void)pickerEditorIsDone:(PickerEditor*)sender {
    [self reloadValues];
}


-(NSString*)pickerEditorTitle:(PickerEditor*)sender {
    return  NSLocalizedStringFromTable(@"Profiles",@"ParametersApp",@"Profil Management Title");
}

-(NSString*)pickerEditorEndButtonTitle:(PickerEditor*)sender {
    return  NSLocalizedStringFromTable(@"Done",@"ParametersApp",@"Back Button for Title management");
}

NSArray* myProfils;
-(NSArray*)profils {
    //if (myProfils == nil) {
        myProfils = [Profil getAll];
    //}
    return myProfils;
}

/** return the number of choices **/
-(int)pickerEditorSize:(PickerEditor*)sender {
    return [[self profils] count];
}



-(void)pimpCellAt:(PickerEditor *)sender cell:(UITableViewCell *)cell index:(int)index {
    ParametersAppPickerProfileCell* pcell = (ParametersAppPickerProfileCell*)cell;
    Profil* p = (Profil*)[[self profils] objectAtIndex:index];
    pcell.nameLabel.text = p.name;
    pcell.minHzLabel.text = [NSString stringWithFormat:@"%1.1f Hz",[p frequenceMin]];
    pcell.maxHzLabel.text = [NSString stringWithFormat:@"%1.1f Hz",[p frequenceMax]];
    pcell.exeDLabel.text = [NSString stringWithFormat:@"%1.0f s",[p duration_exercice_s]];
    pcell.expDLabel.text = [NSString stringWithFormat:@"%1.0f s",[p duration_expiration_s]];
    if ([p isCurrent]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark]; 
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone]; 
    }

    
    pcell = nil;
    p = nil;
}



/** called when selection change on an element **/
-(void)pickerEditorSelectedRowAt:(PickerEditor*)sender index:(int)index {
    Profil* p = (Profil*)[[self profils] objectAtIndex:index];
    if ([p isCurrent]) return;
    [p setCurrent];
    p = nil;
}

# pragma mark navigation

- (void)goToCalibration:(id)sender {
    [FlowerController pushApp:@"CalibrationApp" withUIViewAnimation:UIViewAnimationTransitionFlipFromLeft];
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
    self.buttonProfile = nil;
}


- (void)dealloc {
    [super dealloc];
}




//Allows view to autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


@end
