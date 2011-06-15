//
//  StatisticDetailViewController.m
//  FlutterApp2
//
//  Created by Dev on 28.12.10.
//  Copyright 2010 Defitech. All rights reserved.
//
//	Implementation of the StatisticDetailViewController class


#import "StatisticDetailViewController.h"

#import "DataAccessDB.h"

#import "CPPlotRange.h"
#import "CPPlotSpace.h"

#import "Expiration.h"


@implementation StatisticDetailViewController


@synthesize inTargetExpirationTimes, outOfTargetExpirationTimes, barChart, currentExerciseID;




//Initialize the field self.currentExerciseID with the parameter currentExerciseID
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil extraParameter:(NSInteger)_currentExerciseID{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization.
		self.currentExerciseID = _currentExerciseID;
	}
	return self;
}
 




#pragma mark -
#pragma mark Initialization and teardown

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	
	//Fetch expirations for the exercise self.currentExerciseID. 
	//See class DataAccessDB: only columns inTargetDuration and outOfTargetDuration are fetched
	NSArray *expirations = [DataAccessDB listOfExerciseExpirations:self.currentExerciseID];
	
	
	//Fill arrays with exercise data just obtained from the DB
	self.inTargetExpirationTimes = [[NSMutableArray alloc] init];
	self.outOfTargetExpirationTimes = [[NSMutableArray alloc] init];
	
	
	//Get the maximum of the duration values, in order to initialize the size of the Y axis
	
	float max = 0.0;
	
	for (NSInteger i=0; i < [expirations count]; i++ ) {
		Expiration *ex = [expirations objectAtIndex:i];
		
		float inTargetDurationInSec = ex.inTargetDuration/1000.0f;
		float outOfTargetDurationInSec = ex.outOfTargetDuration/1000.0f;
		
		if (max < inTargetDurationInSec + outOfTargetDurationInSec) {
			max = inTargetDurationInSec + outOfTargetDurationInSec;
		}
		
		[self.inTargetExpirationTimes addObject:[NSString stringWithFormat:@"%f", inTargetDurationInSec]];
		[self.outOfTargetExpirationTimes addObject:[NSString stringWithFormat:@"%f", outOfTargetDurationInSec]];
	}
	
	
    // Create barChart from theme
    barChart = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	//At the moment do not use the gradient theme
	//CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
    [barChart applyTheme:theme];
	
	CPGraphHostingView *hostingView = (CPGraphHostingView *)self.view;
    hostingView.hostedGraph = barChart;
    barChart.plotAreaFrame.masksToBorder = NO;
	
    barChart.paddingLeft = 70.0;
	barChart.paddingTop = 20.0;
	barChart.paddingRight = 20.0;
	barChart.paddingBottom = 80.0;
	
	
	
	// Add plot space for horizontal bar charts
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(max + 1.0f)];
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(16.0f)];

    plotSpace.allowsUserInteraction = YES;
	
	plotSpace.globalYRange = plotSpace.yRange;
	
	[plotSpace setDelegate:self];
	
	
	// Grid style
	CPLineStyle *majorGridLineStyle = [CPLineStyle lineStyle];
	
    majorGridLineStyle.lineWidth = 0.75;
	//minorGridLineStyle.lineColor = [CPColor redColor];
    majorGridLineStyle.lineColor = [CPColor lightGrayColor];
    
    CPLineStyle *minorGridLineStyle = [CPLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [CPColor blueColor];
	
	
	//Number formatter for the numbers displayed on the graph
	NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setPositiveFormat:@"#"];
	
	
	CPXYAxisSet *axisSet = (CPXYAxisSet *)barChart.axisSet;
	
    CPXYAxis *x = axisSet.xAxis;
    x.axisLineStyle = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.majorIntervalLength = CPDecimalFromString(@"5");
    x.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
	x.title = NSLocalizedString(@"GraphExpirations", @"The Expirations label on the X axis of exercise detail graph");
    x.titleLocation = CPDecimalFromFloat(7.5f);
	x.titleOffset = 55.0f;
	x.majorGridLineStyle = majorGridLineStyle;
	//x.minorGridLineStyle = minorGridLineStyle;
	
	x.labelFormatter = formatter;
	
	
	
	CPXYAxis *y = axisSet.yAxis;
    y.axisLineStyle = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.majorIntervalLength = CPDecimalFromString(@"1");
    y.orthogonalCoordinateDecimal = CPDecimalFromString(@"0");
	y.title = NSLocalizedString(@"GraphTime", @"The Time label on the Y axis of exercise detail graph");
	y.titleOffset = 45.0f;
    y.titleLocation = CPDecimalFromFloat(7.5f);
	y.majorGridLineStyle = majorGridLineStyle;
	//y.minorGridLineStyle = minorGridLineStyle;
	
	y.labelFormatter = formatter;
	
	
	
    // First bar plot
    //CPBarPlot *barPlot = [CPBarPlot tubularBarPlotWithColor:[CPColor darkGrayColor] horizontalBars:NO];
	CPBarPlot *barPlot = [CPBarPlot tubularBarPlotWithColor:[CPColor redColor] horizontalBars:NO];
    barPlot.baseValue = CPDecimalFromString(@"0");
    barPlot.dataSource = self;
    //barPlot.barOffset = -0.25f;
	barPlot.barOffset = 0.0f;
    barPlot.identifier = @"Bar Plot 1";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
    
    // Second bar plot
    //barPlot = [CPBarPlot tubularBarPlotWithColor:[CPColor blueColor] horizontalBars:NO];
	barPlot = [CPBarPlot tubularBarPlotWithColor:[CPColor greenColor] horizontalBars:NO];
    barPlot.dataSource = self;
    barPlot.baseValue = CPDecimalFromString(@"0");
    barPlot.barOffset = 0.0f;
    barPlot.cornerRadius = 2.0f;
    barPlot.identifier = @"Bar Plot 2";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
	
#ifdef PERFORMANCE_TEST
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changePlotRange) userInfo:nil repeats:YES];
#endif
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}





#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    return [self.inTargetExpirationTimes count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (index == 0) {
		return 0;
	}
	else {
		
		NSDecimalNumber *num = nil;
		if ( [plot isKindOfClass:[CPBarPlot class]] ) {
			switch ( fieldEnum ) {
				case CPBarPlotFieldBarLocation:
					num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInteger:index];
					break;
				case CPBarPlotFieldBarLength:
					;
					NSDecimalNumber *inTargetDuration = [NSDecimalNumber decimalNumberWithDecimal:[[self.inTargetExpirationTimes objectAtIndex:index-1] decimalValue]];
					NSDecimalNumber *outOfTargetDuration = [NSDecimalNumber decimalNumberWithDecimal:[[self.outOfTargetExpirationTimes objectAtIndex:index-1] decimalValue]];
					num = [inTargetDuration decimalNumberByAdding:outOfTargetDuration];
					if ( [plot.identifier isEqual:@"Bar Plot 2"] ) 
						num = inTargetDuration;
					break;
			}
		}
		
		return num;
	}
	
}






-(CPFill *) barFillForBarPlot:(CPBarPlot *)barPlot recordIndex:(NSNumber *)index; {
	return nil;
}






- (CPPlotRange *)plotSpace:(CPPlotSpace *)space
	 willChangePlotRangeTo:(CPPlotRange *)newRange
			 forCoordinate:(CPCoordinate)coordinate {
	
    // Display only Quadrant I: never let the location go negative.
    //
    if (newRange.locationDouble < 0.0F) {
        newRange.location = CPDecimalFromFloat(0.0);
    }
	
	if (newRange.locationDouble > [self.inTargetExpirationTimes count]-16) {
        newRange.location = CPDecimalFromInt([self.inTargetExpirationTimes count]-16);
    }
	
    // Adjust axis to keep them in view at the left and bottom;
    // adjust scale-labels to match the scroll.
    //
    CPXYAxisSet *axisSet = (CPXYAxisSet *)self.barChart.axisSet;
	if (coordinate == CPCoordinateX) {
		axisSet.yAxis.orthogonalCoordinateDecimal = newRange.location;
		//axisSet.xAxis.titleLocation = CPDecimalFromFloat(newRange.locationDouble +
		//												 (newRange.lengthDouble / 2.0F));
		axisSet.xAxis.titleLocation = CPDecimalFromFloat(7.5f + newRange.locationDouble);
	} else {
		//axisSet.xAxis.orthogonalCoordinateDecimal = newRange.location;
		//axisSet.yAxis.titleLocation = CPDecimalFromFloat(newRange.locationDouble +
		//												 (newRange.lengthDouble / 2.0F));
	}
	
    return newRange;
	
}





//Allows view to autorotate in all directions
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}



@end
