//
//  NTASaveObject.m
//  iSEPTA
//
//  Created by apessos on 12/21/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "NTASaveObject.h"

@implementation NTASaveObject

@synthesize startStopName;
@synthesize endStopName;

@synthesize addedDate;

+(NSArray*) returnAllKeys
{
    return [NSArray arrayWithObjects:@"startStopName", @"endStopName", @"addedDate", nil];
}

+(NSArray*) returnImportantKeys
{
    return [NSArray arrayWithObjects:@"startStopName", @"endStopName", nil];
}


-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:startStopName forKey:@"startStopName"];
    [aCoder encodeObject:endStopName   forKey:@"endStopName"];
    
    [aCoder encodeObject:addedDate     forKey:@"addedDate"];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    NSString *startName = [aDecoder decodeObjectForKey:@"startStopName"];
    NSString *endName   = [aDecoder decodeObjectForKey:@"endStopName"  ];
    
    NSDate  *date      = [aDecoder decodeObjectForKey:@"addedDate"];
    
    return [self initWithStartName:startName andEndName:endName andAddedDate:date];
}

-(id) initWithStartName: (NSString*) startName andEndName:(NSString*) endName andAddedDate:(NSDate*) date
{
    
    if ( ( self = [super init] ) )
    {
        self.startStopName = startName;
        self.endStopName   = endName;
        
        self.addedDate = date;
    }
    
    return self;
    
}


-(NSString*) description
{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"HH:mm:ss, yyyy-MM-dd"];
    NSString *date = [formatter stringFromDate: addedDate];
    return [NSString stringWithFormat:@"start: %@, end: %@, added: %@", startStopName, endStopName, date];
    
}

@end
