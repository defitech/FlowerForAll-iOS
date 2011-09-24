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

@implementation CalibrationApp_NeedleView


CalibratiomApp_NeedleLayer *needleLayer;

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
        
        CGPoint axeCenter = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height * (1.0f + deltaY) / 2.0f );
        
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
    CGContextTranslateCTM(context, self.frame.size.width / 2, self.frame.size.height / 1.5); // Move the context
    
   
    
    // draw the rules
    [self drawFreqRules:[[FlowerController currentFlapix] frequenceTarget]
                freqTol:[[FlowerController currentFlapix] frequenceTolerance]
            isReference:false];
    [self drawFreqRules:lastTarget freqTol:lastTolerance isReference:true];
    
	[super drawRect:rect];
}

-(void)drawFreqRules:(double)target freqTol:(double)tolerance isReference:(BOOL)isRef {
    float angle = tolerance / target;
    float length = 120.0f;
    float x = length * sin(angle);
    float y = - length * cos(angle);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0.0f, 0.0f);
    CGContextAddLineToPoint (ctx, - x, y);
    CGContextMoveToPoint(ctx, 0.0f, 0.0f);
    CGContextAddLineToPoint(ctx, x, y);
    if(isRef) {
        CGContextSetStrokeColor(ctx, CGColorGetComponents([UIColor orangeColor].CGColor));
        CGFloat dash[] = {6.0, 3.0};
        CGContextSetLineDash(ctx, 0.0, dash, 2);
    }
    CGContextSetLineWidth(ctx,1);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}

-(float)frequencyToAngle:(double)freq {
    float longest = ([[FlowerController currentFlapix] frequenceMax] - [[FlowerController currentFlapix] frequenceTarget]) >
         ([[FlowerController currentFlapix] frequenceTarget] - [[FlowerController currentFlapix] frequenceMin]) ?
    ([[FlowerController currentFlapix] frequenceMax] - [[FlowerController currentFlapix] frequenceTarget]) :
    ([[FlowerController currentFlapix] frequenceTarget] - [[FlowerController currentFlapix] frequenceMin]);
    
    return (freq - [[FlowerController currentFlapix] frequenceTarget]) / (2 * longest ) ;
    
}

-(void)calcRotation:(double)freq {
    [needleLayer setAngle:[self frequencyToAngle:freq]];

}

@end
