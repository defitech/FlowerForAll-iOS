//
//  Mailer.m
//  FlowerForAll
//
//  Created by Pierre-Mikael Legris (Perki) on 27.09.11.
//  Copyright 2011 fondation Defitech. All rights reserved.
//

#import "ResultsApp_Mailer.h"
#import "DB.h"

@implementation ResultsApp_Mailer


+ (int) xToCSV:(NSMutableData*)data html:(NSMutableString*)html cStatement:(sqlite3_stmt*)cStatement
        typesC:(char*)typesC headersDB:(NSArray*)headersDB headersTitles:(NSArray*)headersTitles {
    int count = 0;
    
    int typeL = strlen(typesC);
    
    if (data != nil) {
        [data appendData:[[headersTitles componentsJoinedByString:@";"] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
        [data appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    }
    
    if (html != nil) {
        [html appendString:@"<table border=\"1\"><tr><th>"];
        [html appendString:[headersTitles componentsJoinedByString:@"</th>\n\t<th>"]] ;
        [html appendString:@"</th></tr>\n"];
    }
    
    
    
    NSDateFormatter* dateAndTimeFormatter = [[NSDateFormatter alloc] init];
    [dateAndTimeFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateAndTimeFormatter setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    
    NSString* value;
    while(sqlite3_step(cStatement) == SQLITE_ROW) {
        count++;
        for (int i = 0; i <  typeL; i++ ) {
            switch (typesC[i]) {
                case 'T': // time
                    value = [DB colTDF:cStatement index:i format:dateAndTimeFormatter];
                    break;
                case 'D': // difference with start_ts
                    value =  [NSString stringWithFormat:@"%i",(int)([DB colD:cStatement index:i] - [DB colD:cStatement index:0])];
                    break;
                case 'P': // percent
                    value = [NSString stringWithFormat:@"%i",(int)([DB colD:cStatement index:i]*100)];
                    break;
                case 'I': // integer
                    value = [NSString stringWithFormat:@"%i",[DB colI:cStatement index:i]];
                    break;
                case 'F': // float
                    value = [NSString stringWithFormat:@"%1.1f",[DB colD:cStatement index:i]];
                    break;
                case 'B': // boolean
                    value = [DB colB:cStatement index:i] ? @"YES" : @"NO";
                    break;
                default: // string (S)
                    value = [DB colS:cStatement index:i];
                    break;
            }
            
            if (data != nil) {
                [data appendData:[value dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
                if (i < (typeL - 1)) {
                    [data appendData:[@"," dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
                } else {
                    [data appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
                }
            }
            
            if (html != nil) {
                if (i == 0 ) {
                    [html appendString:@"\n<tr>"];
                } 
                [html appendFormat:@"\n\t<td>%@</td>",value];
                if (i == (typeL - 1)) {
                    [html appendString:@"\n</tr>"];
                }
            }
        }
        
    }
    
    sqlite3_finalize(cStatement);
    
    if (html != nil) {
        [html appendString:@"\n</table>"];
    }
    
    [dateAndTimeFormatter release];
    headersDB = nil;
    headersTitles = nil;
    return count;
}


// will take dates as parameter * return exercices and an HTML version
+ (int) exercicesToCSV:(NSMutableData*)data html:(NSMutableString*)html fromDate:(NSDate*)from toDate:(NSDate*)to; {
    float dayBeginAbsoluteTime = [from timeIntervalSinceReferenceDate];
    float dayEndAbsoluteTime = [to timeIntervalSinceReferenceDate];
    
    NSArray* headersTitles = [[NSArray alloc] initWithObjects:
                            NSLocalizedStringFromTable(@"Start",@"ResultsApp", @"Data column title"),
                            NSLocalizedStringFromTable(@"Duration (s)",@"ResultsApp", @"Data column title"), 
                            NSLocalizedStringFromTable(@"Done %", @"ResultsApp", @"Data column title"),
                            NSLocalizedStringFromTable(@"Blows", @"ResultsApp", @"Data column title"),  
                            NSLocalizedStringFromTable(@"Good Blows",@"ResultsApp", @"Data column title"),
                            NSLocalizedStringFromTable(@"Average frequency of blows",@"ResultsApp", @"Data column title"),
                            NSLocalizedStringFromTable(@"Profile",  @"ResultsApp", @"Data column title"),
                            NSLocalizedStringFromTable(@"Target Freq. Hz",@"ResultsApp", @"Data column title"),
                            NSLocalizedStringFromTable(@"Freq. Tolerance Hz", @"ResultsApp", @"Data column title"),
                            NSLocalizedStringFromTable(@"Expected blow duration (s)",@"ResultsApp" , @"Data column title"),
                            NSLocalizedStringFromTable(@"Expected exercice duration (s)",@"ResultsApp" , @"Data column title"),
                            nil ];
    
    NSArray* headersDB = [[NSArray alloc] initWithObjects:
                        @"start_ts", @"stop_ts", @"duration_exercice_done_p", 
                        @"blow_count", @"blow_star_count",  @"avg_median_frequency_hz", @"profile_name",  @"frequency_target_hz",
                        @"frequency_tolerance_hz", @"duration_expiration_s", @"duration_exercice_s", nil ];
    char* typesC = "TDPIIFSFFFI";
        
     
    NSString* headersS = [headersDB componentsJoinedByString:@", "];
    sqlite3_stmt *cStatement = [DB genCStatementWF:@"SELECT %@ FROM exercices WHERE start_ts >= '%f' AND start_ts <= '%f' ORDER BY start_ts DESC", 
                                headersS, dayBeginAbsoluteTime, dayEndAbsoluteTime];
    
    return [self xToCSV:data html:html cStatement:cStatement typesC:typesC headersDB:headersDB headersTitles:headersTitles];
}

// will take dates as parameter * return exercices and an HTML version
+ (int) blowsToCSV:(NSMutableData*)data html:(NSMutableString*)html fromDate:(NSDate*)from toDate:(NSDate*)to; {
    float dayBeginAbsoluteTime = [from timeIntervalSinceReferenceDate];
    float dayEndAbsoluteTime = [to timeIntervalSinceReferenceDate];
    
    NSArray* headersTitles = [[NSArray alloc] initWithObjects:
                              NSLocalizedStringFromTable(@"Start",@"ResultsApp", @"Data column title"),
                              NSLocalizedStringFromTable(@"Duration (s)",@"ResultsApp", @"Data column title"), 
                              NSLocalizedStringFromTable(@"In-Range Duration (s)", @"ResultsApp", @"Data column title"),
                              NSLocalizedStringFromTable(@"Goal", @"ResultsApp", @"Data column title"),  
                              NSLocalizedStringFromTable(@"Median Freq. Hz",@"ResultsApp", @"Data column title"),
                              nil ];
    
    NSArray* headersDB = [[NSArray alloc] initWithObjects:
                          @"timestamp", @"duration", @"ir_duration", 
                          @"goal", @"median_frequency_hz", nil ];
    char* typesC = "TFFBF";
    
    NSString* headersS = [headersDB componentsJoinedByString:@", "];
    sqlite3_stmt *cStatement = [DB genCStatementWF:@"SELECT %@ FROM blows WHERE timestamp >= '%f' AND timestamp <= '%f' ORDER BY timestamp DESC", 
                                headersS, dayBeginAbsoluteTime, dayEndAbsoluteTime];
    
    return [self xToCSV:data html:html cStatement:cStatement typesC:typesC headersDB:headersDB headersTitles:headersTitles];
}
 
@end
