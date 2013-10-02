//
//  RSPageControl.m
//  Sample
//
//  Created by Pratiksha Bhisikar on 01/11/10.
//  Copyright 2010. All rights reserved.
//

#import "RSPageControl.h"

#define SELECTED_PAGE_ICON_IMAGE @"icon_contents_page_selected.png"
#define UNSELECTED_PAGE_ICON_IMAGE @"icon_contents_page_unselected.png"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation RSPageControl

// Sets the image of current page icon to selected
// and that of others to unselected.
-(void) drawFancyPageIcon{
  if SYSTEM_VERSION_LESS_THAN(@"6.0") {
	NSUInteger currentPageIcon = 0;
	NSArray *pageIcons = self.subviews;
	NSString *iconName;
	
	for (UIImageView *pageIcon in pageIcons) {
		if (currentPageIcon == self.currentPage) {
			iconName = SELECTED_PAGE_ICON_IMAGE;
		}else {
			iconName = UNSELECTED_PAGE_ICON_IMAGE;
		}
		pageIcon.image = [UIImage imageNamed:iconName];
		currentPageIcon++;
	}
  }
}

-(void) setCurrentPage:(NSInteger) page{
	[super setCurrentPage:page];
	[self drawFancyPageIcon];
}

-(void) setNumberOfPages:(NSInteger) pageCount{
	[super setNumberOfPages:pageCount];
	[self drawFancyPageIcon];
}

-(void) dealloc{
	[super dealloc];
}

@end
