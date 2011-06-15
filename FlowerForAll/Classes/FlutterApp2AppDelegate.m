//
//  FlutterApp2AppDelegate.m
//  FlutterApp2
//
//  Created by Dev on 24.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the app delegate


#import "FlutterApp2AppDelegate.h"

#import "DataAccessDB.h"

#import "User.h"


@implementation FlutterApp2AppDelegate


@synthesize window, flowerController,  currentUserID, databaseName, databasePath;




#pragma mark -
#pragma mark Application lifecycle

//This method:
// - Setup databaseName and databasePath variables with the correct values
// - Calls the checkAndCreateDatabase method (to cpoy the DB from the app bundle to the file system, if it has not already been done)
// - Creates the main user (with ID 0) if it does not already exist
// - Then adds the tab bar controller view to the main window
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	
	//Setup some global variable: databaseName and databasePath
	databaseName = @"FlutterApp2Database.sql";
	//Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	
	
	//Execute the checkAndCreateDatabase function
	[self checkAndCreateDatabase];
	
	
	//Create the main user (with ID 0) if it does not already exist
	NSInteger ownerID = 0;
	NSString *ownerName = NSLocalizedString(@"OwnerUserName", @"Name of the owner user");
	NSString *ownerPassword = NSLocalizedString(@"OwnerUserPassword", @"Password of the owner user");
	
	if (![DataAccessDB checkIfUserAlreadyExists:ownerID]) {
		[DataAccessDB createUser:ownerID:ownerName:ownerPassword];
	}
	
	/**
	//Set the title of all tab bar items
	UITabBarItem *item1 = [tabBarController.tabBar.items objectAtIndex:0];
	item1.title = NSLocalizedString(@"TabBarItem1", @"Title of the first tab bar item");
	UITabBarItem *item2 = [tabBarController.tabBar.items objectAtIndex:1];
	item2.title = NSLocalizedString(@"TabBarItem2", @"Title of the second tab bar item");
	UITabBarItem *item3 = [tabBarController.tabBar.items objectAtIndex:2];
	item3.title = NSLocalizedString(@"TabBarItem3", @"Title of the thirs tab bar item");
	**/


    
	//Add the tab bar controller, which is the top level controller, to the window, and display the window.
	[self.window addSubview:flowerController.view];
    
    [self.window makeKeyAndVisible];
	
	
    return YES;
}





//This method checks if the database already exists on the device file system (in the documents directory of the application).
//If it is not the case, it copies the database there from the application bundle.
-(void) checkAndCreateDatabase{
	
	//Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	//Create a FileManager object, we will use this to check the status
	//of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	//Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	//If the database already exists then return without doing anything
	if(success) return;
	
	//If not then proceed to copy the database from the application to the users filesystem
	
	//Get the path to the database in the application package (since the DB is in the Resource dir of the app bundle)
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	//Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
	[fileManager release];
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
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
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
    [flowerController release];
    [window release];
    [super dealloc];
}



@end

