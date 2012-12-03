//
//  HistoryGL.m
//  FlowerForAll
//
//  Created by adherent on 29.11.12.
//
//

#import "HistoryGL.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "FlowerController.h"
#import "ParametersManager.h"
#define USE_DEPTH_BUFFER 0
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)

// A class extension to declare private methods
@interface HistoryGL ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation HistoryGL

@synthesize context;
@synthesize animationTimer;

//array to contain historic blows
//const NSArray *blows;

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
        
        
        // Listen to FLAPIX blowEvents
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(eventFlapixStarted:)
                                                     name:FLAPIX_EVENT_START
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventEndBlow:)
                                                     name:FLAPIX_EVENT_BLOW_STOP object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventExerciceStart:)
                                                     name:FLAPIX_EVENT_EXERCICE_START object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventExerciceStop:)
                                                     name:FLAPIX_EVENT_EXERCICE_STOP object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventFrequency:)
                                                     name:FLAPIX_EVENT_FREQUENCY object:nil];
        
        
        
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

- (void)eventFlapixStarted:(NSNotification *)notification {
    NSLog(@"HISTORY VIEW flapix started");
    [self startReloadTimer];
}


- (void) startReloadTimer {
    if ([FlowerController currentFlapix] == nil || ! [[FlowerController currentFlapix] running]) return;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self selector:@selector(timerFireMethod:)
                                                    userInfo:nil  repeats:YES];
//    repeatingTimer = timer;
    
}

- (void) stopReloadTimer {
//    [repeatingTimer invalidate];
//    repeatingTimer = nil;
    
}

- (void) timerFireMethod:(NSTimer*)theTimer {
    if (! [[FlowerController currentFlapix] running]) [self stopReloadTimer];
//    @synchronized([history getHistoryArray]) {
//        [graph reloadData];
//    }
}

const GLfloat needleCenterX = 0.0f, needleCenterY = 0.0f, needleCenterZ = 0.0f;

- (void)setupView {
    const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 60.0;
    GLfloat size;
    
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = 10;
    
    // Nous donne la taille de l'écran de l'iPhone
    CGRect rect = self.bounds;
    //glOrthof(0.0f, self.frame.size.width*2/3, 0.0f, self.frame.size.height , 0.0f, 0.0f);
    //glOrthof(0.0f, self.frame.size.width, 0.0f, self.frame.size.height,0.0f, 0.0f);
    glViewport(0, 0, rect.size.width, rect.size.height);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    
    // Frame dimensions
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    // Alloc Label View
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        
        labelPercent = [ [ UILabel alloc ] initWithFrame:CGRectMake(width*2/3, 0.0, width*1/5, height/2) ];
        [labelPercent setBackgroundColor:[UIColor blackColor]];
        [labelPercent setTextColor:[UIColor whiteColor]];
        [labelPercent setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelPercent setText:@"%"];
        
        labelFrequency = [ [ UILabel alloc ] initWithFrame:CGRectMake(width*5/6, 0.0, width*1/5, height/2) ];
        [labelFrequency setBackgroundColor:[UIColor blackColor]];
        [labelFrequency setTextColor:[UIColor whiteColor]];
        [labelFrequency setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelFrequency setText:@"Hz"];
        
        labelDuration = [ [ UILabel alloc ] initWithFrame:CGRectMake(width*2/3, height/2, width*1/4, height/2) ];
        [labelDuration setBackgroundColor:[UIColor blackColor]];
        [labelDuration setTextColor:[UIColor whiteColor]];
        [labelDuration setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelDuration setText:@"sec"];
    } else {
        labelPercent = [ [ UILabel alloc ] initWithFrame:CGRectMake(width*2/3, 0.0, width*1/3, height/2) ];
        [labelPercent setBackgroundColor:[UIColor blackColor]];
        [labelPercent setTextColor:[UIColor whiteColor]];
        [labelPercent setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelPercent setText:@"%"];
        
        labelFrequency = [ [ UILabel alloc ] initWithFrame:CGRectMake(width*5/6, 0.0, width*1/4, height/2) ];
        [labelFrequency setBackgroundColor:[UIColor blackColor]];
        [labelFrequency setTextColor:[UIColor whiteColor]];
        [labelFrequency setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelFrequency setText:@"Hz"];
        
        labelDuration = [ [ UILabel alloc ] initWithFrame:CGRectMake(width*2/3, height/2, width*1/3, height/2) ];
        [labelDuration setBackgroundColor:[UIColor blackColor]];
        [labelDuration setTextColor:[UIColor whiteColor]];
        [labelDuration setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelDuration setText:@"sec"];
    }
    
    [ self addSubview:labelPercent ];
    [ self addSubview:labelFrequency ];
    [ self addSubview:labelDuration ];
}

- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}

- (void)drawView {
    FLAPIX* flapix = [FlowerController currentFlapix];
    if (flapix == nil) return;

    /*************** Logic code ******************/
    static float position_actual = 0.0f;
    static float speed = 0.0003f;
    
    /*************** Drawing code ******************/
    
    
    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLfloat xorigin = 0.0 - self.frame.size.width / 2;
    
    //draw axes
	const GLfloat axes[] = {
        //y axis
        0.33, -1.0,
        0.32, -1.0,
        0.33, 1.0,
        0.32, -1.0,
        0.33, 1.0,
        0.32, 1.0,
        //x axis
        0.33, -1.0,
        0.33, -0.94,
        -1.0, -1.0,
        -1.0, -1.0,
        -1.0, -0.94,
        0.33, -0.94
    };
    
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glLoadIdentity();
	glVertexPointer(2, GL_FLOAT, 0, axes);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 12);
    
    
    //draw rectangles
    position_actual = position_actual + speed;
    const GLfloat rectangles[] = {
        0.33, -1.0,
        0.25, -1.0,
        0.33, 0.5,
        0.25, -1.0,
        0.33, 0.5,
        0.25, 0.5,
    };
    glColor4f(1.0f, 0.8f, 0.4f, 1.0f);
    glLoadIdentity();
    glTranslatef(-position_actual, 0.0, 0.0);
    glVertexPointer(2, GL_FLOAT, 0, rectangles);
	glDrawArrays(GL_TRIANGLES, 0, 12);
    
    
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    

}

- (void)flapixEventFrequency:(NSNotification *)notification {
    if ([[FlowerController currentFlapix] exerciceInCourse]) {
        int p = (int)([[[FlowerController currentFlapix] currentExercice] percent_done]*100);
        [labelPercent setText:[NSString stringWithFormat:@"%i%%",p]];
    } else {
        [labelPercent setText:@"---"];
    }
}


- (void)flapixEventEndBlow:(NSNotification *)notification {
	FLAPIBlow* blow = (FLAPIBlow*)[notification object];
    if ([[FlowerController currentFlapix] exerciceInCourse]) {
        int p = (int)([[[FlowerController currentFlapix] currentExercice] percent_done]*100);
        [labelPercent setText:[NSString stringWithFormat:@"%i%%",p]];
    } else {
        [labelPercent setText:@"---"];
    }
    [labelFrequency setText:[NSString stringWithFormat:@"%iHz",(int)blow.medianFrequency]];
    [labelDuration setText:[NSString stringWithFormat:@"%.2lf sec",blow.in_range_duration]];
    //NSLog(@"blow duration:%f, in range duration:%f", blow.duration, blow.in_range_duration);
    //Resize Y axis if needed
    if (blow.duration > higherBar) {
        higherBar = blow.duration;
        // if too high blow, resize y axis
    }
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
    
    if (true) {
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
