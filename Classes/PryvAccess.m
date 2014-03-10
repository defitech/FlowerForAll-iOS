//
//  PryvAccess.m
//  FlowerForAll
//
//  Created by Perki on 10.03.14.
//
//

#import "PryvAccess.h"
#import "DB.h"
#import <PryvApiKit/PYConnection.h>

@implementation PryvAccess

static PryvAccess* currentPYAccess = nil;

+(void)reloadFromDB {
    NSString* userID = [DB getInfoValueForKey:@"pryvUsername"];
    NSString* accessToken = [DB getInfoValueForKey:@"pryvToken"];
    if (userID) {
        [PryvAccess setCurrent:[[[PYConnection alloc] initWithUsername:userID andAccessToken:accessToken] autorelease]];
    }
}



+(void)setCurrent:(PYConnection*)connection {
    if (currentPYAccess) {
        [PryvAccess disconnect];
    }
    currentPYAccess = [[PryvAccess alloc] init];
    [DB setInfoValueForKey:@"pryvUsername" value:connection.userID];
    [DB setInfoValueForKey:@"pryvToken" value:connection.accessToken];
    [currentPYAccess setConnection:connection];
}

+(void)disconnect {
    if (currentPYAccess) {
        [currentPYAccess release];
        currentPYAccess = nil;
    }
}

+(PryvAccess*)current {
    return currentPYAccess;
}

-(void)saveExercice:(FLAPIExercice*)exercice {
    PYEvent *event = [[PYEvent alloc] init];
    event.streamId = @"flowerBreath";
    [event setEventDate:[NSDate dateWithTimeIntervalSinceReferenceDate:exercice.start_ts]];
    [event setDuration:exercice.duration_exercice_s];
    event.eventContent = [NSNumber numberWithInt:exercice.blow_star_count];
    event.type = @"count/generic";
    [self.connection createEvent:event requestType:PYRequestTypeAsync successHandler:nil errorHandler:nil];
    [event autorelease];
}


-(NSString*)userName {
    return [self.connection userID];
}

-(void)dealloc {
    [_connection release];
    [super dealloc];
}

@end
