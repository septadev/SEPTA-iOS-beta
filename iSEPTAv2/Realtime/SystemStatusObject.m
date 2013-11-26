//
//  SystemStatusObject.m
//  iSEPTA
//
//  Created by apessos on 12/26/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "SystemStatusObject.h"

@implementation SystemStatusObject

@synthesize route_id;
@synthesize route_name;

@synthesize isadvisory;
@synthesize isalert;
@synthesize isdetour;
@synthesize issuspend;

@synthesize last_updated;
@synthesize mode;


-(id) init
{
    
    self = [super init];
    if ( self )
    {
        self.isadvisory = @"No";
        self.isalert    = @"N";
        self.isdetour   = @"N";
        self.issuspend  = @"N";
    }
    return self;
    
}

-(NSInteger) numOfAlerts
{
//    return [isalert intValue] + [isadvisory intValue] + [isdetour intValue] + [issuspend intValue];
    return ([isalert    isEqualToString:@"N"]  ? 0 : 1 ) +
           ([isadvisory isEqualToString:@"No"] ? 0 : 1 ) +
           ([isdetour   isEqualToString:@"Y"]  ? 1 : 0 ) +
           ([issuspend  isEqualToString:@"N"]  ? 0 : 1 );
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"Route ID: %@ and Name: %@ - isAdvisory: %@, isAlert: %@, isDetour: %@, isSuspend: %@, mode: %@, updated: %@", route_id, route_name, isadvisory, isalert, isdetour, issuspend, mode, last_updated];
}

@end
