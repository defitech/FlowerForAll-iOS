//
//  FlutterApp2AppDelegate.m
//  FlutterApp2
//
//  Created by Dev on 24.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the app delegate


#import "FlutterApp2AppDelegate.h"

#import "DB.h"
#import "ConnectionManager.h"

#import "User.h"


@implementation FlutterApp2AppDelegate


@synthesize window, viewController,  currentUserID;




#pragma mark -
#pragma mark Application lifecycle

//This method:
// - Setup databaseName and databasePath variables with the correct values
// - Calls the checkAndCreateDatabase method (to cpoy the DB from the app bundle to the file system, if it has not already been done)
// - Creates the main user (with ID 0) if it does not already exist
// - Then adds the tab bar controller view to the main window
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	[DB db]; // init and open the database
   	[self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // ping server
    ConnectionManager *cm = [[ConnectionManager alloc] init]; 
    
    NSMutableDictionary *infos = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"applicationDidBecomeActive",@"event",nil];
    //[infos addEntriesFromDictionary:xxxxxxxxxxx];
    [cm ping:infos skipIfLastWasNSecondsAgo:3600];  // advertise presence
    [cm release];
    NSLog(@"applicationDidBecomeActive");
}


- (void)applicationWillTerminate:(UIApplication *)application {

}




#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/





#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {

}



- (void)dealloc {
    [viewController release];
    [window release];
    [DB close];
    [super dealloc];
}



@end

