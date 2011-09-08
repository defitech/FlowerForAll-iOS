//
//  FlowerController.m
//  FlutterApp2
//
//  Created by Pierre-Mikael Legris on 07.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerController.h"
#import "GameViewController.h"
#import "SettingChoiceViewController.h"
#import "SettingsViewController.h"
#import "GameParametersViewController.h"
#import "StatisticsViewController.h"
#import "FlutterApp2AppDelegate.h"
#import "ParametersManager.h"
#import "BlowHistory.h"


@implementation FlowerController

//@synthesize mainView, flapiView;
@synthesize mainView, historyViewController;

static FlowerController *singleton;
static UIViewController *currentMainController ;

static SettingsViewController *settingsViewController ;
static StatisticsViewController *statisticsViewController;
static GameViewController* activitiesViewController;

static FLAPIX* flapix;

# pragma mark View Control


// get Activities View Controller
+ (GameViewController*) getActivitiesViewController
{
    NSLog(@"getActivitiesViewController");
    if (activitiesViewController == nil) {
        activitiesViewController = [[GameViewController alloc] initWithNibName:@"GameView" bundle:[NSBundle mainBundle]];
    }
    return activitiesViewController;
}

// get Settings View Controller
+ (SettingsViewController*) getSettingsViewController
{
    if (settingsViewController == nil) {
        settingsViewController = [[SettingsViewController alloc] init ];
        settingsViewController.view.frame = CGRectMake( 0, -20, 320, 480); // XXX Why??? mérite une question sur stackoverflow
    }
    return settingsViewController;
}

// get Statistics View Controller
+ (StatisticsViewController*) getStatisticsViewController
{
    if (statisticsViewController == nil) {
        statisticsViewController = [[StatisticsViewController alloc] init];
        statisticsViewController.view.frame = CGRectMake( 0, -20, 320, 480); // XXX Why???
    }
    return statisticsViewController;
}

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
            [FlowerController setCurrentMainController:[FlowerController getActivitiesViewController]];
            break;
        case 1:
            NSLog(@"Cancel");
            return;
            break;
            
			
            //case 3: // Settings
            //  [FlowerController setCurrentMainController:[FlowerController getSettingsViewController]];
            // break;
            //case 4: // Statistics
            //   [FlowerController setCurrentMainController:[FlowerController getStatisticsViewController]];
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
    
    currentMainController = [FlowerController getActivitiesViewController];
    historyViewController = [ [ HistoryViewController alloc ] init ];
    [self.view addSubview:historyViewController.view];
    [self.mainView addSubview:currentMainController.view];
    
     NSLog(@"FlowerController viewDidLoad");
    // Do any additional setup after loading the view from its nib.
    [FlowerController currentFlapix];
    
    
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
    [settingsViewController release];
    [statisticsViewController release];
    [activitiesViewController release];
    [singleton release];
}

# pragma mark Quit


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"**** didReceiveMemoryWarning");
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
