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

@end // end interface


@protocol PickerEditorDelegate
@required
-(NSString*)pickerEditorTitle:(PickerEditor*)sender; 
-(NSString*)pickerEditorEndButtonTitle:(PickerEditor*)sender; 
-(void)pickerEditorIsDone:(PickerEditor*)sender didFinishWithSelection:(NSString*)selection;
@end


