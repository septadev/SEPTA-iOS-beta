//
//  RouteData.m
//  iSEPTA
//
//  Created by septa on 11/12/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "RouteData.h"

@implementation RouteData
{
    // Private Variables
}

@synthesize route_long_name;

@synthesize route_short_name;
@synthesize route_id;
@synthesize route_type;

@synthesize direction_id;
@synthesize start_stop_id;
@synthesize end_stop_id;

@synthesize start_stop_name;
@synthesize end_stop_name;

//@synthesize end_arrival_time;
//@synthesize start_arrival_time;

@synthesize preference;
@synthesize database_type;
@synthesize added_date;


+(NSArray*) returnAllKeyValues
{
    return [NSArray arrayWithObjects:@"route_short_name", @"route_id", @"route_type", @"direction_id", @"start_stop_id", @"end_stop_id", @"start_stop_name", @"end_stop_name", @"preference", @"database_type", @"added_date", nil];  // Missing are: route_long_name (as Event does not have it)
}

+(NSArray*) returnImportantKeyValues
{
    return [NSArray arrayWithObjects:@"route_short_name", @"route_id", @"route_type", @"direction_id", @"start_stop_id", @"end_stop_id", @"start_stop_name", @"end_stop_name", @"database_type", nil];  // Missing are: route_long_name (as Event doesn't have it), added_date and preference
}

-(void) flipStartEndStops
{
    NSString *tmpStr = start_stop_name;
    start_stop_name = end_stop_name;
    end_stop_name = tmpStr;
    
    NSInteger tmpNum = start_stop_id;
    start_stop_id = end_stop_id;
    end_stop_id = tmpNum;
}

-(id) copyWithZone:(NSZone *)zone
{
    
    id copy = [[[self class] alloc] init];
    
    if ( copy )
    {
        [copy setRoute_short_name: [self.route_short_name copyWithZone:zone] ];
        [copy setRoute_id        : [self.route_id copyWithZone: zone] ];
        
        [copy setDirection_id   : self.direction_id ];
        [copy setStart_stop_id  : self.start_stop_id ];
        [copy setEnd_stop_id    : self.end_stop_id ];
        
        [copy setStart_stop_name: [self.start_stop_name copyWithZone:zone] ];
        [copy setEnd_stop_name  : [self.end_stop_name copyWithZone:zone] ];
    }
    
    return copy;
    
}

-(NSString*) description
{
    return [[self dictionaryWithValuesForKeys: [RouteData returnAllKeyValues] ] description];
}


@end
