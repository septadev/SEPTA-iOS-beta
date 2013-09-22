//
//  StopSequenceCellData.m
//  iSEPTA
//
//  Created by apessos on 3/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "StopSequenceCellData.h"

@implementation StopSequenceCellData

@synthesize firstSequence;
@synthesize lastSequence;

@synthesize startOfTrip;
@synthesize endOfTrip;

-(NSString*) description
{
    return [NSString stringWithFormat:@"first: %d, last: %d with startOfTrip: %d and endOfTrip: %d", [firstSequence intValue], [lastSequence intValue], [startOfTrip intValue], [endOfTrip intValue] ];
}

@end
