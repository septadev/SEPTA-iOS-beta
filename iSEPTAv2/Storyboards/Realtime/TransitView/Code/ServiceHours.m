//
//  ServiceHours.m
//  iSEPTA
//
//  Created by Administrator on 9/4/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "ServiceHours.h"

@implementation ServiceHours
{
    NSMutableDictionary *_hours;
}

@synthesize route_id;
@synthesize route_short_name;
@synthesize route_type;

@synthesize transitServiceStatus;
@synthesize status = _status;

-(id) init
{
    
    self = [super init];
    if ( self != nil )
    {
        _hours = [[NSMutableDictionary alloc] init];
    }
    return self;
    
}

-(void) addMin:(int) min andMax:(int) max withServiceID:(int) service_id
{
    
    MinMax *mm = [[MinMax alloc] init];
    [mm setMin: [NSNumber numberWithInt: min] ];
    [mm setMax: [NSNumber numberWithInt: max] ];
    
    NSString *serviceID = [NSString stringWithFormat:@"%d", service_id];
    
    NSMutableArray *hoursArr = [_hours objectForKey:serviceID];
    
    // If hoursArr is empty, create it and populate it with mm
    if ( hoursArr == nil )
    {
        hoursArr = [[NSMutableArray alloc] initWithObjects:mm, nil];
        [_hours setObject: hoursArr forKey: serviceID];
    }
    else  // hoursArr is not empty, just add mm to the array
    {
        [hoursArr addObject: mm];
    }
    
    
}

-(NSArray*) hoursForServiceID:(int) service_id
{
    return [_hours objectForKey: [NSString stringWithFormat:@"%d", service_id] ];
}


-(NSString*) statusForTime:(int) time andServiceID: (int) service_id
{
    
    /*
     Possible status messages:
       In Service
       Limited Service
       Resume Service @ X:xx [ap]m
       Weekday Service
       Weekend Service
       Weekday, Sat Service
       Weekday, Sun Service
       Finished Service
     */
    
    /*
     
     Service ID:
       Su | Mo | Tu     We | Th | Fr | Sa
     
       64 - Sunday
       62 - Mo thru Fr
        1 - Saturday
     
     */
    
    int kWeekday = 62;

    int kSunday  = 64;
    int kSaturday = 1;
    
//    int kWeekend = kSaturday + kSunday;
    int kWeekdaySun = kWeekday + kSunday;
    int kWeekdaySat = kWeekday + kSaturday;
    
//    int kAllWeek  = kWeekday + kSunday + kSaturday;
    
    
    int service = 0;
    for (NSString *key in _hours)
    {
        service += [key intValue];
    }
    
    int totalTime = 0;
    int min = 0;
    int max = 0;
    
    BOOL firstTime = YES;
    BOOL found = NO;
    
    for (MinMax *mmObject in [_hours objectForKey: [NSString stringWithFormat:@"%d", service_id] ] )
    {
        

        min = [[mmObject min] intValue];
        
        // --==  Gap Hunting!  ==--
        if ( !firstTime )  // Need to find the gap between MinMax objects, as such, don't execute on the first time in the loop
        {
            
            // As we're gap hunting, max is now the lower value and min is the higher value
            if ( ( max < time ) && ( time < min ) )
            {
                // Current time is between service on this route; we're in a gap!
                return [NSString stringWithFormat:@"Resume Service @%d:%02d", min/100, min%100];
            }
            
        }
        else
        {
            firstTime = NO;
        }
        
        max = [[mmObject max] intValue];
        

        
        
        totalTime += (max - min);
        
        if ( ( min < time ) && ( time < max ) )
        {
            found = YES;
        }
        
    }
    
    
//    TransitServiceStatus tStatus = kTransitServiceOut;
    if ( found )
    {
        transitServiceStatus = [NSNumber numberWithInt:kTransitServiceIn];
        if ( totalTime < 12 )
        {
//            _status = @"Limited Service";
            _status = @"Not In Service";
            return _status;
        }
        else
        {
            _status = @"In Service";
            return _status;
        }

    }
    else  // Not found
    {
        
//        tStatus = kTransitServiceOut;  // Out by default
        transitServiceStatus = [NSNumber numberWithInt: kTransitServiceOut];
        if ( firstTime == NO )  // Hours exist for service_id, but time was not between them
        {
            _status = @"Not In Service";
            return _status;
        }
        else
        {
            _status = @"Not In Service";
            return _status;

            
            NSMutableString *text = [[NSMutableString alloc] init];
            if ( service & kWeekday )
            {
                [text appendString: @"Week"];
                
                if ( service & kSaturday )
                {
                    [text appendString: @",Sat"];
                }
                else if ( service & kSunday )
                {
                    [text appendString: @",Sun"];
                }
                else
                {
                    [text appendString: @"day"];
                }

                [text appendString: @" Service"];
                _status = text;
                return _status;
            }
            
            if ( ( service & kWeekdaySat ) && ( service & kWeekdaySun ) )
            {
                [text appendString: @"Weekend Service"];
            }
            else if ( service & kWeekdaySat )
            {
                [text appendString: @"Saturday Service"];
            }
            else if ( service & kWeekdaySun )
            {
                [text appendString: @"Sunday Service"];
            }
            _status = text;
            return _status;
            
        }
    }
    
    return @"Mistake";
    
}



-(NSString*) description
{
//    return @"What!";
    return [NSString stringWithFormat:@"route_id: %@, hours: %@", route_id, _hours];
}


@end


@implementation MinMax

@synthesize min;
@synthesize max;


-(NSString*) description
{
//    return @"What!";
    return [NSString stringWithFormat:@"min: %d, max: %d", [min intValue], [max intValue] ];
}


@end