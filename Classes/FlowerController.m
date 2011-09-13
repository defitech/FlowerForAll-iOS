//
//  FlowerController.m
//  FlutterApp2
//
//  Created by Pierre-Mikael Legris on 07.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerController.h"
#import "MenuView.h"
#import "ParametersApp.h"
#import "ParametersApp.h"
#import "FlutterApp2AppDelegate.h"
#import "ParametersManager.h"
#import "BlowHistory.h"


@implementation FlowerController

@synthesize mainView, historyViewController;

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
}


/** Promote an App as current Main Controller **/ 
+ (void) pushApp:(NSString*) flowerApp {
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
    [FlowerController setCurrentMainController:[appList objectForKey:flowerApp] ];
}

/** 
 * normaly you should call goTo Menu to set the Menu 
 * If you decide to push your own view a currentMainController you then need to 
 * handle your retain / release yourself
 **/
+(void)setCurrentMainController:(UIViewController*)thisController {
    if ([currentMainController isKindOfClass:[thisController class]]) {
         NSLog(@"FLowerController: setCurrentMainController Skip");
        return;
    }
    if (! [singleton isKindOfClass:[FlowerController class]]) {
        NSLog(@"** Something went bad we've lost FLowerController Singleton");
        return;
    }
    NSLog(@"FLowerController: setCurrentMainController %@",[thisController class]);
    [currentMainController viewWillDisappear:true];
    [thisController viewWillAppear:true];
    
    UIViewController *previousViewController = currentMainController;
    currentMainController = thisController;
    NSLog(@"%f %f %f %f",singleton.mainView.frame.origin.x,singleton.mainView.frame.origin.y,
            singleton.mainView.frame.size.width, singleton.mainView.frame.size.height);
    
    [singleton.mainView addSubview:currentMainController.view];
    [previousViewController viewDidDisappear:true];
    [previousViewController.view removeFromSuperview];
    [singleton.mainView setNeedsLayout];
    [currentMainController viewDidAppear:true];
}


# pragma mark NAVIGATION ACTION SHEET

// show navigation action sheet
+ (void) showNav
{
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:@"Choose an action" 
                                  delegate:singleton 
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") 
                                  destructiveButtonTitle:NSLocalizedString(@"Go to menu", @"Title of the first tab bar item")
                                  otherButtonTitles: nil];
    
    
    
    
    // [actionSheet addButtonWithTitle:NSLocalizedString(@"Settings", @"Title of the second tab bar item")];
    
    // [actionSheet addButtonWithTitle:NSLocalizedString(@"Satistics", @"Title of the third tab bar item")];
    NSString *startstop =  [[FlowerController currentFlapix] running] ? NSLocalizedString(@"Stop Exercice", @"Stop Action") :
    NSLocalizedString(@"Start Exercice", @"Start Action") ;
    
    [actionSheet addButtonWithTitle:startstop];
    if (![[self currentFlapix] IsDemo]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Start Demo Mode", @"Enable Demo Mode")];
    } else {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Stop Demo Mode", @"Enable Demo Mode")];
    }
    
    
    [actionSheet showInView:singleton.view];
    [actionSheet release];
}


// get action sheet answers
-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"actionSheet %i", buttonIndex);
    
    switch (buttonIndex) {
        case 0: // Menu
            [FlowerController pushMenu];
            break;
        case 1:
            NSLog(@"Cancel");
            return;
            break;
        case 2: // Start / Stop
            NSLog(@"Start / Stop");
            if ( [[FlowerController currentFlapix] running]) {
                [[FlowerController currentFlapix] Stop];
            } else {
                [[FlowerController currentFlapix] Start];
            }
            return;
            break;
            
        case 3: // Enable DemoMode
            [[FlowerController currentFlapix] SetDemo:![[FlowerController currentFlapix] IsDemo]];
            break;
            
    }
    
    
}


#pragma mark Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"Init With Nib");
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (singleton != nil)  return ;
    singleton = self;
    
    
    // init App list
    appList = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
               [NSNull alloc], @"VolcanoApp",
               [NSNull alloc], @"ParametersApp",
               nil];
    
    
    historyViewController = [ [ HistoryViewController alloc ] init ];
    [self.view addSubview:historyViewController.view];
    
    [FlowerController pushMenu]; //will init the MenuView
    [self.mainView addSubview:currentMainController.view]; //needed to finish pushMenu int process
    
   
    
    NSLog(@"FlowerController viewDidLoad");
    // Do any additional setup after loading the view from its nib.
    [FlowerController currentFlapix];
    
    
}


+(FlowerController*) currentFlower {
    return singleton;
}

// get the currentFlapix Controller
+ (FLAPIX*) currentFlapix {
    if (flapix == nil) {
        flapix = [FLAPIX new];
        [ParametersManager loadParameters:flapix];
        //[flapix Start];
    }
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
    [historyViewController release];
    [super dealloc];
}


//Allows view to autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

@end
