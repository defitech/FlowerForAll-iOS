//
//  EAGLView.m
//  OpenGL_ES_tuto1
//
//  Created by Marian PAUL on 19/04/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"

#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;
@synthesize flapix;


// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        animationInterval = 1.0 / 60.0;
		[self setupView];
		[self startAnimation];
    }
    
    if(!flapix) {
        flapix = [FLAPIX new];
        [flapix SetTargetFrequency:20 frequency_tolerance:10];
        [flapix Start];
    }
    
    return self;
}

- (void)setupView {
	
    const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
    GLfloat size;
	
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	
	// Nous donne la taille de l'écran de l'iPhone
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
    glViewport(0, 0, rect.size.width, rect.size.height);
	NSLog(@"View port %f,%f",rect.size.width,rect.size.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
}

- (void)drawLine:(float)x1 y1:(float)y1  z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 {
	const GLfloat lineVertices[] = {
        x1, y1, z1,                  
        x2, y2, z2,                  
    };
//	NSLog(@"line %f,%f,%f %f,%f,%f",lineVertices[0],lineVertices[1],lineVertices[2],lineVertices[3],lineVertices[4],lineVertices[5]);	
	
	// line
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	glVertexPointer(3, GL_FLOAT, 0, lineVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_LINES, 0, 2);
	
}


- (void)drawView {
	
//	// Def de notre triangle
//	const GLfloat triangleVertices[] = {
//        1.0, 1.0, -5.0,                    // base droite
//        -3.0, 0.0, -5.0,                   // pointe
//        1.0, -1.0, -5.0                    // base gauche
//    };
    
	// Def needle
	const GLfloat quadVertices[] = {
        0.0, 0.5, -5.0,                     // right
        -2.0, 0.0, -5.0,                    // head
        0.0, -0.5, -5.0,                    // left
        0.5, 0.0, -5.0                      // queue
    };
	
    [EAGLContext setCurrentContext:context];    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
//	NSLog(@"View port %d,%d",backingWidth,backingHeight);
    
	/*************** Debut du nouveau code ******************/
    
    /*
     * TODO:
     * 1. Change color in relation with the distance to the target.
     *    Green for 15 Hz and increasingly red with farther.
     */
    static float target = - 90 / 15;    // the target is to keep the needle at 90 degrees for a frequency of 15
    static float transY = 0.0f;         // effective rotation angle in degrees
    static int freq = 0;                // current frequency
    static float degree = 0.0f;         // current angle
    static float prev = 0.0f;           // previous angle
    static float speed = 0.0f;          // rotation speed
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if(!flapix.blowing) {
        glColor4f(0.0f, 0.0f, 1.0f, 1.0f);
    } else {
        glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
        
        freq = flapix.frequency;
        NSLog(@"freq = %i \n", freq);
        degree = (freq * target); // to reach
        speed = fabs((degree - prev) / 10);
        NSLog(@"speed = %f \n", speed);
    
        if(degree > prev) {
            transY = speed;
        } else {
            transY = - speed;
        }
    
        prev = prev + transY;

        glRotatef(transY, 0.0f, 0.0f, 1.0f);
    }
	
//	glVertexPointer(3, GL_FLOAT, 0, triangleVertices);
	glVertexPointer(3, GL_FLOAT, 0, quadVertices);
	
	glEnableClientState(GL_VERTEX_ARRAY);
    //	glDrawArrays(GL_TRIANGLES, 0, 3);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	 
	[self drawLine:0.0 y1:-4.0 z1:0.0 x2:0.0  y2:4.0  z2:-1.0];
	[self drawLine:-4.0 y1:0.0 z1:0.0 x2:4.0  y2:0.0  z2:-1.0];

	/*************** Fin du nouveau code ********************/ 
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)checkGLError:(BOOL)visibleCheck {
    GLenum error = glGetError();
    
    switch (error) {
        case GL_INVALID_ENUM:
            NSLog(@"GL Error: Enum argument is out of range");
            break;
        case GL_INVALID_VALUE:
            NSLog(@"GL Error: Numeric value is out of range");
            break;
        case GL_INVALID_OPERATION:
            NSLog(@"GL Error: Operation illegal in current state");
            break;
        case GL_STACK_OVERFLOW:
            NSLog(@"GL Error: Command would cause a stack overflow");
            break;
        case GL_STACK_UNDERFLOW:
            NSLog(@"GL Error: Command would cause a stack underflow");
            break;
        case GL_OUT_OF_MEMORY:
            NSLog(@"GL Error: Not enough memory to execute command");
            break;
        case GL_NO_ERROR:
            if (visibleCheck) {
                NSLog(@"No GL Error");
            }
            break;
        default:
            NSLog(@"Unknown GL Error");
            break;
    }
}

- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
}

@end
