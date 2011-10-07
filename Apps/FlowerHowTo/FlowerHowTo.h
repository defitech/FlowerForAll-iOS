//
//  FlowerHowTo.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 07.10.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FlowerApp.h"

#import <MediaPlayer/MediaPlayer.h>

@interface FlowerHowTo : FlowerApp <UIWebViewDelegate> {
    IBOutlet UIWebView* webView;
    
    MPMoviePlayerController *player;
}


@end
