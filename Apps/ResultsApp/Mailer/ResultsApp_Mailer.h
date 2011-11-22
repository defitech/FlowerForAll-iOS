//
//  ResultsApp_Mailer.h
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 27.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ResultsApp_Mailer : NSObject

+ (int) exercicesToCSV:(NSMutableData*)data html:(NSMutableString*)html fromDate:(NSDate*)from toDate:(NSDate*)to;

@end
