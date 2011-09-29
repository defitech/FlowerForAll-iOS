//
//  ResultsApp.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 28.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "ResultsApp.h"
#import "ResultsApp_Mailer.h"

@implementation ResultsApp

@synthesize controllerView, toolbar, sendButton;

# pragma mark FlowerApp overriding

/** Used to put in as label on the App Menu (Localized)**/
+(NSString*)appTitle {
    return NSLocalizedStringFromTable(@"Results",@"ResultsApp",@"ResultsApp Title");
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [sendButton setTitle:
      NSLocalizedStringFromTable(@"Send results",@"ResultsApp",@"Button that open the mailer")];
    


    
    statViewController = [[ResultsApp_Nav alloc] init];
    statViewController.view.frame = CGRectMake(0,0,
                                               self.controllerView.frame.size.width,
                                               self.controllerView.frame.size.height);
    [self.controllerView addSubview:statViewController.view];
   

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    controllerView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark mailer stuff


- (IBAction)sendButtonPressed:(id)sender {
    NSLog(@"sendButtonPressed");
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Flutter Data"];
        
        
        NSMutableData *data = [[NSMutableData alloc] init];
        
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendString:
         NSLocalizedStringFromTable(@"<br>....Data enclosed to this mail.\n<br><br>\n", @"ResultsApp", @"Mail introduction")];
        
        [ResultsApp_Mailer exericesToCSV:data html:message];
        [mailViewController setMessageBody:message isHTML:YES];
        
        [mailViewController addAttachmentData:data mimeType:@"text/csv" fileName:@"FlutterData"];
        
        [self presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
        
    }  else {
        
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

@end
