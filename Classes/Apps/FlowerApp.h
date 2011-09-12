//
//  FlowerApp.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 08.09.11.
//  Copyright 2011 fondation Defitech All rights reserved.
//

//  File Naming convention
//  If you App Name is "MyApp" then all you files should start with "MyApp"
//  Translations 

#import <Foundation/Foundation.h>
#import "FLAPIX.h"

@interface FlowerApp : UIViewController

/** the AppName (code) not displayed to the user **/
+(NSString*)appName;
/** Used to put a button on the App Menu **/
+(UIImage*)appIcon;
/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle;

/** Utility to get translated strings from %lang.lproj%/MyApp.strings**/
+(NSString*)translate:(NSString*)key comment:(NSString*)comment;

/**  
 * A new exerice start  
 * Override this method to catch 
 **/
-(void)flapixEventExerciceStart:(FLAPIExercice *)exercice;
/** 
 * Exerice did finished  
 * Override this method to catch 
 **/
-(void)flapixEventExerciceStop:(FLAPIExercice *)exercice;


/** 
 * Sound level changes. Value is from 0 to 1, this signal is equivalento a vu-meter 
 * Override this method to catch 
 **/
-(void)flapixEventLevel:(float)soundLevel;
/**  
 * return the actual Frequency 
 * Override this method to catch 
 **/
-(void)flapixEventFrequency:(double)ferquency;
/**  
 * A blow started  
 * Override this method to catch 
 **/
-(void)flapixEventBlowStart:(FLAPIBlow *)blow;
/**  
 * A blow finished  
 * Override this method to catch 
 **/
-(void)flapixEventBlowStop:(FLAPIBlow *)blow;

@end
