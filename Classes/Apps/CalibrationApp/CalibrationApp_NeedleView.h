//
//  CalibrationApp_NeedleView.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalibrationApp_NeedleView : UIView {
    double lastTarget;
    double lastTolerance;
}

-(void)drawFreqRules:(double)target freqTol:(double)tolerance isReference:(BOOL)isRef;

@end
