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
        int needle_width = 200;
        int deltaY = - 0.5f ; //  
        needleLayer.frame = CGRectMake((self.frame.size.width - needle_width) / 2,  (self.frame.size.height - needle_width) / 2 , needle_width, needle_width);
        //needleLayer.delegate = self;
        self.layer.zPosition = 0;
        needleLayer.zPosition = 1;
        [self.layer addSublayer:needleLayer];
        
        [needleLayer setNeedsDisplay];
       

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

-(void)calcRotation:(double)freq {
    rotation = 0;
}

@end
