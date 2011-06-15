//
//  MController.h
//  OpenGL_ES_tuto1
//
//  Created by Pierre-Mikael Legris on 11.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAGLView.h"

@interface MController : UIViewController {
	   EAGLView *glView;
}
@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end
