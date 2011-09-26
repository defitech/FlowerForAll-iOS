//
//  CalibrationApp_NeedleView.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalibrationApp_NeedleView.h"
#import "FlowerController.h"
#import "CalibratiomApp_NeedleLayer.h"
#import "NeedleGL.h"

@implementation CalibrationApp_NeedleView


CalibratiomApp_NeedleLayer *needleLayer;
CGPoint axeCenter;
float reference; // width / height of reference (largest)

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        lastTarget = [[FlowerController currentFlapix] frequenceTarget];
        lastTolerance = [[FlowerController currentFlapix] frequenceTolerance];
        
        
        [self setBackgroundColor:[UIColor whiteColor]];
    
        NSLog(@"Done");
        needleLayer = [CalibratiomApp_NeedleLayer layer];
        int needle_width = self.frame.size.width / 2.0f;
        float deltaY = 0.333333f ; //  
        
        axeCenter = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height * (1.0f + deltaY) / 2.0f );
        reference = self.frame.size.width < self.frame.size.height ? self.frame.size.width : self.frame.size.height;
        
        needleLayer.frame = CGRectMake(axeCenter.x-(needle_width/2.0f),  axeCenter.y - (needle_width/2.0f), needle_width, needle_width);
        [self.layer addSublayer:needleLayer];
        
        [needleLayer setNeedsDisplay];
        [needleLayer setAngle:-0.5f];
      

    }
    return self;
    
}



- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, axeCenter.x, axeCenter.y); // Move the context
    CGContextScaleCTM(context,reference / 120.0f , -1 *  reference  / 120.0f); // revert the axis
   
    
    // draw the rules
    [self drawFreqRules:[[FlowerController currentFlapix] frequenceTarget]
                freqTol:[[FlowerController currentFlapix] frequenceTolerance]
            isReference:false];
    [self drawFreqRules:lastTarget freqTol:lastTolerance isReference:true];
    
	[super drawRect:rect];
}

-(void)drawFreqRules:(double)target freqTol:(double)tolerance isReference:(BOOL)isRef {
    float angle[2];
  
    angle[0] = [NeedleGL frequencyToAngle:(target - tolerance)];
    angle[1] = [NeedleGL frequencyToAngle:(target + tolerance)];
    
    float length = 120.0f;
    
    for (int i = 0; i < 2; i++) {
        
    
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextRotateCTM (ctx,-angle[i]*M_PI);
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, 0.0f, 0.0f);
        CGContextAddLineToPoint (ctx, 0.0f, length);
        if(isRef) {
            CGContextSetStrokeColor(ctx, CGColorGetComponents([UIColor orangeColor].CGColor));
            CGFloat dash[] = {6.0, 3.0};
            CGContextSetLineDash(ctx, 0.0, dash, 2);
        }
        CGContextSetLineWidth(ctx,1);
        CGContextStrokePath(ctx);
        CGContextRestoreGState(ctx);
    }
}



-(void)calcRotation:(double)freq {
    [needleLayer setAngle:[NeedleGL frequencyToAngle:freq]];

}

@end
