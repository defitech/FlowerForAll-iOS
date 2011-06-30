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
    IBOutlet UIViewController *viewController;
	
	//Store the ID of the user who is actually using the application
	//Can be accessed from other classes in the program (used like a global variable)
	NSInteger currentUserID;
	
    //Array to store the users objects
	NSMutableArray *users;
	
}


//Properties
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIViewController *viewController;

@property NSInteger currentUserID;



@end
