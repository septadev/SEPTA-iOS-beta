//
//  RouteInfo.m
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "RouteInfo.h"

@implementation RouteInfo

@synthesize route_id;
@synthesize route_long_name;
@synthesize route_short_name;
@synthesize route_type;

@synthesize direction0;
@synthesize direction1;

//@synthesize route_service_hours;


// 08:00 - 10:00 and 4:00 to 6:00 service?

-(void) setCardinalDirection: (NSString*) direction withID: (int) directionID forHoursMin: (NSString *) min andMax: (NSString*) max
{
    
    DirectionInfo *newDir = [[DirectionInfo alloc] init];
    
    [newDir setCardinalDirection:direction];
    [newDir setDirectionID:[NSNumber numberWithInt:directionID] ];
    
    [newDir setMinHours:min];
    [newDir setMaxHours:max];
    
    switch (directionID)
    {
        case 0:
            ;
            if ( direction0 == nil )
            {
                direction0 = [[NSMutableArray alloc] init];
            }
//            [self setDirection0: newDir];
            [direction0 addObject: newDir];
            break;
        case 1:
            ;
            if ( direction1 == nil )
            {
                direction1 = [[NSMutableArray alloc] init];
            }
            [direction1 addObject: newDir];
//            [self setDirection1: newDir];
            break;
        default:
            return;  // Do nothing
            break;
    }
    
}


-(BOOL) inService
{

    // Determine today's service ID
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
//    int weekday = [comps weekday];  // Sunday is 1, Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
//    
//    
//    int currentServiceID = pow(2,(7-weekday));
    
    
    
    return NO;  // Thanks and come again!
}



-(BOOL) inServiceForDirectionID: (int) directionID
{
    
    NSDate *now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HHmm"];
    
//    NSString *timeString = [outputFormatter stringFromDate:now];
    int currentTime = [[outputFormatter stringFromDate:now] intValue];
//    NSLog(@"newDateString %@", newDateString);
    
    
    // Check if now is between direction0.minHours and direction1.maxHours
    // What about direction1?
    // What about routes with multiple start and stops?  Runs only mornings and evenings?
    
    NSMutableArray *array;
    if ( directionID == 0 )
    {
        if ( direction0 == nil )
            return NO;
        array = direction0;
    }
    else
    {
        if ( direction1 == nil )
            return NO;
        array = direction1;
    }

    

    

    for (DirectionInfo *dir in array)
    {
//        NSLog(@"dir: %@", dir);
 
        int start = [[dir.minHours stringByReplacingOccurrencesOfString:@":" withString:@""] intValue];
        int end   = [[dir.maxHours stringByReplacingOccurrencesOfString:@":" withString:@""] intValue];
        
        if ( ( start < currentTime ) && ( currentTime < end ) )
        {
            return YES;
        }
        
    }
    
    return NO;
    
}


-(NSString*) description
{
    return [NSString stringWithFormat:@"Route: %@ (%d), dir0: %@, dir1: %@", route_short_name, [route_id intValue], direction0, direction1];
}

@end


@implementation DirectionInfo

@synthesize cardinalDirection;
@synthesize directionID;
@synthesize maxHours;
@synthesize minHours;

-(NSString *) description
{
    return [NSString stringWithFormat:@"%@ (%d) %@ - %@", cardinalDirection, [directionID intValue], minHours, maxHours];
}

@end