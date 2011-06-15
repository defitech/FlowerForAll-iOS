//
//  FlutterApp2AppDelegate.h
//  FlutterApp2
//
//  Created by Dev on 24.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class defines the app delegate.


#import <UIKit/UIKit.h>

#import <sqlite3.h>

#import "FlowerController.h"



@interface FlutterApp2AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

	//The app main window
    UIWindow *window;
	
	//View controllers
    IBOutlet UIViewController *flowerController;
	
	//Store the ID of the user who is actually using the application
	//Can be accessed from other classes in the program (used like a global variable)
	NSInteger currentUserID;
	
	//Variables to store the name and the path of the database on the device filesystem
	//Can be accessed from other classes in the program (used like global variables)
	NSString *databaseName;
	NSString *databasePath;
	
	//Array to store the users objects
	NSMutableArray *users;
	
}


//Properties
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *flowerController;

@property NSInteger currentUserID;

@property (nonatomic, retain) NSString *databaseName;
@property (nonatomic, retain) NSString *databasePath;



//This method checks if the database already exists on the device file system (in the documents directory of the application).
//If it is not the case, it copies the database there from the application bundle.
-(void) checkAndCreateDatabase;


@end
