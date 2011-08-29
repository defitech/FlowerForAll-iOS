//
//  CorePlot_GeckoGeekAppDelegate.h
//  CorePlot-GeckoGeek
//
//  Created by Vincent on 06/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CorePlot_GeckoGeekViewController;

@interface CorePlot_GeckoGeekAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    CorePlot_GeckoGeekViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, assign) CorePlot_GeckoGeekViewController *viewController;

@end

