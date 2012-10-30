//
//  UserChooser_TextCell.h
//  FlowerForAll
//
//  Created by adherent on 11.10.12.
//
//

#import <UIKit/UIKit.h>

@interface UserChooser_TextCell :  UITableViewCell {
    IBOutlet UITextView* textView;
}

@property (nonatomic ,retain)  IBOutlet UITextView* textView;

- (IBAction) userDataChangeEvent:(id)sender;

- (CGFloat) height;

@end
