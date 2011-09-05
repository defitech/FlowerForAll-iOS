//
//  FLAPIview.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAPIExercice.h"


@interface FLAPIview : UIViewController {
    UIImageView *volcano;
    UIImageView *burst;
    UIView *lavaHidder;
    
    int lavaReverse;
    int lavaSmooth;
    
    CGRect lavaFrame;
    
    int lavaWidth;
    int lavaHeight;
    
    FLAPIExercice *currentExercice;
}


@end
