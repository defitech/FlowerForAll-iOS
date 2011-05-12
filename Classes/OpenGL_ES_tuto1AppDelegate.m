//
//  OpenGL_ES_tuto1AppDelegate.m
//  OpenGL_ES_tuto1
//
//  Created by Marian PAUL on 19/04/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "OpenGL_ES_tuto1AppDelegate.h"
#import "EAGLView.h"

@implementation OpenGL_ES_tuto1AppDelegate

@synthesize window;


@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	// Add the view controller's view to the window and display.
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];

}


- (void)applicationWillResignActive:(UIApplication *)application {

}


- (void)applicationDidBecomeActive:(UIApplication *)application {

}


- (void)dealloc {
	[window release];

	[super dealloc];
}

@end
