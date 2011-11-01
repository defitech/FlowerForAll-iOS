#import "_CPTStocksTheme.h"

#import "CPTXYGraph.h"
#import "CPTColor.h"
#import "CPTGradient.h"
#import "CPTFill.h"
#import "CPTPlotAreaFrame.h"
#import "CPTXYPlotSpace.h"
#import "CPTUtilities.h"
#import "CPTXYAxisSet.h"
#import "CPTXYAxis.h"
#import "CPTMutableLineStyle.h"
#import "CPTMutableTextStyle.h"
#import "CPTBorderedLayer.h"
#import "CPTExceptions.h"

NSString * const kCPTStocksTheme = @"Stocks";	///< Stocks theme.

/** @brief Creates a CPTXYGraph instance formatted with a gradient background and white lines.
 **/
@implementation _CPTStocksTheme

+(void)load
{
	[self registerTheme:self];
}

+(NSString *)name 
{
	return kCPTStocksTheme;
}

#pragma mark -

-(void)applyThemeToBackground:(CPTXYGraph *)graph 
{	
    graph.fill = [CPTFill fillWithColor:[CPTColor blackColor]];
}
	
-(void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame
{	
    CPTGradient *stocksBackgroundGradient = [[[CPTGradient alloc] init] autorelease];
    stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPTColor colorWithComponentRed:0.21569 green:0.28627 blue:0.44706 alpha:1.0] atPosition:0.0];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPTColor colorWithComponentRed:0.09412 green:0.17255 blue:0.36078 alpha:1.0] atPosition:0.5];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPTColor colorWithComponentRed:0.05882 green:0.13333 blue:0.33333 alpha:1.0] atPosition:0.5];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPTColor colorWithComponentRed:0.05882 green:0.13333 blue:0.33333 alpha:1.0] atPosition:1.0];
    stocksBackgroundGradient.angle = 270.0;
	plotAreaFrame.fill = [CPTFill fillWithGradient:stocksBackgroundGradient];

	CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
	borderLineStyle.lineColor = [CPTColor colorWithGenericGray:0.2];
	borderLineStyle.lineWidth = 0.0;
	
	plotAreaFrame.borderLineStyle = borderLineStyle;
	plotAreaFrame.cornerRadius = 14.0;
}

-(void)applyThemeToAxisSet:(CPTXYAxisSet *)axisSet 
{	
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapRound;
    majorLineStyle.lineColor = [CPTColor whiteColor];
    majorLineStyle.lineWidth = 3.0;
    
    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineColor = [CPTColor whiteColor];
    minorLineStyle.lineWidth = 3.0;
	
    CPTXYAxis *x = axisSet.xAxis;
	CPTMutableTextStyle *whiteTextStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
	whiteTextStyle.color = [CPTColor whiteColor];
	whiteTextStyle.fontSize = 14.0;
	CPTMutableTextStyle *minorTickWhiteTextStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
	minorTickWhiteTextStyle.color = [CPTColor whiteColor];
	minorTickWhiteTextStyle.fontSize = 12.0;
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength = CPTDecimalFromDouble(0.5);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
	x.tickDirection = CPTSignNone;
    x.minorTicksPerInterval = 4;
    x.majorTickLineStyle = majorLineStyle;
    x.minorTickLineStyle = minorLineStyle;
    x.axisLineStyle = majorLineStyle;
    x.majorTickLength = 7.0;
    x.minorTickLength = 5.0;
	x.labelTextStyle = whiteTextStyle;
	x.minorTickLabelTextStyle = minorTickWhiteTextStyle;
	x.titleTextStyle = whiteTextStyle;
	
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    y.majorIntervalLength = CPTDecimalFromDouble(0.5);
    y.minorTicksPerInterval = 4;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
	y.tickDirection = CPTSignNone;
    y.majorTickLineStyle = majorLineStyle;
    y.minorTickLineStyle = minorLineStyle;
    y.axisLineStyle = majorLineStyle;
    y.majorTickLength = 7.0;
    y.minorTickLength = 5.0;
	y.labelTextStyle = whiteTextStyle;
	y.minorTickLabelTextStyle = minorTickWhiteTextStyle;
	y.titleTextStyle = whiteTextStyle;
}

#pragma mark -
#pragma mark NSCoding methods

-(Class)classForCoder
{
	return [CPTTheme class];
}

@end
