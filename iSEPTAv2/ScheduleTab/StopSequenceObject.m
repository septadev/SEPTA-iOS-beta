//
//  StopSequenceObject.m
//  iSEPTA
//
//  Created by apessos on 3/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "StopSequenceObject.h"

@implementation StopSequenceObject

@synthesize stopID;
@synthesize stopName;
@synthesize stopSequence;

@synthesize stopLon;
@synthesize stopLat;

@synthesize arrivalTime;


+(NSArray*) allKeys
{
    return [NSArray arrayWithObjects:@"stopID", @"stopName", @"stopSequence", @"arrivalTime", nil];
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"%d) %@ (%d) at %@", [stopSequence intValue], stopName, [stopID intValue], arrivalTime ];
}

@end
