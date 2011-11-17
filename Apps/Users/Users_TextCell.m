//
//  Users_TextCell.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Users_TextCell.h"

@implementation Users_TextCell

@synthesize textView;

- (NSString *) reuseIdentifier {
    return @"textCell";
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        UIView *transparentBackground = [[UIView alloc] initWithFrame:CGRectZero];
        transparentBackground.backgroundColor = [UIColor clearColor];
        self.backgroundView = transparentBackground;	
    }
    return self;
}


- (CGFloat) height {
    [textView setText:NSLocalizedStringFromTable(@"Add users if this device is used by several persons. Only the owner may add or remove users.",@"Users",@"Info Text")];
    
    CGSize constraintSize = CGSizeMake(textView.frame.size.width, MAXFLOAT);
    
    CGSize textViewSize = [[textView text] sizeWithFont:[textView font] constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    if (textViewSize.height < 60) textViewSize.height = 60;
    
    [textView setFrame:CGRectMake(textView.frame.origin.x, textView.frame.origin.y,textView.frame.size.width, textViewSize.height + 10)];
    return textView.frame.size.height + 10;
}

- (void)dealloc {
    [super dealloc];
    [textView release];
}

@end
