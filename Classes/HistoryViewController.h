//
//  HistoryViewController.h
//
//  Created by Jerome on 29/08/11.
//  Copyright 2010 Defitech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "BlowHistory.h"

@interface HistoryViewController : UIViewController <CPPlotDataSource,BlowHistoryDelegate> {
    
	CPGraphHostingView *graphView;
	CPXYGraph *graph;
    
    UILabel *labelView;
    
    BlowHistory *history;
    int historyDuration;
    int graphPadding;
    int blowDuration;
}

-(void) historyChange:(id*) history;

@end