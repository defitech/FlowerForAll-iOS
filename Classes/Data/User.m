//
//  User.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 24.08.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "User.h"

#import "UserManager.h"

@implementation User

@synthesize uid,name,password;

- (id)initWithId:(int)_uid
{
    self = [super init];
    if (self) {
        [self setUid:_uid];
        [self setName:[UserManager getUserInfo:_uid key:@"username"]];
        [self setPassword:[UserManager getUserInfo:_uid key:@"password"]];
    }
    
    return self;
}



@end
