//
//  MyClass.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 09.09.11.
//  Copyright 2011 fondationDefitech All rights reserved.
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

+(FlowerApp*)autoInit {
    NSLog(@"FlowerApp autoInit: %@ ",[self appName]);
    return [[[self class] alloc] initWithNibName:([self appName])  bundle:[NSBundle mainBundle]];
}


/** MyName **/
+(NSString*)appName {
    if ([[self class] isKindOfClass:[FlowerApp class]]) {
        NSLog(@"**WARNING!! FlowerApp:appName is called directly - you should do a stack trace to get from where");
    }
    return NSStringFromClass([self class]);
}

/** Used to put a button on the App Menu **/
+(UIImage*)appIcon {
    NSString* iconName = [NSString stringWithFormat:@"%@-Icon.png",[self appName]];
    return [[[UIImage alloc] initWithContentsOfFile:iconName ] autorelease];
}

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    return [self translate:@"AppTitle" comment:@"Will be dispayed behing the icon"];
}

/** Utility to get translated strings from %lang.lproj%/MyApp.strings**/
+(NSString*)translate:(NSString*)key comment:(NSString*)comment {
    return NSLocalizedStringFromTable(key,[self appName],comment);
}


// Event Observers 
-(void)viewDidLoad {
    [super viewDidLoad]; 
    
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


- (void)_flapixEventLevel:(NSNotification *)notification {
    [self flapixEventLevel:[((FLAPIX*)[notification object]) lastlevel]];
}
- (void)_flapixEventFrequency:(NSNotification *)notification {
    [self flapixEventFrequency:[((FLAPIX*)[notification object]) frequency]];
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

- (void)flapixEventLevel:(float)soundLevel {}
- (void)flapixEventFrequency:(double)frequency {}

- (void)flapixEventBlowStart:(FLAPIBlow *)blow {}
- (void)flapixEventBlowStop:(FLAPIBlow *)blow {}

- (void)flapixEventExerciceStart:(FLAPIExercice *)exercice {}
- (void)flapixEventExerciceStop:(FLAPIExercice *)exercice {}


// View lifecycle
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }


// Allows view to autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (void)dealloc
{
    
    [super dealloc];
}


@end
