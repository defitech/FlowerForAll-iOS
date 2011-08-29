//
//  CorePlot_GeckoGeekViewController.h
//  CorePlot-GeckoGeek
//
//  Created by Vincent on 06/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface CorePlot_GeckoGeekViewController : UIViewController <CPPlotDataSource> {

	CPLayerHostingView *graphView;
	CPXYGraph *graph;

}

@end

