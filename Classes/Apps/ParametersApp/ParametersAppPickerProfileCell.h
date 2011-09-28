//
//  ParametersAppPickerProfileCell.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 22.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParametersAppPickerProfileCell : UITableViewCell {
    IBOutlet UILabel* nameLabel;
    IBOutlet UILabel* minHzLabel;
    IBOutlet UILabel* maxHzLabel;
    IBOutlet UILabel* exeDLabel;
    IBOutlet UILabel* expDLabel;
}

@property (nonatomic, retain) IBOutlet UILabel* nameLabel;
@property (nonatomic, retain) IBOutlet UILabel*  minHzLabel;
@property (nonatomic, retain) IBOutlet UILabel*  maxHzLabel;
@property (nonatomic, retain) IBOutlet UILabel*  exeDLabel;
@property (nonatomic, retain) IBOutlet UILabel*  expDLabel;

@end
