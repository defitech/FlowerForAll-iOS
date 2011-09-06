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
    
    int mainWidth = self.view.frame.size.width;
    int mainHeight = self.view.frame.size.height - 40 - 20; // 40 for needle + 20 for padding
    lavaHeight = volcano.frame.size.height;
    
    volcano.center = CGPointMake(mainWidth / 2, mainHeight - (lavaHeight / 2));
    burst.center = CGPointMake(mainWidth / 2, mainHeight - lavaHeight - (burst.frame.size.height / 2) + 67);
    burst.hidden = true;
    lavaHidder.center = CGPointMake(mainWidth / 2, mainHeight - (lavaHeight / 2));
    lavaHidder.hidden = false;

    lavaFrame = lavaHidder.frame;
    
    lavaSmooth = 1;
    lavaReverse = 1;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
                
        volcano = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"volcano.png"] ] autorelease];
        burst = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"burst.png"] ] autorelease];     
        lavaHidder =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, volcano.frame.size.height)];
        lavaHidder.backgroundColor = [UIColor whiteColor];
        
        [self initVariables];
        
        [self.view addSubview:volcano];
        [self.view addSubview:burst];
        [self.view addSubview:lavaHidder];
        
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
    NSLog(@"lavaSmooth: %i", lavaSmooth);
    if ((lavaReverse > 0 && lavaSmooth == 7) ||
        (lavaReverse < 0 && lavaSmooth == 2)) {
        
        lavaReverse = -1 * lavaReverse;
    }
    
    lavaSmooth = lavaSmooth + lavaReverse;
}

- (void)flapixEventEndBlow:(NSNotification *)notification {
	FLAPIBlow* blow = (FLAPIBlow*)[notification object];
    
    [self.view setNeedsDisplay];
    
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
        
        //Raise up lava
        lavaHidder.frame = CGRectOffset(lavaFrame, 0, - lavaHeight * [currentExercice percent_done]);
    }
}

- (void)flapixEventExerciceStop:(NSNotification *)notification {
    lavaHidder.hidden = true;
    burst.hidden = false;
}

- (void)flapixEventExerciceStart:(NSNotification *)notification {
    NSLog(@"FLAPIView flapixEventExerciceStart");
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
