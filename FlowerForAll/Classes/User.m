//
//  User.m
//  FlutterApp2
//
//  Created by Dev on 17.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  Implements the User class


#import "User.h"


@implementation User


@synthesize userId, name, password;


//Used to initialize a User object. Simply copies the values passed as parameters to the instance fields
-(id)initWithName:(NSInteger)_userId description:(NSString *)_name url:(NSString *)_password {
	self.userId = _userId;
	self.name = _name;
	self.password = _password;
	return self;
}


@end
