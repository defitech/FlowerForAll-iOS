#import "CPTLegendEntry.h"

#import "CPTPlot.h"
#import "CPTTextStyle.h"
#import "NSCoderExtensions.h"

/**	@cond */
@interface CPTLegendEntry()

@property (nonatomic, readonly, retain) NSString *title;

@end
/**	@endcond */

#pragma mark -

/**	@brief A graph legend entry.
 **/
@implementation CPTLegendEntry

/**	@property plot
 *	@brief The plot associated with this legend entry.
 **/
@synthesize plot;

/**	@property index
 *	@brief index The zero-based index of the legend entry for the given plot.
 **/
@synthesize index;

/**	@property row
 *	@brief The row number where this entry appears in the legend (first row is 0).
 **/
@synthesize row;

/**	@property column
 *	@brief The column number where this entry appears in the legend (first column is 0).
 **/
@synthesize column;

/**	@property title
 *	@brief The legend entry title.
 **/
@dynamic title;

/**	@property textStyle
 *	@brief The text style used to draw the legend entry title.
 **/
@synthesize textStyle;

/**	@property titleSize
 *	@brief The size of the legend entry title when drawn using the textStyle.
 **/
@dynamic titleSize;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if ( (self = [super init]) ) {
		plot = nil;
		index = 0;
		row = 0;
		column = 0;
		textStyle = nil;
	}
	return self;
}

-(void)dealloc
{
	[textStyle release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeConditionalObject:self.plot forKey:@"CPTLegendEntry.plot"];
	[coder encodeInteger:self.index forKey:@"CPTLegendEntry.index"];
	[coder encodeInteger:self.row forKey:@"CPTLegendEntry.row"];
	[coder encodeInteger:self.column forKey:@"CPTLegendEntry.column"];
	[coder encodeObject:self.textStyle forKey:@"CPTLegendEntry.textStyle"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
		plot = [coder decodeObjectForKey:@"CPTLegendEntry.plot"];
		index = [coder decodeIntegerForKey:@"CPTLegendEntry.index"];
		row = [coder decodeIntegerForKey:@"CPTLegendEntry.row"];
		column = [coder decodeIntegerForKey:@"CPTLegendEntry.column"];
		textStyle = [[coder decodeObjectForKey:@"CPTLegendEntry.textStyle"] retain];
	}
    return self;
}

#pragma mark -
#pragma mark Drawing

/**	@brief Draws the legend title centered vertically in the given rectangle.
 *	@param rect The bounding rectangle where the title should be drawn.
 *	@param context The graphics context to draw into.
 **/
-(void)drawTitleInRect:(CGRect)rect inContext:(CGContextRef)context;
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, rect.origin.y);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextTranslateCTM(context, 0.0, -CGRectGetMaxY(rect));
#endif
	// center the title vertically
	CGRect textRect = rect;
	CGSize theTitleSize = self.titleSize;
	if ( theTitleSize.height < textRect.size.height ) {
		textRect = CGRectInset(textRect, 0.0, (textRect.size.height - theTitleSize.height) / (CGFloat)2.0);
	}
	[self.title drawInRect:textRect withTextStyle:self.textStyle inContext:context];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	CGContextRestoreGState(context);
#endif
}

#pragma mark -
#pragma mark Accessors

-(void)setTextStyle:(CPTTextStyle *)newTextStyle
{
	if ( newTextStyle != textStyle ) {
		[textStyle release];
		textStyle = [newTextStyle retain];
	}
}

-(NSString *)title
{
	return [self.plot titleForLegendEntryAtIndex:self.index];
}

-(CGSize)titleSize
{
	CGSize theTitleSize = CGSizeZero;
	
	NSString *theTitle = self.title;
	CPTTextStyle *theTextStyle = self.textStyle;
	
	if ( theTitle && theTextStyle ) {
		theTitleSize = [theTitle sizeWithTextStyle:theTextStyle];
	}
	
	return theTitleSize;
}

@end
