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

@synthesize link;

CGPoint axeCenter;
float reference; // width / height of reference (largest)

- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        lastTarget = [[FlowerController currentFlapix] frequenceTarget];
        lastTolerance = [[FlowerController currentFlapix] frequenceTolerance];
        
        // init position and frame rederences
        float deltaY = 0.333333f ; //  
        axeCenter = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height * (1.0f + deltaY) / 2.0f );
        reference = self.frame.size.width < self.frame.size.height ? self.frame.size.width : self.frame.size.height;
        
        [self setBackgroundColor:[UIColor whiteColor]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification 
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification 
                                                   object:nil];
        [self startAnimation];

    }
    return self;
    
}


float angle_actual = -0.5f;         // effective rotation angle in degrees
float angle_toreach = 0.0f;         // current angle
float angle_previous = 0.0f;           // previous angle
float angle_freqMin = 0.0f;
float angle_freqMax = 0.0f;
float angle_freqMin_previous = 0.0f;
float angle_freqMax_previous = 0.0f;
float speed = 0.0f;          // rotation speed

- (void)drawRect:(CGRect)rect
{
   
    
     
    FLAPIX* flapix = [FlowerController currentFlapix];
    if (flapix == nil) return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, axeCenter.x, axeCenter.y); // Move the context
    CGContextScaleCTM(context,reference / 120.0f , -1 *  reference  / 120.0f); // revert the axis
   
    
    // draw the needle
    [self drawNeedle];
         
    // draw the rules
    [self drawFreqRules:[[FlowerController currentFlapix] frequenceTarget]
                freqTol:[[FlowerController currentFlapix] frequenceTolerance]
            isReference:false];
    [self drawFreqRules:lastTarget freqTol:lastTolerance isReference:true];

    [super drawRect:rect];
}

-(void)shouldUpdateDisplayLink:(id)sender {
   
    // Code manly taken from NeedlGL
    FLAPIX* flapix = [FlowerController currentFlapix];
    if (flapix == nil) return;
    
    angle_freqMin = [NeedleGL frequencyToAngle:([flapix frequenceTarget] - [flapix frequenceTolerance])];
    angle_freqMax = [NeedleGL frequencyToAngle:([flapix frequenceTarget] + [flapix frequenceTolerance])];
    angle_toreach = [NeedleGL frequencyToAngle:flapix.frequency];
    
    BOOL needle_needrefresh = (fabs(angle_toreach - angle_actual) < 0.02 ) || ! flapix.blowing;
    if ( needle_needrefresh && angle_freqMin == angle_freqMin_previous && angle_freqMax == angle_freqMax_previous) {
        return;
    }
     NSLog(@"%f %f %f",angle_toreach ,angle_actual,fabs(angle_toreach - angle_actual));
    
    angle_freqMin_previous = angle_freqMin;
    angle_freqMax_previous = angle_freqMax;
    
    if (! flapix.blowing) {
        
        
    } else {
        speed = fabs((angle_toreach - angle_previous) / 4);
        
        if (fabs(angle_toreach - angle_actual) < 0.02) {
            angle_toreach = angle_actual;
        } else if(angle_toreach > angle_previous) {
            angle_actual = angle_previous + speed;
        } else {
            angle_actual = angle_previous - speed;
        }
        
        if ((angle_freqMax > angle_actual) && (angle_freqMin < angle_actual)) { // Good
            
        } else { // Bad
            
        }
        
        angle_previous = angle_actual;
    }
    
    
    [self setNeedsDisplay];
}

-(void)drawNeedle {
    CGContextRef context = UIGraphicsGetCurrentContext();
     CGContextSaveGState(context);
    
    // draw the needle
   
    
    CGContextRotateCTM (context,-1*angle_actual*M_PI);
    
    CGMutablePathRef path = CGPathCreateMutable();
    float minX = -10.0f; float maxX = 10.0f;
    float minY = -10.0f; float maxY = 50.0f;
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


-(void)drawFreqRules:(double)target freqTol:(double)tolerance isReference:(BOOL)isRef {
    
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    float angle[2];
  
    angle[0] = [NeedleGL frequencyToAngle:(target - tolerance)];
    angle[1] = [NeedleGL frequencyToAngle:(target + tolerance)];
    

    NSLog(@"uuuuu");
    for (int i = 0; i < 2; i++) {
       
        CGContextRotateCTM (ctx,-angle[i]*M_PI);
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, 0.0f, 3.0f);
        CGContextAddLineToPoint (ctx, 0.0f, 60.0f);
        if(isRef) {
            CGContextSetStrokeColor(ctx, CGColorGetComponents([UIColor orangeColor].CGColor));
            CGFloat dash[] = {6.0, 3.0};
            CGContextSetLineDash(ctx, 0.0, dash, 2);
        }
        CGContextSetLineWidth(ctx,1);
        CGContextStrokePath(ctx);
    }
    CGContextRestoreGState(ctx);
}



-(void)calcRotation:(double)freq {
    //[needleLayer setAngle:[NeedleGL frequencyToAngle:freq]];

}


# pragma mark animation Stuff


- (void)startAnimation {
    [self shouldUpdateDisplayLink:nil];
    self.link = [CADisplayLink   displayLinkWithTarget:self
            selector:@selector(shouldUpdateDisplayLink:)];
    [self.link setFrameInterval:2];
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];


}


- (void)stopAnimation {
    self.link = nil;
}



- (void)applicationWillResignActive:(NSNotification *)notification {
    [self stopAnimation];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self startAnimation];
}

- (void) dealloc {
    [self startAnimation];
    [super dealloc];
}

@end
