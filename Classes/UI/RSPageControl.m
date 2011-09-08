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

@implementation RSPageControl

// Sets the image of current page icon to selected
// and that of others to unselected.
-(void) drawFancyPageIcon{
	NSUInteger currentPageIcon = 0;
	NSArray *pageIcons = self.subviews;
	
	for (UIImageView *pageIcon in pageIcons) {
		if (currentPageIcon == self.currentPage) {
			pageIcon.image = [UIImage imageNamed:SELECTED_PAGE_ICON_IMAGE];
		}else {
			pageIcon.image = [UIImage imageNamed:UNSELECTED_PAGE_ICON_IMAGE];
		}
		currentPageIcon++;
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
