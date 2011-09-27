//
//  DoubleSlider.m
//  Sweeter
//
//  Created by Dimitris on 23/06/2010.
//  Copyright 2010 locus-delicti.com. All rights reserved.
//

#import "DoubleSlider.h"
#import "FLAPIX.h"
#import "FlowerController.h"

#define kMinHandleDistance          22.0
#define kBoundaryValueThreshold     0.04

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


//define private methods
@interface DoubleSlider (PrivateMethods)
- (void)updateValues;
- (void)addToContext:(CGContextRef)context roundRect:(CGRect)rrect withRoundedCorner1:(BOOL)c1 corner2:(BOOL)c2 corner3:(BOOL)c3 corner4:(BOOL)c4 radius:(CGFloat)radius;
- (void)updateHandleImages;
- (void)addMarkWithLabel:(float)mark;
@end


@implementation DoubleSlider

@synthesize  minSelectedValue, maxSelectedValue, valueStepRounding;
@synthesize minHandle, maxHandle;

- (void) dealloc
{
	CGColorRelease(bgColor);
    marks = nil;
	self.minHandle = nil;
	self.maxHandle = nil;
	[super dealloc];
}

#pragma mark Object initialization

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)aDecoder {
    self = [super initWithCoder:aDecoder];
    NSLog(@"***DoubleSlider: Init with coder called");
    NSLog(@"init with coder before super width %f",super.frame.size.width); 
    if (self)
	{
       [self initValues:(float)[[FlowerController currentFlapix] frequenceMin] 
               maxValue:(float)[[FlowerController currentFlapix] frequenceMax] ];
       [self initView:10.0f];
        marks = [[NSMutableArray alloc] init];
    }
    return self;
    
}

-(void) initValues:(float)aMinValue maxValue:(float)aMaxValue  {
    NSLog(@"DoubleSlider: initWithValue%f %f",aMinValue,aMaxValue);
    if (aMinValue < aMaxValue) {
        minValue = aMinValue;
        maxValue = aMaxValue;
    }
    else {
        minValue = aMaxValue;
        maxValue = aMinValue;
    }
    valueSpan = maxValue - minValue;
    valueStepRounding = 0.2;
    
    
    //init
    latchMin = NO;
    latchMax = NO;
    
    [self updateValues];
}

-(float) xToValue:(float)x {
    float realvalue = (x - sliderBarDeltaX) * valueSpan / sliderBarWidth  + minValue ;
    return round( realvalue / valueStepRounding) * valueStepRounding;
}

-(float)valueToX:(float)value {
    if (value < minValue) {
        value = minValue;
    }
    if  (value > maxValue) {
        value = maxValue;
    }
    return ((value - minValue) * sliderBarWidth / valueSpan) + sliderBarDeltaX ;
}


-(void) setSelectedValues:(float)aMinValue maxValue:(float)aMaxValue {
    self.minHandle.center = CGPointMake([self valueToX:aMinValue] , sliderBarHeight * 0.5+sliderBarDeltaY);
    self.maxHandle.center = CGPointMake([self valueToX:aMaxValue], sliderBarHeight * 0.5+sliderBarDeltaY);
    [self updateValues];
}

-(void) initView:(float)height {
    sliderBarDeltaX = 20; // needed to catch touches that are arround the handles (see TrackingWithTouch radius)
    sliderBarDeltaY = (self.frame.size.height - height) / 2.5;
    sliderBarHeight = height;
    sliderBarWidth = self.frame.size.width / self.transform.a - 2*sliderBarDeltaX;  //calculate the actual bar width by dividing with the cos of the view's angle
    
    self.minHandle = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle_highlight.png"]] autorelease];
    
    self.minHandle.center = CGPointMake(sliderBarWidth * 0.2+sliderBarDeltaX, sliderBarHeight * 0.5 + sliderBarDeltaY);
    [self addSubview:self.minHandle];
    
    self.maxHandle = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle_highlight.png"]] autorelease];
    self.maxHandle.center = CGPointMake(sliderBarWidth * 0.8+sliderBarDeltaX, sliderBarHeight * 0.5 + sliderBarDeltaY);
    [self addSubview:self.maxHandle];
    
    bgColor = CGColorRetain([UIColor greenColor].CGColor);
    self.backgroundColor = [UIColor clearColor];

}

- (id) initWithFrame:(CGRect)aFrame minValue:(float)aMinValue maxValue:(float)aMaxValue barHeight:(float)height
{
    self = [super initWithFrame:aFrame];
    if (self)
	{
		[self initValues:aMinValue maxValue:aMaxValue ];
        [self initView:height];
	}
	return self;
}

+ (id) doubleSlider
{
	return [[[self alloc] initWithFrame:CGRectMake(0., 0., 300., 40.) minValue:0.0 maxValue:100.0 barHeight:10.0] autorelease];
}

- (void) setMarks:(NSArray*)_marks {
    [marks removeAllObjects];
    [marks addObjectsFromArray:_marks];
    [self setNeedsDisplay];
}

#pragma mark Touch tracking

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    int radius = sliderBarDeltaX;
    CGPoint touchPoint = [touch locationInView:self];
    CGRect detectMin = CGRectMake(self.minHandle.frame.origin.x-radius, self.minHandle.frame.origin.y-radius, 
                                  self.minHandle.frame.size.width+radius*2, self.minHandle.frame.size.height+radius*2);
    CGRect detectMax = CGRectMake(self.maxHandle.frame.origin.x-radius, self.maxHandle.frame.origin.y-radius, 
                                  self.maxHandle.frame.size.width+radius*2, self.maxHandle.frame.size.height+radius*2);
    
    // take closest
    if (abs(touchPoint.x - self.minHandle.center.x) < abs(touchPoint.x - self.maxHandle.center.x)) {
        if ( CGRectContainsPoint(detectMin, touchPoint) ) {
		latchMin = YES;
        }
    } else if ( CGRectContainsPoint(detectMax, touchPoint) ) {
		latchMax = YES;
	}
    [self updateHandleImages];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchPoint = [touch locationInView:self];
   	if ( latchMin || CGRectContainsPoint(self.minHandle.frame, touchPoint) ) {
		if (touchPoint.x < self.maxHandle.center.x - kMinHandleDistance && touchPoint.x > sliderBarDeltaX) {
			self.minHandle.center = CGPointMake(touchPoint.x, self.minHandle.center.y);
			[self updateValues];
		}
	}
	else if ( latchMax || CGRectContainsPoint(self.maxHandle.frame, touchPoint) ) {
		if (touchPoint.x > self.minHandle.center.x + kMinHandleDistance && touchPoint.x < (sliderBarWidth + sliderBarDeltaX)) {
			self.maxHandle.center = CGPointMake(touchPoint.x, self.maxHandle.center.y);
			[self updateValues];
		}
	}
	// Send value changed alert
	[self sendActionsForControlEvents:UIControlEventValueChanged];
    
	//redraw
	[self setNeedsDisplay];
	return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    latchMin = NO;
    latchMax = NO;
    [self updateHandleImages];
}

#pragma mark Custom Drawing

- (void) drawRect:(CGRect)rect
{
	//FIX: optimise and save some reusable stuff
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGGradientRef innerGradient = CGGradientCreateWithColorComponents(baseSpace, innerColors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
	
	CGRect rect1 = CGRectMake(sliderBarDeltaX, sliderBarDeltaY, self.minHandle.center.x, sliderBarHeight );
	CGRect rect2 = CGRectMake(self.minHandle.center.x, sliderBarDeltaY, self.maxHandle.center.x - self.minHandle.center.x, sliderBarHeight );
	CGRect rect3 = CGRectMake(self.maxHandle.center.x, sliderBarDeltaY, sliderBarWidth - self.maxHandle.center.x+sliderBarDeltaX, sliderBarHeight );
    	
    CGContextSaveGState(context);
	
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect2), CGRectGetMinY(rect2));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect2), CGRectGetMaxY(rect2));
	
	//add the right rect
	[self addToContext:context roundRect:rect3 withRoundedCorner1:NO corner2:YES corner3:YES corner4:NO radius:5.0f];
	//add the left rect
	[self addToContext:context roundRect:rect1 withRoundedCorner1:YES corner2:NO corner3:NO corner4:YES radius:5.0f];
	
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);    
    CGGradientRelease(gradient), gradient = NULL;
    
    
     //draw middle rect
	CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    [self addToContext:context roundRect:rect2 withRoundedCorner1:NO corner2:NO corner3:NO corner4:NO radius:5.0f];
    CGContextClip(context);
    CGContextDrawLinearGradient(context, innerGradient, startPoint, endPoint, 0);
    CGGradientRelease(innerGradient), innerGradient = NULL;
    
   
    CGContextRestoreGState(context);
    
    for (id mark in marks) {
        [self addMarkWithLabel:[(NSNumber*)mark floatValue]];
    }
    
    CGContextSaveGState(context);
  
	[super drawRect:rect];
}

- (void)addToContext:(CGContextRef)context roundRect:(CGRect)rrect withRoundedCorner1:(BOOL)c1 corner2:(BOOL)c2 corner3:(BOOL)c3 corner4:(BOOL)c4 radius:(CGFloat)radius
{	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, c1 ? radius : 0.0f);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, c2 ? radius : 0.0f);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, c3 ? radius : 0.0f);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, c4 ? radius : 0.0f);
}

-(void)addMarkWithLabel:(float)mark {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGFloat x = [self valueToX:mark];
    CGFloat y = self.frame.size.height / 2;
    
    UIColor *orange = [UIColor orangeColor];
    CGContextSetStrokeColor(ctx, CGColorGetComponents(orange.CGColor));
    CGContextSetLineWidth(ctx, 1);
    CGContextMoveToPoint(ctx, x, y - 15);
    CGContextAddLineToPoint(ctx, x, y + 10);
    
    CGFloat dash[] = {5.0, 2.0};
    CGContextSetLineDash(ctx, 0.0, dash, 2);
    
    CGContextStrokePath(ctx);
    
    CGContextRestoreGState(ctx);
    
    // ---- Text
    NSString* str = [NSString stringWithFormat:@"%1.1f", mark];
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [orange CGColor]);
    CGContextSelectFont(ctx,  "Helvetica Neue Bold" , 12.0, kCGEncodingMacRoman);
    CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1, -1)); 
    
    
    CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1, -1)); 
    CGContextSetShadowWithColor(ctx, CGSizeMake(0.0, 1.0), 1.0, [[UIColor whiteColor] CGColor]);
    CGContextSetTextMatrix(ctx, CGAffineTransformMake(1.0,0.0, 0.0, -1.0, 0.0, 0.0));
    
    CGContextShowTextAtPoint(ctx,x - 12, y + 20, [str UTF8String], str.length);
    CGContextRestoreGState(ctx);
    
    orange = nil;
    
}

#pragma mark Helper

- (void)updateHandleImages
{
    self.minHandle.highlighted = latchMin;
    self.maxHandle.highlighted = latchMax;
}

- (void)updateValues
{
	self.minSelectedValue = [self xToValue:self.minHandle.center.x];
    
    //snap to min value
    if (self.minSelectedValue < minValue + kBoundaryValueThreshold * valueSpan) self.minSelectedValue = minValue;
        
    self.maxSelectedValue = [self xToValue:self.maxHandle.center.x];
    //snap to max value
    if (self.maxSelectedValue > maxValue - kBoundaryValueThreshold * valueSpan) self.maxSelectedValue = maxValue;
}

@end