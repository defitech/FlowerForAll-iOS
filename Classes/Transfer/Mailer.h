//
//  Mailer.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 27.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface Mailer : UIViewController <MFMailComposeViewControllerDelegate> {
    
}

- (IBAction)actionEmailComposer;

@end
