//
//  ResultsApp.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 28.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerApp.h"
#import "StatisticsViewController.h";

@interface ResultsApp : FlowerApp {
    IBOutlet UIView* controllerView; 
    IBOutlet UITabBar* toolbar; 
    StatisticsViewController* statViewController;
}

@property (nonatomic, retain)  IBOutlet UIView* controllerView;  
@property (nonatomic, retain)  IBOutlet UITabBar* toolbar; 
@end
