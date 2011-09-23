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

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        lastTarget = [[FlowerController currentFlapix] frequenceTarget];
        lastTolerance = [[FlowerController currentFlapix] frequenceTolerance];
        
        
        [self setBackgroundColor:[UIColor whiteColor]];
        NSLog(@"Done");
        CalibratiomApp_NeedleLayer *needleLayer = [CalibratiomApp_NeedleLayer layer];
        needleLayer.frame = CGRectMake(5, 35, 150, 150);
        //needleLayer.delegate = self;
        [self.layer addSublayer:needleLayer];
        [needleLayer setNeedsDisplay];
        
        //needleLayer.transform = CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
        CAKeyframeAnimation *rot = [CAKeyframeAnimation animation];
     
        rot.values = [NSArray arrayWithObjects:
                               [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0.0f, 0.0f, 1.0f, 0.0f)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f)],nil];

        
        rot.duration = 2;
        rot.delegate = self;
        
        [needleLayer addAnimation:rot forKey:@"transform"];

    }
    return self;
    
}




- (void)xdrawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, self.frame.size.width / 2, self.frame.size.height / 1.5); // Move the context
    
    // draw the needle
    CGContextSaveGState(context);
    
    CGContextRotateCTM(context, rotation);
    float reference = self.frame.size.width < self.frame.size.height ? self.frame.size.width : self.frame.size.height;
    CGContextScaleCTM(context,reference / 60, -1 *  reference / 60 ); // revert the axis

    
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
    
    CGContextRestoreGState(context);
    
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

-(void)calcRotation:(double)freq {
    rotation = 0;
}

@end
