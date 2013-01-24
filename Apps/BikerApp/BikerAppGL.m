//
//  BikerGL.m
//  FlowerForAll
//
//  Created by adherent on 07.12.12.
//
//

#import "BikerAppGL.h"
#import "BikerApp.h"

#import "FLAPIBlow.h"
#import "FLAPIX.h"
#import "FLAPIExercice.h"
#import "FlowerController.h"

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "ParametersManager.h"
#import "BikerAppOpenGLCommon.h"
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

@synthesize context, animationTimer, animationInterval;


/********* GAME PARAMETERS *****************/
const float gravity = 0.002;
const float JumpMaxRotation = 45.0;
float StartTreePosition = 1.5;
float StartCloudPosition = 1.5;
const int trees_size = 20;
const int clouds_size = 20;
/******* END GAME PARAMETERS **************/
/********* GAME VARIABLES *****************/
float gravity_accel;
float gravity_accelFromTime;
float up_accel;
float rotation_speed;
float unrotationSpeed;
float rotation_angle_current;
float JumpRotation;
float BikerSpeed;
float BikerSpeedFromTime;
float TimeScaleFactor;
int JumpType;
float YPos;
GLuint      texture[8];
float TreesPositions[5];
float CloudsPositions[5];
int frameNO = 0;
int frameNO_clouds =  0;
const int trees[] = {1, 37, 120, 169, 197, 250, 300, 330, 380, 451,
    500, 538, 560, 607, 680, 719, 813, 848, 883, 966};
const int clouds[] = {19, 87, 160, 229, 297, 370, 410, 500, 680, 748,
    822, 900, 941, 1026, 1110, 1192, 1283, 1379, 1444, 1555};
const float cloudsYPos[] = {-0.1, 0.2, 0.13, 0.0, -0.2, -0.12, 0.02, -0.06, -0.18, 0.13,
                           -0.15, 0.02, -0.13, 0.10, -0.12, -0.19, 0.12, 0.06, 0.18, -0.13};
int NextTreePosition;       //index of the next tree in the trees[] array
int NextCloudPosition;      //index of the next cloud in the clouds[] array
int NextTree;               //index of the next tree in the array which contains the positions on the screen
int NextCloud;              //index of the next cloud in the array which contains the positions on the screen
bool TreeRuptor;
bool CloudRuptor;
int combo;
float JumpPos;
bool ShowJump;
bool DOwn;
int unrotate;
FLAPIX* flapixBiker;
static float hPos;
static BOOL goal;
float h;

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
        
        //label for diplaying the number of stars on iPad or iPhone
        if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
            StarCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 77, 56, 56)];
            StarCounterLabel.font = [UIFont fontWithName:@"Helvetica" size: 27.0];
        } else {
            StarCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.5, 27, 65, 65)];
            StarCounterLabel.font = [UIFont fontWithName:@"Helvetica" size: 21.0];
        }
        
        StarCounterLabel.text = [NSString stringWithFormat:@"%i",
                                 [[[FlowerController currentFlapix] currentExercice] blow_star_count]];
        StarCounterLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:StarCounterLabel];
        
    
        
        //button for starting the game
        StartButtonProg = [[UIButton buttonWithType:UIButtonTypeRoundedRect]retain];
        StartButtonProg.frame = CGRectMake((self.frame.size.width - self.frame.size.width * 0.4479)/2, (self.frame.size.height - self.frame.size.height * 0.073)/2, self.frame.size.width * 0.4479, self.frame.size.height * 0.073);
        StartButtonProg.backgroundColor = [UIColor clearColor];
        
        [StartButtonProg setTitleColor:[UIColor colorWithRed:0.286 green:0.38 blue:0.592 alpha:1.0] forState:UIControlStateNormal];
        if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
            StartButtonProg.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 27.0];
        } else {
             StartButtonProg.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 17.0];
        }
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
        //[self addSubview:ItemsButtonProg];
        //[ItemsButtonProg setFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
        
        
        
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
    glGenTextures(8, &texture[0]);
    
    // the picture height and width in pixels must be powers of 2 !!!
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    [self LoadPic:@"BikerAppBiker"];
    glBindTexture(GL_TEXTURE_2D, texture[1]);
    [self LoadPic:@"BikerAppGround"];    
    glBindTexture(GL_TEXTURE_2D, texture[2]);
    [self LoadPic:@"BikerAppArbre"];
    glBindTexture(GL_TEXTURE_2D, texture[3]);
    [self LoadPic:@"BikerAppJump"];
    glBindTexture(GL_TEXTURE_2D, texture[4]);
    [self LoadPic:@"BikerAppCloud"];
    glBindTexture(GL_TEXTURE_2D, texture[5]);
    [self LoadPic:@"BikerAppBikerandStar"];
    glBindTexture(GL_TEXTURE_2D, texture[6]);
    [self LoadPic:@"BikerAppBikerBlue"];
    glBindTexture(GL_TEXTURE_2D, texture[7]);
    [self LoadPic:@"BikerAppBikerBlowing"];
    
    for (int i = 0; i < 5; i++) {
        TreesPositions[i] = 4.0;
    }
    for (int i = 0; i < 5; i++) {
        CloudsPositions[i] = 4.0;
    }
    
    flapixBiker = [FlowerController currentFlapix];
}

//Function for loading png pictures taking the name (without .png) as parameter. Don't forget to change the number of textures!
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
//The function that draws each frame
- (void)drawView {
    
    static NSTimeInterval lastDrawTime;
    NSTimeInterval timeSinceLastDraw;
    if (lastDrawTime)
    {
        timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastDrawTime;
        //rot+=  60 * timeSinceLastDraw * BikerSpeed;
        //BikerSpeedFromTime = BikerSpeed * timeSinceLastDraw * 33 ;
        TimeScaleFactor = timeSinceLastDraw * 60;
        
    }
    lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
    
    [EAGLContext setCurrentContext:context];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingWidth);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glMatrixMode(GL_MODELVIEW);
    /*
    //hack
    static NSTimeInterval lastKeyframeTime = 0.0;
    if (lastKeyframeTime == 0.0)
        lastKeyframeTime = [NSDate timeIntervalSinceReferenceDate];
    static AnimationDirection direction = kAnimationDirectionForward;
    
    glLoadIdentity();
    glTranslatef(0.0,0.0,0.0);
    glRotatef(-90.0, 1.0, 0.0, 0.0); // Blender uses Z-up, not Y-up like OpenGL ES
    
    static const VertexData3D sourcevertices[] = {
        {-0.2,  0.2, 0.41},
        { 0.2,  0.2, 0.41},
        {-0.2, -0.2, 0.41},
        { 0.2, -0.2, 0.41}
    };
    static const VertexData3D destvertices[] = {
        {-0.2,  0.2, 0.41},
        { 0.2,  0.2, 0.41},
        {-0.2, -0.2, 0.41},
        { 0.2, -0.2, 0.41}
    };
    static VertexData3D drewvertices[4];
    
    glColor4f(0.0, 0.3, 1.0, 1.0);
    glEnable(GL_COLOR_MATERIAL);
    NSTimeInterval timeSinceLastKeyFrame = [NSDate timeIntervalSinceReferenceDate] - lastKeyframeTime;
    if (timeSinceLastKeyFrame > kAnimationDuration) {
        direction = !direction;
        timeSinceLastKeyFrame = timeSinceLastKeyFrame - kAnimationDuration;
        lastKeyframeTime = [NSDate timeIntervalSinceReferenceDate];
    }
    NSTimeInterval percentDone = timeSinceLastKeyFrame / kAnimationDuration;
    
    VertexData3D *source, *dest;
    if (direction == kAnimationDirectionForward)
    {
        source = (VertexData3D *)sourcevertices;
        dest = (VertexData3D *)destvertices;
    }
    else
    {
        source = (VertexData3D *)destvertices;
        dest = (VertexData3D *)sourcevertices;
    }
    
    for (int i = 0; i < 4; i++)
    {
        GLfloat diffX = dest[i].vertex.x - source[i].vertex.x;
        GLfloat diffY = dest[i].vertex.y - source[i].vertex.y;
        GLfloat diffZ = dest[i].vertex.z - source[i].vertex.z;
        GLfloat diffNormalX = dest[i].normal.x - source[i].normal.x;
        GLfloat diffNormalY = dest[i].normal.y - source[i].normal.y;
        GLfloat diffNormalZ = dest[i].normal.z - source[i].normal.z;
        
        drewvertices[i].vertex.x = source[i].vertex.x + (percentDone * diffX);
        drewvertices[i].vertex.y = source[i].vertex.y + (percentDone * diffY);
        drewvertices[i].vertex.z = source[i].vertex.z + (percentDone * diffZ);
        drewvertices[i].normal.x = source[i].normal.x + (percentDone * diffNormalX);
        drewvertices[i].normal.y = source[i].normal.y + (percentDone * diffNormalY);
        drewvertices[i].normal.z = source[i].normal.z + (percentDone * diffNormalZ);
        
    }
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glVertexPointer(3, GL_FLOAT, sizeof(VertexData3D), &destvertices[0].vertex);
    glNormalPointer(GL_FLOAT, sizeof(VertexData3D), &destvertices[0].normal);
    glDrawArrays(GL_TRIANGLES, 0, 4);
    //glDisableClientState(GL_VERTEX_ARRAY);
    //glDisableClientState(GL_NORMAL_ARRAY);
    //hackend
    */
    
    
    //              DRAW THE BIKER BLUE
    static GLfloat rot = 0.0;
    
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    int p=0;
    if ([[FlowerController currentFlapix] currentExercice]) {
        p = (int)([[[FlowerController currentFlapix] currentExercice] percent_done]*100);
    }
    // coordinates of the edges of the square
    const Vertex3D verticesblue[] = {
        {-0.2,  -0.2 + 0.004 * p, -0.1},
        { 0.2,  -0.2 + 0.004 * p, -0.1},
        {-0.2, -0.6, -0.1},
        { 0.2, -0.6, -0.1}
    };
    static const Vector3D normals[] = {
        {0.0, 0.0, 1.0},
        {0.0, 0.0, 1.0},
        {0.0, 0.0, 1.0},
        {0.0, 0.0, 1.0}
    };
    // coordinates used to crop the picture
    const GLfloat texCoordsblue[] = {
        0.0, 0.5 + 0.005 * p,
        1.0, 0.5 + 0.005 * p,
        0.0, 0.0,
        1.0, 0.0
    };
    
    glLoadIdentity();
    
    //implementing the jump with of without backflip
    if (JumpType == 1 && JumpPos < 0.2) {
        //NSLog(@"Ypos:%f",YPos);
        gravity_accel = gravity_accel + gravity * TimeScaleFactor;
        YPos = YPos + up_accel - gravity_accel;
        if (YPos <= -0.45) {
            YPos = -0.45;
            JumpType = 0;
            gravity_accel = 0.0;
            DOwn = true;
        }
        glTranslatef(0.0,YPos, 0.0);
        
    } else if (JumpType == 2 && JumpPos < 0.23) {
        gravity_accel = gravity_accel + gravity;
        YPos = YPos + up_accel - gravity_accel;
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
        glTranslatef(0.0, -0.45 + 0.002 * sin(0.8*frameNO) * TimeScaleFactor, 0.0);
    }
    
    //if (combo >0) {
    //    glColor4f(1.0, 0.7, 0.7, 1.0);
    //}
    
    //implementing the rotation when hitting the jump
    if (JumpType > 0 && JumpRotation < JumpMaxRotation && JumpPos < 0.3 && unrotate == 0) {
        JumpRotation = JumpRotation + 5.0 * TimeScaleFactor;
        glRotatef(JumpRotation, 0.0, 0.0, 1.0);
        //NSLog(@"first jumprot: %f",JumpRotation);
    } else if (JumpRotation >= JumpMaxRotation) {
        JumpRotation = JumpRotation - 5.0 * TimeScaleFactor;
        glRotatef(JumpRotation, 0.0, 0.0, 1.0);
        unrotate++;
        //NSLog(@"second jumprot: %f",JumpRotation);
    } else if (unrotate == 1) {
        JumpRotation = JumpRotation - unrotationSpeed * TimeScaleFactor;
        glRotatef(JumpRotation, 0.0, 0.0, 1.0);
        if (JumpRotation < 0.0) unrotate++;
        //NSLog(@"third jumprot: %f",JumpRotation);
    }
    glRotatef(180.0 + rot, 0.0, 0.0, 1.0);
    glRotatef(180.0, 0.0, 1.0, 0.0);
    
    glEnable(GL_BLEND);
    //glBlendFunc(GL_ONE, GL_SRC_COLOR);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindTexture(GL_TEXTURE_2D, texture[6]);
    glVertexPointer(3, GL_FLOAT, 0, verticesblue);
    glNormalPointer(GL_FLOAT, 0, normals);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoordsblue);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    
    //              DRAW THE BIKER
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    // coordinates of the edges of the square
    static const Vertex3D vertices[] = {
        {-0.2,  0.2, -0.1},
        { 0.2,  0.2, -0.1},
        {-0.2, -0.6, -0.1},
        { 0.2, -0.6, -0.1}
    };
    // coordinates used to crop the picture
    static const GLfloat texCoords[] = {
        0.0, 1.0,
        1.0, 1.0,
        0.0, 0.0,
        1.0, 0.0
    };
    
    glLoadIdentity();
    
    //implementing the jump with of without backflip
    if (JumpType == 1 && JumpPos < 0.2) {
        //NSLog(@"Ypos:%f",YPos);
        gravity_accel = gravity_accel + gravity * TimeScaleFactor;
        YPos = YPos + up_accel - gravity_accel;
        if (YPos <= -0.45) {
            YPos = -0.45;
            JumpType = 0;
            gravity_accel = 0.0;
            DOwn = true;
        }
        glTranslatef(0.0,YPos, 0.0);
        
    } else if (JumpType == 2 && JumpPos < 0.23) {
        gravity_accel = gravity_accel + gravity;
        YPos = YPos + up_accel - gravity_accel;
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
        glTranslatef(0.0, -0.45 + 0.002 * sin(0.8*frameNO) * TimeScaleFactor, 0.0);
    }
    
    //if (combo >0) {
    //    glColor4f(1.0, 0.7, 0.7, 1.0);
    //}
    
    //implementing the rotation when hitting the jump
    if (JumpType > 0 && JumpRotation < JumpMaxRotation && JumpPos < 0.3 && unrotate == 0) {
        JumpRotation = JumpRotation + 5.0 * TimeScaleFactor;
        glRotatef(JumpRotation, 0.0, 0.0, 1.0);
        //NSLog(@"first jumprot: %f",JumpRotation);
    } else if (JumpRotation >= JumpMaxRotation) {
        JumpRotation = JumpRotation - 5.0 * TimeScaleFactor;
        glRotatef(JumpRotation, 0.0, 0.0, 1.0);
        unrotate++;
        //NSLog(@"second jumprot: %f",JumpRotation);
    } else if (unrotate == 1) {
        JumpRotation = JumpRotation - unrotationSpeed * TimeScaleFactor;
        glRotatef(JumpRotation, 0.0, 0.0, 1.0);
        if (JumpRotation < 0.0) unrotate++;
        //NSLog(@"third jumprot: %f",JumpRotation);
    }
    glRotatef(180.0 + rot, 0.0, 0.0, 1.0);
    glRotatef(180.0, 0.0, 1.0, 0.0);
    
    glEnable(GL_BLEND);
    //glBlendFunc(GL_ONE, GL_SRC_COLOR);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    /*hPos = 0;
    goal = NO;
    h = [flapixBiker currentBlowPercent];
    static float hSpeed = 0.01;
    if (! flapixBiker.blowing) h = 0;
    [flapixBiker 
    if (h < 1 && (h > hPos)) goal = NO; // we keep goal value to descend the gauge
    if (h > 1) goal = YES;*/
    if (combo >0) {
        glBindTexture(GL_TEXTURE_2D, texture[5]);
    } else if (flapixBiker.frequency < flapixBiker.frequenceTarget+flapixBiker.frequenceTolerance && flapixBiker.frequency > flapixBiker.frequenceTarget-flapixBiker.frequenceTolerance) {
        glBindTexture(GL_TEXTURE_2D, texture[7]);
    }else {
        glBindTexture(GL_TEXTURE_2D, texture[0]);
    }
    
    /*hSpeed = (h < hPos) ? 0.2 : 0.1;
    
    hPos = hPos + (h - hPos ) * hSpeed;*/
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glNormalPointer(GL_FLOAT, 0, normals);
    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    //          DRAW GRASS
    static const Vertex3D ground[] = {
        {-2,  0.2, -0.1},
        { 2,  0.2, -0.1},
        {-2, -0.2, -0.1},
        { 2, -0.2, -0.1}
    };
    static const GLfloat grassCoords[] = {
        0.0, 0.8,
        1.0, 0.8,
        0.0, 0.18,
        1.0, 0.18
    };
    
    glDisable(GL_BLEND);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glLoadIdentity();
    GrassPosition = GrassPosition - BikerSpeed * TimeScaleFactor;
    if (GrassPosition <= -1.0) GrassPosition = 1.0;
    glTranslatef(GrassPosition, -0.81, 0.0);
    glRotatef(180.0, 0.0, 0.0, 1.0);
   //glBlendFunc(GL_ONE, GL_SRC_COLOR);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindTexture(GL_TEXTURE_2D, texture[1]);
    glVertexPointer(3, GL_FLOAT, 0, ground);
    glNormalPointer(GL_FLOAT, 0, normals);
    glTexCoordPointer(2, GL_FLOAT, 0, grassCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    //          DRAW TREES
    if (frameNO >= trees[NextTreePosition]) {
        TreesPositions[NextTree] = 1.5;
        while ( frameNO >= trees[NextTreePosition] && frameNO < trees[trees_size-1]) {
            NextTreePosition = (NextTreePosition + 1) % trees_size;
            //NSLog(@"in the tree while loop");
            //if (frameNO == trees[0]) frameNO = 0;
        }
        NextTree = (NextTree + 1) % 5;
        //NSLog(@"frameno: %i; NextTreePosition:%i", frameNO, NextTreePosition);
    }

    for (int i = 0; i < 5; i++) {
        
        if (TreesPositions[i] > -1.5 && TreesPositions[i] < 2.0) {
            
            static const Vertex3D tree[] = {
                {-0.2,  0.3, -0.15},
                { 0.2,  0.3, -0.15},
                {-0.2, -0.2, -0.15},
                { 0.2, -0.2, -0.15}
            };
            static const GLfloat treeCoords[] = {
                0.0, 1.0,
                0.8, 1.0,
                0.0, 0.0,
                0.8, 0.0
            };
            glLoadIdentity();
            glTranslatef(TreesPositions[i], -0.40, 0.0);
            glRotatef(180.0, 0.0, 0.0, 1.0);
    
            glEnable(GL_BLEND);
            //glBlendFunc(GL_ONE, GL_SRC_COLOR);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            glBindTexture(GL_TEXTURE_2D, texture[2]);
            glVertexPointer(3, GL_FLOAT, 0, tree);
            glNormalPointer(GL_FLOAT, 0, normals);
            glTexCoordPointer(2, GL_FLOAT, 0, treeCoords);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
            TreesPositions[i] = TreesPositions[i] - BikerSpeed * TimeScaleFactor;
        }
    }
    
    //          DRAW CLOUDS
    if (frameNO_clouds >= clouds[NextCloudPosition]) {
        CloudsPositions[NextCloud] = 1.5;
        //NSLog(@"NextCloudbefore:%i; frameno: %i",NextCloud, frameNO_clouds);
        while (frameNO_clouds >= clouds[NextCloudPosition] && frameNO_clouds < clouds[clouds_size-1]) {
            NextCloudPosition = (NextCloudPosition + 1) % clouds_size;
        }
        //if (frameNO_clouds >= clouds[clouds_size-1]) frameNO_clouds = 0;
        //NSLog(@"NextCloudafter:%i; frameno: %i", NextCloud, frameNO_clouds);
        //frameNO_clouds++;
        NextCloud = (NextCloud + 1) % 5;
    }
    
    for (int i = 0; i < 5; i++) {
        
        if (CloudsPositions[i] > -1.5 && CloudsPositions[i] < 2.0) {
            
            static const Vertex3D cloud[] = {
                {-0.4,  0.2, -0.2},
                { 0.4,  0.2, -0.2},
                {-0.4, -0.2, -0.2},
                { 0.4, -0.2, -0.2}
            };
            static const GLfloat cloudCoords[] = {
                0.0, 1.0,
                1.0, 1.0,
                0.0, 0.0,
                1.0, 0.0
            };
            glLoadIdentity();
            //NSLog(@"cloudsypos:%f",cloudsYPos[i]);
            glTranslatef(CloudsPositions[i], 0.50 + cloudsYPos[i], 0.0);
            glRotatef(180.0, 0.0, 0.0, 1.0);
            
            glEnable(GL_BLEND);
            //glBlendFunc(GL_ONE, GL_SRC_COLOR);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            glBindTexture(GL_TEXTURE_2D, texture[4]);
            glVertexPointer(3, GL_FLOAT, 0, cloud);
            glNormalPointer(GL_FLOAT, 0, normals);
            glTexCoordPointer(2, GL_FLOAT, 0, cloudCoords);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            
            CloudsPositions[i] = CloudsPositions[i] - (BikerSpeed - 0.0007 + 0.0035 * (clouds[i] % 2)) * TimeScaleFactor;
        }
        
    }
    
    //      DRAW JUMP    
    if (ShowJump) {
        static const Vertex3D jump[] = {
            {-0.3,  0.1, 0.2},
            { 0.3,  0.1, 0.2},
            {-0.3, -0.1, 0.2},
            { 0.3, -0.1, 0.2}
        };
        static const GLfloat jumpCoords[] = {
            0.0, 1.0,
            1.0, 1.0,
            0.0, 0.0,
            1.0, 0.0
        };
        JumpPos = JumpPos - BikerSpeed * TimeScaleFactor;
        glLoadIdentity();
        glTranslatef(JumpPos, -0.61, 0.0);
        glRotatef(180.0, 0.0, 0.0, 1.0);
        glRotatef(180.0, 0.0, 1.0, 0.0);
        
        //blending to make the object transparent
        glEnable(GL_BLEND);
        //glBlendFunc(GL_ONE, GL_SRC_COLOR);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
        glBindTexture(GL_TEXTURE_2D, texture[3]);
        glVertexPointer(3, GL_FLOAT, 0, jump);
        glNormalPointer(GL_FLOAT, 0, normals);
        glTexCoordPointer(2, GL_FLOAT, 0, jumpCoords);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
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
    
    
    if (TreeRuptor==true) frameNO = 1 * TimeScaleFactor + frameNO;
    if (frameNO >= trees[trees_size-1]) {
        frameNO = 0;
        NextTreePosition = 0;
    }
    if (CloudRuptor==true) frameNO_clouds = 1 * TimeScaleFactor + frameNO_clouds;
    if (frameNO_clouds >= clouds[clouds_size-1]) {
        NSLog(@"frameno_clouds = 0");
        frameNO_clouds = 0;
        NextCloudPosition = 0;
    }
    //NSLog(@"frameNO_clouds: %i, frameNO: %i, next cloud: %i, next tree: %i",frameNO_clouds, frameNO, clouds[NextCloudPosition], trees[NextTreePosition]);
}

bool debug_events_bikerGL = NO;
- (void)flapixEventFrequency:(NSNotification *)notification {
    if ([[FlowerController currentFlapix] exerciceInCourse]) {
        //[labelPercent setText:[NSString stringWithFormat:@"%i%%",p]];
    } else {
        //[labelPercent setText:@"---"];
    }
    NSLog(@"flapixEVENTFREQUENCY!!!");
}

//function which executes stuffs after each blow
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
    //up_accel = up_accel * TimeScaleFactor;
}

- (void) pressStart {
    if ([[FlowerController currentFlapix] exerciceInCourse]) {
        NSLog(@"pressStart: stop");
        [[FlowerController currentFlapix] exerciceStop];
    } else if ([[FlowerController currentFlapix] running]){
        NSLog(@"pressStart: start");
        [[FlowerController currentFlapix] exerciceStart];
        
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

// function which executes stuffs when an exercice is starting
- (void)flapixEventExerciceStart:(NSNotification *)notification {
    [ItemsLabel removeFromSuperview];
    [ItemRotationProg removeFromSuperview];
    ItemsDisplayed = false;
    [StartButtonProg setFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    [ItemsButtonProg setFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    if (debug_events_bikerGL) NSLog(@"BIKER flapixEvent  ExerciceStart");
    BikerSpeed = 0.015f;
    frameNO = 0;
    frameNO_clouds = 0;
    NextTree = 0;
    TreeRuptor = true;
    NextTreePosition = 0;
    NextCloud = 0;
    CloudRuptor = true;
    NextCloudPosition = 0;
    
    for (int i = 0; i < 5; i++) {
        TreesPositions[i] = 4.0;
    }
    for (int i = 0; i < 5; i++) {
        CloudsPositions[i] = 4.0;
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
    [ItemsButtonProg setFrame:CGRectMake(self.frame.size.width*0.85, self.frame.size.height/12, self.frame.size.height * 0.073, self.frame.size.height * 0.073)];
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

//function that displays items when the button is hit
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
