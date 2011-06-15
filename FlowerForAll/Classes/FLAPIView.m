//
//  FLAPIView.m
//  FlutterApp2
//
//  Created by Pierre-Mikael Legris on 07.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FLAPIView.h"
#import "FlowerController.h"

@implementation FLAPIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touched");
    [FlowerController showNav];
}

- (void)dealloc
{
    [super dealloc];
}

@end
