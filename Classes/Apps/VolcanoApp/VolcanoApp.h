//
//  VolcanoApp.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAPIExercice.h"
#include <AudioToolbox/AudioToolbox.h>
#import "FlowerApp.h"

@interface VolcanoApp : FlowerApp {
    IBOutlet UIButton *start;
    UIImageView *volcano;
    UIImageView *burst;
    UIView *lavaHidder;
    
    CGRect lavaFrame;
    
    int lavaWidth;
    int lavaHeight;
    
    FLAPIExercice *currentExercice;
}

- (void)playSystemSound:(NSString *)soundFilename;
- (IBAction) pressStart:(id) sender;

@end
