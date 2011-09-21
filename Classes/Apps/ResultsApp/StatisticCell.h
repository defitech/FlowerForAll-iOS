//
//  StatisticCell.h
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  This class defines a custom table view cell, which is used in the statistics table views.


#import <UIKit/UIKit.h>


@interface StatisticCell : UITableViewCell {
	
	//Widgets of the custom cell
	UILabel *primaryLabel;
	UILabel *secondaryLabel;
	UILabel *thirdLabel;
	//UISwitch *aSwitch;
	
}


//Properties
@property(nonatomic,retain)UILabel *primaryLabel;
@property(nonatomic,retain)UILabel *secondaryLabel;
@property(nonatomic,retain)UILabel *thirdLabel;
//@property(nonatomic,retain)UISwitch *aSwitch;


@end
