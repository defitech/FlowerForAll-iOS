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
    double min_ts;
    double max_ts;
    int count;
}

@property (readwrite,retain)  NSString *strDate;
@property (readwrite)  double min_ts;
@property (readwrite)  double max_ts;
@property (readwrite)  int count;

- (id) initWithData:(NSString*)str min_ts:(double)mints max_ts:(double)maxts count:(int)c ;

@end
