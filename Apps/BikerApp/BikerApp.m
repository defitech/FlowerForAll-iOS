//
//  BikerApp.m
//  FlowerForAll
//
//  Created by adherent on 06.12.12.
//
//

#import "BikerApp.h"
#import "BikerGL.h"

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

/*- (void)flapixEventBlowStop:(NSNotification *)notification {
	FLAPIBlow* blow = (FLAPIBlow*)[notification object];
    if (blow.goal) {
        starLabel.text = [NSString stringWithFormat:@"%i",
        [[[FlowerController currentFlapix] currentExercice] blow_star_count]];
    }
    //Raise up lava
    //lavaHidder.frame = CGRectOffset(lavaFrame, 0, - lavaHeight * percent);
    //[self refreshStartButton];
    //[self setNeedsDisplay];
}*/

/*- (void)refreshStartButton {
    if ([FlowerController shouldShowStartButton]) {
        [self.view bringSubviewToFront:start];
    } else {
        [self.view sendSubviewToBack:start];
        
    }
}

-(void)flapixEventStart:(FLAPIX *)flapix {
    [self refreshStartButton];
}

-(void)flapixEventStop:(FLAPIX *)flapix {
    [self refreshStartButton];
}*/

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

bool debug_events_biker = NO;
/*- (void)flapixEventFrequency:(double)frequency in_target:(BOOL)good current_exercice:(double)percent_done {
    if (! [[FlowerController currentFlapix] exerciceInCourse]) return;
    if (percent_done > 0)
        lavaHidder.frame =  CGRectOffset(lavaFrame, 0, - lavaHeight * percent_done);
}

- (void)flapixEventBlowStop:(FLAPIBlow *)blow {
    if (debug_events_biker) NSLog(@"BIKER flapixEvent  BlowStop");
    
    if (! [[FlowerController currentFlapix] exerciceInCourse]) return;
    float percent = [[[FlowerController currentFlapix] currentExercice] percent_done];
    //NSLog(@"percent_done: %f", percent);
    
    //Add sound when the goal has been reached for the last blow
    if (blow.goal) {
       //[self playSystemSound:@"/VolcanoApp_goal.wav"];
        
    }
    starLabel.text = [NSString stringWithFormat:@"%i",
                      [[[FlowerController currentFlapix] currentExercice] blow_star_count]];
    //Raise up lava
    lavaHidder.frame = CGRectOffset(lavaFrame, 0, - lavaHeight * percent);
    [self refreshStartButton];
    [self.view setNeedsDisplay];
}*/


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
	
    [super dealloc];
}

@end
