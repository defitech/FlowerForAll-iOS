//
//  Users_Editor.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 16.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface Users_Editor : UIViewController <UIAlertViewDelegate> {
    UILabel* nameLabel;
    UITextField* nameField;
    UILabel* passwordLabel;
    UITextField* passwordField;
    UIButton* deleteButton;
    User* me;
}

- (id) initWithUser:(User*)user;
@property (nonatomic, retain) User* me;

@property (nonatomic, retain) IBOutlet UILabel* nameLabel;
@property (nonatomic, retain) IBOutlet UITextField* nameField;
@property (nonatomic, retain) IBOutlet UILabel* passwordLabel;
@property (nonatomic, retain) IBOutlet UITextField* passwordField;
@property (nonatomic, retain) IBOutlet UIButton* deleteButton;


- (IBAction) nameFieldEditingEnd:(id)sender;
- (IBAction) passwordFieldEditingEnd:(id)sender;

- (IBAction) buttonDeletePressed: (id)sender ;
@end

