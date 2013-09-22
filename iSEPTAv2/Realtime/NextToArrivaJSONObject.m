//
//  NextToArrivaJSONObject.m
//  iSEPTA
//
//  Created by apessos on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "NextToArrivaJSONObject.h"

@implementation NextToArrivaJSONObject

@synthesize orig_arrival_time;
@synthesize orig_delay;
@synthesize orig_departure_time;
@synthesize orig_line;

@synthesize orig_train;

@synthesize Connection;
@synthesize isdirect;

@synthesize term_arrival_time;
@synthesize term_delay;
@synthesize term_depart_time;
@synthesize term_line;

@synthesize term_train;


-(NSString*) description
{
    return [NSString stringWithFormat:@"\nOrig: arrival_time-%@, orig_delay-%@, orig_departure_time-%@, orig_line-%@, orig_train-%@\nTerm: arrival_time-%@, orig_delay-%@, orig_departure_time-%@, orig_line-%@, orig_train-%@\nConnection: %@, isdirect: %@", orig_arrival_time, orig_delay, orig_departure_time, orig_line, orig_train, term_arrival_time, term_delay, term_depart_time, term_line, term_train, Connection, isdirect];
    
//    return [NSString stringWithFormat:@"Orig: arrival_time-%@, delay-%@, departure_time-%@, line-%@, train-%@, Connection: %@, isdirect: %@", orig_arrival_time, orig_delay, orig_departure_time, orig_line, orig_train, Connection, isdirect];
    
}

@end
