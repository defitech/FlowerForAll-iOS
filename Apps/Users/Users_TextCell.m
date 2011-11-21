//
//  Users_TextCell.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Users_TextCell.h"
#import "UserManager.h"

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
        

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(userDataChangeEvent:)
         name: @"userDataChangeEvent"
         object: nil];
      
    }
    return self;
}

BOOL  textIsSet = NO;

- (IBAction) userDataChangeEvent:(id)sender {
     textIsSet = YES;
    
    if ([UserManager currentUser].uid == 0) {
        if ([[UserManager listAllUser] count] > 1) {
             [textView setText:NSLocalizedStringFromTable(@"Only the owner may remove or edit user. \nYou may switch to another identity by choosing the coresponding username.",@"Users",@"Info Text")];
        } else {
            [textView setText:NSLocalizedStringFromTable(@"Add users if this device is used by several persons. Use the + button on the top right corner.",@"Users",@"Info Text")];
        }
    } else {
        [textView setText:NSLocalizedStringFromTable(@"You may switch to another identity by choosing the coresponding username. Only the owner may add or remove user.",@"Users",@"Info Text")];
    }
}


- (CGFloat) height {
    if (! textIsSet)   [self userDataChangeEvent:nil];
    
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
