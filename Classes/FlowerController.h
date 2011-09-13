//
//  FlowerController.h
//  FlutterApp2
//
//  Created by Pierre-Mikael Legris on 07.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NeedleGL.h"
#import "StatisticsViewController.h"
#import "FLAPIX.h"
#import "HistoryViewController.h"
#import "ParametersApp.h"

@interface FlowerController : UIViewController <UIActionSheetDelegate> {
    UIView *mainView;
    HistoryViewController *historyViewController;
    
   

}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) HistoryViewController *historyViewController;

// show navigation action sheet
+ (void) showNav;


+ (FlowerController*) currentFlower;

+ (FLAPIX*) currentFlapix;

/** 
 *called by Button on the UINavBar 
 *This is a shortcut to a pushMenu static call
 **/
- (void)goToMenu: (id) sender  ;

/** show The Menu **/
+ (void)pushMenu ;

/** Promote an App as current Main COntroller **/ 
+ (void) pushApp:(NSString*) flowerApp ;

+(void)setCurrentMainController:(UIViewController*)thisController;

@end
