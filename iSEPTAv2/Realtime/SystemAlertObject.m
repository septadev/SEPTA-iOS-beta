//
//  SystemAlertObject.m
//  iSEPTA
//
//  Created by apessos on 12/26/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "SystemAlertObject.h"

@implementation SystemAlertObject

@synthesize route_id;
@synthesize route_name;

@synthesize current_message;
@synthesize advisory_message;

@synthesize detour_message;
@synthesize detour_start_location;
@synthesize detour_start_date_time;

@synthesize detour_end_date_time;
@synthesize detour_reason;

@synthesize last_updated;


-(NSString*) description
{
    return [NSString stringWithFormat:@"route: %@ (%@) - update: %@ \n current: %@ --- advisory: %@ --- detour: %@ --- startLoc: %@ --- startTime: %@ --- endTime: %@ --- reason: %@", route_id, route_name, last_updated, current_message, advisory_message, detour_message, detour_start_location, detour_start_date_time, detour_end_date_time, detour_reason];
}

@end
