//
//  ResultApp_MailerOptions.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultsApp.h"

@interface ResultsApp_MailerOptions : UIViewController {
    
    UIDatePicker* datePicker;
    
    UIButton* fromStartButton;
    UIButton* fromMailButton;
    
    UILabel* includeBlowsLabel;
     UISwitch* includeBlowsSwitch;
    
    UILabel* displayTableLabel;
    UISwitch* displayTableSwitch;
    
}


@property  (nonatomic, retain) IBOutlet  UIDatePicker* datePicker;

@property  (nonatomic, retain) IBOutlet  UIButton* fromStartButton;
@property  (nonatomic, retain) IBOutlet  UIButton* fromMailButton;

@property  (nonatomic, retain) IBOutlet  UILabel* includeBlowsLabel;
@property  (nonatomic, retain) IBOutlet  UISwitch* includeBlowsSwitch;

@property  (nonatomic, retain) IBOutlet  UILabel* displayTableLabel;
@property  (nonatomic, retain) IBOutlet  UISwitch* displayTableSwitch;

- (IBAction)fromStartButtonPressed:(id)sender;

- (IBAction)fromMailButtonPressed:(id)sender;

- (IBAction)displayTableSwitchValueChange:(id)sender;

- (IBAction)includeBlowsSwitchValueChange:(id)sender;

- (IBAction)datePickerValueChange:(id)sender;

- (id)initWithResultsApp:(ResultsApp*)delegate;


- (int)selectedExerciceCount ;

- (NSDate*) selectedStartDate ;

@end
