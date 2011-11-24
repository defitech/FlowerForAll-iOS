//
//  Month.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Month : NSObject {
    NSString *strDate;
    float min_ts;
    float max_ts;
    int count;
}

@property (readwrite,retain)  NSString *strDate;
@property (readwrite)  float min_ts;
@property (readwrite)  float max_ts;
@property (readwrite)  int count;

- (id) initWithData:(NSString*)str min_ts:(float)mints max_ts:(float)maxts count:(int)c ;

@end
