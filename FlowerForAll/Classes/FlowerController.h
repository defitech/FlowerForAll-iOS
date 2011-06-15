//
//  FlowerController.h
//  FlutterApp2
//
//  Created by Pierre-Mikael Legris on 07.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLAPIView.h"
#import "SettingsViewController.h"
#import "StatisticsViewController.h";

@interface FlowerController : UIViewController <UIActionSheetDelegate> {
    UIView *mainView;
    FLAPIView *flapiView;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet FLAPIView *flapiView;

// show navigation action sheet
+ (void) showNav;



// get Settings view Controller
+ (SettingsViewController*) getSettingsViewController;

// get Statistics view Controller
+ (StatisticsViewController*) getStatisticsViewController;


@end
