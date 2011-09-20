//
//  DoubleSlider.h
//  Sweeter
//
//  Created by Dimitris on 23/06/2010.
//  Copyright 2010 locus-delicti.com. All rights reserved.
//


@interface DoubleSlider : UIControl {
	float lastMinSelectedValue;
	float lastMaxSelectedValue;
	float minSelectedValue;
	float maxSelectedValue;
	float minValue;
	float maxValue;
    float valueSpan;
    BOOL latchMin;
    BOOL latchMax;
	
	UIImageView *minHandle;
	UIImageView *maxHandle;
	
	float sliderBarHeight;
    float sliderBarWidth;
    float sliderBarDeltaY;
	
	CGColorRef bgColor;
}

@property float minSelectedValue;
@property float maxSelectedValue;

@property (nonatomic, retain) UIImageView *minHandle;
@property (nonatomic, retain) UIImageView *maxHandle;

-(void) initView:(float)height;
-(void) initValues:(float)aMinValue maxValue:(float)aMaxValue ;
-(void) setSelectedValues:(float)aMinValue maxValue:(float)aMaxValue ;

- (id) initWithFrame:(CGRect)aFrame minValue:(float)minValue maxValue:(float)maxValue barHeight:(float)height;

+ (id) doubleSlider;

-(void)addMarkWithLabel:(float)mark;

@end


/*
Improvements:
 - initWithWidth instead of frame?
 - do custom drawing below an overlay layer
 - add inner shadow to the background and shadow to handles in code
*/