//
//  Users_TextCell.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Users_TextCell : UITableViewCell {
    IBOutlet UITextView* textView;
}

@property (nonatomic ,retain)  IBOutlet UITextView* textView;  

- (IBAction) userDataChangeEvent:(id)sender;

- (CGFloat) height;

@end
