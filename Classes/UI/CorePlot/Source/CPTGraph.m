#import "CPTGraph.h"
#import "CPTExceptions.h"
#import "CPTLegend.h"
#import "CPTPlot.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTMutableTextStyle.h"
#import "CPTPlotSpace.h"
#import "CPTFill.h"
#import "CPTAxisSet.h"
#import "CPTAxis.h"
#import "CPTTheme.h"
#import "CPTLayerAnnotation.h"
#import "CPTTextLayer.h"
#import "NSCoderExtensions.h"

/**	@defgroup graphAnimation Graphs
 *	@brief Graph properties that can be animated using Core Animation.
 *	@if MacOnly
 *	@since Custom layer property animation is supported on MacOS 10.6 and later.
 *	@endif
 *	@ingroup animation
 **/

NSString * const CPTGraphNeedsRedrawNotification = @"CPTGraphNeedsRedrawNotification";

/**	@cond */
@interface CPTGraph()

@property (nonatomic, readwrite, retain) NSMutableArray *plots;
@property (nonatomic, readwrite, retain) NSMutableArray *plotSpaces;
@property (nonatomic, readwrite, retain) CPTLayerAnnotation *titleAnnotation;
@property (nonatomic, readwrite, retain) CPTLayerAnnotation *legendAnnotation;

-(void)plotSpaceMappingDidChange:(NSNotification *)notif;
-(CGPoint)contentAnchorForLegend;

@end
/**	@endcond */

#pragma mark -

/**	@brief An abstract graph class.
 *	@todo More documentation needed 
 **/
@implementation CPTGraph

/**	@property axisSet
 *	@brief The axis set.
 **/
@dynamic axisSet;

/**	@property plotAreaFrame
 *	@brief The plot area frame.
 **/
@synthesize plotAreaFrame;

/**	@property plots
 *	@brief An array of all plots associated with the graph.
 **/
@synthesize plots;

/**	@property plotSpaces
 *	@brief An array of all plot spaces associated with the graph.
 **/
@synthesize plotSpaces;

/**	@property defaultPlotSpace
 *	@brief The default plot space.
 **/
@dynamic defaultPlotSpace;

/** @property topDownLayerOrder
 *	@brief An array of graph layers to be drawn in an order other than the default.
 *	@see CPTPlotArea#topDownLayerOrder
 **/
@dynamic topDownLayerOrder;

/**	@property title
 *	@brief The title string. 
 *  Default is nil.
 **/
@synthesize title;

/**	@property titleTextStyle
 *	@brief The text style of the title.
 **/
@synthesize titleTextStyle;

/**	@property titlePlotAreaFrameAnchor
 *	@brief The location of the title with respect to the plot area frame.
 *  Default is top center.
 **/
@synthesize titlePlotAreaFrameAnchor;

/**	@property titleDisplacement
 *	@brief A vector giving the displacement of the title from the edge location.
 *	@ingroup graphAnimation
 **/
@synthesize titleDisplacement;

/**	@property legend
 *	@brief The graph legend.
 *	Setting this property will automatically anchor the legend to the graph and position it
 *	using the legendAnchor and legendDisplacement properties. This is a convenience property
 *	only—the legend may be inserted in the layer tree and positioned like any other CPTLayer
 *	if more flexibility is needed.
 **/
@dynamic legend;

/**	@property legendAnchor
 *	@brief The location of the legend with respect to the graph frame.
 *  Default is bottom center.
 **/
@synthesize legendAnchor;

/**	@property legendDisplacement
 *	@brief A vector giving the displacement of the legend from the edge location.
 *	@ingroup graphAnimation
 **/
@synthesize legendDisplacement;

@synthesize titleAnnotation;
@synthesize legendAnnotation;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		plots = [[NSMutableArray alloc] init];
        
        // Margins
        self.paddingLeft = 20.0;
        self.paddingTop = 20.0;
        self.paddingRight = 20.0;
        self.paddingBottom = 20.0;
        
        // Plot area
        CPTPlotAreaFrame *newArea = [(CPTPlotAreaFrame *)[CPTPlotAreaFrame alloc] initWithFrame:self.bounds];
        self.plotAreaFrame = newArea;
        [newArea release];

        // Plot spaces
		plotSpaces = [[NSMutableArray alloc] init];
        CPTPlotSpace *newPlotSpace = [self newPlotSpace];
        [self addPlotSpace:newPlotSpace];
        [newPlotSpace release];

        // Axis set
		CPTAxisSet *newAxisSet = [self newAxisSet];
		self.axisSet = newAxisSet;
		[newAxisSet release];
        
        // Title
        title = nil;
        titlePlotAreaFrameAnchor = CPTRectAnchorTop;
        titleTextStyle = [[CPTTextStyle textStyle] retain];
        titleDisplacement = CGPointZero;
		titleAnnotation = nil;

		// Legend
		legend = nil;
		legendAnnotation = nil;
		legendAnchor = CPTRectAnchorBottom;
		legendDisplacement = CGPointZero;
		
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTGraph *theLayer = (CPTGraph *)layer;
		
		plotAreaFrame = [theLayer->plotAreaFrame retain];
		plots = [theLayer->plots retain];
		plotSpaces = [theLayer->plotSpaces retain];
		title = [theLayer->title retain];
		titlePlotAreaFrameAnchor = theLayer->titlePlotAreaFrameAnchor;
		titleTextStyle = [theLayer->titleTextStyle retain];
		titleDisplacement = theLayer->titleDisplacement;
		titleAnnotation = [theLayer->titleAnnotation retain];
		legend = [theLayer->legend retain];
		legendAnnotation = [theLayer->legendAnnotation retain];
		legendAnchor = theLayer->legendAnchor;
		legendDisplacement = theLayer->legendDisplacement;
	}
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[plotAreaFrame release];
	[plots release];
	[plotSpaces release];
    [title release];
    [titleTextStyle release];
    [titleAnnotation release];
	[legend release];
	[legendAnnotation release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	
	[coder encodeObject:self.plotAreaFrame forKey:@"CPTGraph.plotAreaFrame"];
	[coder encodeObject:self.plots forKey:@"CPTGraph.plots"];
	[coder encodeObject:self.plotSpaces forKey:@"CPTGraph.plotSpaces"];
	[coder encodeObject:self.title forKey:@"CPTGraph.title"];
	[coder encodeObject:self.titleTextStyle forKey:@"CPTGraph.titleTextStyle"];
	[coder encodeInteger:self.titlePlotAreaFrameAnchor forKey:@"CPTGraph.titlePlotAreaFrameAnchor"];
	[coder encodeCPTPoint:self.titleDisplacement forKey:@"CPTGraph.titleDisplacement"];
	[coder encodeObject:self.titleAnnotation forKey:@"CPTGraph.titleAnnotation"];
	[coder encodeObject:self.legend forKey:@"CPTGraph.legend"];
	[coder encodeObject:self.legendAnnotation forKey:@"CPTGraph.legendAnnotation"];
	[coder encodeInteger:self.legendAnchor forKey:@"CPTGraph.legendAnchor"];
	[coder encodeCPTPoint:self.legendDisplacement forKey:@"CPTGraph.legendDisplacement"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
		plotAreaFrame = [[coder decodeObjectForKey:@"CPTGraph.plotAreaFrame"] retain];
		plots = [[coder decodeObjectForKey:@"CPTGraph.plots"] mutableCopy];
		plotSpaces = [[coder decodeObjectForKey:@"CPTGraph.plotSpaces"] mutableCopy];
		title = [[coder decodeObjectForKey:@"CPTGraph.title"] copy];
		titleTextStyle = [[coder decodeObjectForKey:@"CPTGraph.titleTextStyle"] copy];
		titlePlotAreaFrameAnchor = [coder decodeIntegerForKey:@"CPTGraph.titlePlotAreaFrameAnchor"];
		titleDisplacement = [coder decodeCPTPointForKey:@"CPTGraph.titleDisplacement"];
		titleAnnotation = [[coder decodeObjectForKey:@"CPTGraph.titleAnnotation"] retain];
		legend = [[coder decodeObjectForKey:@"CPTGraph.legend"] retain];
		legendAnnotation = [[coder decodeObjectForKey:@"CPTGraph.legendAnnotation"] retain];
		legendAnchor = [coder decodeIntegerForKey:@"CPTGraph.legendAnchor"];
		legendDisplacement = [coder decodeCPTPointForKey:@"CPTGraph.legendDisplacement"];
	}
    return self;
}

#pragma mark -
#pragma mark Drawing

-(void)layoutAndRenderInContext:(CGContextRef)context
{
    [self reloadDataIfNeeded];
    [self.axisSet.axes makeObjectsPerformSelector:@selector(relabel)];
	[super layoutAndRenderInContext:context];
}

#pragma mark -
#pragma mark Animation

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
	static NSArray *keys = nil;
	
	if ( !keys ) {
		keys = [[NSArray alloc] initWithObjects:
				@"titleDisplacement",
				@"legendDisplacement", 
				nil];
	}
	
	if ( [keys containsObject:aKey] ) {
		return YES;
	}
	else {
		return [super needsDisplayForKey:aKey];
	}
}

#pragma mark -
#pragma mark Retrieving Plots

/**	@brief Makes all plots reload their data.
 **/
-(void)reloadData
{
    [self.plots makeObjectsPerformSelector:@selector(reloadData)];
}

/**	@brief Makes all plots reload their data if their data cache is out of date.
 **/
-(void)reloadDataIfNeeded
{
    [self.plots makeObjectsPerformSelector:@selector(reloadDataIfNeeded)];
}

/**	@brief All plots associated with the graph.
 *	@return An array of all plots associated with the graph. 
 **/
-(NSArray *)allPlots 
{    
	return [NSArray arrayWithArray:self.plots];
}

/**	@brief Gets the plot at the given index in the plot array.
 *	@param index An index within the bounds of the plot array.
 *	@return The plot at the given index.
 **/
-(CPTPlot *)plotAtIndex:(NSUInteger)index
{
    return [self.plots objectAtIndex:index];
}

/**	@brief Gets the plot with the given identifier from the plot array.
 *	@param identifier A plot identifier.
 *	@return The plot with the given identifier or nil if it was not found.
 **/
-(CPTPlot *)plotWithIdentifier:(id <NSCopying>)identifier 
{
	for (CPTPlot *plot in self.plots) {
        if ( [[plot identifier] isEqual:identifier] ) return plot;
	}
    return nil;
}

#pragma mark -
#pragma mark Organizing Plots

/**	@brief Add a plot to the default plot space.
 *	@param plot The plot.
 **/
-(void)addPlot:(CPTPlot *)plot
{
	[self addPlot:plot toPlotSpace:self.defaultPlotSpace];
}

/**	@brief Add a plot to the given plot space.
 *	@param plot The plot.
 *	@param space The plot space.
 **/
-(void)addPlot:(CPTPlot *)plot toPlotSpace:(CPTPlotSpace *)space
{
	if ( plot ) {
		[self.plots addObject:plot];
		plot.plotSpace = space;
        plot.graph = self;
		[self.plotAreaFrame.plotGroup addPlot:plot];
	}
}

/**	@brief Remove a plot from the graph.
 *	@param plot The plot to remove.
 **/
-(void)removePlot:(CPTPlot *)plot
{
    if ( [self.plots containsObject:plot] ) {
        plot.plotSpace = nil;
        plot.graph = nil;
		[self.plotAreaFrame.plotGroup removePlot:plot];
        [self.plots removeObject:plot];
    }
    else {
        [NSException raise:CPTException format:@"Tried to remove CPTPlot which did not exist."];
    }
}

/**	@brief Add a plot to the default plot space at the given index in the plot array.
 *	@param plot The plot.
 *	@param index An index within the bounds of the plot array.
 **/
-(void)insertPlot:(CPTPlot* )plot atIndex:(NSUInteger)index 
{
	[self insertPlot:plot atIndex:index intoPlotSpace:self.defaultPlotSpace];
}

/**	@brief Add a plot to the given plot space at the given index in the plot array.
 *	@param plot The plot.
 *	@param index An index within the bounds of the plot array.
 *	@param space The plot space.
 **/
-(void)insertPlot:(CPTPlot* )plot atIndex:(NSUInteger)index intoPlotSpace:(CPTPlotSpace *)space
{
	if (plot) {
		[self.plots insertObject:plot atIndex:index];
		plot.plotSpace = space;
        plot.graph = self;
		[self.plotAreaFrame.plotGroup addPlot:plot];
	}
}

/**	@brief Remove a plot from the graph.
 *	@param identifier The identifier of the plot to remove.
 **/
-(void)removePlotWithIdentifier:(id <NSCopying>)identifier 
{
	CPTPlot* plotToRemove = [self plotWithIdentifier:identifier];
	if (plotToRemove) {
		plotToRemove.plotSpace = nil;
        plotToRemove.graph = nil;
		[self.plotAreaFrame.plotGroup removePlot:plotToRemove];
		[self.plots removeObjectIdenticalTo:plotToRemove];
	}
}

#pragma mark -
#pragma mark Retrieving Plot Spaces

-(CPTPlotSpace *)defaultPlotSpace {
    return ( self.plotSpaces.count > 0 ? [self.plotSpaces objectAtIndex:0] : nil );
}

/**	@brief All plot spaces associated with the graph.
 *	@return An array of all plot spaces associated with the graph. 
 **/
-(NSArray *)allPlotSpaces
{
	return [NSArray arrayWithArray:self.plotSpaces];
}

/**	@brief Gets the plot space at the given index in the plot space array.
 *	@param index An index within the bounds of the plot space array.
 *	@return The plot space at the given index.
 **/
-(CPTPlotSpace *)plotSpaceAtIndex:(NSUInteger)index
{
	return ( self.plotSpaces.count > index ? [self.plotSpaces objectAtIndex:index] : nil );
}

/**	@brief Gets the plot space with the given identifier from the plot space array.
 *	@param identifier A plot space identifier.
 *	@return The plot space with the given identifier or nil if it was not found.
 **/
-(CPTPlotSpace *)plotSpaceWithIdentifier:(id <NSCopying>)identifier
{
	for (CPTPlotSpace *plotSpace in self.plotSpaces) {
        if ( [[plotSpace identifier] isEqual:identifier] ) return plotSpace;
	}
    return nil;	
}

#pragma mark -
#pragma mark Set Plot Area

-(void)setPlotAreaFrame:(CPTPlotAreaFrame *)newArea 
{
    if ( plotAreaFrame != newArea ) {
    	plotAreaFrame.graph = nil;
    	[plotAreaFrame removeFromSuperlayer];
        [plotAreaFrame release];
        plotAreaFrame = [newArea retain];
        [self addSublayer:newArea];
        plotAreaFrame.graph = self;
		for ( CPTPlotSpace *space in self.plotSpaces ) {
            space.graph = self;
        }
    }
}

#pragma mark -
#pragma mark Organizing Plot Spaces

/**	@brief Add a plot space to the graph.
 *	@param space The plot space.
 **/
-(void)addPlotSpace:(CPTPlotSpace *)space
{
	[self.plotSpaces addObject:space];
    space.graph = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(plotSpaceMappingDidChange:) name:CPTPlotSpaceCoordinateMappingDidChangeNotification object:space];
}

/**	@brief Remove a plot space from the graph.
 *	@param plotSpace The plot space.
 **/
-(void)removePlotSpace:(CPTPlotSpace *)plotSpace
{
	if ( [self.plotSpaces containsObject:plotSpace] ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTPlotSpaceCoordinateMappingDidChangeNotification object:plotSpace];

        // Remove space
		plotSpace.graph = nil;
		[self.plotSpaces removeObject:plotSpace];
        
        // Update axes that referenced space
        for ( CPTAxis *axis in self.axisSet.axes ) {
            if ( axis.plotSpace == plotSpace ) axis.plotSpace = nil;
        }
    }
    else {
        [NSException raise:CPTException format:@"Tried to remove CPTPlotSpace which did not exist."];
    }
}

#pragma mark -
#pragma mark Coordinate Changes in Plot Spaces

-(void)plotSpaceMappingDidChange:(NSNotification *)notif 
{
	CPTPlotSpace *plotSpace = notif.object;
	BOOL backgroundBandsNeedRedraw = NO;
	
	for ( CPTAxis *axis in self.axisSet.axes ) {
		if ( axis.plotSpace == plotSpace ) {
			[axis setNeedsRelabel];
			backgroundBandsNeedRedraw |= (axis.backgroundLimitBands.count > 0);
		}
	}
	for ( CPTPlot *plot in self.plots ) {
		if ( plot.plotSpace == plotSpace ) {
			[plot setNeedsDisplay];
		}
	}
	if ( backgroundBandsNeedRedraw ) {
		[self.plotAreaFrame.plotArea setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Axis Set

-(CPTAxisSet *)axisSet
{
	return self.plotAreaFrame.axisSet;
}

-(void)setAxisSet:(CPTAxisSet *)newSet
{
	self.plotAreaFrame.axisSet = newSet;
}

#pragma mark -
#pragma mark Themes

/**	@brief Apply a theme to style the graph.
 *	@param theme The theme object used to style the graph.
 **/
-(void)applyTheme:(CPTTheme *)theme 
{
    [theme applyThemeToGraph:self];
}

#pragma mark -
#pragma mark Legend

-(CPTLegend *)legend
{
	return (CPTLegend *)self.legendAnnotation.contentLayer;
}

-(void)setLegend:(CPTLegend *)newLegend
{
	if ( newLegend != legend ) {
        [legend release];
        legend = [newLegend retain];
		CPTLayerAnnotation *theLegendAnnotation = self.legendAnnotation;
		if ( legend ) {
			if ( theLegendAnnotation ) {
				theLegendAnnotation.contentLayer = legend;
			}
			else {
				CPTLayerAnnotation *newLegendAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:self];
				newLegendAnnotation.contentLayer = legend;
				newLegendAnnotation.displacement = self.legendDisplacement;
				newLegendAnnotation.rectAnchor = self.legendAnchor;
				newLegendAnnotation.contentAnchorPoint = [self contentAnchorForLegend];
				[self addAnnotation:newLegendAnnotation];
				self.legendAnnotation = newLegendAnnotation;
				[newLegendAnnotation release];
			}
		}
		else {
			if ( theLegendAnnotation ) {
				[self removeAnnotation:theLegendAnnotation];
				self.legendAnnotation = nil;
			}
		}
    }
}

-(void)setLegendAnchor:(CPTRectAnchor)newLegendAnchor
{
	if ( newLegendAnchor != legendAnchor ) {
		legendAnchor = newLegendAnchor;
		CPTLayerAnnotation *theLegendAnnotation = self.legendAnnotation;
		if ( theLegendAnnotation ) {
			theLegendAnnotation.rectAnchor = newLegendAnchor;
			theLegendAnnotation.contentAnchorPoint = [self contentAnchorForLegend];
		}
	}
}

-(void)setLegendDisplacement:(CGPoint)newLegendDisplacement
{
	if ( !CGPointEqualToPoint(newLegendDisplacement, legendDisplacement) ) {
		legendDisplacement = newLegendDisplacement;
		self.legendAnnotation.displacement = newLegendDisplacement;
	}
}

-(CGPoint)contentAnchorForLegend
{
	CGPoint contentAnchor = CGPointZero;
	
	switch ( self.legendAnchor ) {
		case CPTRectAnchorBottomLeft:
			contentAnchor = CGPointMake(0.0, 0.0);
			break;
		case CPTRectAnchorBottom:
			contentAnchor = CGPointMake(0.5, 0.0);
			break;
		case CPTRectAnchorBottomRight:
			contentAnchor = CGPointMake(1.0, 0.0);
			break;
		case CPTRectAnchorLeft:
			contentAnchor = CGPointMake(0.0, 0.5);
			break;
		case CPTRectAnchorRight:
			contentAnchor = CGPointMake(1.0, 0.5);
			break;
		case CPTRectAnchorTopLeft:
			contentAnchor = CGPointMake(0.0, 1.0);
			break;
		case CPTRectAnchorTop:
			contentAnchor = CGPointMake(0.5, 1.0);
			break;
		case CPTRectAnchorTopRight:
			contentAnchor = CGPointMake(1.0, 1.0);
			break;
		case CPTRectAnchorCenter:
			contentAnchor = CGPointMake(0.5, 0.5);
			break;
		default:
			break;
	}
	
	return contentAnchor;
}

#pragma mark -
#pragma mark Accessors

-(void)setPaddingLeft:(CGFloat)newPadding 
{
    if ( newPadding != self.paddingLeft ) {
        [super setPaddingLeft:newPadding];
		[self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }
}

-(void)setPaddingRight:(CGFloat)newPadding 
{
    if ( newPadding != self.paddingRight ) {
        [super setPaddingRight:newPadding];
		[self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }
}

-(void)setPaddingTop:(CGFloat)newPadding 
{
    if ( newPadding != self.paddingTop ) {
        [super setPaddingTop:newPadding];
		[self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }
}

-(void)setPaddingBottom:(CGFloat)newPadding 
{
    if ( newPadding != self.paddingBottom ) {
        [super setPaddingBottom:newPadding];
		[self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }
}

-(NSArray *)topDownLayerOrder
{
	return self.plotAreaFrame.plotArea.topDownLayerOrder;
}

-(void)setTopDownLayerOrder:(NSArray *)newArray
{
	self.plotAreaFrame.plotArea.topDownLayerOrder = newArray;
}

-(void)setTitle:(NSString *)newTitle
{
	if ( newTitle != title ) {
        [title release];
        title = [newTitle copy];
		CPTLayerAnnotation *theTitleAnnotation = self.titleAnnotation;
		if ( title ) {
			if ( theTitleAnnotation ) {
				((CPTTextLayer *)theTitleAnnotation.contentLayer).text = title;
			}
			else {
				CPTLayerAnnotation *newTitleAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:self.plotAreaFrame];
				CPTTextLayer *newTextLayer = [[CPTTextLayer alloc] initWithText:title style:self.titleTextStyle];
				newTitleAnnotation.contentLayer = newTextLayer;
				newTitleAnnotation.displacement = self.titleDisplacement;
				newTitleAnnotation.rectAnchor = self.titlePlotAreaFrameAnchor;
				[self addAnnotation:newTitleAnnotation];
				self.titleAnnotation = newTitleAnnotation;
				[newTextLayer release];
				[newTitleAnnotation release];
			}
		}
		else {
			if ( theTitleAnnotation ) {
				[self removeAnnotation:theTitleAnnotation];
				self.titleAnnotation = nil;
			}
		}
    }
}

-(void)setTitleTextStyle:(CPTMutableTextStyle *)newStyle
{
    if ( newStyle != titleTextStyle ) {
        [titleTextStyle release];
        titleTextStyle = [newStyle copy];
		((CPTTextLayer *)self.titleAnnotation.contentLayer).textStyle = titleTextStyle;
    }
}

-(void)setTitleDisplacement:(CGPoint)newDisplace
{
    if ( !CGPointEqualToPoint(newDisplace, titleDisplacement) ) {
        titleDisplacement = newDisplace;
        titleAnnotation.displacement = newDisplace;
    }
}

-(void)setTitlePlotAreaFrameAnchor:(CPTRectAnchor)newAnchor
{
    if ( newAnchor != titlePlotAreaFrameAnchor ) {
        titlePlotAreaFrameAnchor = newAnchor;
        titleAnnotation.rectAnchor = titlePlotAreaFrameAnchor;
    }
}

#pragma mark -
#pragma mark Event Handling

-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    // Plots
    for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
        if ( [plot pointingDeviceDownEvent:event atPoint:interactionPoint] ) return YES;
    } 
    
    // Axes Set
    if ( [self.axisSet pointingDeviceDownEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot area
    if ( [self.plotAreaFrame pointingDeviceDownEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot spaces
    // Plot spaces do not block events, because several spaces may need to receive
    // the same event sequence (e.g., dragging coordinate translation)
    BOOL handledEvent = NO;
    for ( CPTPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceDownEvent:event atPoint:interactionPoint];
        handledEvent |= handled;
    } 
    
    return handledEvent;
}

-(BOOL)pointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    // Plots
    for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
        if ( [plot pointingDeviceUpEvent:event atPoint:interactionPoint] ) return YES;
    } 
    
    // Axes Set
    if ( [self.axisSet pointingDeviceUpEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot area
    if ( [self.plotAreaFrame pointingDeviceUpEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot spaces
    // Plot spaces do not block events, because several spaces may need to receive
    // the same event sequence (e.g., dragging coordinate translation)
    BOOL handledEvent = NO;
    for ( CPTPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceUpEvent:event atPoint:interactionPoint];
        handledEvent |= handled;
    } 
    
    return handledEvent;
}

-(BOOL)pointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    // Plots
    for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
        if ( [plot pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) return YES;
    } 
    
    // Axes Set
    if ( [self.axisSet pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot area
    if ( [self.plotAreaFrame pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot spaces
    // Plot spaces do not block events, because several spaces may need to receive
    // the same event sequence (e.g., dragging coordinate translation)
    BOOL handledEvent = NO;
    for ( CPTPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceDraggedEvent:event atPoint:interactionPoint];
        handledEvent |= handled;
    } 
    
    return handledEvent;
}

-(BOOL)pointingDeviceCancelledEvent:(id)event
{
    // Plots
    for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
        if ( [plot pointingDeviceCancelledEvent:event] ) return YES;
    } 
    
    // Axes Set
    if ( [self.axisSet pointingDeviceCancelledEvent:event] ) return YES;
    
    // Plot area
    if ( [self.plotAreaFrame pointingDeviceCancelledEvent:event] ) return YES;
    
    // Plot spaces
    BOOL handledEvent = NO;
    for ( CPTPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceCancelledEvent:event];
        handledEvent |= handled;
    } 
    
    return handledEvent;
}

@end

#pragma mark -

@implementation CPTGraph(AbstractFactoryMethods)

/**	@brief Creates a new plot space for the graph.
 *	@return A new plot space.
 **/
-(CPTPlotSpace *)newPlotSpace
{
	return nil;
}

/**	@brief Creates a new axis set for the graph.
 *	@return A new axis set.
 **/
-(CPTAxisSet *)newAxisSet
{
	return nil;
}

@end
