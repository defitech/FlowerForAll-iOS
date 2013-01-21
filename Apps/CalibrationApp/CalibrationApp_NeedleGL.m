//
//  CalibrationApp_NeedleGL.m
//  FlowerForAll
//
//  Created by adherent on 17.01.13.
//
//

#import "CalibrationApp_NeedleGL.h"
#import "CalibrationApp.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>


#import "FlowerController.h"
#import "ParametersManager.h"

#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)


//some variables
float angles[4];
double frequencies[4];
double freq_target_previous;
double freq_tol_previous;

// A class extension to declare private methods
@interface CalibrationApp_NeedleGL ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation CalibrationApp_NeedleGL

@synthesize context;
@synthesize animationTimer, animationInterval;
//@synthesize animationInterval;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        // ? retina Display
        if ([self respondsToSelector:@selector(contentScaleFactor)])
        {
            self.contentScaleFactor = [[UIScreen mainScreen] scale];
            eaglLayer.contentsScale = [[UIScreen mainScreen] scale];
        }
        
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventBlowStop:)
                                                     name:FLAPIX_EVENT_BLOW_STOP object:nil];
        
        animationInterval = 1.0 / 60.0;
		[self setupView];
		[self startAnimation];
    }
    
    return self;
}


- (void)applicationWillResignActive:(NSNotification *)notification {
    [self stopAnimation];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self startAnimation];
}

const GLfloat needleCenterX = 0.0f, needleCenterY = -0.5f, needleCenterZ = 0.0f;

- (void)setupView {
	
    const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 35.0;
    
    GLfloat size;
    
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
	
	// The size of the UIView
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
    glViewport(0, 0, rect.size.width, rect.size.height);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    
    angles[0] = 57.2957795 * M_PI * ([BottomBarGL frequencyToAngle:([[FlowerController currentFlapix] frequenceTarget] - [[FlowerController currentFlapix] frequenceTolerance])]);
    angles[1] = 57.2957795 * M_PI * ([BottomBarGL frequencyToAngle:([[FlowerController currentFlapix] frequenceTarget] + [[FlowerController currentFlapix] frequenceTolerance])]);
    angles[2] = 0;//angles[0];
    angles[3] = 0;//angles[1];
    //CalibrationApp* lastfreqValue = [[CalibrationApp alloc] init];
    //angles[2] = lastfreqValue.lastFreqLabelValue. * 57.2957795 * M_PI;
    //angles[3] = 57.2957795 * M_PI * ([BottomBarGL frequencyToAngle:([blow medianFrequency] + [blow medianTolerance])]);
}

- (void)drawLine:(float)x1 y1:(float)y1  z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 {
	const GLfloat lineVertices[] = {
        x1, y1, z1,
        x2, y2, z2,
    };
    //	NSLog(@"line %f,%f,%f %f,%f,%f",lineVertices[0],lineVertices[1],lineVertices[2],lineVertices[3],lineVertices[4],lineVertices[5]);
	
	// line
    
	glVertexPointer(3, GL_FLOAT, 0, lineVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glLineWidth(10.0f);
    glDrawArrays(GL_LINES, 0, 2);
	
}



- (void)drawBox:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 z:(float)z {
	const GLfloat quadVertices[] = {
        x1, y1, z,
        x1, y2, z,
        x2, y2, z,
        x2, y1, z
    };
    glVertexPointer(3, GL_FLOAT, 0, quadVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	
}



- (void)drawView {
    FLAPIX* flapix = [FlowerController currentFlapix];
    if (flapix == nil) return;
    
    
	//""""""""""""""""""" Logic code """""""""""""""""""/
    
    
    static float angle_actual = 0.1f;         // effective rotation angle in degrees
    static float angle_toreach = 0.0f;         // current angle
    static float angle_previous = 0.0f;           // previous angle
    static float angle_freqMin = 0.0f;
    static float angle_freqMax = 0.0f;
    static float angle_freqMin_previous = 0.0f;
    static float angle_freqMax_previous = 0.0f;
    static float speed = 0.0f;          // rotation speed
    
    
    
    angle_freqMin = [CalibrationApp_NeedleGL frequencyToAngle:([flapix frequenceTarget] - [flapix frequenceTolerance])]*180;
    angle_freqMax = [CalibrationApp_NeedleGL frequencyToAngle:([flapix frequenceTarget] + [flapix frequenceTolerance])]*180;
    angle_toreach = [CalibrationApp_NeedleGL frequencyToAngle:flapix.frequency]*180;
    
    if (fabs(angle_toreach - angle_actual) < 2  && angle_freqMin == angle_freqMin_previous && angle_freqMax == angle_freqMax_previous) {
        //nothing to do
        // return;
    }
    angle_freqMin_previous = angle_freqMin;
    angle_freqMax_previous = angle_freqMax;
    
    
    //"""""""""""""""""" Drawing code """"""""""""""""""""""/
    
    
    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    //glRotatef(angle_freqMax, 0.0f, 0.0f, -1.0f);
    
    // --- Needle
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glTranslatef(needleCenterX,needleCenterY,needleCenterZ);
    
    // Def needle
	const GLfloat quadVertices[] = {
        0.0, 1.3, -5.0,                    // head
        0.3, 0.0, -5.0,                    // left
        0.0, -0.3, -5.0,                      // queue
        -0.3, 0.0, -5.0                     // right
    };
    
    
    if(!flapix.blowing) {
        
        glColor4f(0.2f, 0.2f, 0.5f+[flapix lastlevel]/2, 1.0f);
    } else {
        speed = fabs((angle_toreach - angle_previous) / 10);
        // NSLog(@"speed = %f \n", speed);
        
        if(angle_toreach > angle_previous) {
            angle_actual = angle_previous + speed;
        } else {
            angle_actual = angle_previous - speed;
        }
        
        
        if ((angle_freqMax > angle_actual) && (angle_freqMin < angle_actual)) { // Good
            glColor4f(0.1f,  0.9f, 0.1f, 1.0f);
        } else { // Bad
            glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
        }
        
        angle_previous = angle_actual;
       
    }
     glRotatef(angle_actual, 0.0f, 0.0f, -1.0f);
    
	
	glVertexPointer(3, GL_FLOAT, 0, quadVertices);
	
	glEnableClientState(GL_VERTEX_ARRAY);
    
    //if ([flapix running])
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glTranslatef(needleCenterX,needleCenterY,needleCenterZ);
    
    //start calculate angle from freq values
    frequencies[0] = [flapix frequenceTarget];
    frequencies[1] = [flapix frequenceTolerance];

    
    angles[0] = [BottomBarGL frequencyToAngle:(frequencies[0] - frequencies[1])]*180;
    angles[1] = [BottomBarGL frequencyToAngle:(frequencies[0] + frequencies[1])]*180;
    
    
    if (freq_tol_previous != frequencies[1]) {
    if ((freq_target_previous < frequencies[0] && freq_tol_previous > frequencies[1]) || (freq_target_previous > frequencies[0] && freq_tol_previous < frequencies[1])) {
        angles[2] = angles[0] + ((frequencies[0] - frequencies[1]) - (frequencies[2] - frequencies[3])) * 180/ ([flapix frequenceMax] - [flapix frequenceMin]);
        angles[3] = angles[0] + ((frequencies[0] - frequencies[1]) - (frequencies[2] + frequencies[3])) * 180/ ([flapix frequenceMax] - [flapix frequenceMin]);
    } else {
        angles[2] = angles[1] + ((frequencies[0] + frequencies[1]) - (frequencies[2] - frequencies[3])) * 180/ ([flapix frequenceMax] - [flapix frequenceMin]);
        angles[3] = angles[1] + ((frequencies[0] + frequencies[1]) - (frequencies[2] + frequencies[3])) * 180/ ([flapix frequenceMax] - [flapix frequenceMin]);
    }
    }
    
    //ends calculate angles from freq values
    //[self CalFreqsToAnglesWithtarget:flapix.frequenceTarget Andtolerance:flapix.frequenceTolerance WithMin:flapix.frequenceMin AndMax:flapix.frequenceMax];
    
    NSLog(@"mindiff:%f,maxdiff:%f, angles0:%f, angles1:%f, angles2:%f, angles3:%f",(frequencies[0] - frequencies[1]) - (frequencies[2] - frequencies[3]),(frequencies[0] + frequencies[1]) - (frequencies[2] + frequencies[3]), angles[0], angles[1], angles[2], angles[3]);
    glRotatef(angles[0], 0.0f, 0.0f, -1.0f);
    glColor4f(0.0f, 0.0f, 0.0f, 1.0f);
	[self drawLine:0.0 y1:0.0 z1:-4.999 x2:0.0  y2:1.3  z2:-4.999];
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(needleCenterX,needleCenterY,needleCenterZ);
    
    glRotatef(angles[1], 0.0f, 0.0f, -1.0f);
    glColor4f(0.0f, 0.0f, 0.0f, 1.0f);
	[self drawLine:0.0 y1:0.0 z1:-4.999 x2:0.0  y2:1.3  z2:-4.999];
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glTranslatef(needleCenterX,needleCenterY,needleCenterZ);
    
    
    glRotatef(angles[2], 0.0f, 0.0f, -1.0f);
    glColor4f(1.0f, 0.5f, 0.0f, 1.0f);
	[self drawLine:0.0 y1:0.0 z1:-4.999 x2:0.0  y2:1.3  z2:-4.989];
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(needleCenterX,needleCenterY,needleCenterZ);
    
    glRotatef(angles[3], 0.0f, 0.0f, -1.0f);
    glColor4f(1.0f, 0.5f, 0.0f, 1.0f);
	[self drawLine:0.0 y1:0.0 z1:-4.999 x2:0.0  y2:1.3  z2:-4.989];
    
    
	
	//""""""""""""""""" Fin du nouveau code """""""""""""""""""
	
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    freq_target_previous = flapix.frequenceTarget;
    freq_tol_previous = flapix.frequenceTolerance;
}

//function which executes stuffs after each blow
- (void)flapixEventBlowStop:(NSNotification *)notification {
    FLAPIBlow* blow = (FLAPIBlow*)[notification object];
    frequencies[2] = blow.medianFrequency;
    frequencies[3] = blow.medianTolerance;
    [self setNeedsDisplay];
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

- (NSTimeInterval)animationInterval {
    return animationInterval;
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

+(float)frequencyToAngle:(double)freq {
    float longest = ([[FlowerController currentFlapix] frequenceMax] - [[FlowerController currentFlapix] frequenceTarget]) >
    ([[FlowerController currentFlapix] frequenceTarget] - [[FlowerController currentFlapix] frequenceMin]) ?
    ([[FlowerController currentFlapix] frequenceMax] - [[FlowerController currentFlapix] frequenceTarget]) :
    ([[FlowerController currentFlapix] frequenceTarget] - [[FlowerController currentFlapix] frequenceMin]);
    
    return (freq - [[FlowerController currentFlapix] frequenceTarget]) / (2 * longest ) ;
    
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touched");
    [FlowerController showNav];
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
