//
//  User.h
//  FlutterApp2
//
//  Created by Dev on 17.01.11.
//  Copyright 2011 Defitech. All rights reserved.
//
//  This class defines fields that mapps whith the column of the database table 'users'.
//  The role of this class is to map with the database table in order to easily fetch data from this table.


#import <Foundation/Foundation.h>


@interface User : NSObject {
	
	//User attributes
	NSInteger userId;
	NSString *name;
	NSString *password;
	
}

//Used to initialize a User object. Simply copies the values passed as parameters to the instance fields
-(id)initWithName:(NSInteger)_userId description:(NSString *)_name url:(NSString *)_password;

//Properties
@property  NSInteger userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *password;



@end
