//
//  TripObject.m
//  iSEPTA
//
//  Created by septa on 3/4/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TripObject.h"

@implementation TripObject

@synthesize startTime;
@synthesize startSeq;

@synthesize endTime;
@synthesize endSeq;

@synthesize directionID;
@synthesize serviceID;

@synthesize routeName;

//@synthesize routeStart;
//@synthesize routeEnd;

@synthesize trainNo;

@synthesize tripID;

+(NSArray*) allKeys
{
    // Any reason to not include tripID here?
    return [NSArray arrayWithObjects:@"startTime",@"startSeq",@"endTime",@"endSeq",@"directionID",@"serviceID",@"routeName",@"trainNo", nil];
}

-(NSString*) description
{
    if ( routeName == nil )
        return nil;
    
    return [NSString stringWithFormat:@"TO - train #%4d, route: %@, start/end seq: %d/%d, start/end times: %d/%d, dir: %d, ser: %d, trip: %@", [trainNo intValue], routeName, [startSeq intValue], [endSeq intValue], [startTime intValue], [endTime intValue], [directionID intValue], [serviceID intValue], tripID];
}

-(BOOL) isEqual:(TripObject*)object
{
    
    if ( self == object )
        return YES;
    else if ( !object || ![object isKindOfClass:[self class]] )
        return NO;
    else
    {
        NSDictionary *selfDict = [self dictionaryWithValuesForKeys:[TripObject allKeys] ];
        NSDictionary *otherDict = [object dictionaryWithValuesForKeys:[TripObject allKeys] ];
        
        if ( [selfDict isEqual: otherDict ] )
            return YES;
        else
            return NO;
    }
    
    return NO;
    
}

@end
