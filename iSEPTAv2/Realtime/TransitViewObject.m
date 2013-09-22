//
//  TransitViewObject.m
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "TransitViewObject.h"

@implementation TransitViewObject

@synthesize lat;
@synthesize lng;

@synthesize label;
@synthesize VehicleID;

@synthesize BlockID;
@synthesize Direction;

@synthesize destination;
@synthesize Offset;

@synthesize distance;

-(NSString*) description
{
    return [NSString stringWithFormat:@"Vehicle ID: %@, Block ID: %@, dir: %@, dest: %@, lat/lng: (%@,%@), dist: %6.3f, offset: %@", VehicleID, BlockID, Direction, destination, lat, lng, [distance floatValue], Offset];
}

@end
