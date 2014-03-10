//
//  PryvAccess.h
//  FlowerForAll
//
//  Created by Perki on 10.03.14.
//
//

#import <Foundation/Foundation.h>
#import <PryvApiKit/PryvApiKit.h>
#import "FLAPIExercice.h"

@interface PryvAccess : NSObject

@property (nonatomic,retain) PYConnection* connection;

+(void)reloadFromDB;

+(void)setCurrent:(PYConnection*)connection;

+(void)disconnect;

+(PryvAccess*)current;

-(void)saveExercice:(FLAPIExercice*)e;

-(NSString*)userName;



@end
