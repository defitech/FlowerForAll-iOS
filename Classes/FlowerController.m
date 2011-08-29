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


@implementation FlowerController

//@synthesize mainView, flapiView;
@synthesize mainView, historyViewController;

static FlowerController *singleton;
static UIViewController *currentMainController ;

static SettingsViewController *settingsViewController ;
static StatisticsViewController *statisticsViewController;
static GameViewController* activitiesViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"Init With Nib");
    }
    
    return self;
}

- (void)dealloc
{
    [historyViewController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


// get the currentFlapix Controller
+ (FLAPIX*) currentFlapix {
    return [[singleton flapiView] flapix];
}


// get Activities View Controller
+ (GameViewController*) getActivitiesViewController
{
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


// show navigation action sheet
+ (void) showNav
{
    
    NSString *startstop =  [[FlowerController currentFlapix] running] ? NSLocalizedString(@"Stop Exercice", @"Stop Action") :
                NSLocalizedString(@"Start Exercice", @"Start Action") ;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:@"Jump to" 
                                  delegate:singleton 
        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") 
                                  destructiveButtonTitle:startstop
                                  otherButtonTitles: nil];
    
    
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Activities", @"Title of the first tab bar item")];
    
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Settings", @"Title of the second tab bar item")];

        [actionSheet addButtonWithTitle:NSLocalizedString(@"Satistics", @"Title of the third tab bar item")];
    
    
    [actionSheet showInView:singleton.view];
    [actionSheet release];
}

// get action sheet answers
-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"actionSheet %i", buttonIndex);
    
    switch (buttonIndex) {
        case 0: // Start / Stop
            NSLog(@"Start / Stop");
            if ( [[FlowerController currentFlapix] running]) {
                [[FlowerController currentFlapix] Stop];
            } else {
                 [[FlowerController currentFlapix] Start];
            }
            return;
            break;
        case 1:
            NSLog(@"Cancel");
            return;
            break;
        case 2: // Activities
            if ([currentMainController isKindOfClass:[GameViewController class]]) {
                NSLog(@"Skip");
                return;
            }
            [FlowerController setCurrentMainController:[FlowerController getActivitiesViewController]];
            
            break;
			
        case 3: // Settings
            if ([currentMainController isKindOfClass:[SettingsViewController class]]) {
                NSLog(@"Skip");
                return;
            }
             
            [FlowerController setCurrentMainController:[FlowerController getSettingsViewController]];
            
            break;
        case 4: // Statistics
            if ([currentMainController isKindOfClass:[StatisticsViewController class]]) {
                NSLog(@"Skip");
                return;
            }
            [FlowerController setCurrentMainController:[FlowerController getStatisticsViewController]];
            
            break;

    }
    
    
}

+(void)setCurrentMainController:(UIViewController*)thisController {
    NSLog(@"setCurrentMainController");
    UIViewController *previousViewController = currentMainController;
    currentMainController = thisController;
    
    [singleton.mainView addSubview:currentMainController.view];
    [previousViewController.view removeFromSuperview];
    [singleton.mainView setNeedsLayout];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (singleton == nil) {
        singleton = self;
    }
    
    currentMainController = [FlowerController getActivitiesViewController];
    
    historyViewController = [ [ HistoryViewController alloc ] init ];
    [currentMainController.view addSubview:historyViewController.view];
    
    [self.mainView addSubview:currentMainController.view];
    
     NSLog(@"FlowerController viewDidLoad");
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [currentMainController release];
    [settingsViewController release];
    [statisticsViewController release];
    [activitiesViewController release];
    [singleton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
