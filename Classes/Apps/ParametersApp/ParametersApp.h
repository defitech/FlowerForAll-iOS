//
//  ParametersApp.h
//  FlutterApp2
//
//  Created by Dev on 27.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class is the view controller for the game parameters view


#import <UIKit/UIKit.h>

#import "FlowerApp.h"
#import "PickerEditor.h"

@interface ParametersApp : FlowerApp <PickerEditorDelegate> {
	
	//Widgets
    IBOutlet UILabel *durationLabel;
    
    IBOutlet UILabel *playBackLabel;
    IBOutlet UISlider *playBackSlider;
    
	IBOutlet UILabel *expirationLabel;
	IBOutlet UILabel *expirationTimeLabel;
    IBOutlet UISlider *expirationSlider;
    
    IBOutlet UILabel *exerciceLabel;
	IBOutlet UILabel *exerciceTimeLabel;
    IBOutlet UISlider *exerciceSlider;
    
    IBOutlet UIButton *buttonProfile;
    
    
    IBOutlet UIButton *goToCalibrationButton;
    
}



//Properties

@property (nonatomic, retain) UILabel *playBackLabel;
@property (nonatomic, retain) UISlider *playBackSlider;

@property (nonatomic, retain) UILabel *durationLabel;

@property (nonatomic, retain) UILabel *expirationLabel;
@property (nonatomic, retain) UILabel *expirationTimeLabel;
@property (nonatomic, retain) UISlider *expirationSlider;


@property (nonatomic, retain) UILabel *exerciceLabel;
@property (nonatomic, retain) UILabel *exerciceTimeLabel;
@property (nonatomic, retain) UISlider *exerciceSlider;

@property (nonatomic, retain) UIButton *buttonProfile;
@property (nonatomic, retain) UIButton *goToCalibrationButton;

- (IBAction)profileButtonPushed:(id)sender;
- (IBAction)goToCalibration:(id)sender;

- (void)reloadValues ;

- (void)valueChangedForExpirationSlider:(UISlider *)aSlider;
- (void)valueChangedForExericeSlider:(UISlider *)aSlider;



@end
