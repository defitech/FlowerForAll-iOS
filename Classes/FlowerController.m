//
//  FlowerController.m
//  FlutterApp2
//
//  Created by Pierre-Mikael Legris (Perki) on 07.06.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "FlowerController.h"
#import "MenuView.h"
#import "ParametersApp.h"
#import "FlutterApp2AppDelegate.h"
#import "ParametersManager.h"

#import "UserManager.h"

#import "DataAccess.h"


@implementation FlowerController

@synthesize mainView, menuButton, needleGL, historyView; 
static FlowerController *singleton;
static UIViewController *currentMainController ;
static MenuView* activitiesViewController;
static FLAPIX* flapix;


/** 
 * known application lists 
 * responsible of singelton management
 **/
static NSMutableDictionary* appList;

# pragma mark View Control

/** called by Button on the UINavBar **/
-(void) goToMenu: (id) sender {
    [FlowerController pushMenu];
}

- (void) showMenu: (id) sender {
    [FlowerController pushMenu];
}

/** Promote the Menu as current Main Controller **/ 
+(void) pushMenu {
    if (activitiesViewController == nil) {
        activitiesViewController = [[MenuView alloc] initWithNibName:@"MenuView" bundle:[NSBundle mainBundle]];
    }
    if (currentMainController == nil) {
        currentMainController = activitiesViewController;
    } else {
        [FlowerController setCurrentMainController:activitiesViewController];
    }
    [activitiesViewController backToMenu];
}






/** 
 * normaly you should call goTo Menu to set the Menu 
 * If you decide to push your own view a currentMainController you then need to 
 * handle your retain / release yourself
 **/
+(void)setCurrentMainController:(UIViewController*)thisController {
    [FlowerController setCurrentMainController:thisController withUIViewAnimation:UIViewAnimationTransitionNone];
}

/** 
 * normaly you should call goTo Menu to set the Menu 
 * If you decide to push your own view a currentMainController you then need to 
 * handle your retain / release yourself
 **/
+(void)setCurrentMainController:(UIViewController*)thisController withUIViewAnimation:(UIViewAnimationTransition)transition {
    if ([currentMainController isKindOfClass:[thisController class]]) {
        NSLog(@"FLowerController: setCurrentMainController Skip");
        return;
    }
    if (! [singleton isKindOfClass:[FlowerController class]]) {
        NSLog(@"** Something went bad we've lost FLowerController Singleton");
        return;
    }
    BOOL animated = transition != UIViewAnimationTransitionNone;
    [currentMainController viewWillDisappear:animated];
    [thisController viewWillAppear:animated];
    
    UIViewController *previousViewController = currentMainController;
    currentMainController = thisController;
    
    if ( transition != UIViewAnimationTransitionNone) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:transition
                               forView:singleton.mainView
                                 cache:YES];
    }
    [singleton.mainView addSubview:currentMainController.view];
    if ( transition != UIViewAnimationTransitionNone) {
        [UIView commitAnimations];
    }
    
    
    
    [previousViewController viewDidDisappear:animated];
    [previousViewController.view removeFromSuperview];
    [singleton.mainView setNeedsLayout];
    [currentMainController viewDidAppear:animated];
}


# pragma user chooser

/** show User chooser **/
+ (void)chooseUser {
   
}


# pragma mark window management

/** Promote an App as current Main Controller **/ 
+ (void) pushApp:(NSString*) flowerApp {
    // [FlowerController pushMail];
    [FlowerController pushApp:flowerApp withUIViewAnimation:UIViewAnimationTransitionNone];
}

/** Promote an App as current Main Controller **/ 
+ (void) pushApp:(NSString*) flowerApp withUIViewAnimation:(UIViewAnimationTransition)transition{
    if ([appList objectForKey:flowerApp] == nil) {
        NSLog(@"FlowerController:pushApp unkown app: %@",flowerApp);
        return;
    }
    if ([[[appList objectForKey:flowerApp] class] isSubclassOfClass:[FlowerApp class]]) {
        NSLog(@"FlowerController:pushApp retrieving %@ from Dictionnary",flowerApp);
    } else {
        Class flowerAppClass = NSClassFromString(flowerApp);
        if (! [flowerAppClass isSubclassOfClass:[FlowerApp class]]) {
            NSLog(@"FlowerController:pushApp Requesting %@ which is not a FlowerAppClass",flowerApp);
            return;
        }
        NSLog(@"FlowerController:pushApp Init %@",flowerApp);
        [appList setValue:[flowerAppClass autoInit] forKey:flowerApp];
    }
    [FlowerController setCurrentMainController:[appList objectForKey:flowerApp] withUIViewAnimation:transition];
}


# pragma mark NAVIGATION ACTION SHEET
// return true if start button should be shown 
+ (BOOL) shouldShowStartButton {
    return [[FlowerController currentFlapix] running] && (! [[FlowerController currentFlapix] exerciceInCourse]);
}

// show navigation action sheet
+ (void) showNav
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init ];
    actionSheet.title = NSLocalizedString(@"Choose an action",@"CalibrationApp Title");
    actionSheet.delegate = singleton;
    
    // propose start / stop exercice only if running
    if ([[FlowerController currentFlapix] running]) {
        NSString *startstop =  
        [[FlowerController currentFlapix] exerciceInCourse] ? NSLocalizedString(@"Stop Exercice", @"Action Popup Menu") :
        NSLocalizedString(@"Start Exercice", @"Action Popup Menu") ;
        [actionSheet addButtonWithTitle:startstop];
    }
    
    
    
    if (![[self currentFlapix] IsDemo]) {
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Start Demo Mode", @"Action Popup Menu")];
    } else {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Stop Demo Mode", @"Action Popup Menu")];
    }
    
   
    // iPad Tweak
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        actionSheet.cancelButtonIndex = 
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel",nil)];
    }
    [actionSheet showInView:singleton.view];
    
}


// get action sheet answers
-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"actionSheet %i", buttonIndex);
    
    // skip start / stop if not plugged in
    if (! [[FlowerController currentFlapix] running]) buttonIndex++ ;
    
    switch (buttonIndex) {
        case 0: // Start / Stop
            NSLog(@"Start / Stop");
            if ( [[FlowerController currentFlapix] exerciceInCourse]) {
                [[FlowerController currentFlapix] exerciceStop];
            } else {
                [[FlowerController currentFlapix] exerciceStart];
            }
            return;
            break;
            
        case 1: // Enable DemoMode
            [[FlowerController currentFlapix] SetDemo:![[FlowerController currentFlapix] IsDemo]];
            break;
        case 2: // not used on iPad
            NSLog(@"Cancel");
            return;
            break;

            
    }
    [actionSheet release];
    
}


// jack plug clicked
-(void) startButtonPressed:(id) sender {
    [FlowerController showNav];
}

- (void)startStopButtonRefresh:(NSNotification *)notification {
    if ([[FlowerController currentFlapix] running]) {
        [self.view bringSubviewToFront:historyView];
        [self.view bringSubviewToFront:menuButton];
    } else {
        [self.view bringSubviewToFront:startButton];
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (singleton != nil)  return ;
    singleton = self;
    
    // init any data if needed
    [DataAccess initOrUpgrade];
    
    
    NSLog(@"FlowerController viewDidLoad");
 
    
    // init App list
    appList = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
               [NSNull alloc], @"VolcanoApp",
               [NSNull alloc], @"ParametersApp",
               [NSNull alloc], @"CalibrationApp",
               [NSNull alloc], @"ResultsApp",
               [NSNull alloc], @"Users",
               nil];
    
    
       [FlowerController pushMenu]; //will init the MenuView
    [self.mainView addSubview:currentMainController.view]; //needed to finish pushMenu int process
    
    // Plug an iPhone
    CGRect plugFrame = historyView.frame; 

    startButton = [[UIButton alloc] initWithFrame:plugFrame];
    UIImage *buttonImageHighlighted = [UIImage imageNamed: @"jack.png"];
    [startButton setImage:buttonImageHighlighted forState:UIControlStateHighlighted];
    [startButton setTitle:NSLocalizedString(@"Plug headphones with\nmicrophone to start",@"Displayed on the ToolBar") forState:UIControlStateNormal];
    startButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    startButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [startButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [startButton setBackgroundColor:[UIColor blackColor]];
    [startButton setOpaque:NO];
    [startButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    
    [buttonImageHighlighted release];
 
    // depend of flapix state
    [self startStopButtonRefresh:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startStopButtonRefresh:)
                                                 name:FLAPIX_EVENT_START object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startStopButtonRefresh:)
                                                 name:FLAPIX_EVENT_STOP object:nil];
    

}

-(void) viewDidAppear:(BOOL)animated {
    // check for user
    [UserManager requireUser];
}


+(FlowerController*) currentFlower {
    return singleton;
}

/** normally called when a use is set **/
+ (void) initFlapix {
    if (flapix == nil && [UserManager currentUser] != nil) {
        flapix = [FLAPIX new];
    }
    [ParametersManager loadParameters:flapix];
}

// get the currentFlapix Controller
+ (FLAPIX*) currentFlapix {
    return flapix;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [currentMainController release];
    [activitiesViewController release];
    [appList removeAllObjects];
    [appList release];
    [singleton release];
    menuButton = nil;
    mainView = nil;
    needleGL = nil;
    startButton = nil;
    historyView = nil;
}

# pragma mark Quit


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"**** FlowerController: didReceiveMemoryWarning");
    for(NSString *aKey in [appList allKeys]){
        Class c = [[appList valueForKey:aKey] class];
        if ([c isSubclassOfClass:[FlowerApp class]] && ! [currentMainController isKindOfClass:c]) {
            [appList setValue:[[NSNull alloc] init] forKey:aKey]; // will call release on previous object
            NSLog(@"FlowerController: poped up %@",aKey);
        }
    }

}


- (void)dealloc
{
    [flapix release];
    //[historyViewController release];
    [super dealloc];
}


//Allows view to autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
