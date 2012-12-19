//
//  BikerGL.m
//  FlowerForAll
//
//  Created by adherent on 07.12.12.
//
//

#import "BikerGL.h"
#import "BikerApp.h"

#import "FLAPIBlow.h"
#import "FLAPIX.h"
#import "FLAPIExercice.h"
#import "FlowerController.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "ParametersManager.h"
#import "OpenGLCommon.h"
#import "DB.h"
#import "UserManager.h"


//#define USE_DEPTH_BUFFER 0

@interface BikerGL ()

    @property (nonatomic, retain) EAGLContext *context;
    @property (nonatomic, assign) NSTimer *animationTimer;

    - (BOOL) createFramebuffer;
    - (void) destroyFramebuffer;

@end


@implementation BikerGL

@synthesize context;
@synthesize animationTimer;


/********* GAME PARAMETERS *****************/
float BikerSpeed;
float BikerSpeedFromTime;
int JumpType;
const float gravity = 0.002;
float gravity_accel;
float gravity_accelFromTime;
float up_accel;
float rotation_speed;
float unrotationSpeed;
float rotation_angle_current;
float JumpRotation;
const float JumpMaxRotation = 45.0;
/******* END GAME PARAMETERS **************/
/********* GAME VARIABLES *****************/
float YPos;
GLuint      texture[4];
float StartTreePosition = 1.5;
float TreesPositions[5];
int frameNO = 0;
const int trees[] = {1, 37, 120, 169, 197, 250, 300, 330, 380, 451,
    500, 538, 560, 607, 680, 719, 813, 848, 883, 966};
int NextTreePosition;
const int trees_size = 20;
int NextTree;
bool TreeRuptor;
int combo;
float JumpPos;
bool ShowJump;
bool DOwn;
int unrotate;

float GrassPosition;
UILabel *StarCounterLabel;
UIButton *StartButtonProg;
UIButton *ItemsButtonProg;
UIButton* ItemRotationProg;
UILabel *ItemsLabel;

/******* END GAME VARIABLES **************/
/******* ITEMS VARIABLES **************/
bool ItemsDisplayed;
bool ItemRotation;
/******* END ITEMS VARIABLES **************/


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



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
            NSLog(@"biker contentscalefactor:%f, eagllayercontentscale:%f", self.contentScaleFactor, eaglLayer.contentsScale);
        }
        
        NSLog(@"self.layer.bounds.size.height:%f",self.layer.bounds.size.height);
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
                                                 selector:@selector(flapixEventStart:)
                                                     name:FLAPIX_EVENT_START
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventStop:)
                                                     name:FLAPIX_EVENT_START
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventBlowStop:)
                                                     name:FLAPIX_EVENT_BLOW_STOP object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventExerciceStart:)
                                                     name:FLAPIX_EVENT_EXERCICE_START object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(flapixEventExerciceStop:)
                                                     name:FLAPIX_EVENT_EXERCICE_STOP object:nil];
        
        //BlowsArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        
        animationInterval = 1.0 / 60.0;
		[self setupView];
		[self startAnimation];
        
        //initialize items bool
        //int items_avail = [DB fetchItemsAvail:[UserManager currentUser].uid];
        //NSString *items_string = [[NSNumber numberWithInt:items_avail] stringValue];
        //if ([items_string characterAtIndex:0] == '0') {
            ItemRotation = false;
        //} else ItemRotation = true;
        
        //label for diplaying the number of stars
        StarCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 77, 56, 56)];
        StarCounterLabel.font = [UIFont fontWithName:@"Helvetica" size: 27.0];
        StarCounterLabel.text = [NSString stringWithFormat:@"%i",
                                 [[[FlowerController currentFlapix] currentExercice] blow_star_count]];
        //NSLog(@"blowstarcount:%i",[[[FlowerController currentFlapix] currentExercice] blow_star_count]);
        StarCounterLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:StarCounterLabel];
        
    
        
        //button for starting the game
        StartButtonProg = [[UIButton buttonWithType:UIButtonTypeRoundedRect]retain];
        StartButtonProg.frame = CGRectMake((self.frame.size.width - self.frame.size.width * 0.4479)/2, (self.frame.size.height - self.frame.size.height * 0.073)/2, self.frame.size.width * 0.4479, self.frame.size.height * 0.073);
        StartButtonProg.backgroundColor = [UIColor clearColor];
        [StartButtonProg setTitleColor:[UIColor colorWithRed:0.286 green:0.38 blue:0.592 alpha:1.0] forState:UIControlStateNormal];
        StartButtonProg.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 27.0];
        [StartButtonProg setTitle:@"Start Exercice" forState:UIControlStateNormal];
        [StartButtonProg addTarget: self action:@selector(pressStart) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:StartButtonProg];
    
        //button for displaying the items
        ItemsButtonProg = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        ItemsButtonProg.frame = CGRectMake(self.frame.size.width*0.85, self.frame.size.height/12, self.frame.size.height * 0.073, self.frame.size.height * 0.073);
        ItemsButtonProg.backgroundColor = [UIColor clearColor];
        [ItemsButtonProg setTitleColor:[UIColor colorWithRed:0.286 green:0.38 blue:0.592 alpha:1.0] forState:UIControlStateNormal];
        ItemsButtonProg.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 27.0];
        [ItemsButtonProg setTitle:@"Items" forState:UIControlStateNormal];
        [ItemsButtonProg setBackgroundImage:[UIImage imageNamed:@"BikerTreee.png"] forState:UIControlStateNormal];
        [ItemsButtonProg addTarget: self action:@selector(displayItems) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:ItemsButtonProg];
        
        ItemsDisplayed = false;
    }
    
    return self;
}

- (void)setupView {
    //GLfloat size;
    
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    //size = 10;
    
    // Nous donne la taille de l'écran de l'iPhone
    CGRect rect = self.bounds;
    NSLog(@"rect width:%f, height:%f", rect.size.height, rect.size.width);
    glViewport(0, 0, rect.size.width, rect.size.width);
    
    glClearColor(0.25f, 0.5f, 0.9f, 1.0f);
    
    // texture
    //turn things on
    glEnable(GL_TEXTURE_2D);
    
    
    //generate and bind texture
    glGenTextures(4, &texture[0]);
    
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    [self LoadPic:@"BikerStar"];
    
    glBindTexture(GL_TEXTURE_2D, texture[1]);
    [self LoadPic:@"BikerTreeeCopie"];
    glBindTexture(GL_TEXTURE_2D, texture[2]);
    [self LoadPic:@"BikerTreee"];
    
    glBindTexture(GL_TEXTURE_2D, texture[3]);
    [self LoadPic:@"BikerRondins"];
    
    for (int i = 0; i < 5; i++) {
        TreesPositions[i] = 4.0;
    }
}

- (void) LoadPic: (NSString*) PicName {
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    //load the image
    NSString *path = [[NSBundle mainBundle] pathForResource:PicName ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
        NSLog(@"couldn't load image");
    
    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context_pic = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context_pic, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context_pic, 0, height - height );
    CGContextDrawImage( context_pic, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    
    CGContextRelease(context_pic);
    
    free(imageData);
    [image release];
    [texData release];
    
}

float current_angle = 0.0;

- (void)drawView {
    /*static NSTimeInterval lastDrawTime;
    NSTimeInterval timeSinceLastDraw;
    if (lastDrawTime)
    {
        timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastDrawTime;
        //rot+=  60 * timeSinceLastDraw * BikerSpeed;
        BikerSpeedFromTime = BikerSpeed * timeSinceLastDraw * 33 ;
        up_accelFromTime = up_accel * timeSinceLastDraw * 33 ;
        gravity_accelFromTime = gravity_accel * timeSinceLastDraw * 33 ;
        rotation_speedFromTime = rotation_speed * timeSinceLastDraw * 33 ;
        unrotationSpeedFromTime = unrotationSpeed * timeSinceLastDraw * 33 ;
        gravity_accel = gravity_accel * timeSinceLastDraw * 33 ;
    }
    lastDrawTime = [NSDate timeIntervalSinceReferenceDate];*/

    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingWidth);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    
    //              DRAW THE STAR
    static GLfloat rot = 0.0;
    
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    static const Vertex3D vertices[] = {
        {-0.2,  0.2, -0.1},
        { 0.2,  0.2, -0.1},
        {-0.2, -0.2, -0.1},
        { 0.2, -0.2, -0.1}
    };
    static const Vector3D normals[] = {
        {0.0, 0.0, 1.0},
        {0.0, 0.0, 1.0},
        {0.0, 0.0, 1.0},
        {0.0, 0.0, 1.0}
    };
    static const GLfloat texCoords[] = {
        0.0, 1.0,
        1.0, 1.0,
        0.0, 0.0,
        1.0, 0.0
    };
    
    glLoadIdentity();
    if (JumpType == 1 && JumpPos < 0.2) {
        //NSLog(@"Ypos:%f",YPos);
        gravity_accel = gravity_accel + gravity;
        YPos = YPos + (up_accel - gravity_accel);
        if (YPos <= -0.45) {
            YPos = -0.45;
            JumpType = 0;
            gravity_accel = 0.0;
            DOwn = true;
        }
        glTranslatef(0.0,YPos, 0.0);
        
    } else if (JumpType == 2 && JumpPos < 0.2) {
        gravity_accel = gravity_accel + gravity;
        YPos = YPos + (up_accel - gravity_accel);
        rotation_angle_current = rotation_angle_current + rotation_speed;
        if (YPos <= -0.45) {
            YPos = -0.45;
            JumpType = 0;
            gravity_accel = 0.0;
            DOwn = true;
        }
        glTranslatef(0.0,YPos, 0.0);
        if (ItemRotation == false) {
            glRotatef(rotation_angle_current, 0.0, 0.0, 1.0);
        } else {
            glRotatef(rotation_angle_current, 1.0, 1.0, 1.0);
        }
    } else {
        glTranslatef(0.0, -0.45 + 0.005 * sin(1.5*frameNO), 0.0);
    }
    
    if (combo >0) {
        glColor4f(1.0, 0.7, 0.7, 1.0);
    }
    if (JumpType > 0 && JumpRotation < JumpMaxRotation && JumpPos < 0.3 && unrotate == 0) {
        JumpRotation = JumpRotation + 5.0;
        glRotatef(JumpRotation, 0.0, 0.0, 1.0);
        //NSLog(@"first jumprot: %f",JumpRotation);
    } else if (JumpRotation >= JumpMaxRotation) {
        JumpRotation = JumpRotation - 5.0;
        glRotatef(JumpRotation, 0.0, 0.0, 1.0);
        unrotate++;
        //NSLog(@"second jumprot: %f",JumpRotation);
    } else if (unrotate == 1) {
        JumpRotation = JumpRotation - unrotationSpeed;
        glRotatef(JumpRotation, 0.0, 0.0, 1.0);
        if (JumpRotation < 0.0) unrotate++;
        //NSLog(@"third jumprot: %f",JumpRotation);
    }
    glRotatef(180.0 + rot, 0.0, 0.0, 1.0);
    
    glEnable(GL_BLEND);
    //glBlendFunc(GL_ONE, GL_SRC_COLOR);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glNormalPointer(GL_FLOAT, 0, normals);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    
   
    
    
    //          DRAW GRASS
    static const Vertex3D ground[] = {
        {-2,  0.2, -0.05},
        { 2,  0.2, -0.05},
        {-2, -0.2, -0.05},
        { 2, -0.2, -0.05}
    };
    static const GLfloat grassCoords[] = {
        0.0, 0.9,
        1.0, 0.9,
        0.0, 0.1,
        1.0, 0.1
    };
    
    glDisable(GL_BLEND);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glLoadIdentity();
    GrassPosition = GrassPosition - BikerSpeed;
    if (GrassPosition <= -1.0) GrassPosition = 0.0;
    glTranslatef(GrassPosition, -0.85, 0.0);
   //glBlendFunc(GL_ONE, GL_SRC_COLOR);
    //glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindTexture(GL_TEXTURE_2D, texture[1]);
    glVertexPointer(3, GL_FLOAT, 0, ground);
    glNormalPointer(GL_FLOAT, 0, normals);
    glTexCoordPointer(2, GL_FLOAT, 0, grassCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    //          DRAW TREES
    if (frameNO == trees[NextTreePosition]) {
        TreesPositions[NextTree] = 1.5;
        NextTreePosition = (NextTreePosition + 1) % trees_size;
        NextTree = (NextTree + 1) % 5;
        //NSLog(@"NextTree:%i; frameno: %i",NextTree, frameNO);
    }

    for (int i = 0; i < 5; i++) {
        
        if (TreesPositions[i] > -1.5 && TreesPositions[i] < 2.0) {
            
            static const Vertex3D tree[] = {
                {-0.2,  0.3, -0.2},
                { 0.2,  0.3, -0.2},
                {-0.2, -0.2, -0.2},
                { 0.2, -0.2, -0.2}
            };
            static const GLfloat treeCoords[] = {
                0.0, 0.9,
                1.0, 0.9,
                0.0, 0.0,
                1.0, 0.0
            };
            glLoadIdentity();
            glTranslatef(TreesPositions[i], -0.37, 0.0);
            glRotatef(180.0, 0.0, 0.0, 1.0);
    
            glEnable(GL_BLEND);
            //glBlendFunc(GL_ONE, GL_SRC_COLOR);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            glBindTexture(GL_TEXTURE_2D, texture[2]);
            glVertexPointer(3, GL_FLOAT, 0, tree);
            glNormalPointer(GL_FLOAT, 0, normals);
            glTexCoordPointer(2, GL_FLOAT, 0, treeCoords);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
            TreesPositions[i] = TreesPositions[i] - BikerSpeed;
           
        }
        
    }
    
    //      DRAW JUMP    
    if (ShowJump) {
        static const Vertex3D jump[] = {
            {-0.2,  -0.3, -0.21},
            { 0.2,  -0.3, -0.21},
            {0.2, -0.1, -0.21}
        };
        static const GLfloat jumpCoords[] = {
            0.0, 0.9,
            1.0, 0.9,
            0.0, 0.0,
            1.0, 0.0
        };
        JumpPos = JumpPos - BikerSpeed;
        glLoadIdentity();
        glTranslatef(JumpPos, -0.36, 0.0);
        //glRotatef(180.0, 0.0, 0.0, 1.0);
            
        glEnable(GL_BLEND);
        //glBlendFunc(GL_ONE, GL_SRC_COLOR);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
        glBindTexture(GL_TEXTURE_2D, texture[3]);
        glVertexPointer(3, GL_FLOAT, 0, jump);
        glNormalPointer(GL_FLOAT, 0, normals);
        glTexCoordPointer(2, GL_FLOAT, 0, jumpCoords);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
        if (JumpPos < -1.2 && DOwn) {
            ShowJump = false;
            JumpPos = 1.3;
        }
    }
    
    //      FINISH DRAWING

    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);    
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    
    if (TreeRuptor==true) frameNO = 1 + frameNO;
    if (frameNO == trees[trees_size-1] + 30) frameNO = 0;
}

/*- (void)drawRectangleWithWidth:(float)Width andHeight:(float) Height AtX:(float) x_translation AndY:(float) y_translation AndRotation:(float) RotAngle{
    const GLfloat rectangle[] = {
        -Width / 2, Height / 2, -0.057,
        Width / 2, Height / 2, -0.057,
        Width / 2, -Height / 2, -0.057,
        -Width / 2, -Height / 2, -0.057
    };
    glLoadIdentity();
    glTranslatef(x_translation, y_translation, 0.0f);
    glRotatef(RotAngle, 0.0, 0.0, 1.0);
    
    //glBindTexture(GL_TEXTURE_2D, texture);
    glVertexPointer(3, GL_FLOAT, 0, rectangle);
    glEnableClientState(GL_VERTEX_ARRAY);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}*/

bool debug_events_bikerGL = NO;
- (void)flapixEventFrequency:(NSNotification *)notification {
    if ([[FlowerController currentFlapix] exerciceInCourse]) {
        //[labelPercent setText:[NSString stringWithFormat:@"%i%%",p]];
    } else {
        //[labelPercent setText:@"---"];
    }
    NSLog(@"flapixEVENTFREQUENCY!!!");
}

- (void)flapixEventBlowStop:(NSNotification *)notification {
	FLAPIBlow* blow = (FLAPIBlow*)[notification object];
    ShowJump = true;
    DOwn = false;
    JumpRotation = 0;
    unrotate = 0;
    if (debug_events_bikerGL) NSLog(@"BIKER flapixEvent  BlowStop");
    
    if (! [[FlowerController currentFlapix] exerciceInCourse]) return;
    
    //Add sound when the goal has been reached for the last blow
    up_accel = 0.04 + blow.in_range_duration / 160;
    unrotationSpeed = 45.0 / (up_accel / gravity * 1.75);
    if (up_accel > 0.04 + 5.0 / 160) {
        up_accel = 0.04 + 5.0 / 160;
        combo = 0;
    }
    if (blow.goal) {
        JumpType = 2;
        combo++;
        rotation_speed = 360.0 / (up_accel / gravity * 2) * combo;
        int stars_nb = [DB fetchStarsCount:[UserManager currentUser].uid];
        int items_avail = [DB fetchItemsAvail:[UserManager currentUser].uid];
        stars_nb++;
        //NSLog(@"check stars_nb in flapixeventblowstop:%i", stars_nb);
        [DB deleteStarsItems:[UserManager currentUser].uid];
        [DB insertStarsItems:stars_nb withItems:items_avail atID:[UserManager currentUser].uid];
        //NSLog(@"check database in flapixeventblowstop:%i",[DB fetchStarsCount:[UserManager currentUser].uid]);
        ItemsLabel.text = [NSString stringWithFormat:@"You have %i stars left", stars_nb];
    //    [self playSystemSound:@"/VolcanoApp_goal.wav"];
    } else {
        JumpType = 1;
        combo = 0;
    }
    BikerApp *bikerForStar = [[BikerApp alloc] init];
    bikerForStar.starLabel.text = [NSString stringWithFormat:@"%i", 3];//[[[FlowerController currentFlapix] currentExercice] blow_star_count]];
    //starLabel.text = [NSString stringWithFormat:@"%i",
                     // [[[FlowerController currentFlapix] currentExercice] blow_star_count]];
    //Raise up lava
    //lavaHidder.frame = CGRectOffset(lavaFrame, 0, - lavaHeight * percent);
    //[self refreshStartButton];
    StarCounterLabel.text = [NSString stringWithFormat:@"%i",
                             [[[FlowerController currentFlapix] currentExercice] blow_star_count]];
    [self setNeedsDisplay];
}

- (void) pressStart {
    if ([[FlowerController currentFlapix] exerciceInCourse]) {
        NSLog(@"pressStart: stop");
        [[FlowerController currentFlapix] exerciceStop];
    } else {
        NSLog(@"pressStart: start");
        [[FlowerController currentFlapix] exerciceStart];
        [StartButtonProg setFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    }
}

/*- (void)refreshStartButton {
    if ([FlowerController shouldShowStartButton]) {
        //[self bringSubviewToFront:StartButtonProg];
        [self addSubview:StartButtonProg];
        NSLog(@"shall bring to front");
    } else {
        //[self sendSubviewToBack:StartButtonProg];
        NSLog(@"shall bring to back");
    }
}*/

-(void)flapixEventStart:(FLAPIX *)flapix {
}

-(void)flapixEventStop:(FLAPIX *)flapix {
}

- (void)flapixEventExerciceStart:(NSNotification *)notification {
    if (debug_events_bikerGL) NSLog(@"BIKER flapixEvent  ExerciceStart");
    BikerSpeed = 0.02f;
    frameNO = 0;
    NextTree = 0;
    TreeRuptor = true;
    NextTreePosition = 0;
    
    for (int i = 0; i < 5; i++) {
        TreesPositions[i] = 4.0;
    }
    
    JumpType = 0;
    YPos = -0.45f;
    gravity_accel = 0.0;
    rotation_angle_current = 0.0;
    combo = 0;
    JumpPos = 1.3;
    ShowJump = false;
    DOwn = true;
    GrassPosition = 0.0;
}

- (void)flapixEventExerciceStop:(NSNotification *)notification {
    if (debug_events_bikerGL) NSLog(@"BIKER flapixEvent  ExerciceStop");
    
    //if (exercice.duration_exercice_s <= exercice.duration_exercice_done_s) {
        //lavaHidder.hidden = true;
        //burst.hidden = false;
        //[self playSystemSound:@"/VolcanoApp_explosion.wav"];
    //}
        
    [self setNeedsDisplay];
    //[self addSubview:StartButtonProg];
    [StartButtonProg setFrame:CGRectMake((self.frame.size.width - self.frame.size.width * 0.4479)/2, (self.frame.size.height - self.frame.size.height * 0.073)/2, self.frame.size.width * 0.4479, self.frame.size.height * 0.073)];
    //[self refreshStartButton];
}


- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (void) displayItems {
    //button for displaying the items
    if (ItemsDisplayed) {
        [ItemsButtonProg setBackgroundImage:[UIImage imageNamed:@"BikerTreee.png"] forState:UIControlStateNormal];
        [ItemsLabel removeFromSuperview];
        [ItemRotationProg removeFromSuperview];
        ItemsDisplayed = false;
    } else {
        //label for diplaying the number of stars
        ItemsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 100, 400, 120)];
        ItemsLabel.font = [UIFont fontWithName:@"Helvetica" size: 27.0];
        ItemsLabel.text = [NSString stringWithFormat:@"You have %i star(s) left", [DB fetchStarsCount:[UserManager currentUser].uid]];
        //NSLog(@"blowstarcount:%i",[[[FlowerController currentFlapix] currentExercice] blow_star_count]);
        ItemsLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:ItemsLabel];
        
        //[ItemsButtonProg setBackgroundImage:[UIImage imageNamed:@"BikerRondins.png"] forState:UIControlStateNormal];
        
        ItemRotationProg = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        ItemRotationProg.frame = CGRectMake(self.frame.size.width*0.15, self.frame.size.height * 0.25, self.frame.size.height * 0.123, self.frame.size.height * 0.123);
        ItemRotationProg.backgroundColor = [UIColor clearColor];
        int items_avail = [DB fetchItemsAvail:[UserManager currentUser].uid];
        NSString *items_string = [[NSNumber numberWithInt:items_avail] stringValue];
        if ([items_string characterAtIndex:0] == 48) {
            [ItemRotationProg setTitle:[NSString stringWithFormat:@"Item 1 \n \r Price: %i stars",2] forState:UIControlStateNormal];
            ItemRotationProg.titleLabel.numberOfLines = 2;
            ItemRotationProg.titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            ItemRotationProg.titleLabel.textAlignment = UITextAlignmentCenter;
        } else if (ItemRotation == true) {
            [ItemRotationProg setBackgroundImage:[UIImage imageNamed:@"BikerTreee.png"] forState:UIControlStateNormal];
        } else if (ItemRotation == false) {
            [ItemRotationProg setBackgroundImage:[UIImage imageNamed:@"BikerStar.png"] forState:UIControlStateNormal];
        }
        [ItemRotationProg addTarget: self action:@selector(selectItemRotation) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:ItemRotationProg];
        ItemsDisplayed = true;
    }
    
}

- (void) selectItemRotation {
    int stars_nb = [DB fetchStarsCount:[UserManager currentUser].uid];
    int items_avail = [DB fetchItemsAvail:[UserManager currentUser].uid];
    NSString *items_string = [[NSNumber numberWithInt:items_avail] stringValue];
    if ([items_string characterAtIndex:0] == 48 && stars_nb >= 2) {
        stars_nb = stars_nb - 2;
        ItemsLabel.text = [NSString stringWithFormat:@"You have %i stars left", stars_nb];
        items_avail = 00001;
        [DB deleteStarsItems:[UserManager currentUser].uid];
        [DB insertStarsItems:stars_nb withItems:items_avail atID:[UserManager currentUser].uid];
        ItemRotation = true;
        [ItemRotationProg setBackgroundImage:[UIImage imageNamed:@"BikerTreee.png"] forState:UIControlStateNormal];
        [ItemRotationProg setTitle:@"" forState:UIControlStateNormal];
        NSLog(@"check Items available in selectItemRotation:%i",[DB fetchItemsAvail:[UserManager currentUser].uid]);
    } else if ([items_string characterAtIndex:0] == 49 && ItemRotation == true){
        ItemRotation = false;
        [ItemRotationProg setBackgroundImage:[UIImage imageNamed:@"BikerStar.png"] forState:UIControlStateNormal];
        [ItemRotationProg setTitle:@"" forState:UIControlStateNormal];
    } else if ([items_string characterAtIndex:0] == 49 && ItemRotation == false){
        ItemRotation = true;
        [ItemRotationProg setBackgroundImage:[UIImage imageNamed:@"BikerTreee.png"] forState:UIControlStateNormal];
        [ItemRotationProg setTitle:@"" forState:UIControlStateNormal];
    }
    NSLog(@"ItemRotation = %s and character in string: %hu", ItemRotation ? "true" : "false", [items_string characterAtIndex:0]);
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
    NSLog(@"biker backingw:%i, backingh: %i", backingWidth, backingHeight);
    
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

- (void)encodeWithCoder:(NSCoder *)enCoder {
    [super encodeWithCoder:enCoder];
    
    //[enCoder encodeObject:start forKey:INSTANCEVARIABLE_KEY];
    
    // Similarly for the other instance variables.
}

- (void)dealloc {
	
	[self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];
    [super dealloc];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
