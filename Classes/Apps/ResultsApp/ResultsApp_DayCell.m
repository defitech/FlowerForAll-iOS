//
//  StatisticCell.m
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//  Implementation of the StatisticCell class


#import "ResultsApp_DayCell.h"


@implementation ResultsApp_DayCell


@synthesize primaryLabel, secondaryLabel, thirdLabel;




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self == ([super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

		// Initialization code
		primaryLabel = [[UILabel alloc]init];
		primaryLabel.textAlignment = UITextAlignmentLeft;
		//primaryLabel.font = [UIFont systemFontOfSize:20];
		primaryLabel.font = [UIFont boldSystemFontOfSize:20];
		
		secondaryLabel = [[UILabel alloc]init];
		secondaryLabel.textAlignment = UITextAlignmentLeft;
		secondaryLabel.font = [UIFont systemFontOfSize:14];
		secondaryLabel.textColor = [UIColor grayColor];
		
		thirdLabel = [[UILabel alloc]init];
		thirdLabel.textAlignment = UITextAlignmentLeft;
		//thirdLabel.font = [UIFont systemFontOfSize:20];
		thirdLabel.font = [UIFont boldSystemFontOfSize:20];

		
		//myImageView = [[UIImageView alloc]init];
		[self.contentView addSubview:primaryLabel];
		[self.contentView addSubview:secondaryLabel];
		[self.contentView addSubview:thirdLabel];
		//[self.contentView addSubview:myImageView];
		
	}
	
	return self;	
}




//Place the widgets inside the cell
- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	CGRect frame;
	
	frame= CGRectMake(boundsX+10 ,0, 200, 25);
	primaryLabel.frame = frame;
	
	frame= CGRectMake(boundsX+10 ,25, 100, 15);
	secondaryLabel.frame = frame;
	
	frame= CGRectMake(boundsX+140 ,0, 100, 25);
	thirdLabel.frame = frame;
	
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
}




- (void)dealloc {
	[primaryLabel dealloc];
	[secondaryLabel dealloc];
	[thirdLabel dealloc];
    [super dealloc];
}


@end
