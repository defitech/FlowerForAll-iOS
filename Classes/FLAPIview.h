//
//  FLAPIview.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAPIExercice.h"
#include <AudioToolbox/AudioToolbox.h>


@interface FLAPIview : UIViewController {
    IBOutlet UIButton *start;
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

- (void)playSystemSound:(NSString *)soundFilename;
- (IBAction) pressStart:(id) sender;

@end
