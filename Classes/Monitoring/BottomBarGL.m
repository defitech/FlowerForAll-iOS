//
//  BottomBarGL.m
//  FlowerForAll
//
//  Created by adherent on 29.11.12.
//
//

#import "BottomBarGL.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "FlowerController.h"
#import "ParametersManager.h"
#define USE_DEPTH_BUFFER 1
#define DEGREES_TO_RADIANS(__ANGLE) ((__ANGLE) / 180.0 * M_PI)

// A class extension to declare private methods
@interface BottomBarGL ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;
//- (void) drawRectangleDuration;

@end


@implementation BottomBarGL

@synthesize context, animationTimer, animationInterval, labelPercent, labelFrequency, labelDuration, higherBar;

//array to contain historic blows
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

    
}



- (void)setupView {
    
    // Frame dimensions
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float widthHist = width * 0.893;
    float widthNeedle = width * 0.107;
    
    //const GLfloat needleCenterX = -1.0f + widthNeedle/2, needleCenterY = -1.0f, needleCenterZ = 0.0f;
    
    GLfloat size;
    
    const GLfloat zNear = 0.1, zFar = 1000.0, fieldOfView = 35.0;
    
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0);
    
    // Nous donne la taille de l'écran de l'iPhone
    CGRect rect = self.bounds;
    glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
    glViewport(0, 0, rect.size.width, rect.size.height);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
    
    // Alloc Label View
    // Add Touch
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
     [self addGestureRecognizer:singleFingerTap];
    [singleFingerTap release];
    
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        
        self.labelPercent = [[ [ UILabel alloc ] initWithFrame:CGRectMake(widthNeedle + widthHist*2/3, 0.0,  widthHist*1/5, height/2) ] autorelease];
        [labelPercent setBackgroundColor:[UIColor blackColor]];
        [labelPercent setTextColor:[UIColor whiteColor]];
        [labelPercent setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelPercent setText:@"%"];
        
        self.labelFrequency = [[ [ UILabel alloc ] initWithFrame:CGRectMake(widthNeedle + widthHist*5/6, 0.0, widthHist*1/5, height/2) ] autorelease];
        [labelFrequency setBackgroundColor:[UIColor blackColor]];
        [labelFrequency setTextColor:[UIColor whiteColor]];
        [labelFrequency setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelFrequency setText:@"Hz"];
        
        self.labelDuration = [[ [ UILabel alloc ] initWithFrame:CGRectMake(widthNeedle + widthHist*2/3, height/2,  widthHist*1/4, height/2) ] autorelease];
        [labelDuration setBackgroundColor:[UIColor blackColor]];
        [labelDuration setTextColor:[UIColor whiteColor]];
        [labelDuration setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelDuration setText:@"sec"];
    } else {
        self.labelPercent = [[ [ UILabel alloc ] initWithFrame:CGRectMake(width*0.702, 0.0, width*1/3, height/2) ]autorelease];
        [labelPercent setBackgroundColor:[UIColor blackColor]];
        [labelPercent setTextColor:[UIColor whiteColor]];
        [labelPercent setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelPercent setText:@"%"];
        
        self.labelFrequency = [[ [ UILabel alloc ] initWithFrame:CGRectMake(width*0.85, 0.0, width*1/4, height/2) ] autorelease];
        [labelFrequency setBackgroundColor:[UIColor blackColor]];
        [labelFrequency setTextColor:[UIColor whiteColor]];
        [labelFrequency setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelFrequency setText:@"Hz"];
        
        self.labelDuration = [[ [ UILabel alloc ] initWithFrame:CGRectMake(width*0.702, height/2, width*1/3, height/2) ] autorelease];
        [labelDuration setBackgroundColor:[UIColor blackColor]];
        [labelDuration setTextColor:[UIColor whiteColor]];
        [labelDuration setFont:[UIFont systemFontOfSize:height*2/5]];
        [labelDuration setText:@"sec"];
    }
    
    [ self addSubview:labelPercent ];
    [ self addSubview:labelFrequency ];
    [ self addSubview:labelDuration ];
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

- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}

- (void)drawView {
    FLAPIX* flapix = [FlowerController currentFlapix];
    if (flapix == nil) return;
    
    /////////////////////////Logic code /////////////////////
    // Frame dimensions    
    static const GLfloat needleCenterX = -1.311f, needleCenterY = -0.15f, needleCenterZ = 0.0f;
    
    //static float position_actual = 0.0f;
    static float speed;
    if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
        speed = 0.00075f;
    } else
        speed = 0.0005f;
    
    static float HeightFactor = 0.0f;
    
    
    //for the needle
    static float angle_actual = 0.1f;         // effective rotation angle in degrees
    static float angle_toreach = 0.0f;         // current angle
    static float angle_previous = 0.0f;           // previous angle
    static float angle_freqMin = 0.0f;
    static float angle_freqMax = 0.0f;
    static float angle_freqMin_previous = 0.0f;
    static float angle_freqMax_previous = 0.0f;
    static float rotspeed = 0.0f;          // rotation speed
    
    
    angle_freqMin = [BottomBarGL frequencyToAngle:([flapix frequenceTarget] - [flapix frequenceTolerance])]*180;
    angle_freqMax = [BottomBarGL frequencyToAngle:([flapix frequenceTarget] + [flapix frequenceTolerance])]*180;
    angle_toreach = [BottomBarGL frequencyToAngle:flapix.frequency]*180;
    
    if (fabs(angle_toreach - angle_actual) < 2  && angle_freqMin == angle_freqMin_previous && angle_freqMax == angle_freqMax_previous) {
        //nothing to do
        // return;
    }
    angle_freqMin_previous = angle_freqMin;
    angle_freqMax_previous = angle_freqMax;
    
    ///////////////////////// Drawing code /////////////////////////
    
    
    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // --- Blowing gauge
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    //glTranslatef(needleCenterX,needleCenterY,needleCenterZ);
    
    //draw axes
	static const GLfloat axes[] = {
        //y axis
        0.64, 0.15, -5.00,
        0.62, -0.15, -5.00,
        0.62, 0.15, -5.00,
        0.62, -0.15, -5.00,
        0.64, -0.15, -5.00,
        0.64, 0.15, -5.00,
        //x axis
        0.64, -0.14, -5.00,
        -1.0, -0.15, -5.00,
        -1.0, -0.14, -5.00,
        -1.0, -0.15, -5.00,
        0.64, -0.15, -5.00,
        0.64, -0.14, -5.00
    };
     
    
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glLoadIdentity();
	glVertexPointer(3, GL_FLOAT, 0, axes);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 12);
    
    
    
    //"""""""""""""""""""""draw needle"""""""""""""""""""""
    static float hPos = 0;
    static float hSpeed = 0.01;
    static BOOL goal = NO;
    float h = [flapix currentBlowPercent];
    if (! flapix.blowing) h = 0;
    if (h < 1 && (h > hPos)) goal = NO; // we keep goal value to descend the gauge
    if (h > 1) goal = YES;
    
    if (goal) {
        glColor4f(0.9f,  0.7f, 0.0f, 1.0f);
    } else {
        glColor4f(0.1f,  0.5f, 0.3f, 1.0f);
    }
    
    hSpeed = (h < hPos) ? 0.2 : 0.1;
    
    hPos = hPos + (h - hPos ) * hSpeed;
    
    //draws the box which shows the length of the current blow and is coloured in green if the blow is "in range"
	[self drawBox:-1.44 y1:-0.15 x2:-1.182 y2:-0.15 + 0.305 * hPos z:-5.001];
    
    // gauge line (just a yellow line parallel to the screen bottom)
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glColor4f(1.0f, 9.0f, 0.0f, 1.0f);
    [self drawLine:-1.361 y1:0.15 z1:-5.002 x2:-1.261  y2:0.15  z2:-5.002];
    
    // --- Needle
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // Def needle
	static const GLfloat quadVertices[] = {
        0.0, 0.25, -5.0,                    // head
        -0.07, 0.03, -5.0,                    // left
        0.0, -0.05, -5.0,                      // queue
        0.07, 0.03, -5.0                     // right
    };
    
    
    if(!flapix.blowing) {
        
        glColor4f(0.2f, 0.2f, 0.5f+[flapix lastlevel]/2, 1.0f);
    } else {
        rotspeed = fabs((angle_toreach - angle_previous) / 10);
        // NSLog(@"speed = %f \n", speed);
        
        if(angle_toreach > angle_previous) {
            angle_actual = angle_previous + rotspeed;
        } else {
            angle_actual = angle_previous - rotspeed;
        }
        
        
        if ((angle_freqMax > angle_actual) && (angle_freqMin < angle_actual)) { // Good
            glColor4f(0.1f,  0.9f, 0.1f, 1.0f);
        } else { // Bad
            glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
        }
        
        angle_previous = angle_actual;
    }
    glTranslatef(needleCenterX, needleCenterY+0.05, needleCenterZ);
    glRotatef(angle_actual, 0.0f, 0.0f, -1.0f);
	glVertexPointer(3, GL_FLOAT, 0, quadVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
    if ([flapix running])
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    //glTranslatef(0.5f,0.15f,0.0f);
    
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glTranslatef(needleCenterX,needleCenterY+0.05,needleCenterZ);
    
    
    glRotatef(angle_freqMax, 0.0f, 0.0f, -1.0f);
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	[self drawLine:0.0 y1:0.0 z1:-4.999 x2:0.0  y2:0.3  z2:-4.999];
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef(needleCenterX,needleCenterY+0.05,needleCenterZ);
    
    glRotatef(angle_freqMin, 0.0f, 0.0f, -1.0f);
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	[self drawLine:0.0 y1:0.0 z1:-4.999 x2:0.0  y2:0.3  z2:-4.999];
    //"""""""""""""""""end draw needle""""""""""""""""""""""""
    
    //draw rectangles
    
    // determine the scaling factor for the rectangles height
    float maxduration = 0.0f;
    for (int i = 0; i < [BlowsDurationTot count]; i++) {
        if (maxduration < [[BlowsDurationTot objectAtIndex:i]floatValue] && [[BlowsPosition objectAtIndex:i]floatValue] < 1.7f) {
            maxduration = [[BlowsDurationTot objectAtIndex:i]floatValue];
        }
        HeightFactor = 0.25 / maxduration;
    }
    
    
    
    //draw the rectangles for each blow
    //first, draw a rectangle to cover the other rectangles when they "go out of range"
    static const GLfloat rectangle[] = {
        -1.1f, -0.15f, -5.0f,
        -1.0f, 0.25f, -5.0f,
        -1.1f, 0.25f, -5.0f,
        -1.0f, 0.25f, -5.0f,
        -1.1f, -0.15f, -5.0f,
        -1.0f, -0.15f, -5.0f
    };
    glColor4f(0.0, 0.0, 0.0, 1.0);
    glLoadIdentity();
    glVertexPointer(3, GL_FLOAT, 0, rectangle);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 6);
    for (int i = 0; i < [BlowsPosition count]; i++) {
        if ([[BlowsPosition objectAtIndex:i]floatValue] < 1.7f) {
            [BlowsPosition replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[BlowsPosition objectAtIndex:i]floatValue] + speed]];
            float height1 = HeightFactor * [[BlowsDurationGood objectAtIndex:i]floatValue];
            float height2 = HeightFactor * ([[BlowsDurationTot objectAtIndex:i]floatValue] - [[BlowsDurationGood objectAtIndex:i]floatValue]);
        
            [self drawRectangleDuration:[[BlowsPosition objectAtIndex:i]floatValue] RectHeight: height1 offset: 0.0f color1:0.1f color2:0.9f color3:0.1f color4:1.0f];
            [self drawRectangleDuration:[[BlowsPosition objectAtIndex:i]floatValue] RectHeight: height2 offset: height1 color1:1.0f color2:0.0f color3:0.0f color4:1.0f];
        }
    }
    
    //draw the stars
    for (int i = 0; i < [StarsPosition count]; i++) {
        if ([[StarsPosition objectAtIndex:i]floatValue] < 1.7f) {
            [StarsPosition replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[StarsPosition objectAtIndex:i]floatValue] + speed]];
            [self drawStar:[[StarsPosition objectAtIndex:i]floatValue]];
        }
    }
    
    
    //draw the start/stop exercice triangles
    for (int i = 0; i < [StartStopPosition count]; i++) {
        if ([[StartStopPosition objectAtIndex:i]floatValue] < 1.7f) {
            [StartStopPosition replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:[[StartStopPosition objectAtIndex:i]floatValue] + speed]];
            [self drawStartStopTriangle:[[StartStopPosition objectAtIndex:i]floatValue]];
        }
    }
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    //draw line for blow length    
    glColor4f(1.0f, 9.0f, 0.0f, 1.0f);
    glLoadIdentity();
    [self drawLine:-1.0 y1:-0.15 + HeightFactor * [flapix expirationDurationTarget] z1:-5.00 x2:0.64  y2:-0.15 + HeightFactor * [flapix expirationDurationTarget]  z2:-5.00];
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
}

- (void)drawRectangleDuration: (float) PositionActual RectHeight:(float) RectangleHeight offset:(float) Offset color1:(float)col1 color2:(float)col2 color3:(float)col3 color4:(float)col4 {
    const GLfloat rectangle[] = {
        0.67f, -0.15f + Offset, -5.0f,
        0.62f, -0.15f + Offset, -5.0f,
        0.67f, -0.15f + RectangleHeight + Offset, -5.0f,
        0.62f, -0.15f + Offset, -5.0f,
        0.67f, -0.15f + RectangleHeight + Offset, -5.0f,
        0.62f, -0.15f + RectangleHeight + Offset, -5.0f
    };
    glColor4f(col1, col2, col3, col4);
    glLoadIdentity();
    glTranslatef(-PositionActual, 0.0f, 0.0f);
    glVertexPointer(3, GL_FLOAT, 0, rectangle);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 6);
}
- (void)drawStar: (float) PositionActual {
    const GLfloat star_cover[] = {
        0.628f, 0.55f * 0.2, -5.0f,
        0.662f, 0.55f * 0.2, -5.0f,
        0.645f, 0.64f * 0.2, -5.0f
    };
    glColor4f(0.0f, 0.0f, 0.0f, 1.0f);
    glLoadIdentity();
    glTranslatef(-PositionActual, 0.0f, 0.0f);
    glVertexPointer(3, GL_FLOAT, 0, star_cover);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 3);

    
    const GLfloat star[] = {
        0.62f, 0.77f * 0.2, -5.0f,
        0.67f, 0.77f * 0.2, -5.0f,
        0.645f, 0.64f * 0.2, -5.0f,
        0.645f, 0.92f * 0.2, -5.0f,
        0.628f, 0.55f * 0.2, -5.0f,
        0.662f, 0.55f * 0.2, -5.0f
    };
    glColor4f(1.0f, 1.0f, 0.0f, 1.0f);
    glLoadIdentity();
    glTranslatef(-PositionActual, 0.0f, 0.0f);
    glVertexPointer(3, GL_FLOAT, 0, star);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 6);
    
}

- (void)drawStartStopTriangle: (float) PositionActual {
    const GLfloat triangle[] = {
        0.68f, -0.15f, -5.0f,
        0.61f, -0.15f, -5.0f,
        0.645f, 0.0f, -5.0f
    };
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glLoadIdentity();
    glTranslatef(-PositionActual, 0.0f, 0.0f);
    glVertexPointer(3, GL_FLOAT, 0, triangle);
    glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_TRIANGLES, 0, 3);
}


- (void)flapixEventFrequency:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{            // this block will run on the main thread
    if ([[FlowerController currentFlapix] exerciceInCourse]) {
        int p = (int)([[[FlowerController currentFlapix] currentExercice] percent_done]*100);
        [labelPercent setText:[NSString stringWithFormat:@"%i%%",p]];
    } else {
        [labelPercent setText:@"---"];
    }
    });
}


- (void)flapixEventEndBlow:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{            // this block will run on the main thread
        FLAPIBlow* blow = (FLAPIBlow*)[notification object];
        if ([[FlowerController currentFlapix] exerciceInCourse]) {
            int p = (int)([[[FlowerController currentFlapix] currentExercice] percent_done]*100);
            NSString *StringForLabelPercent = [[NSString alloc ] initWithFormat:@"%i%%",p];
            [labelPercent setText:StringForLabelPercent];
            [StringForLabelPercent release];
        } else {
            [labelPercent setText:@"---"];
        }
        NSString *StringForLabelFrequency = [[NSString alloc ] initWithFormat:@"%iHz",(int)blow.medianFrequency];
        [labelFrequency setText:StringForLabelFrequency];
        [StringForLabelFrequency release];
        NSString *StringForLabelDuration = [[NSString alloc ] initWithFormat:@"%.2lf sec",blow.in_range_duration];
        [labelDuration setText:StringForLabelDuration];
        [StringForLabelDuration release];
        [BlowsPosition addObject:[NSNumber numberWithFloat:0.0f]];
        [BlowsDurationGood addObject:[NSNumber numberWithFloat:blow.in_range_duration]];
        [BlowsDurationTot addObject:[NSNumber numberWithFloat:blow.duration]];
        if (blow.goal) {
            [StarsPosition addObject:[NSNumber numberWithFloat:0.0f]];
        }
    
        //NSLog(@"blow duration:%f, in range duration:%f", blow.duration, blow.in_range_duration);
        //Resize Y axis if needed
        if (blow.duration > higherBar) {
            self.higherBar = blow.duration;
            // if too high blow, resize y axis
        }
        
        //remove objects when array reaches a certain count
        if ([BlowsPosition count] >= 10) {
            for (int i = 0; i < [BlowsPosition count]-1; i++) {
                [BlowsPosition replaceObjectAtIndex:i withObject:[BlowsPosition objectAtIndex:i+1]];
                [BlowsDurationGood replaceObjectAtIndex:i withObject:[BlowsDurationGood objectAtIndex:i+1]];
                [BlowsDurationTot replaceObjectAtIndex:i withObject:[BlowsDurationTot objectAtIndex:i+1]];
            }
            [BlowsPosition removeLastObject];
            [BlowsDurationGood removeLastObject];
            [BlowsDurationTot removeLastObject];
        }
        if ([StarsPosition count] >= 10) {
            for (int i = 0; i < [StarsPosition count]-1; i++) {
                [StarsPosition replaceObjectAtIndex:i withObject:[StarsPosition objectAtIndex:i+1]];
            }
            [StarsPosition removeLastObject];
        }
        if ([StartStopPosition count] >= 10) {
            for (int i = 0; i < [StartStopPosition count]-1; i++) {
                [StartStopPosition replaceObjectAtIndex:i withObject:[StartStopPosition objectAtIndex:i+1]];
            }
            [StartStopPosition removeLastObject];
        }
    });
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

+(float)frequencyToAngle:(double)freq {
    float longest = ([[FlowerController currentFlapix] frequenceMax] - [[FlowerController currentFlapix] frequenceTarget]) >
    ([[FlowerController currentFlapix] frequenceTarget] - [[FlowerController currentFlapix] frequenceMin]) ?
    ([[FlowerController currentFlapix] frequenceMax] - [[FlowerController currentFlapix] frequenceTarget]) :
    ([[FlowerController currentFlapix] frequenceTarget] - [[FlowerController currentFlapix] frequenceMin]);
    
    return (freq - [[FlowerController currentFlapix] frequenceTarget]) / (2 * longest );
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
    
    //if (true) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    //}
    
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
