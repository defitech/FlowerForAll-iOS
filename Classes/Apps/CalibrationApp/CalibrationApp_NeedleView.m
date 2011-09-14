//
//  CalibrationApp_NeedleView.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalibrationApp_NeedleView.h"

@implementation CalibrationApp_NeedleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//create the gradient
static const CGFloat colors [] = { 
	1.0, 0.6, 0.6, 1.0, 
	0.8, 0.0, 0.0, 1.0
};
//create the gradient
static const CGFloat innerColors [] = { 
	0.1, 0.8, 0.3, 1.0, 
	0.0, 0.6, 0.0, 1.0
};

- (void)drawRect:(CGRect)rect
{
    
    
    	
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGContextTranslateCTM(context, self.frame.size.width / 2, self.frame.size.height / 1.5); // Move the context 
    CGContextScaleCTM(context,self.frame.size.width / 60, -1 *  self.frame.size.height / 60 ); // revert the axis
    
    // center the Needle
   // CGContextMoveToPoint(context,10.0f,10.0f);
    
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


    
	[super drawRect:rect];
}



@end
