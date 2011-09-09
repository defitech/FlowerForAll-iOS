//
//  MyClass.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 09.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerApp.h"
#import "FLAPIX.h"

@implementation FlowerApp

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

/** MyName **/
+(NSString*)AppName {
    return NSStringFromClass([self class]);
}

/** Used to put a button on the App Menu **/
+(UIImage*)AppIcon {
    NSString* iconName = [NSString stringWithFormat:@"%@-Icon.png",[self AppName]];
    return [[[UIImage alloc] initWithContentsOfFile:iconName ] autorelease];
}

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)AppLabel {
    return [self AppName];
}



// Event Observers 
-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_flapixEventStart:)
                                                 name:FLAPIX_EVENT_START object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_flapixEventStop:)
                                                 name:FLAPIX_EVENT_STOP object:nil];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_flapixEventLevel:)
                                                 name:FLAPIX_EVENT_LEVEL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_flapixEventFrequency:)
                                                 name:FLAPIX_EVENT_FREQUENCY object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_flapixEventBlowStart:)
                                                 name:FLAPIX_EVENT_BLOW_START object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_flapixEventBlowStop:)
                                                 name:FLAPIX_EVENT_BLOW_STOP object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_flapixEventExerciceStart:)
                                                 name:FLAPIX_EVENT_EXERCICE_START object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_flapixEventExerciceStop:)
                                                 name:FLAPIX_EVENT_EXERCICE_STOP object:nil];
}



- (void)_flapixEventStart:(NSNotification *)notification {
    [self flapixEventStart:((FLAPIX*)[notification object])];
}
- (void)_flapixEventStop:(NSNotification *)notification {
    [self flapixEventStop:((FLAPIX*)[notification object])];
}
- (void)_flapixEventLevel:(NSNotification *)notification {
    [self flapixEventLevel:((FLAPIX*)[notification object])];
}
- (void)_flapixEventFrequency:(NSNotification *)notification {
    [self flapixEventFrequency:((FLAPIX*)[notification object])];
}
- (void)_flapixEventBlowStart:(NSNotification *)notification {
    [self flapixEventBlowStart:((FLAPIBlow*)[notification object])];
}
- (void)_flapixEventBlowStop:(NSNotification *)notification {
    [self flapixEventBlowStop:((FLAPIBlow*)[notification object])];
}
- (void)_flapixEventExerciceStart:(NSNotification *)notification {
    [self flapixEventExerciceStart:((FLAPIExercice*)[notification object])];
}
- (void)_flapixEventExerciceStop:(NSNotification *)notification {
    [self flapixEventExerciceStop:((FLAPIExercice*)[notification object])];
}
- (void)flapixEventStart:(FLAPIX *)flapix {}
- (void)flapixEventStop:(FLAPIX *)flapix {}

- (void)flapixEventLevel:(FLAPIX *)flapix {}
- (void)flapixEventFrequency:(FLAPIX *)flapix {}

- (void)flapixEventBlowStart:(FLAPIBlow *)blow {}
- (void)flapixEventBlowStop:(FLAPIBlow *)blow {}

- (void)flapixEventExerciceStart:(FLAPIExercice *)exercice {}
- (void)flapixEventExerciceStop:(FLAPIExercice *)exercice {}


// View lifecycle
- (void)viewDidUnload { [super viewDidUnload]; }
- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }


// Allows view to autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


@end
