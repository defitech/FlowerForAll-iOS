//
//  BlowHistory.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 31.08.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BlowHistoryDelegate <NSObject>
//-(void) historyChange:(id*) history;
@end

@interface BlowHistory : NSObject {
    /** duration of the history in secondes **/
    int duration_s;
    /** the history Array **/
    NSMutableArray* history;
    
    id<BlowHistoryDelegate> delegate;
    
}

- (id)initWithDuration:(int)duration_m delegate:(id)blowHistoryDelegate;

/** 
 * change the duration of the history (in minutes) 
 * @return TRUE in case of success
 **/
-(BOOL) setDuration:(int)duration_m;

/** fill the history with the value in the db matching the interval **/
-(void) reloadFromDB ;

/** get the actual history array **/
-(NSMutableArray*) getHistoryArray;

/** called by the NSNotificationCenter **/
-(void) flapixEventEndBlow:(id)flapix_id;

/** will return a min of 1second if empty or lower than 6Hz **/
-(double) longestDuration ;

@end


