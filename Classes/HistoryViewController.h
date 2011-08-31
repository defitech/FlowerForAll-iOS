//
//  HistoryViewController.h
//
//  Created by Jerome on 29/08/11.
//  Copyright 2010 Defitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "FLAPIX.h"

@interface HistoryViewController : UIViewController <CPPlotDataSource> {

	CPGraphHostingView *graphView;
	CPXYGraph *graph;
    FLAPIX *flapix;

}

@property (nonatomic, retain) FLAPIX *flapix;

@end

