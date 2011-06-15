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

@synthesize mainView, flapiView;

static FlowerController *singleton;
static UIViewController *currentMainController ;

static SettingsViewController *settingsViewController ;
static StatisticsViewController *statisticsViewController;

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
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// get Settings View Controller
+ (SettingsViewController*) getSettingsViewController
{
    if (settingsViewController == nil) {
        settingsViewController = [[SettingsViewController alloc] init];
    }
    return settingsViewController;
}

// get Statistics View Controller
+ (StatisticsViewController*) getStatisticsViewController
{
    if (statisticsViewController == nil) {
        statisticsViewController = [[StatisticsViewController alloc] init];
    }
    return statisticsViewController;
}


// show navigation action sheet
+ (void) showNav
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                                  initWithTitle:@"Jump to" 
                                  delegate:singleton 
        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") 
                                  destructiveButtonTitle:nil 
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
    UIViewController *previousViewController = currentMainController;
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel");
            return;
            break;
        case 1: // Activities
            if ([currentMainController isKindOfClass:[GameViewController class]]) {
                NSLog(@"Skip");
                return;
            }
            currentMainController = [[GameViewController alloc] initWithNibName:@"GameView" bundle:[NSBundle mainBundle]];
            
            break;
			
        case 2: // Settings
            if ([currentMainController isKindOfClass:[SettingsViewController class]]) {
                NSLog(@"Skip");
                return;
            }
             
            currentMainController = [FlowerController getSettingsViewController];
            
            break;
        case 3: // Statistics
            if ([currentMainController isKindOfClass:[StatisticsViewController class]]) {
                NSLog(@"Skip");
                return;
            }
            currentMainController = [FlowerController getStatisticsViewController];
            
            break;

            break;
    }
    [self.mainView addSubview:currentMainController.view];
    [previousViewController.view removeFromSuperview];
    [self.mainView setNeedsLayout];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (singleton == nil) {
        singleton = self;
    }
    
    currentMainController = [[GameViewController alloc] initWithNibName:@"GameView" bundle:[NSBundle mainBundle]];
    [self.mainView addSubview:currentMainController.view];
    
     NSLog(@"FlowerController viewDidLoad");
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [currentMainController dealloc];
    [settingsViewController dealloc];
    [statisticsViewController dealloc];
    [singleton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
