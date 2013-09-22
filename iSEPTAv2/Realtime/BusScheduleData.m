//
//  BusScheduleData.m
//  iSEPTA
//
//  Created by septa on 6/27/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "BusScheduleData.h"

@implementation BusScheduleData
{
    
}

@synthesize Route;
@synthesize date;
@synthesize day;

@synthesize DateCalender;
@synthesize Direction;
@synthesize StopName;

@synthesize dateTime;
@synthesize routeType;


+(NSArray*) allKeys
{
    return [NSArray arrayWithObjects:@"Route", @"date", @"day", @"DateCalender", @"Direction", @"StopName",@"dateTime", nil];
}


-(NSString*) description
{
//    NSDictionary *values = [self dictionaryWithValuesForKeys:[BusScheduleData allKeys] ];
    return [NSString stringWithFormat:@"route %@, stop: %@, dateTime: %@", self.Route, self.StopName, self.dateTime];
}


@end
