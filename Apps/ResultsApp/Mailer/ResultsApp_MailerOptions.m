//
//  ResultApp_MailerOptions.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris on 21.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultsApp_MailerOptions.h"
#import "DB.h"


@implementation ResultsApp_MailerOptions

@synthesize  datePicker, includeBlowsSwitch, fromStartButton, fromMailButton, includeBlowsLabel, displayTableLabel, displayTableSwitch;

ResultsApp* delegate;
NSDate* mailDate ;


- (id)initWithResultsApp:(ResultsApp*)_delegate
{   
    if (self == nil) {
        self = [super init];
    }
    delegate = _delegate;
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (IBAction)fromStartButtonPressed:(id)sender {
    [datePicker setDate:[datePicker minimumDate] animated:YES];
    [self datePickerValueChange:nil];
}

- (IBAction)fromMailButtonPressed:(id)sender {
    [datePicker setDate:mailDate animated:YES];
    [self datePickerValueChange:nil];
}

- (IBAction)displayTableSwitchValueChange:(id)sender {
    [DB setInfoBOOLForKey:@"hideResultTableInMails" value:![displayTableSwitch isOn]];
}

- (IBAction)includeBlowsSwitchValueChange:(id)sender {
    [DB setInfoBOOLForKey:@"includeBlowsInMails" value:[includeBlowsSwitch isOn]];
}

int selectedExerciceCount;
- (IBAction)datePickerValueChange:(id)sender {
    selectedExerciceCount = [DB exercicesCountBetween:[self selectedStartDate] and:[datePicker maximumDate]];
    [delegate refreshSendButton];
}

- (int)selectedExerciceCount {
    return selectedExerciceCount;
}

- (NSDate*) selectedStartDate {
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:flags fromDate:[datePicker date]];
    
    return [calendar dateFromComponents:components];
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedStringFromTable(@"Send results by e-mail",@"ResultsApp", @"Mail option title");
       
    
       
    [includeBlowsLabel setText:NSLocalizedStringFromTable(@"Include expirations data",@"ResultsApp", @"Include expirations data switch tip")];
    
    
    [displayTableLabel setText:NSLocalizedStringFromTable(@"Display the result table:",@"ResultsApp", @"Display result table switch tip")];
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [displayTableSwitch setOn:![DB getInfoBOOLForKey:@"hideResultTableInMails"]];
    [includeBlowsSwitch setOn:[DB getInfoBOOLForKey:@"includeBlowsInMails"]];
    
    NSDate* startDate = [DB firstExerciceDate];
    NSDate* now = [[[NSDate alloc] init] autorelease];
    mailDate = [DB getInfoNSDateForKey:@"lastResultMail" defaultValue:startDate];
    [mailDate retain];
    
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    
    [fromStartButton setTitle:[NSString stringWithFormat:
                               NSLocalizedStringFromTable(@"First exercise %@",@"ResultsApp", @"Set date to first exercise"), [dateFormatter stringFromDate:startDate]] forState:UIControlStateNormal];
    [fromMailButton setTitle:[NSString stringWithFormat:
                               NSLocalizedStringFromTable(@"Last e-mail %@",@"ResultsApp", @"Set date to last e-mail exercise"), [dateFormatter stringFromDate:mailDate]] forState:UIControlStateNormal];
    
    [dateFormatter release];
    
    [datePicker setMinimumDate:startDate]; 
    [datePicker setMaximumDate:now]; // now
    [datePicker setDate:mailDate animated:YES];
    
    selectedExerciceCount = 0;
    [self datePickerValueChange:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [delegate release];
    self.datePicker = nil;
    self.includeBlowsSwitch = nil;
    self.fromStartButton = nil;
    self.fromMailButton = nil;
    self.includeBlowsLabel = nil;
    self.displayTableLabel = nil;
    self.displayTableSwitch = nil;
    
    [mailDate release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
