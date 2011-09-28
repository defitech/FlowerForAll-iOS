//
//  ParametersAppPickerProfileCell.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 22.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "ParametersAppPickerProfileCell.h"

@implementation ParametersAppPickerProfileCell

@synthesize   nameLabel, minHzLabel, maxHzLabel, exeDLabel, expDLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *) reuseIdentifier {
    return @"ParametersAppPickerProfileCell";
}


@end
