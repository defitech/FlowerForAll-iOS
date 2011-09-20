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
}

@property (nonatomic, assign) id delegate;
-(id)initWithDelegate:(id<PickerEditorDelegate>)delegate ;
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

/** return the true if the object at this index is selected **/
-(BOOL)pickerEditorIsSelected:(PickerEditor*)sender index:(int)index;;

/** return the text to display for this element **/
-(NSString*)pickerEditorValue:(PickerEditor*)sender index:(int)index;

/** called when selection change on an element **/
-(void)pickerEditorSelectionChange:(PickerEditor*)sender index:(int)index;

@end


