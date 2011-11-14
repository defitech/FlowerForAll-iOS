//
//  Users_CellView.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Users_CellView.h"

@implementation Users_CellView

- (NSString *) reuseIdentifier {
    return @"userCell";
}


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

@end
