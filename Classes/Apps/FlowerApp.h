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

@interface FlowerApp : UIViewController 

/** Used to put a button on the App Menu **/
+(UIImage*)AppIcon;
/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)AppLabel;

@end
