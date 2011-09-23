//
//  CalibratiomApp_NeedleLayer.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 23.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalibratiomApp_NeedleLayer.h"

@implementation CalibratiomApp_NeedleLayer

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawInContext:(CGContextRef)context

{
    
    CGContextTranslateCTM(context, self.frame.size.width / 2, self.frame.size.height / 1.5); // Move the context
    
    // draw the needle
    CGContextSaveGState(context);
    
    float reference = self.frame.size.width < self.frame.size.height ? self.frame.size.width : self.frame.size.height;
    CGContextScaleCTM(context,reference / 20, -1 *  reference / 40 ); // revert the axis
    
    
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
