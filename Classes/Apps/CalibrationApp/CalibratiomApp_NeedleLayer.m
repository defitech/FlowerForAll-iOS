//
//  CalibratiomApp_NeedleLayer.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 23.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalibratiomApp_NeedleLayer.h"

@implementation CalibratiomApp_NeedleLayer


float lastAngle;

- (id)initWithAngle:(float)angle
{
    self = [super init];
    if (self) {
        lastAngle = 0;
        [self setAngle:-0.0f];
    }
    
    return self;
}

float actualAngle;

- (void)setAngle:(float)angle
{
    
    //needleLayer.transform = CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0);
    /**CAKeyframeAnimation *rot = [CAKeyframeAnimation animation];
    
    rot.values = [NSArray arrayWithObjects:
                  [NSValue valueWithCATransform3D:CATransform3DMakeRotation(lastAngle * M_PI, 0.0f, 0.0f, 1.0f)],
                  [NSValue valueWithCATransform3D:CATransform3DMakeRotation(angle * M_PI, 0.0f, 0.0f, 1.0f)],nil];
    
    lastAngle = angle;
    
    rot.duration = 0.3;
    rot.delegate = self;
     [self addAnimation:rot forKey:@"transform"];
    **/
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat: lastAngle*M_PI];
    rotationAnimation.toValue = [NSNumber numberWithFloat: angle*M_PI];
    rotationAnimation.duration = 0.3;
    rotationAnimation.additive = YES;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    [self addAnimation:rotationAnimation forKey:@"rotationAnimation1"];

    
     lastAngle = angle;
    
}

- (void)drawInContext:(CGContextRef)context

{
    CGContextTranslateCTM(context, self.frame.size.width / 2, self.frame.size.height / 2); // Move the context
    
    // draw the needle
    CGContextSaveGState(context);
    
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
    
}

@end
