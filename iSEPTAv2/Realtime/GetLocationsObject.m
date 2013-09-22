//
//  GetLocationsObject.m
//  iSEPTA
//
//  Created by septa on 1/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "GetLocationsObject.h"

@implementation LocationData

@synthesize location_name;
@synthesize location_id;
@synthesize loc_name;
@synthesize status;

@synthesize city;
@synthesize state;
@synthesize zip;

@synthesize hours;
@synthesize phone;

@synthesize address1;
@synthesize address2;

@synthesize startDate;
@synthesize endDate;

+(NSArray*) allKeys
{
    return [NSArray arrayWithObjects:@"location_name", @"location_id", @"loc_name", @"status", @"city", @"state", @"zip", @"hours", @"phone", @"address1", @"address2", @"startDate", @"endDate", nil];
}

-(NSString*) description
{
    
    NSDictionary *values = [self dictionaryWithValuesForKeys:[LocationData allKeys] ];
    return [NSString stringWithFormat:@"%@", values];
}

@end



@implementation GetLocationsObject

@synthesize location_data;
@synthesize location_id;
@synthesize location_lat;
@synthesize location_lon;

@synthesize location_name;
@synthesize location_type;

@synthesize distance;

@synthesize routeStr;


-(id) init
{
    
    if ( ( self = [super init] ) )
    {
        location_data = [[LocationData alloc] init];
    }
    
    return self;
    
}

+(NSArray*) allKeys
{
    return [NSArray arrayWithObjects:@"location_id", @"location_lat", @"location_lon", @"location_name", @"location_type", @"location_data", @"routeStr", nil];
}


-(NSString*) description
{
    NSDictionary *values = [self dictionaryWithValuesForKeys:[GetLocationsObject allKeys] ];
    return [NSString stringWithFormat:@"%@", values];
}



@end
