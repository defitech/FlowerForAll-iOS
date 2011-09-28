//
//  User.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 24.08.11.
//  Copyright 2011 fondation Defitech All rights reserved.
//
// Vehicule for UserDara

#import <Foundation/Foundation.h>

@interface User : NSObject  {
	NSInteger uid;
	NSString* name;
	NSString* password;
}


//Properties
@property NSInteger uid;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* password;

- (id)initWithId:(int)_uid;

@end
