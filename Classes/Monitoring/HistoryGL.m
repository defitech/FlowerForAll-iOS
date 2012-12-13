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
- (void) drawRectangleDuration;

@end


@implementation HistoryGL

@synthesize context;
@synthesize animationTimer;

//array to contain historic blows
NSMutableArray *BlowsArray;
NSMutableArray *BlowsPosition;
NSMutableArray *BlowsDurationGood;
NSMutableArray *BlowsDurationTot;
NSMutableArray *StarsPosition;
NSMutableArray *StartStopPosition;


float lastExerciceStartTimeStamp2 = 0;
float lastExerciceStopTimeStamp2 = 0;



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
        
        BlowsArray = [[NSMutableArray alloc] initWithCapacity:0];
        BlowsPosition = [[NSMutableArray alloc] initWithCapacity:0];
        BlowsDurationGood = [[NSMutableArray alloc] initWithCapacity:0];
        BlowsDurationTot = [[NSMutableArray alloc] initWithCapacity:0];
        StarsPosition = [[NSMutableArray alloc] initWithCapacity:0];
        StartStopPosition = [[NSMutableArray alloc] initWithCapacity:0];
        
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
    // Add Touch
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
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
    //static float position_actual = 0.0f;
    static float speed = 0.0005f;
    static float HeightFactor = 0.0f;
    
    /*************** Drawing code ******************/
    
    
    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
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
    
    // determine the scaling factor for the rectangles height
    float maxduration = 0.0f;
    for (int i = 0; i < [BlowsDurationTot count]; i++) {
        if (maxduration < [[BlowsDurationTot objectAtIndex:i]floatValue] && [[BlowsPosition objectAtIndex:i]floatValue] < 1.4f) {
            maxduration = [[BlowsDurationTot objectAtIndex:i]floatValue];
        }
        HeightFactor = 1.5 / maxduration;
    }
    
    
    /*for (int i = outofrange; [[BlowsPosition objectAtIndex:i]floatValue] > -0.3f ; i++) {
        outofrange = i;
    }*/
    
    //draw the rectangles for each blow
    
    for (int i = 0; i < [BlowsArray count]; i++) {
        if ([[BlowsPosition objectAtIndex:i]floatValue] < 1.4f) {
            [BlowsPosition replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[BlowsPosition objectAtIndex:i]floatValue] + speed]];
            float height1 = HeightFactor * [[BlowsDurationGood objectAtIndex:i]floatValue];
            float height2 = HeightFactor * ([[BlowsDurationTot objectAtIndex:i]floatValue] - [[BlowsDurationGood objectAtIndex:i]floatValue]);
        
            [self drawRectangleDuration:[[BlowsPosition objectAtIndex:i]floatValue] RectHeight: height1 offset: 0.0f color1:0.1f color2:0.9f color3:0.1f color4:1.0f];
            [self drawRectangleDuration:[[BlowsPosition objectAtIndex:i]floatValue] RectHeight: height2 offset: height1 color1:1.0f color2:0.0f color3:0.0f color4:1.0f];
        }
    }
    
    for (int i = 0; i < [StarsPosition count]; i++) {
        if ([[StarsPosition objectAtIndex:i]floatValue] < 1.4f) {
            [StarsPosition replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[StarsPosition objectAtIndex:i]floatValue] + speed]];
            [self drawStar:[[StarsPosition objectAtIndex:i]floatValue]];
        }
    }
    
    for (int i = 0; i < [StartStopPosition count]; i++) {
        if ([[StartStopPosition objectAtIndex:i]floatValue] < 1.4f) {
            [StartStopPosition replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[StartStopPosition objectAtIndex:i]floatValue] + speed]];
            [self drawStartStopTriangle:[[StartStopPosition objectAtIndex:i]floatValue]];
        }
    }
    
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    

}

- (void)drawRectangleDuration: (float) PositionActual RectHeight:(float) RectangleHeight offset:(float) Offset color1:(float)col1 color2:(float)col2 color3:(float)col3 color4:(float)col4 {
    const GLfloat rectangle[] = {
        0.37f, -1.0f + Offset,
        0.32f, -1.0f + Offset,
        0.37f, -1.0f + RectangleHeight + Offset,
        0.32f, -1.0f + Offset,
        0.37f, -1.0f + RectangleHeight + Offset,
        0.32f, -1.0f + RectangleHeight + Offset
    };
    glColor4f(col1, col2, col3, col4);
    glLoadIdentity();
    glTranslatef(-PositionActual, 0.0f, 0.0f);
    glVertexPointer(2, GL_FLOAT, 0, rectangle);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 6);
}
- (void)drawStar: (float) PositionActual {
    const GLfloat star_cover[] = {
        0.33f, 0.55f,
        0.36f, 0.55f,
        0.345, 0.64
    };
    glColor4f(0.0f, 0.0f, 0.0f, 1.0f);
    glLoadIdentity();
    glTranslatef(-PositionActual, 0.0f, 0.0f);
    glVertexPointer(2, GL_FLOAT, 0, star_cover);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 3);

    
    const GLfloat star[] = {
        0.32f, 0.77f,
        0.37f, 0.77f,
        0.345f, 0.64f,
        0.345f, 0.92f,
        0.33f, 0.55f,
        0.36f, 0.55f
    };
    glColor4f(1.0f, 1.0f, 0.0f, 1.0f);
    glLoadIdentity();
    glTranslatef(-PositionActual, 0.0f, 0.0f);
    glVertexPointer(2, GL_FLOAT, 0, star);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 6);
    
    }

- (void)drawStartStopTriangle: (float) PositionActual {
    const GLfloat triangle[] = {
        0.37f, -1.0f,
        0.32f, -1.0f,
        0.345f, -0.3f
    };
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glLoadIdentity();
    glTranslatef(-PositionActual, 0.0f, 0.0f);
    glVertexPointer(2, GL_FLOAT, 0, triangle);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 3);
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
    [BlowsArray addObject:[NSNumber numberWithDouble:blow.in_range_duration]];
    [BlowsPosition addObject:[NSNumber numberWithFloat:0.0f]];
    [BlowsDurationGood addObject:[NSNumber numberWithFloat:blow.in_range_duration]];
    [BlowsDurationTot addObject:[NSNumber numberWithFloat:blow.duration]];
    if (blow.goal) {
        [StarsPosition addObject:[NSNumber numberWithFloat:0.0f]];
    }
    
    //NSLog(@"blow duration:%f, in range duration:%f", blow.duration, blow.in_range_duration);
    //Resize Y axis if needed
    if (blow.duration > higherBar) {
        higherBar = blow.duration;
        // if too high blow, resize y axis
    }
}

- (void)flapixEventExerciceStart:(NSNotification *)notification {
    lastExerciceStartTimeStamp2 = [(FLAPIExercice*)[notification object] start_ts];
    [StartStopPosition addObject:[NSNumber numberWithFloat:0.0f]];
}



- (void)flapixEventExerciceStop:(NSNotification *)notification {
    lastExerciceStopTimeStamp2 = [(FLAPIExercice*)[notification object] stop_ts];
    [StartStopPosition addObject:[NSNumber numberWithFloat:0.0f]];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [FlowerController showNav];
    NSLog(@"Graph Touched");
    //Do stuff here...
    
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

-(void) reloadFromDB {
    [history reloadFromDB];
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
