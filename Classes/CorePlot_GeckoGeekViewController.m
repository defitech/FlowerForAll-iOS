//
//  CorePlot_GeckoGeekViewController.m
//  CorePlot-GeckoGeek
//
//  Created by Vincent on 06/09/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CorePlot_GeckoGeekViewController.h"

@implementation CorePlot_GeckoGeekViewController

- (void)loadView {
	
	// Alloc & Init Main View
	UIView *tmpView = [ [ UIView alloc ] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0-20.0) ];
	[ tmpView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
	[ tmpView setBackgroundColor:[ UIColor whiteColor ] ];
	[ self setView:[ tmpView autorelease ] ];
	
	// Alloc Graph View
	graphView = [ [ CPLayerHostingView alloc ] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0-20.0) ];
	[ self.view addSubview:[ graphView autorelease ] ];
	
}


- (void)viewDidLoad {
	
    [ super viewDidLoad ];
	
	/*
	 *	CPXYGraph Prefs
	 */
	// Alloc CPXYGraph
	graph = [ [ CPXYGraph alloc ] initWithFrame: self.view.bounds ];
	// Link between the view and the Layer
	graphView.hostedLayer = graph;
	// Init Padding to 0
	graph.paddingLeft = 0.0;
	graph.paddingTop = 0.0;
	graph.paddingRight = 0.0;
	graph.paddingBottom = 0.0;
	
	/*
	 *	PLOTS
	 */
	// Plot 1 - Alloc
	CPScatterPlot *plot1 = [[[CPScatterPlot alloc]initWithFrame:self.view.bounds] autorelease];
	// Plot 1 - Set ID
	plot1.identifier = @"Plot 1";
	// Plot 1 - Set Line Width
	plot1.dataLineStyle.lineWidth = 1.0f;
	// Plot 1 - Set Line Color
	plot1.dataLineStyle.lineColor = [CPColor colorWithComponentRed:255.0/255.0 green:0.0 blue:0.0 alpha:1.0];
	// Plot 1 - Set Data Source Object
	plot1.dataSource = self;
	// Plot 1 - Add Plot to the graph layer
	[ graph addPlot:plot1 ];
	
	// Plots 2 - Same Things
	CPScatterPlot *plot2 = [[[CPScatterPlot alloc]initWithFrame:self.view.bounds] autorelease];
	plot2.identifier = @"Plot 2";
	plot2.dataLineStyle.lineWidth = 1.0f;
	plot2.dataLineStyle.lineColor = [CPColor colorWithComponentRed:0.0 green:0.0 blue:205.0/255.0 alpha:1.0];
	plot2.dataSource = self;
	[graph addPlot:plot2];
	
	
	/*
	 *	Graph Prefs
	 */
	// X & Y Range
	// Get Default Plot Space
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
	// Set X Range from -10 to 10 (length = 20)
	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInteger(-10) length:CPDecimalFromInteger(20)];
	// Set Y Range from -5 to 5 (length = 10)
	plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-5.0) length:CPDecimalFromFloat(10.0)];
		
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
	axisSet.xAxis.minorTicksPerInterval = 4;
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
	axisSet.yAxis.majorIntervalLength = [ [ NSDecimalNumber decimalNumberWithString:@"2.0" ] decimalValue ];
	axisSet.yAxis.minorTicksPerInterval = 1;
	axisSet.yAxis.majorTickLineStyle = lineStyle;
	axisSet.yAxis.minorTickLineStyle = lineStyle;
	axisSet.yAxis.axisLineStyle = lineStyle;
	axisSet.yAxis.minorTickLength = 5.0f;
	axisSet.yAxis.majorTickLength = 10.0f;
	axisSet.yAxis.labelOffset = 3.0f;	
	
}

- (NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
	
	// If Plot 1
	if (plot.identifier == @"Plot 1")
		return 21;
	
	// If Plot 2
	return 11;
	
}

- (NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	
	// Number of the X axis asked
	if (fieldEnum == CPScatterPlotFieldX) {
		
		// Return -10, -9, -8, ... 8, 9, 10
		if (plot.identifier == @"Plot 1")
			return [ NSNumber numberWithInteger:-10.0+index ];
		// Return -5, -4, ..., 4, 5
		else if (plot.identifier == @"Plot 2")
			return [ NSNumber numberWithInteger:-5.0+index ];
		
	// Number of the Y axis asked
	} else if (fieldEnum == CPScatterPlotFieldY) { 
		
		// Return -10, -9, -8, ... 8, 9, 10
		if (plot.identifier == @"Plot 1")
			return [ NSNumber numberWithFloat:(-10.0+index)/2.0 ];
		// Return -5, -4, ..., 4, 5
		else if (plot.identifier == @"Plot 2")
			return [ NSNumber numberWithInteger:-5.0+index ];
		
	}
	
	// Return a default value, shouldn't be returned
	return [ NSNumber numberWithFloat:0.0 ];
	
}

- (void)dealloc {
	
    [super dealloc];
	
}

@end