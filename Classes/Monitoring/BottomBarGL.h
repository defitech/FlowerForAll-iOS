//
//  BottomBarGL.h
//  FlowerForAll
//
//  Created by adherent on 29.11.12.
//
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "FLAPIX.h"
#import "BlowHistory.h"

@interface BottomBarGL : UIView <BlowHistoryDelegate> {


@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;

    EAGLContext *context;

    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;

    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;

    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
    
    UILabel *labelPercent;
    UILabel *labelFrequency;
    UILabel *labelDuration;
    
    double higherBar;
    
    BlowHistory *history;
}


@property NSTimeInterval animationInterval;


//- (void)drawLine:(float)x1 y1:(float)y1  z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 ;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView;
- (void)setupView;
- (void)checkGLError:(BOOL)visibleCheck;

//-(void) historyChange:(id*) history;

-(void) reloadFromDB;

//function for the needle
+(float)frequencyToAngle:(double)freq;

@end
