//
//  CalibrationApp_NeedleView.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FLAPIBlow.h"


@interface CalibrationApp_NeedleView : UIView {
    double lastTarget;
    double lastTolerance;
    double rotation;
    
    CADisplayLink *link;
}
@property (retain) CADisplayLink *link;

-(void)drawNeedle:(const CGFloat[])gradient;
-(void)drawFreqRules:(double)target freqTol:(double)tolerance isReference:(BOOL)isRef;

-(void)refreshLastBlow:(FLAPIBlow*)blow;

# pragma mark animation stuff

- (void)startAnimation;
- (void)stopAnimation;

- (void)shouldUpdateDisplayLink:(id)sender;

@end
