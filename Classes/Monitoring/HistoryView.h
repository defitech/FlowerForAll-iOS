//
//  HistoryView.h
//
//  Created by Jerome on 29/08/11.
//  Copyright 2010 Defitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "BlowHistory.h"

@interface HistoryView : UIView <CPPlotDataSource,CPScatterPlotDelegate,BlowHistoryDelegate> {
    
	CPGraphHostingView *graphView;
	CPXYGraph *graph;
    CPXYPlotSpace *plotSpace;
    
    UILabel *labelPercent;
    UILabel *labelFrequency;
    UILabel *labelDuration;
    
    BlowHistory *history;
    int historyDuration;
    int graphPadding;
    
    double higherBar;
}

-(void) historyChange:(id*) history;

@end