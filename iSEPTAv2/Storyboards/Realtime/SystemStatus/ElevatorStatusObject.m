//
//  ElevatorStatusObject.m
//  iSEPTA
//
//  Created by septa on 11/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "ElevatorStatusObject.h"

@implementation ElevatorMetaObject

@synthesize elevators_out;
@synthesize updated;

@end


@implementation ElevatorResultsObject

@synthesize line;
@synthesize station;
@synthesize elevator;
@synthesize message;

@synthesize alternate_url;

@end


@implementation ElevatorStatusObject

-(BOOL) setJSON:(NSData*) data
{
 
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: data options:kNilOptions error:&error];
    
    if ( json == nil )
        return NO;
    
    if ( error != nil )
        return NO;  // Something bad happened, so just return.
    
    NSMutableArray *results = [json objectForKey:@"results"];  // keys: elevators_out, updated
    NSMutableDictionary *meta    = [json objectForKey:@"meta"];     // keys: line, station, elevator, message, alternate_url
    
    self.meta = [[ElevatorMetaObject alloc] init];
    [self.meta setElevators_out: [meta objectForKey:@"elevator_out"] ];
    [self.meta setUpdated: [meta objectForKey:@"updated"] ];
    
    self.results = [[NSMutableArray alloc] initWithCapacity: [self.meta.elevators_out intValue] ];
    
    for (NSMutableDictionary *thisDict in results)
    {
        
        ElevatorResultsObject *erObj = [[ElevatorResultsObject alloc] init];
        
        [erObj setLine    : [thisDict objectForKey:@"line"] ];
        [erObj setStation : [thisDict objectForKey:@"station"] ];
        [erObj setElevator: [thisDict objectForKey:@"elevator"] ];
        [erObj setMessage:  [thisDict objectForKey:@"message"] ];
        
        [erObj setAlternate_url: [thisDict objectForKey:@"alternate_url"] ];
        
        [self.results addObject: erObj];
        
    }
    
    return YES;
    
}

@end
