//
//  Mailer.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 27.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ResultsApp_Mailer : UIViewController <MFMailComposeViewControllerDelegate> {
    
}

- (IBAction)actionEmailComposer;


+ (int) exericesToCSV:(NSMutableData*)data html:(NSMutableString*)html;

@end
