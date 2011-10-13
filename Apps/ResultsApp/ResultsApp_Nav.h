//
//  StatisticsViewController.h
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	This class defines the navigation controller, who manages the views inside the Statistics tab.


#import <UIKit/UIKit.h>
#import "ResultsApp_List.h"


@interface ResultsApp_Nav : UINavigationController {

    //Child view controller
    ResultsApp_List* statisticListViewController;
}

@property (nonatomic, retain) ResultsApp_List* statisticListViewController;

@end
