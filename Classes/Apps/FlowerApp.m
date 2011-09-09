//
//  MyClass.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 09.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerApp.h"

@implementation FlowerApp

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

/** MyName **/
+(NSString*) myName {
    return NSStringFromClass([self class]);
}

/** Used to put a button on the App Menu **/
+(UIImage*)AppIcon {
    NSString* iconName = [NSString stringWithFormat:@"%@-Icon.png",[self myName]];
    return [[[UIImage alloc] initWithContentsOfFile:iconName ] autorelease];
}

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)AppLabel {
    return [self myName];
}


@end
