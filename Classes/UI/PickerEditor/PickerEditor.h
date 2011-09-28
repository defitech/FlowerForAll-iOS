//
//  PickerEditor.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 15.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  PickerEditorDelegate;




@interface PickerEditor : UITableViewController
{
    id<PickerEditorDelegate> delegate;
    UINavigationController* nav;
    NSString* cellNibName;
    
    // My Cell
	IBOutlet UITableViewCell *tblCell;
}

@property (nonatomic, assign) id delegate;
-(id)initWithDelegate:(id<PickerEditorDelegate>)delegate useCellNib:(NSString*)nib;
-(void)showOnTopOfView:(UIView*)onView;
-(void)close;
@end // end interface


@protocol PickerEditorDelegate
@required
-(NSString*)pickerEditorTitle:(PickerEditor*)sender; 
-(NSString*)pickerEditorEndButtonTitle:(PickerEditor*)sender; 
-(void)pickerEditorIsDone:(PickerEditor*)sender;

/** return the number of choices **/
-(int)pickerEditorSize:(PickerEditor*)sender; 


/** use it if you want to pimp a custom cell **/
-(void)pimpCellAt:(PickerEditor*)sender cell:(UITableViewCell*)cell index:(int)index;

/** called when selection change on an element **/
-(void)pickerEditorSelectedRowAt:(PickerEditor*)sender index:(int)index;

@end


