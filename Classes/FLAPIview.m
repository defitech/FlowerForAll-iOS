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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        logo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon@2x.png"] ] autorelease];
        logo.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        [self.view addSubview:logo];
        
        // Listen to FLAPIX blowEvents
        [[NSNotificationCenter defaultCenter] 
                                    addObserver:self 
                                    selector:@selector(flapixEventEndBlow:) 
                                    name:@"FlapixEventBlowEnd" object:nil];
        
        [[NSNotificationCenter defaultCenter] 
                                    addObserver:self 
                                    selector:@selector(flapixEventFrequency:) 
                                    name:@"FlapixEventFrequency" object:nil];
        
    }
    return self;
}
double pfreq = 0;

- (void)flapixEventFrequency:(NSNotification *)notification {
	FLAPIX* flapix = (FLAPIX*)[notification object];
    //NSLog(@"******Frequency %f",[flapix frequency]);
  
       // logo.transform = CGAffineTransformMakeRotation();
          
    CABasicAnimation *spinAnimation = [CABasicAnimation
                                       animationWithKeyPath:@"transform.rotation.z"];
    spinAnimation.fromValue = [NSNumber numberWithFloat:pfreq];
    pfreq = 3.14*([flapix frequency]/20)-1.6;
    spinAnimation.toValue = [NSNumber numberWithFloat:pfreq];
    spinAnimation.duration = 100;  
    [logo.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
    
    //[self.view setNeedsDisplay];
	//do stuff
}

- (void)flapixEventEndBlow:(NSNotification *)notification {
	FLAPIBlow* fb = (FLAPIBlow*)[notification object];
    NSLog(@"******flapixEventEndBlow %f",[fb timestamp]);
    //logo.transform = CGAffineTransformMakeRotation(0);
    CABasicAnimation *spinAnimation = [CABasicAnimation
                                       animationWithKeyPath:@"transform.rotation.z"];
    spinAnimation.fromValue = [NSNumber numberWithFloat:pfreq];
    pfreq = 0;
    spinAnimation.duration = 100;  
    spinAnimation.toValue = [NSNumber numberWithFloat:pfreq];
    //spinAnimation.duration = 0.10;  
    [logo.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
    
    [self.view setNeedsDisplay];
	//do stuff
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

@end
