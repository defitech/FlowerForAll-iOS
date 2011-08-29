//
//  CorePlot_GeckoGeekAppDelegate.m
//  CorePlot-GeckoGeek
//
//  Created by Vincent on 06/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CorePlot_GeckoGeekAppDelegate.h"
#import "CorePlot_GeckoGeekViewController.h"

@implementation CorePlot_GeckoGeekAppDelegate

@synthesize window, viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// Init Window
    self.window = [ [ [ UIWindow alloc ] initWithFrame:[ [ UIScreen mainScreen ] bounds ] ]
				   autorelease
				   ];
	
	// Init Tab Bar
	viewController = [ [ CorePlot_GeckoGeekViewController alloc ] init ];	

    // Add the view controller's view to the window and display.
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

    return YES;
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
