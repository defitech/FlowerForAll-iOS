//
//  Users_CellView.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 14.11.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Users_CellView : UITableViewCell {
    IBOutlet UIButton *selectedButton;
    IBOutlet UILabel *myLabel;
}

@property (nonatomic ,retain)  IBOutlet UIButton* selectedButton;  

@property (nonatomic, retain) IBOutlet UILabel *myLabel;


@end
