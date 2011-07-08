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

	NSLog(@"there");
	
	

   	[self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];
	
    return YES;
}










- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // ping server
    ConnectionManager *cm = [[ConnectionManager alloc] init]; 
        
        NSMutableDictionary *infos = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"applicationDidBecomeActive",@"event",nil];
        
        //[infos addEntriesFromDictionary:[EasyMemoryCommon getInfos]];
        //[infos setObject:[EasyMemoryCommon getSrcTitle] forKey:@"srcTitle"] ;
        [cm ping:infos];  // advertise presence
        [cm release];
        NSLog(@"applicationDidBecomeActive");
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
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
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}



- (void)dealloc {
    [viewController release];
    [window release];
    [DB close];
    [super dealloc];
}



@end

