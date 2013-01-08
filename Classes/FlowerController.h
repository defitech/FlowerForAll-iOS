//
//  FlowerController.h
//  FlutterApp2
//
//  Created by Pierre-Mikael Legris (Perki) on 07.06.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NeedleGL.h"
#import "FLAPIX.h"
#import "ParametersApp.h"
#import "HistoryGL.h"


@interface FlowerController : UIViewController <UIActionSheetDelegate> {
    UIView *mainView;
    NeedleGL *needleGL;
    IBOutlet UIButton *menuButton;
    UIButton *startButton;
    //HistoryView *historyView;
    HistoryGL *historyGL;
}

//@property (nonatomic, retain) IBOutlet HistoryView *historyView;
@property (nonatomic, retain) IBOutlet NeedleGL *needleGL;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIButton *menuButton;
@property (nonatomic, retain) IBOutlet HistoryGL *historyGL;

- (IBAction) showMenu: (id) sender;

// show navigation action sheet
+ (void) showNav;


// current State and shortcuts
+ (FlowerController*) currentFlower;
+ (FLAPIX*) currentFlapix;
/** normally called when a use is set **/
+ (void) initFlapix ;

// utils to monitor FLowerController State
/** return true is a start Button should be shown **/
+ (BOOL) shouldShowStartButton;

/** 
 *called by Button on the UINavBar 
 *This is a shortcut to a pushMenu static call
 **/
- (void)goToMenu: (id) sender  ;

/** show The Menu **/
+ (void)pushMenu ;


/** show User chooser **/
+ (void)chooseUser ;

/** Promote an App as current Main COntroller **/ 
+ (void) pushApp:(NSString*) flowerApp ;
+ (void) pushApp:(NSString*) flowerApp withUIViewAnimation:(UIViewAnimationTransition)transition;

+ (void) setCurrentMainController:(UIViewController*)thisController;
+ (void) setCurrentMainController:(UIViewController*)thisController withUIViewAnimation:(UIViewAnimationTransition)transition;
@end

