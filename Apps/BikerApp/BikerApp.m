//
//  BikerApp.m
//  FlowerForAll
//
//  Created by adherent on 06.12.12.
//
//

#import "BikerApp.h"
#import "BikerAppGL.h"

#import "FLAPIBlow.h"
#import "FLAPIX.h"
#import "FlowerController.h"


@interface BikerApp ()

@end

@implementation BikerApp

@synthesize starLabel;
# pragma mark FlowerApp overriding

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    return NSLocalizedStringFromTable(@"Biker Game",@"BikerApp",@"BikerApp Title");
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    BikerGL *bikerGL_startanimation = [[BikerGL alloc] init];
    [bikerGL_startanimation stopAnimation];
    [bikerGL_startanimation release];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    BikerGL *bikerGL_stopanimation = [[BikerGL alloc] init];
    [bikerGL_stopanimation stopAnimation];
    [bikerGL_stopanimation release];
}

- (void)initVariables {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction) pressStart:(id)sender {
    if ([[FlowerController currentFlapix] exerciceInCourse]) {
        NSLog(@"pressStart: stop");
        [[FlowerController currentFlapix] exerciceStop];
    } else {
        NSLog(@"pressStart: start");
        [[FlowerController currentFlapix] exerciceStart];
        [startbutton removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	
    [super dealloc];
}

@end
