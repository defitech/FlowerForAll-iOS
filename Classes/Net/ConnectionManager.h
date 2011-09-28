//
//  ConnectionManager.h
//  EasyMemory
//
//  Created by Pierre-Mikael Legris (Perki) on 07.07.11.
//  Copyright 2011 SimpleData Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ConnectionManager : NSObject <UIAlertViewDelegate> {
	NSMutableData *webData;
	BOOL isAlertActive;
}


@property (nonatomic, retain) NSMutableData *webData;

//ping easymemory server
-(void)ping:(NSDictionary*)infos;

//this is used to post the data to web server database through HTTP POST method
-(void)sendPostRequest:(NSString*)url postString:(NSString*)post;

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response ;

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data ;
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error ;

//this is used to fetch the data through JSON .
-(void)connectionDidFinishLoading:(NSURLConnection *)connection ;


@end
