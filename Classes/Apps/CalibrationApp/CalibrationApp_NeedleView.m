//
//  CalibrationApp_NeedleView.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "CalibrationApp_NeedleView.h"
#import "FlowerController.h"
#import "NeedleGL.h"

@implementation CalibrationApp_NeedleView

@synthesize link;


//create the gradient
static const CGFloat gradientGreen [] = { 
	0.0, 0.8, 0.1, 1.0, 
	0.0, 0.6, 0.0, 1.0
};

//create the gradient
static const CGFloat gradientBlue [] = { 
	0.0, 0.1, 0.8, 1.0, 
	0.0, 0.0, 0.6, 1.0
};

//create the gradient
static const CGFloat gradientRed [] = { 
	0.8, 0.1, 0.0, 1.0, 
	0.6, 0.0, 0.0, 1.0
};

int actualGradient = 0;

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

BOOL lastBlowIdentical = false; // if we nedd a redraw of last blow

- (void)drawRect:(CGRect)rect
{
   
    
     
    FLAPIX* flapix = [FlowerController currentFlapix];
    if (flapix == nil) return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, axeCenter.x, axeCenter.y); // Move the context
    CGContextScaleCTM(context,reference / 120.0f , -1 *  reference  / 120.0f); // revert the axis
   
    
    // draw the needle
    switch (actualGradient) {
        case 0:
            [self drawNeedle:gradientBlue];
        break;
        case 1:
            [self drawNeedle:gradientGreen];
        break;
        case 2:
            [self drawNeedle:gradientRed];
        break;  
            
    }
    
         
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
    if ( lastBlowIdentical && needle_needrefresh && angle_freqMin == angle_freqMin_previous && angle_freqMax == angle_freqMax_previous) {
        return;
    }
    
    angle_freqMin_previous = angle_freqMin;
    angle_freqMax_previous = angle_freqMax;
    
    actualGradient = 0;
    if (! flapix.blowing) {
        
        
    } else {
        speed = fabs((angle_toreach - angle_previous) / 9);
        
        if (fabs(angle_toreach - angle_actual) < 0.02) {
            angle_toreach = angle_actual;
        } else if(angle_toreach > angle_previous) {
            angle_actual = angle_previous + speed;
        } else {
            angle_actual = angle_previous - speed;
        }
        
        if ((angle_freqMax > angle_actual) && (angle_freqMin < angle_actual)) { // Good
            actualGradient = 1;
        } else { // Bad
            actualGradient = 2;
        }
        
        angle_previous = angle_actual;
    }
    
    lastBlowIdentical = true;
    [self setNeedsDisplay];
}

-(void)drawNeedle:(const CGFloat[])gradient {
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
    CGContextAddPath(context, path);

    // Gradient
    CGContextClip(context);
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gGradient = CGGradientCreateWithColorComponents(baseSpace, gradient, NULL, 2);
    CGContextDrawLinearGradient(context, gGradient, CGPointMake(0, maxY), CGPointMake(0, minY), 0); 
    
    CGContextDrawLinearGradient(context, gGradient, CGPointMake(0, maxY), CGPointMake(0, minY), 0);
    
    CGGradientRelease(gGradient), gGradient = NULL;

    
    CGPathRelease(path);
    
    CGContextRestoreGState(context);

}

-(void)drawFreqRules:(double)target freqTol:(double)tolerance isReference:(BOOL)isRef {
    
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
   
    float angle[2];
  
    angle[0] = [NeedleGL frequencyToAngle:(target - tolerance)];
    angle[1] = [NeedleGL frequencyToAngle:(target + tolerance)];
    
    for (int i = 0; i < 2; i++) {
        CGContextSaveGState(ctx);
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
        CGContextRestoreGState(ctx);
    }
   
}


-(void)refreshLastBlow:(FLAPIBlow*)blow {
    lastTarget = [blow medianFrequency];
    lastTolerance =  [blow medianTolerance];
    lastBlowIdentical = false;
    [self setNeedsDisplay];
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
