//
//  OpenGL_ES_tuto1AppDelegate.h
//  OpenGL_ES_tuto1
//
//  Created by Marian PAUL on 19/04/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MController.h"

@class EAGLView;

@interface OpenGL_ES_tuto1AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
 
	MController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


@property (nonatomic, retain) IBOutlet MController *viewController;

@end

