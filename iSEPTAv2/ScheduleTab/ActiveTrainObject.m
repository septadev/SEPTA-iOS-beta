//
//  ActiveTrainObject.m
//  iSEPTA
//
//  Created by septa on 3/14/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "ActiveTrainObject.h"

@implementation ActiveTrainObject

@synthesize  trainNo;
@synthesize  trainDelay;

@synthesize nextStop;
@synthesize serviceType;

@synthesize destination;
@synthesize source;

// These properties should mimics those in TripObject so it can be filtered the same way
@synthesize startTime;

@synthesize serviceID;
@synthesize directionID;

@synthesize tripID;

-(NSString*) description
{
    return [NSString stringWithFormat:@"ATO - train #%4d, delay: %d, nextStop: %@, serviceType: %@, start time: %@, dir: %d, ser: %d", [trainNo intValue], [trainDelay intValue], nextStop, serviceType, startTime, [directionID intValue], [serviceID intValue] ];
}

@end
