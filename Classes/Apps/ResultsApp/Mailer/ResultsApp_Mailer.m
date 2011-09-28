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



// will take dates as parameter * return exerices and an HTML version
+ (int) exericesToCSV:(NSMutableData*)data html:(NSMutableString*)html {
    int count = 0;
    float dayBeginAbsoluteTime = 0;
    float dayEndAbsoluteTime = 1000000000000000;
    
    NSArray* headersName = [[NSArray alloc] initWithObjects:
                            @"Start", @"Duration (s)", @"Done %", 
                            @"Blows",   @"Good Blows",@"Profile",  @"Target Freq. Hz",
                            @"Freq. Tolerance Hz", @"Expected blow duration (s)", @"Expected exercice duration (s)", nil ];
    
    NSMutableArray* headersTitles = [[NSMutableArray alloc] init];
    for (int i = 0; i <  [headersName count]; i++ ) {
        [headersTitles addObject:NSLocalizedStringFromTable([headersName objectAtIndex:i], @"ResultsApp", @"For data columns title")];
    }
    
    NSArray* headersDB = [[NSArray alloc] initWithObjects:
                        @"start_ts", @"stop_ts", @"duration_exercice_done_p", 
                        @"blow_count",   @"blow_star_count",@"profile_name",  @"frequency_target_hz",
                        @"frequency_tolerance_hz", @"duration_expiration_s", @"duration_exercice_s", nil ];
    char* typesC = "TDPIISFFFI";
    int typeL = strlen(typesC);
    
    if (data != nil) {
        [data appendData:[[headersTitles componentsJoinedByString:@","] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
        [data appendData:[@"\n" dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    }
    
    if (html != nil) {
        [html appendString:@"<table border=\"1\"><tr><th>"];
        [html appendString:[headersTitles componentsJoinedByString:@"</th>\n\t<th>"]] ;
        [html appendString:@"</th></tr>\n"];
    }
    
    NSString* headersS = [headersDB componentsJoinedByString:@", "];
    sqlite3_stmt *cStatement = [DB genCStatementWF:@"SELECT %@ FROM exercices WHERE start_ts >= '%f' AND start_ts <= '%f' ORDER BY start_ts DESC", 
                                headersS, dayBeginAbsoluteTime, dayEndAbsoluteTime];
    
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
                default: // string (S)
                    value = [DB colS:cStatement index:i];
                    break;
            }
            
            if (data != nil) {
                [data appendData:[value dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
                if (i < typeL) {
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
                if (i == typeL) {
                    [html appendString:@"\n</tr>"];
                }
            }
        }
        
    }
    
    if (html != nil) {
        [html appendString:@"\n</table>"];
    }
    
    [dateAndTimeFormatter release];
    //NSLog(html);
    return count;
}


@end
