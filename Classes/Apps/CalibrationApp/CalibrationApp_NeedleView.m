//
//  CalibrationApp_NeedleView.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalibrationApp_NeedleView.h"
#import "FlowerController.h"

@implementation CalibrationApp_NeedleView


- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        lastTarget = [[FlowerController currentFlapix] frequenceTarget];
        lastTolerance = [[FlowerController currentFlapix] frequenceTolerance];
    }
    return self;
    
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, self.frame.size.width / 2, self.frame.size.height / 1.5); // Move the context
    CGContextScaleCTM(context,self.frame.size.width / 60, -1 *  self.frame.size.height / 60 ); // revert the axis
    
    // draw the needle
    CGMutablePathRef path = CGPathCreateMutable();
    
    float minX = -10.0f; float maxX = 10.0f;
    float minY = -10.0f; float maxY = 30.0f;
    float r = 3.0f;
    float rN = 1.0f;
    
    CGPathMoveToPoint(path,NULL, 0.0f , minY); // S
    CGPathAddCurveToPoint(path,NULL,  0.0f - r, minY, minX, 0.0f -r,   minX, 0.0f); // S -> E
    CGPathAddCurveToPoint(path,NULL,   minX, 0.0f + r,     0.0f - rN, maxY,  0.0f, maxY); // E -> N
    CGPathAddCurveToPoint(path,NULL, 0.0f + rN, maxY,   maxX, 0.0f + r, maxX, 0.0f); // N -> W
    CGPathAddCurveToPoint(path,NULL,    maxX, 0.0f -r ,     0.0f + r, minY,  0.0f , minY); // W -> S
    CGPathCloseSubpath(path);
    
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
    
    // draw current frequency rules
    [self drawFreqRules:[[FlowerController currentFlapix] frequenceTarget]
                freqTol:[[FlowerController currentFlapix] frequenceTolerance]
            isReference:false];
    // draw last blow frequency rules
    [self drawFreqRules:lastTarget freqTol:lastTolerance isReference:true];
    
    
	[super drawRect:rect];
}

-(void)drawFreqRules:(double)target freqTol:(double)tolerance isReference:(BOOL)isRef {
    float angle = tolerance /target;
    float length = 40.0f;
    float x = length * sin(angle);
    float y = length * cos(angle);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0.0f, 0.0f);
    CGContextAddLineToPoint (ctx, - x, y);
    CGContextMoveToPoint(ctx, 0.0f, 0.0f);
    CGContextAddLineToPoint(ctx, x, y);
    if(isRef) {
        CGContextSetStrokeColor(ctx, CGColorGetComponents([UIColor orangeColor].CGColor));
        CGFloat dash[] = {3.0, 1.0};
        CGContextSetLineDash(ctx, 0.0, dash, 2);
    }
    CGContextSetLineWidth(ctx,0.5);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
}

@end
