//
//  Mailer.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 27.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Mailer.h"

@implementation Mailer

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (IBAction)actionEmailComposer {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Flutter Data"];
        [mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        
        
        
        
        // Create NSData object as PNG image data from camera image
        NSMutableData *data = [[NSMutableData alloc] init];
        
        
        
        // Attach image data to the email
        // 'CameraImage.png' is the file name that will be attached to the email
        [mailViewController addAttachmentData:data mimeType:@"text/csv" fileName:@"FlutterData"];
        
        [self presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
        
    }
    
    else {
        
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //message.text = @"Result: canceled";
            break;
        case MFMailComposeResultSaved:
            //message.text = @"Result: saved";
            break;
        case MFMailComposeResultSent:
            //message.text = @"Result: sent";
            break;
        case MFMailComposeResultFailed:
            //message.text = @"Result: failed";
            break;
        default:
            //message.text = @"Result: not sent";
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    
}

- (void)dealloc {
    
    [super dealloc];
    
}
@end
