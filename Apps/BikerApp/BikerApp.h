//
//  BikerApp.h
//  FlowerForAll
//
//  Created by adherent on 06.12.12.
//
//

#import <UIKit/UIKit.h>
#import "FLAPIExercice.h"
#include <AudioToolbox/AudioToolbox.h>
#import "FlowerApp.h"



@interface BikerApp : FlowerApp {

    IBOutlet UILabel *starLabel;
    IBOutlet UIButton *startbutton;
    
    CGRect lavaFrame;

    float mainWidth;
    float mainHeight;
    float lavaWidth;
    float lavaHeight;
    
    
}

@property (nonatomic, retain) IBOutlet UILabel *starLabel;

- (void)playSystemSound:(NSString *)soundFilename;
- (IBAction) pressStart:(id) sender;



@end
