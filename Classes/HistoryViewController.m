//
//  HistoryViewController.m
//
//  Created by Jerome on 29/08/11.
//  Copyright 2010 Defitech. All rights reserved.
//

#import "HistoryViewController.h"
#import "ParametersManager.h"
#import "FLAPIBlow.h"

@implementation HistoryViewController

- (void)loadView {
	// Alloc & Init Main View
	UIView *tmpView = [ [ UIView alloc ] initWithFrame:CGRectMake(40.0, 420.0, 280.0, 40.0) ];
	[ tmpView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
	[ tmpView setBackgroundColor:[ UIColor blackColor ] ];
	[ self setView:[ tmpView autorelease ] ];
	
	// Alloc Graph View
	graphView = [ [ CPGraphHostingView alloc ] initWithFrame:CGRectMake(0.0, 0.0, 280.0, 40.0) ];
	[ self.view addSubview:[ graphView autorelease ] ];
    
    historyDuration = 2; // 2 minutes
    graphPadding = 2; // 2 pixels
    blowDuration = 4; // 4 secondes
    
    history = [[BlowHistory alloc] initWithDuration:historyDuration delegate:self];
}


- (void)viewDidLoad {
    
    [ super viewDidLoad ];
	
	/*
	 *	CPXYGraph Prefs
	 */
	// Alloc CPXYGraph
	graph = [ [ CPXYGraph alloc ] initWithFrame: self.view.bounds ];
	// Link between the view and the Layer
	graphView.hostedGraph = graph;
	// Init Padding to 2
	graph.paddingLeft = graphPadding;
	graph.paddingTop = graphPadding;
	graph.paddingRight = graphPadding;
	graph.paddingBottom = graphPadding;
	
	/*
	 *	Graph Prefs
	 */
	// Default X & Y Range for Plot Space
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	// Set X Range from -45 minutes to now
	plotSpace.xRange = [CPPlotRange
                        plotRangeWithLocation:CPDecimalFromDouble(-(historyDuration * 60))
                        length:CPDecimalFromDouble(historyDuration * 60 + 1)];
	// Set Y Range from 0 to 4 secondes
	plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) length:CPDecimalFromInt(blowDuration)];
    
	/*
	 *	Axis Prefs
	 */
	// Line Style
	CPLineStyle *lineStyle = [CPLineStyle lineStyle];
	lineStyle.lineColor = [CPColor whiteColor];
	lineStyle.lineWidth = 1.0f;
	
	// Axis X Prefs
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    //	// Set the "major" interval length to 5 minutes
    //	axisSet.xAxis.majorIntervalLength = [ [ NSDecimalNumber decimalNumberWithString:@"60.0" ] decimalValue ];
    //	// Set the number of ticks per interval
    //	axisSet.xAxis.minorTicksPerInterval = 30;
    //	// Set major & minor line style
    //	axisSet.xAxis.majorTickLineStyle = lineStyle;
    //	axisSet.xAxis.minorTickLineStyle = lineStyle;
	// Set axis line style
	axisSet.xAxis.axisLineStyle = lineStyle;
    //	// Set length of the minor tick
    //	axisSet.xAxis.minorTickLength = 5.0f;
    //	// Set length of the major tick
    //	axisSet.xAxis.majorTickLength = 10.0f;
    //	// Set the offset of the label (beside the X axis)
    //	axisSet.xAxis.labelOffset = 3.0f;
    // Set the exclusion ranges where no axis label will be drawn
    axisSet.xAxis.labelExclusionRanges = [NSArray arrayWithObjects:
                                          [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-200) 
                                                                      length:CPDecimalFromFloat(250)], nil];
    
	// Axis Y Prefs (same things)
    //	axisSet.yAxis.majorIntervalLength = [ [ NSDecimalNumber decimalNumberWithString:@"2.0" ] decimalValue ];
    //	axisSet.yAxis.minorTicksPerInterval = 1;
    //	axisSet.yAxis.majorTickLineStyle = lineStyle;
    //	axisSet.yAxis.minorTickLineStyle = lineStyle;
	axisSet.yAxis.axisLineStyle = lineStyle;
    //	axisSet.yAxis.minorTickLength = 5.0f;
    //	axisSet.yAxis.majorTickLength = 10.0f;
    //	axisSet.yAxis.labelOffset = 3.0f;
    axisSet.yAxis.labelExclusionRanges = [NSArray arrayWithObjects:
                                          [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-10) 
                                                                      length:CPDecimalFromFloat(20)], nil];
	
	/*
	 *	PLOTS
	 */
	// Plot 1 - Alloc
	CPScatterPlot *plot1 = [[[CPScatterPlot alloc]initWithFrame:self.view.bounds] autorelease];
	// Plot 1 - Set ID
	plot1.identifier = @"inRange";
	// Plot 1 - Set Line Width
	plot1.dataLineStyle.lineWidth = 1.0f;
	// Plot 1 - Set Line Color
	plot1.dataLineStyle.lineColor = [CPColor greenColor];
	// Plot 1 - Set Data Source Object
	plot1.dataSource = self;
	// Plot 1 - Add Plot to the graph layer
	[ graph addPlot:plot1 ];
	
	// Plots 2 - Same Things
	CPScatterPlot *plot2 = [[[CPScatterPlot alloc]initWithFrame:self.view.bounds] autorelease];
	plot2.identifier = @"total";
	plot2.dataLineStyle.lineWidth = 1.0f;
	plot2.dataLineStyle.lineColor = [CPColor redColor];
	plot2.dataSource = self;
	[graph addPlot:plot2];
	
}

- (NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    
    return [[history getHistoryArray] count];
    
}

- (NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	
    FLAPIBlow* current = [[history getHistoryArray] objectAtIndex:index];
    
	// Number of the X axis asked
	if (fieldEnum == CPScatterPlotFieldX) {
        double xVal = current.timestamp - CFAbsoluteTimeGetCurrent();
        NSLog(@"xVal = %f", xVal);
		return [ NSNumber numberWithDouble:xVal ];
		
        // Number of the Y axis asked
	} else if (fieldEnum == CPScatterPlotFieldY) { 
		
		if (plot.identifier == @"inRange") {
            NSLog(@"inRange = %f", current.in_range_duration);
            return [ NSNumber numberWithDouble:current.in_range_duration ];
            
        } else if (plot.identifier == @"total") {
            NSLog(@"duration = %f", current.duration);
            return [ NSNumber numberWithDouble:current.duration ];
        }
	}
	
	// Return a default value, shouldn't be returned
	return nil;
	
}

-(void) historyChange:(id*) history_id {
    //    NSLog(@"History change %i",[[(BlowHistory*)history_id getHistoryArray] count]);
    //redraw the graph
    [graph reloadData];
}

- (void)dealloc {
	[history release];
    [super dealloc];
	
}

@end