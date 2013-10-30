//
//  TripData.m
//  iSEPTA
//
//  Created by septa on 11/15/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "TripData.h"

@implementation TripData
{
    
}

@synthesize vanity_start_stop_name;

@synthesize start_arrival_time;
@synthesize end_arrival_time;

@synthesize start_stop_name;
@synthesize end_stop_name;

@synthesize start_stop_id;
@synthesize end_stop_id;

@synthesize start_stop_sequence;
@synthesize end_stop_sequence;

@synthesize train_no;
@synthesize trip_id;
@synthesize direction_id;

-(void) switchStartEnd
{
    
//    NSString *tempStr;
//    NSNumber *tempNum;
    
    NSArray *startStringKeys = [NSArray arrayWithObjects: @"start_arrival_time", @"start_stop_name", @"start_stop_id", @"start_stop_sequence", nil];
    NSArray *endStringKeys   = [NSArray arrayWithObjects: @"end_arrival_time"  , @"end_stop_name"  , @"end_stop_id"  , @"end_stop_sequence"  , nil];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjects:startStringKeys forKeys:endStringKeys];
    
    NSEnumerator *e = [dict keyEnumerator];
    id dictEnd;
    id temp;
    NSString *dictStart;
    
    while ( dictEnd = [e nextObject])
    {
        dictStart = [dict objectForKey: dictEnd];
        
//        if ( [ [self valueForKey: dictStart] isKindOfClass:[NSString class] ] )
//            temp = tempStr;
//        else if ( [dictStart isKindOfClass:[NSNumber class] ] )
//            temp = tempNum;
        
        temp = [self valueForKey: dictEnd];
        [self setValue: [self valueForKey:dictStart] forKey:dictEnd];
        [self setValue: temp forKey: dictStart];
    }
    
    
    return;
    
}

-(id) copyWithZone:(NSZone *)zone
{
    
    id copy = [[[self class] alloc] init];
    
    if ( copy )
    {
        [copy setStart_arrival_time: [self.start_arrival_time copyWithZone:zone] ];
        [copy setEnd_arrival_time  : [self.end_arrival_time   copyWithZone:zone] ];
        
        [copy setDirection_id   : [self.direction_id copyWithZone:zone] ];
        [copy setStart_stop_id  : [self.start_stop_id copyWithZone:zone] ];
        [copy setEnd_stop_id    : [self.end_stop_id copyWithZone:zone] ];

        
        [copy setStart_stop_name: [self.start_stop_name copyWithZone:zone] ];
        [copy setEnd_stop_name  : [self.end_stop_name copyWithZone:zone] ];
        
        [copy setStart_stop_sequence  : [self.start_stop_sequence copyWithZone:zone] ];
        [copy setEnd_stop_sequence    : [self.end_stop_sequence copyWithZone:zone] ];
        
        [copy setTrip_id        : [self.trip_id copyWithZone:zone] ];
        [copy setTrain_no       : [self.train_no copyWithZone:zone] ];
    }
    
    return copy;
    
}

+(NSArray*) returnKeyValues
{
    return [NSArray arrayWithObjects:@"start_stop_name", @"end_stop_name", @"start_arrival_time", @"end_arrival_time", @"start_stop_id", @"end_stop_id", @"trip_id", @"train_no", @"direction_id", @"start_stop_sequence", @"end_stop_sequence", nil];
}

-(NSString*) description
{
    return [[self dictionaryWithValuesForKeys: [TripData returnKeyValues] ] description];
}

@end
