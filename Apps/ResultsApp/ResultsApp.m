//
//  ResultsApp.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 28.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "ResultsApp.h"
#import "ResultsApp_Mailer.h"
#import "ResultsApp_MailerOptions.h"
#import "UserManager.h"
#import "DB.h"

@implementation ResultsApp

@synthesize controllerView, toolbar, sendButton;

BOOL optionShowing;
ResultsApp_MailerOptions* mailerOptions;

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
    

    optionShowing = NO;
    [self refreshSendButton];
    
    statViewController = [[ResultsApp_Nav alloc] init];
    [statViewController setDelegate:self];
    statViewController.view.frame = CGRectMake(0,0,
                                               self.controllerView.frame.size.width,
                                               self.controllerView.frame.size.height);
    [self.controllerView addSubview:statViewController.view];
    [statViewController viewWillAppear:NO];

}

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
    optionShowing = ([viewController class] == [ResultsApp_MailerOptions class]);
    [self refreshSendButton];
}


- (void)refreshSendButton {
    if (optionShowing) {
        if ([mailerOptions selectedExerciceCount] == 0) {
            [sendButton setEnabled:NO];
            [sendButton setTitle:[NSString stringWithFormat:
                                  NSLocalizedStringFromTable(@"There is no result from this date",@"ResultsApp",@"Button that open the mailer Step - no result"),[mailerOptions selectedExerciceCount]]];
        } else {
            [sendButton setEnabled:YES];
            
            [sendButton setTitle:[NSString stringWithFormat:
                                  NSLocalizedStringFromTable(@"Send the results of %i exercices",@"ResultsApp",@"Button that open the mailer Step2"),[mailerOptions selectedExerciceCount]]];
        }
    } else {
        [sendButton setEnabled:YES];
        [sendButton setTitle:
         NSLocalizedStringFromTable(@"Send results",@"ResultsApp",@"Button that open the mailer")];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    mailerOptions = nil;
    controllerView = nil;
    toolbar = nil;
    statViewController = nil;
    sendButton = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	[statViewController viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark mailer stuff



- (IBAction)sendButtonPressed:(id)sender {
    
    if (! optionShowing) {
        optionShowing = YES;
        if (mailerOptions == nil)
            mailerOptions = [[ResultsApp_MailerOptions alloc] initWithResultsApp:self];
        
        [statViewController pushViewController:mailerOptions animated:YES];
        [self refreshSendButton];
        return;
    }
    
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:[NSString stringWithFormat:
          NSLocalizedStringFromTable(@"Flower-Breath data for %@",@"ResultsApp", @"Mail subject"),[UserManager currentUser].name]];
        
        
        NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
        NSMutableString *HTMLtable = ![DB getInfoBOOLForKey:@"hideResultTableInMails"] ? [[NSMutableString alloc] init] : nil ;
        [ResultsApp_Mailer exercicesToCSV:data html:HTMLtable fromDate:[mailerOptions selectedStartDate] toDate:[[NSDate alloc] init]];
        
               
        NSMutableString *message = [[NSMutableString alloc] init];
        [message appendString:
         NSLocalizedStringFromTable(@"<br>....Data enclosed to this mail.\n<br><br>\n", @"ResultsApp", @"Mail introduction")];
        
        if (HTMLtable != nil) [message appendString:HTMLtable];
        
        [mailViewController setMessageBody:message isHTML:YES];
        [mailViewController addAttachmentData:data mimeType:@"text/csv" 
                                     fileName:[NSString stringWithFormat:@"FlowerExercises %@.csv",[UserManager currentUser].name]];
        
        
        if ([DB getInfoBOOLForKey:@"includeBlowsInMails"]) { // add blows 
            NSMutableData *data2 = [[[NSMutableData alloc] init] autorelease];
            [ResultsApp_Mailer blowsToCSV:data2 html:nil fromDate:[mailerOptions selectedStartDate] toDate:[[NSDate alloc] init]];

            
            [mailViewController addAttachmentData:data2 mimeType:@"text/csv" 
                                     fileName:[NSString stringWithFormat:@"FlowerBlows %@.csv",[UserManager currentUser].name]];
        
            
        }
        
        
        
        
        [self presentModalViewController:mailViewController animated:YES];
        [mailViewController release];
        [HTMLtable release];
       
        
    }  else {
        
    }
    [statViewController popViewControllerAnimated:NO];
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
             [DB setInfoNSDateForKey:@"lastResultMail" value:[[NSDate alloc] init]];
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
