//
//  ConnectionManager.m
//  EasyMemory
//
//  Created by Pierre-Mikael Legris (Perki) on 07.07.11.
//  Copyright 2011 SimpleData Sarl. All rights reserved.
//

/**
 <?php
 
 file_put_contents("../logs/log.data","log['".time()."'] = ".var_export($_REQUEST,true).";\n\n",FILE_APPEND);
 
 echo '{"msg": "OK"}';
 exit ;
 
 // look at the structure below if you need to generate alerts
 
 ?>{ "msg": "ALERT",
	"alert" :
	{
		"title": "Want to know more",
		"message" : "Is Flower4All A1 a perfect tool?",
		"options": [
			{"title": "SimpleData.ch",
			 "action" : "open_url", 
			 "url" : "http://simpledata.ch"},
			{"title": "Later",
			 "action" : "background_url" , 
			 "url" : "http://flower.simpledata.ch/ping.php?dummy=0"},
			{"title": "No Thanks",
			 "action" : "dismiss",
			 "url" : ""}
			]
	 }
 }
 */


#import "ConnectionManager.h"
#import "SBJson.h"
#include "OpenUDID.h"


@implementation ConnectionManager

@synthesize webData;


static double lastPing = 0;
static BOOL pinging;
// Am I the pinger?
BOOL pinger = NO;
//
-(void)ping:(NSDictionary*)infos  skipIfLastWasNSecondsAgo:(double)seconds
{
	if (pinging) { NSLog(@"Already Pinging"); return ;};
    if ((lastPing + seconds) > CFAbsoluteTimeGetCurrent()) {
        return ;
    }
    lastPing = CFAbsoluteTimeGetCurrent();
	NSLog(@"Pinging");
	pinger = YES;
	pinging = YES;
	UIDevice *device = [UIDevice currentDevice];
	//NSString *udid = [device uniqueIdentifier]; // removed because of new Apple Policy
    NSString* openUDID = [OpenUDID value];
    
	NSString *sysname = [device systemName];
	NSString *sysver = [device systemVersion];
	NSString *model = [device model];
	NSString *bundleID = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"];
	NSString *bundleV = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
	
	NSLog(@"openID is:%@",openUDID);
	NSLog(@"system name is :%@",sysname);
	NSLog(@"System version is:%@",sysver);
	NSLog(@"System model is:%@",model);
	NSLog(@"Bundle ID:%@",bundleID);
	NSLog(@"Bundle Version:%@",bundleV);
    NSLog(@"System Language:%@",language);
	
	NSString *post = [NSString stringWithFormat:@"BundleID=%@&BundleV=%@&DeviceCode=%@&Firmware=%@&openUDID=%@&language=%@",bundleID,bundleV,model,sysver,openUDID,language];
	
	if (infos != nil)
	for (NSString* key in infos) {
		post = [post stringByAppendingFormat:@"&%@=%@",key,(NSString*)[infos objectForKey:key]];
	}
	
	[self sendPostRequest:@"http://flower.simpledata.ch/ping.php" postString:post];
}

//this is used to post the data to web server database through HTTP POST method
-(void)sendPostRequest:(NSString*)url postString:(NSString*)post
	{	
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]; 
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]]; 
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease]; 
	
	[request setURL:[NSURL URLWithString:url]]; 
	[request setHTTPMethod:@"POST"]; 
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"]; 
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
	[request setHTTPBody:postData];
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (theConnection) {
		webData = [[NSMutableData data] retain];
		NSLog(@"%@",webData);
	}
	else 
	{
		NSLog(@"Connection failed");
	}
	
}





-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{   
	[webData setLength: 0]; 
} 

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{         
	[webData appendData:data]; 
	//NSLog(@"connection didReceiveData %@",webData);
} 

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{     
	NSLog(@"connection didFailWithError %@",[error localizedDescription]);
	[connection release];  
	[webData release]; 
	
} 

// for response from the UIAlert
NSArray *optionList ;

//this is used to fetch the data through JSON .
-(void)connectionDidFinishLoading:(NSURLConnection *)connection 
{      
	NSString *response = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
	NSLog(@"connection response %@",response);
	self.webData = nil;
	
	SBJsonParser *json;
	NSError *jsonError;
	NSDictionary *jsonResults;
	
	// Init JSON
	json = [ [ SBJsonParser new ] autorelease ];
	
	// Get result in a NSDictionary
	jsonResults = [ json objectWithString:response error:&jsonError ];
	
	// Check if there is an error
	if (jsonResults != nil) {
		NSString *msg = [ jsonResults objectForKey:@"msg" ];
		if ((isAlertActive == NO) && [msg isEqualToString:@"ALERT"]) {
			NSDictionary *alert = [ jsonResults objectForKey:@"alert"];
			NSString *title =  [ alert objectForKey:@"title"];
			NSString *message  = [ alert objectForKey:@"message"];
			
			// object - wide 
			NSArray *optionListT = [ alert objectForKey:@"options"];
			optionList = [[NSArray alloc] initWithArray:optionListT]; // keep a copy
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: title
																message: message 
															   delegate: self 
													  cancelButtonTitle: nil 
													  otherButtonTitles: nil];
			
			for (NSDictionary *option in optionListT) {
				
				[alertView addButtonWithTitle:[option objectForKey:@"title"]];
			}
			[alertView show];
			[self retain]; // retain until alertView is proceesed
		}

		isAlertActive = YES;
		
	} else {
		
		NSLog(@"Erreur lors de la lecture du code JSON (%@).", [ jsonError localizedDescription ]);
		
	}
	[response release];           
	[connection release];  
	[webData release]; 
} 


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	
	NSLog(@"alertView %i",buttonIndex);
	if (optionList == nil && ([optionList count] > buttonIndex)) {
		NSLog(@"alertView: optionList is null or invalid");
		
	} else {
		NSDictionary *option =  [optionList objectAtIndex:buttonIndex];
		NSLog(@"B");
		NSString *action = [option objectForKey:@"action"];
		NSLog(@"alertView: action: %@",action);
		if ([@"open_url" isEqualToString:action]) {
			NSString *url = [option objectForKey:@"url"];
				NSLog(@"alertView: url: %@",url);
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
		} else if ([@"background_url" isEqualToString:action]) {
			[self sendPostRequest:[option objectForKey:@"url"] postString:@""];
		}
	}
	
	isAlertActive = NO;
	[alertView release];
	[self release];	 // was retained after alter view is shown
}

- (void) dealloc {
	if (pinger) pinging = NO;
	[super dealloc];
	NSLog(@"Connection Manager is gone");
}


@end
