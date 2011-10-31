#import "CPTAxis.h"
#import "CPTGridLines.h"

/**	@brief An abstract class that draws grid lines for an axis.
 **/
@implementation CPTGridLines

/**	@property axis
 *	@brief The axis.
 **/
@synthesize axis;

/**	@property major
 *	@brief If YES, draw the major grid lines, else draw the minor grid lines.
 **/
@synthesize major;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		axis = nil;
		major = NO;
		
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTGridLines *theLayer = (CPTGridLines *)layer;
		
		axis = theLayer->axis;
		major = theLayer->major;
	}
	return self;
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	
	[coder encodeConditionalObject:self.axis forKey:@"CPTGridLines.axis"];
	[coder encodeBool:self.major forKey:@"CPTGridLines.major"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
		axis = [coder decodeObjectForKey:@"CPTGridLines.axis"];
		major = [coder decodeBoolForKey:@"CPTGridLines.major"];
	}
    return self;
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	if ( self.hidden ) return;
	
	[self.axis drawGridLinesInContext:theContext isMajor:self.major];
}

#pragma mark -
#pragma mark Accessors

-(void)setAxis:(CPTAxis *)newAxis 
{
    if ( newAxis != axis ) {
        axis = newAxis;
		[self setNeedsDisplay];		
	}
}

@end
