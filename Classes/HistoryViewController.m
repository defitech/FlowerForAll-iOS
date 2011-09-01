//
//  HistoryViewController.m
//
//  Created by Jerome on 29/08/11.
//  Copyright 2010 Defitech. All rights reserved.
//

#import "HistoryViewController.h"
#import "ParametersManager.h"

@implementation HistoryViewController

- (void)loadView {
	// Alloc & Init Main View
	UIView *tmpView = [ [ UIView alloc ] initWithFrame:CGRectMake(40.0, 420.0, 280.0, 40.0) ];
	[ tmpView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
	[ tmpView setBackgroundColor:[ UIColor lightGrayColor ] ]; //clearColor = transparent
	[ self setView:[ tmpView autorelease ] ];
	
	// Alloc Graph View
	graphView = [ [ CPGraphHostingView alloc ] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0) ];
	[ self.view addSubview:[ graphView autorelease ] ];
    
   
	// Alloc History
    history = [[BlowHistory alloc] initWithDuration:1 delegate:self];
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
	// Init Padding to 0
	graph.paddingLeft = 10.0;
	graph.paddingTop = 10.0;
	graph.paddingRight = 10.0;
	graph.paddingBottom = 10.0;
	
	/*
	 *	Graph Prefs
	 */
	// X & Y Range
	// Get Default Plot Space
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	// Set X Range from -10 to 10 (length = 20)
	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(20.0)];
	// Set Y Range from -5 to 5 (length = 10)
	plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0) length:CPDecimalFromFloat(20.0)];
    
	/*
	 *	Axis X & Y Prefs
	 */
	// Line Style
	CPLineStyle *lineStyle = [CPLineStyle lineStyle];
	lineStyle.lineColor = [CPColor blackColor];
	lineStyle.lineWidth = 1.0f;
	
	// Axis X Prefs
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
	// Set the "major" interval length
	axisSet.xAxis.majorIntervalLength = [ [ NSDecimalNumber decimalNumberWithString:@"5.0" ] decimalValue ];
	// Set the number of ticks per interval
	axisSet.xAxis.minorTicksPerInterval = 1;
	// Set major & minor line style
	axisSet.xAxis.majorTickLineStyle = lineStyle;
	axisSet.xAxis.minorTickLineStyle = lineStyle;
	// Set axis line style
	axisSet.xAxis.axisLineStyle = lineStyle;
	// Set length of the minor tick
	axisSet.xAxis.minorTickLength = 5.0f;
	// Set length of the major tick
	axisSet.xAxis.majorTickLength = 10.0f;
	// Set the offset of the label (beside the X axis)
	axisSet.xAxis.labelOffset = 3.0f;
    
	// Axis Y Prefs (same things)
	axisSet.yAxis.majorIntervalLength = [ [ NSDecimalNumber decimalNumberWithString:@"5.0" ] decimalValue ];
	axisSet.yAxis.minorTicksPerInterval = 1;
	axisSet.yAxis.majorTickLineStyle = lineStyle;
	axisSet.yAxis.minorTickLineStyle = lineStyle;
	axisSet.yAxis.axisLineStyle = lineStyle;
	axisSet.yAxis.minorTickLength = 5.0f;
	axisSet.yAxis.majorTickLength = 10.0f;
	axisSet.yAxis.labelOffset = 3.0f;
	
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
	
	// If Plot 1
	if (plot.identifier == @"inRange")
		return 10;
	
	// If Plot 2
	return 10;
	
}

- (NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	
	// Number of the X axis asked
	if (fieldEnum == CPScatterPlotFieldX) {
		
		// Return -10, -9, -8, ... 8, 9, 10
		if (plot.identifier == @"inRange")
			return [ NSNumber numberWithInteger:index ];
		// Return -5, -4, ..., 4, 5
		else if (plot.identifier == @"total")
			return [ NSNumber numberWithInteger:index ];
		
	// Number of the Y axis asked
	} else if (fieldEnum == CPScatterPlotFieldY) { 
		
		// Return -10, -9, -8, ... 8, 9, 10
		if (plot.identifier == @"inRange")
			return [ NSNumber numberWithInteger:index ];
		// Return -5, -4, ..., 4, 5
		else if (plot.identifier == @"total")
			return [ NSNumber numberWithInteger:index+1 ];
		
	}
	
	// Return a default value, shouldn't be returned
	return nil;
	
}

-(void) historyChange:(id*) history_id {
    NSLog(@"History change %i",[[(BlowHistory*)history_id getHistoryArray] count]);
}

- (void)addValues {
    //store new data
    
    //resize axis
    
    //redraw the graph
    [graph reloadData];
}

- (void)dealloc {
	[history release];
    [super dealloc];
	
}

@end