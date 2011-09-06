//
//  FLAPIview.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FLAPIview.h"
#import "FLAPIBlow.h"
#import "FLAPIX.h"

#import <QuartzCore/QuartzCore.h>

@implementation FLAPIview


- (void)initVariables {
    
    lavaWidth = 22; // depending of the image
    lavaHeight = volcano.frame.size.height;
    
    lavaSmooth = 0;
    lavaReverse = 1;
    
    int mainWidth = self.view.frame.size.width;
    volcano.center = CGPointMake(mainWidth / 2, 334);
    burst.center = CGPointMake(mainWidth / 2, 201);
    burst.hidden = true;
    lavaHidder.frame = CGRectMake(mainWidth / 2 - lavaWidth / 2, 264, lavaWidth, lavaHeight);
    lavaHidder.hidden = false;
    
    lavaFrame = lavaHidder.frame;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        volcano = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"volcano.png"] ] autorelease];
        [self.view addSubview:volcano];
        
        burst = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"burst.png"] ] autorelease];
        [self.view addSubview:burst];        
        
//        lavaHidder =[[UIView alloc] initWithFrame:CGRectMake(
//                                    self.view.frame.size.width / 2 - lavaWidth / 2,
//                                    self.view.frame.size.height / 2 - lavaHeight / 2,
//                                    lavaWidth, lavaHeight)];
        lavaHidder =[[UIView alloc] initWithFrame:CGRectMake(
                                                             self.view.frame.size.width / 2 - lavaWidth / 2,
                                                             264,
                                                             lavaWidth, lavaHeight)];
        lavaHidder.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:lavaHidder];
        
        [self initVariables];
        
        // Listen to FLAPIX blowEvents
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventEndBlow:)
                                                     name:@"FlapixEventBlowEnd" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventFrequency:)
                                                     name:@"FlapixEventFrequency" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventExerciceStop:)
                                                     name:@"FlapixEventExerciceStop" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventExerciceStart:)
                                                     name:@"FlapixEventExerciceStart" object:nil];
        
    }
    
    return self;
}

- (void)flapixEventFrequency:(NSNotification *)notification {
    lavaHidder.frame = CGRectOffset(lavaHidder.frame, 0, - lavaReverse);
    
    // oscillates between 1/4 and 3/4 of lavaUp
    if ((lavaReverse < 0 && lavaSmooth <= 7) ||
        (lavaReverse > 0 && lavaSmooth >= 2)) {
        
        lavaReverse = -1 * lavaReverse;
    }
    
    lavaSmooth = lavaSmooth + lavaReverse;
}

- (void)flapixEventEndBlow:(NSNotification *)notification {
	FLAPIBlow* blow = (FLAPIBlow*)[notification object];
    
    [self.view setNeedsDisplay];
	//do stuff
    
    //Add sound when the goal has been reached for the last blow
    if (blow.goal){
        //Get the filename of the sound file:
        NSString *path = [NSString stringWithFormat:@"%@%@", 
                          [[NSBundle mainBundle] resourcePath],
                          @"/goal.wav"];
        
        //declare a system sound id
        SystemSoundID soundID;
        
        //Get a URL for the sound file
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        
        //Use audio sevices to create the sound
        AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
        
        //Use audio services to play the sound
        AudioServicesPlaySystemSound(soundID);
    }
}

- (void)flapixEventExerciceStop:(NSNotification *)notification {
    lavaHidder.hidden = true;
    burst.hidden = false;
}

- (void)flapixEventExerciceStart:(NSNotification *)notification {
    currentExercice = (FLAPIExercice*)[notification object];
    [self initVariables];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	[volcano release];
	[burst release];
	[lavaHidder release];
	
    [super dealloc];
}

@end
