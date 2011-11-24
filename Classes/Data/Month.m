//
//  Month.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 24.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Month.h"

@implementation Month 

@synthesize  strDate, min_ts, max_ts, count;

- (id) initWithData:(NSString*)str min_ts:(double)mints max_ts:(double)maxts count:(int)c {
    if (self = [super init]) {
        self.strDate = str;
        self.min_ts = mints;
        self.max_ts = maxts;
        self.count = c;
        NSLog(@"Month: %@ %i %f %f",str,c,self.min_ts,self.max_ts);
    }
    return self;
}

-(void) dealloc {
    [self.strDate release];
    self.strDate = nil ;
}

@end
