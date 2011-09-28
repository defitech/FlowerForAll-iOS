//
//  subsys_ios_AVAudioSessionDelegate.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 06.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "subsys_ios_AVAudioSessionDelegate.h"

@implementation subsys_ios_AVAudioSessionDelegate

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)beginInterruption {
    NSLog(@"subsys_ios_AVAudioSessionDelegate beginInterruption");
}

- (void)endInterruption {
    NSLog(@"subsys_ios_AVAudioSessionDelegate endInterruption");
}

- (void)endInterruptionWithFlags:(NSUInteger)flags {
    NSLog(@"subsys_ios_AVAudioSessionDelegate endInterruptionWF:%i",flags);
}


- (void)inputIsAvailableChanged:(BOOL)isInputAvailable {
    NSLog(@"subsys_ios_AVAudioSessionDelegate isInputAvailable:%i",isInputAvailable);
}

@end
