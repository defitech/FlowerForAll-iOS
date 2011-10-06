//
//  VolcanoApp.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 26.08.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "VolcanoApp.h"
#import "FLAPIBlow.h"
#import "FLAPIX.h"
#import "FlowerController.h"

#import <QuartzCore/QuartzCore.h>



@implementation VolcanoApp

# pragma mark FlowerApp overriding

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    return NSLocalizedStringFromTable(@"Volcano Game",@"VolcanoApp",@"VolcanoApp Title");
}

- (void)refreshStartButton {
    if ( (! [[FlowerController currentFlapix] running]) 
        || [[FlowerController currentFlapix] exerciceInCourse]) {
        [self.view sendSubviewToBack:start]; 
    } else {
        [self.view bringSubviewToFront:start]; 
    }
}



-(void)flapixEventStart:(FLAPIX *)flapix {
    [self refreshStartButton];
}

-(void)flapixEventStop:(FLAPIX *)flapix {
    [self refreshStartButton];
}


- (void)initVariables {
    float correctedHeight = self.view.frame.size.height - 40 - 20; // 40 for needle + 20 for padding
    float adjustBurst = 100.0f; // kind of hack to adjust burst on top of volcano 
    
    volcano.center = CGPointMake(mainWidth / 2, correctedHeight - (lavaHeight / 2));
    burst.center = CGPointMake(mainWidth / 2, correctedHeight - lavaHeight - (burst.frame.size.height / 2) + adjustBurst);
    burst.hidden = true;
    lavaHidder.center = CGPointMake(mainWidth / 2, correctedHeight - (lavaHeight / 2));
    lavaHidder.hidden = false;

    lavaFrame = lavaHidder.frame;
   
      [self refreshStartButton];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mainWidth = self.view.frame.size.width;
        mainHeight = self.view.frame.size.height;
        
        volcano = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VolcanoApp_volcano.png"] ] autorelease];
        [volcano setFrame:CGRectMake(0, 0, mainWidth * 0.9, volcano.frame.size.height * mainWidth * 0.9 / volcano.frame.size.width)];
        volcano.contentMode = UIViewContentModeScaleAspectFit;
        
        burst = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VolcanoApp_burst.png"] ] autorelease];
        [burst setFrame:CGRectMake(0, 0, mainWidth * 0.9, burst.frame.size.height * mainWidth * 0.9 / burst.frame.size.width)];
        burst.contentMode = UIViewContentModeScaleAspectFit;
        
        lavaWidth = 19; //depending of volcano image
        lavaHeight = volcano.frame.size.height;
        
        lavaHidder =[[UIView alloc] initWithFrame:CGRectMake(0, 0, lavaWidth, lavaHeight)];
        lavaHidder.backgroundColor = [UIColor whiteColor];
        
         [start setTitle:NSLocalizedStringFromTable(@"Start Exercice",@"VolcanoApp",@"Start Button") 
                forState:UIControlStateNormal];
        
        [self initVariables];
        
        [self.view addSubview:volcano];
        [self.view addSubview:burst];
        [self.view addSubview:lavaHidder];
        
        
        
        starLabel.text = @"0";
        
       
    }
    
    return self;
}




- (IBAction) pressStart:(id)sender {
    if ([[FlowerController currentFlapix] exerciceInCourse]) {
        NSLog(@"pressStart: stop");
        [[FlowerController currentFlapix] exerciceStop];
    } else {
        NSLog(@"pressStart: start");
        [[FlowerController currentFlapix] exerciceStart];
    }
}

bool debug_events = NO;
- (void)flapixEventFrequency:(double)frequency in_target:(BOOL)good {
    if (! [[FlowerController currentFlapix] exerciceInCourse]) return;
    if (good)
        lavaHidder.frame = CGRectOffset(lavaHidder.frame, 0, - 1.0f);
}

- (void)flapixEventBlowStop:(FLAPIBlow *)blow {
     if (debug_events) NSLog(@"VOLCANO flapixEvent  BlowStop");
    
    if (! [[FlowerController currentFlapix] exerciceInCourse]) return;
    float percent = [[[FlowerController currentFlapix] currentExercice] percent_done];
    //NSLog(@"percent_done: %f", percent);
    
    //Add sound when the goal has been reached for the last blow
    if (blow.goal) {
        [self playSystemSound:@"/VolcanoApp_goal.wav"];
        starLabel.text = [NSString stringWithFormat:@"%d", [starLabel.text intValue] + 1];
    }
    
    //Raise up lava
    lavaHidder.frame = CGRectOffset(lavaFrame, 0, - lavaHeight * percent);
    [self refreshStartButton];
    [self.view setNeedsDisplay];
}

- (void)flapixEventExerciceStart:(FLAPIExercice *)exercice {
    if (debug_events) NSLog(@"VOLCANO flapixEvent  ExerciceStart");
    [self initVariables];
}

- (void)flapixEventExerciceStop:(FLAPIExercice *)exercice {
    if (debug_events) NSLog(@"VOLCANO flapixEvent  ExerciceStop");
    
    if (exercice.duration_exercice_s <= exercice.duration_exercice_done_s) {
        lavaHidder.hidden = true;
        burst.hidden = false;
        [self playSystemSound:@"/VolcanoApp_explosion.wav"];
    }
    [self.view setNeedsDisplay];
    [self refreshStartButton];
}



- (void)playSystemSound:(NSString *)soundFilename{
    //Get the filename of the sound file:
    NSString *path = [NSString stringWithFormat:@"%@%@", 
                      [[NSBundle mainBundle] resourcePath],
                      soundFilename];
    
    //declare a system sound id
    SystemSoundID soundID;
    
    //Get a URL for the sound file
    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    
    //Use audio sevices to create the sound
    AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
    
    //Use audio services to play the sound
    AudioServicesPlaySystemSound(soundID);
}



- (void)dealloc {
	[volcano release];
	[burst release];
	[lavaHidder release];
	
    [super dealloc];
}

@end
