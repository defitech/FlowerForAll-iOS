//
//  HistoryViewController.m
//
//  Created by Jerome on 29/08/11.
//  Copyright 2010 Defitech. All rights reserved.
//

#import "HistoryViewController.h"
#import "ParametersManager.h"
#import "FLAPIBlow.h"
#import "FlowerController.h"

@implementation HistoryViewController

- (void)loadView {
	// Alloc & Init Main View
	UIView *tmpView = [ [ UIView alloc ] initWithFrame:CGRectMake(40.0, 420.0, 280.0, 40.0) ];
	[ tmpView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight ];
	[ tmpView setBackgroundColor:[ UIColor blackColor ] ];
	[ self setView:[ tmpView autorelease ] ];
    
    // Add Touch
    UITapGestureRecognizer *singleFingerTap = 
    [[UITapGestureRecognizer alloc] initWithTarget:self 
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];

    
	
	// Alloc Graph View
	graphView = [ [ CPGraphHostingView alloc ] initWithFrame:CGRectMake(0.0, 0.0, 230.0, 40.0) ];
	[ self.view addSubview:[ graphView autorelease ] ];
    
    // Alloc Label View
    labelView = [ [ UITextView alloc ] initWithFrame:CGRectMake(230.0, 0.0, 50.0, 40.0) ];
    [labelView setBackgroundColor:[UIColor blackColor]];
    [labelView setTextColor:[UIColor whiteColor]];
    [labelView setFont:[UIFont systemFontOfSize:8.0]];
    [labelView setText:@"Label 1\nLabel 2\nLabel 3"];
    [labelView setEditable:FALSE];
    [ self.view addSubview:[ labelView autorelease ] ];
    
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
	// Set axis line style
	axisSet.xAxis.axisLineStyle = lineStyle;
    axisSet.xAxis.labelExclusionRanges = [NSArray arrayWithObjects:
                                          [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-200) 
                                                                      length:CPDecimalFromFloat(250)], nil];
    
	// Axis Y Prefs (same things)
	axisSet.yAxis.axisLineStyle = lineStyle;
    axisSet.yAxis.labelExclusionRanges = [NSArray arrayWithObjects:
                                          [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-10) 
                                                                      length:CPDecimalFromFloat(20)], nil];
	
	/*
	 *	PLOTS
	 */
	// isGood plot
	CPScatterPlot *goodPlot = [[[CPScatterPlot alloc]initWithFrame:self.view.bounds] autorelease];
    goodPlot.identifier = @"isGood";
	goodPlot.dataLineStyle.lineWidth = 1.0f;
	goodPlot.dataLineStyle.lineColor = [CPColor blackColor];
	goodPlot.dataSource = self;
	[ graph addPlot:[goodPlot autorelease] ];
    
    // blow duration plot
    CPBarPlot* blowPlot = [[[CPBarPlot alloc] initWithFrame:self.view.bounds] autorelease];
    blowPlot.identifier = @"blow";
    blowPlot.dataSource = self;
    blowPlot.barWidth = 5;
    blowPlot.barOffset = 0;  
    blowPlot.fill = [[CPFill alloc] initWithColor:[CPColor redColor]];;
    [ graph addPlot:[blowPlot autorelease] ];
    
    // in range duration
    CPBarPlot* inRangePlot = [[[CPBarPlot alloc] initWithFrame:self.view.bounds] autorelease];
    inRangePlot.identifier = @"inRange";
    inRangePlot.dataSource = self;
    inRangePlot.barWidth = 5;
    inRangePlot.barOffset = 0;
    inRangePlot.fill = [[CPFill alloc] initWithColor:[CPColor greenColor]];
    [ graph addPlot:[inRangePlot autorelease] ];
	
}

- (NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    
    return [[history getHistoryArray] count];
    
}

- (NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	
    FLAPIBlow* current = [[history getHistoryArray] objectAtIndex:index];
    
//    NSLog(@"timestamp = %f", current.timestamp);
//    NSLog(@"in_range_duration = %f", current.in_range_duration);
//    NSLog(@"duration = %f", current.duration);
//    NSLog(@"goal = %@", (current.goal ? @"YES" : @"NO"));
    
    switch ( fieldEnum ) {
        case CPScatterPlotFieldY:
            if (current.goal)
                return [ NSNumber numberWithInt:3 ];
            break;
        case CPBarPlotFieldBarLength:
            if (plot.identifier == @"inRange")
                return [ NSNumber numberWithDouble:current.in_range_duration ];
                
            else if (plot.identifier == @"blow")
                return [ NSNumber numberWithDouble:current.duration ];
            
            break;
        default:
            return [ NSNumber numberWithDouble:current.timestamp - CFAbsoluteTimeGetCurrent() ];
            break;
    }
	
	// Return a default value, shouldn't be returned
	return nil;
	
}

-(CPPlotSymbol *)symbolForScatterPlot:(CPScatterPlot *)plot recordIndex:(NSUInteger)index {
    CPPlotSymbol *symbol = [[CPPlotSymbol alloc] init];
    symbol.symbolType = CPPlotSymbolTypeStar;
    symbol.size = CGSizeMake(10.0, 10.0);
    symbol.fill = [CPFill fillWithColor:[CPColor whiteColor]];
    return symbol;
}

-(void) historyChange:(id*) history_id {
    //    NSLog(@"History change %i",[[(BlowHistory*)history_id getHistoryArray] count]);
    //redraw the graph
    [graph reloadData];
}


//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [FlowerController showNav];
     NSLog(@"Graph Touched");
    //Do stuff here...
}

- (void)dealloc {
	[history release];
    [graph release];
    [super dealloc];
	
}

@end