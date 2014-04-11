//
//  GTFSFunctions.m
//  iSEPTA
//
//  Created by septa on 4/10/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "GTFSFunctions.h"

@implementation GTFSFunctions

-(NSString*) getDBPath
{
    
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [NSString stringWithFormat:@"%@/SEPTA.sqlite", [paths objectAtIndex:0] ];
    
    bool b = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
    
    if ( !b )  // If the file does not exist
    {
//        dbPath = [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
        dbPath = nil;
        
        // Or uncompress the zip file to get SEPTA.sqlite
    }
    
    return dbPath;

}

//

-(UInt32) getServiceID
{
    
    NSLog(@"filePath: %@", [self getDBPath]);
    FMDatabase *database = [FMDatabase databaseWithPath: [self getDBPath] ];
    
    if ( ![database open] )
    {
        [database close];
        return 0;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
    int weekday = [comps weekday];  // Sunday is 1, Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
    
    int dayOfWeek;
    dayOfWeek = pow(2,(7-weekday) );
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT service_id, days FROM calendarDB WHERE (days & %d)", dayOfWeek];
    
    queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"ITVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"ITVC - query str: %@", queryStr);
        
        return 0;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    NSInteger service_id = 0;
    [results next];
    
    service_id = [results intForColumn:@"service_id"];
    
    return (NSInteger)service_id;
    
    
    return 0;
}


-(UInt32) getServiceIDFor:(NSString*) date
{
    return 0;
}




@end
