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


//-(int) getMinWithServiceID:(int) service_id
//{
//    NSString *serviceID = [NSString stringWithFormat:@"%d", service_id];
//    NSMutableArray *hourArr = [_hours objectForKey:serviceID];
//    
//    return 0;
//}
//
//-(int) getMaxWithServiceID:(int) service_id
//{
//
//    NSString *serviceID = [NSString stringWithFormat:@"%d", service_id];
//    NSMutableArray *hourArr = [_hours objectForKey:serviceID];
//
//    
//    return 0;
//}


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


-(NSString*) statusForTime:(int) time andServiceIDs: (NSArray*) sids
{

//    NSArray* hourKeys = [_hours allKeys];

    NSMutableSet *rteHoursSet = [NSMutableSet setWithArray:[_hours allKeys]];
    NSMutableSet *serviceSet  = [NSMutableSet setWithArray:sids];
    
    [rteHoursSet intersectSet:serviceSet];
    
    if ( [[rteHoursSet allObjects] count] > 0)
    {
        NSString *key = [[rteHoursSet allObjects] objectAtIndex:0];
        MinMax *mmToday = [ [_hours objectForKey: key] objectAtIndex:0];
        
        if ( mmToday == nil )
        {
            transitServiceStatus = [NSNumber numberWithInt:kTransitServiceOut];
            _status = @"Not In Service";
            return _status;
        }
        else // if ( mmToday == nil )
        {
            
            //        NSArray *sidToday = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetToday];
            //        NSArray *sidYest = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetYesterday];
            
            NSString *sidToday = [GTFSCommon getServiceIDStrFor:kGTFSRouteTypeBus withOffset:kGTFSCalendarOffsetToday];
            NSString *sidYest  = [GTFSCommon getServiceIDStrFor:kGTFSRouteTypeBus withOffset:kGTFSCalendarOffsetYesterday];
            
            int x, y, yPrime;
            
            x = [[mmToday min] intValue];
            y = [[mmToday max] intValue];
            
            if ( [sidToday isEqualToString: sidYest] )
            {
                
                // If the service IDs for today and yesterday match, then letting:
                //   x be today's min, y be today's max and a time being the current time,
                //   The route is in service if the following is true:
                //      ( (x < a) && (a < y) ) || ( (a + 2400) < y )
                
                // If the service IDs for today and yesterday do not match, then letting:
                //   x be today's min, y be today's max, a time being the current time and y' be yesterday's max
                //   The route is in service if the following is true:
                //      ( (x < a) && (a < y) ) || ( (a + 2400) < y' )
                
                
                yPrime = y;
                
            }
            else  // if ( [sidToday isEqualToString: sidYest] )
            {
                
                NSArray *yestArr = [GTFSCommon getServiceIDFor:kGTFSRouteTypeBus withOffset:kGTFSCalendarOffsetYesterday];
                if ( yestArr != nil )
                {
                    int yest_service_id = [(NSNumber*)[yestArr objectAtIndex:0] intValue];
                    MinMax *mmYest = [[_hours objectForKey: [NSString stringWithFormat:@"%d", yest_service_id] ] objectAtIndex:0];
                    
                    if ( mmYest == nil )
                    {
                        // Then this route didn't offer service yesterday
                        yPrime = 0;  // Set yPrime to 0
                    }
                    else
                    {
                        yPrime = [[mmYest max] intValue];
                    }
                    
                }  // if ( yestArr != nil )
                
            }  // if ( [sidToday isEqualToString: sidYest] )
            
            
            if ( ( (x <= time) && (time < y) ) || ( (time + 2400) < yPrime ) )
            {
                transitServiceStatus = [NSNumber numberWithInt:kTransitServiceIn];
                _status = @"In Service";
                return _status;
            }
            else
            {
                transitServiceStatus = [NSNumber numberWithInt:kTransitServiceOut];
                _status = @"Not In Service";
                return _status;
            }
            
            
        }  // if ( mmToday == nil )

        
    }
    else  // No service_ids in sids were found in rteHoursSet
    {
        transitServiceStatus = [NSNumber numberWithInt:kTransitServiceOut];
        _status = @"Not In Service";
        return _status;
    }

    
    
//    @try
//    {
//
//        // sids is an array, _hours is an array for service_ids for a route.
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",]
//        
//        MinMax *mmToday = [[_hours objectForKey: [NSString stringWithFormat:@"%d", service_id] ] objectAtIndex:0];
//        
//        if ( mmToday == nil )
//        {
//            // No service today!
//            transitServiceStatus = [NSNumber numberWithInt:kTransitServiceOut];
//            _status = @"Not In Service";
//            return _status;
//        }
//        else
//        {
//            
//            //        NSArray *sidToday = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetToday];
//            //        NSArray *sidYest = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetYesterday];
//            
//            NSString *sidToday = [GTFSCommon getServiceIDStrFor:kGTFSRouteTypeBus withOffset:kGTFSCalendarOffsetToday];
//            NSString *sidYest  = [GTFSCommon getServiceIDStrFor:kGTFSRouteTypeBus withOffset:kGTFSCalendarOffsetYesterday];
//            
//            int x, y, yPrime;
//            
//            x = [[mmToday min] intValue];
//            y = [[mmToday max] intValue];
//            
//            if ( [sidToday isEqualToString: sidYest] )
//            {
//                
//                // If the service IDs for today and yesterday match, then letting:
//                //   x be today's min, y be today's max and a time being the current time,
//                //   The route is in service if the following is true:
//                //      ( (x < a) && (a < y) ) || ( (a + 2400) < y )
//                
//                // If the service IDs for today and yesterday do not match, then letting:
//                //   x be today's min, y be today's max, a time being the current time and y' be yesterday's max
//                //   The route is in service if the following is true:
//                //      ( (x < a) && (a < y) ) || ( (a + 2400) < y' )
//                
//                
//                yPrime = y;
//                
//            }
//            else
//            {
//                
//                NSArray *yestArr = [GTFSCommon getServiceIDFor:kGTFSRouteTypeBus withOffset:kGTFSCalendarOffsetYesterday];
//                if ( yestArr != nil )
//                {
//                    int yest_service_id = [(NSNumber*)[yestArr objectAtIndex:0] intValue];
//                    MinMax *mmYest = [[_hours objectForKey: [NSString stringWithFormat:@"%d", yest_service_id] ] objectAtIndex:0];
//                    
//                    if ( mmYest == nil )
//                    {
//                        // Then this route didn't offer service yesterday
//                        yPrime = 0;  // Set yPrime to 0
//                    }
//                    else
//                    {
//                        yPrime = [[mmYest max] intValue];
//                    }
//                    
//                    
//                }
//                
//            }
//            
//            
//            if ( ( (x <= time) && (time < y) ) || ( (time + 2400) < yPrime ) )
//            {
//                transitServiceStatus = [NSNumber numberWithInt:kTransitServiceIn];
//                _status = @"In Service";
//                return _status;
//            }
//            else
//            {
//                transitServiceStatus = [NSNumber numberWithInt:kTransitServiceOut];
//                _status = @"Not In Service";
//                return _status;
//            }
//            
//            
//        }
//        
//        
//    }
//    @catch (NSException *exception)
//    {
//        NSLog(@"Exception thrown");
//    }
//    @finally
//    {
//        // <#Code that gets executed whether or not an exception is thrown#
//    }
//    
//    return @"N/A";
//    
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
    
//    int kWeekday = 62;
//
//    int kSunday  = 64;
//    int kSaturday = 1;
    
//    int kWeekend = kSaturday + kSunday;
//    int kWeekdaySun = kWeekday + kSunday;
//    int kWeekdaySat = kWeekday + kSaturday;
    
//    int kAllWeek  = kWeekday + kSunday + kSaturday;
    
    
//    int service = 0;
//    for (NSString *key in _hours)
//    {
//        service += [key intValue];
//    }
    
//    int totalTime = 0;
//    int min = 0;
//    int max = 0;
//    
//    BOOL firstTime = YES;
//    BOOL found = NO;
    
    
    // Does the current service_id exist in _hours
//    time = 100;
//    service_id = 3;
    
    @try
    {
    
        MinMax *mmToday = [[_hours objectForKey: [NSString stringWithFormat:@"%d", service_id] ] objectAtIndex:0];
        
        if ( mmToday == nil )
        {
            // No service today!
            transitServiceStatus = [NSNumber numberWithInt:kTransitServiceOut];
            _status = @"Not In Service";
            return _status;
        }
        else
        {
            
    //        NSArray *sidToday = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetToday];
    //        NSArray *sidYest = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetYesterday];
            
            NSString *sidToday = [GTFSCommon getServiceIDStrFor:kGTFSRouteTypeBus withOffset:kGTFSCalendarOffsetToday];
            NSString *sidYest  = [GTFSCommon getServiceIDStrFor:kGTFSRouteTypeBus withOffset:kGTFSCalendarOffsetYesterday];
            
            int x, y, yPrime;

            x = [[mmToday min] intValue];
            y = [[mmToday max] intValue];
            
            if ( [sidToday isEqualToString: sidYest] )
            {
                
                // If the service IDs for today and yesterday match, then letting:
                //   x be today's min, y be today's max and a time being the current time,
                //   The route is in service if the following is true:
                //      ( (x < a) && (a < y) ) || ( (a + 2400) < y )
                
                // If the service IDs for today and yesterday do not match, then letting:
                //   x be today's min, y be today's max, a time being the current time and y' be yesterday's max
                //   The route is in service if the following is true:
                //      ( (x < a) && (a < y) ) || ( (a + 2400) < y' )
                

                yPrime = y;
                
            }
            else
            {
                
                    NSArray *yestArr = [GTFSCommon getServiceIDFor:kGTFSRouteTypeBus withOffset:kGTFSCalendarOffsetYesterday];
                    if ( yestArr != nil )
                    {
                        int yest_service_id = [(NSNumber*)[yestArr objectAtIndex:0] intValue];
                        MinMax *mmYest = [[_hours objectForKey: [NSString stringWithFormat:@"%d", yest_service_id] ] objectAtIndex:0];
                        
                        if ( mmYest == nil )
                        {
                            // Then this route didn't offer service yesterday
                            yPrime = 0;  // Set yPrime to 0
                        }
                        else
                        {
                            yPrime = [[mmYest max] intValue];
                        }
                        
                        
                    }
                
            }
            
            
            if ( ( (x <= time) && (time < y) ) || ( (time + 2400) < yPrime ) )
            {
                transitServiceStatus = [NSNumber numberWithInt:kTransitServiceIn];
                _status = @"In Service";
                return _status;
            }
            else
            {
                transitServiceStatus = [NSNumber numberWithInt:kTransitServiceOut];
                _status = @"Not In Service";
                return _status;
            }
            
            
        }
    
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception thrown");
    }
    @finally
    {
        // <#Code that gets executed whether or not an exception is thrown#
    }
    
    return @"N/A";
    
    
//    for (MinMax *mmObject in [_hours objectForKey: [NSString stringWithFormat:@"%d", service_id] ] )
//    {
//        
//
//        min = [[mmObject min] intValue];
//        
//        // --==  Gap Hunting!  ==--
//        if ( !firstTime )  // Need to find the gap between MinMax objects, as such, don't execute on the first time in the loop
//        {
//            
//            // As we're gap hunting, max is now the lower value and min is the higher value
//            if ( ( max < time ) && ( time < min ) )
//            {
//                // Current time is between service on this route; we're in a gap!
//                return [NSString stringWithFormat:@"Resume Service @%d:%02d", min/100, min%100];
//            }
//            
//        }
//        else
//        {
//            firstTime = NO;
//        }
//        
//        max = [[mmObject max] intValue];
// 
//        
//        totalTime += (max - min);
//        
//        if ( ( min < time ) && ( time < max ) )
//        {
//            found = YES;
//        }
//        
//    }
//    
//    
////    TransitServiceStatus tStatus = kTransitServiceOut;
//    if ( found )
//    {
//        transitServiceStatus = [NSNumber numberWithInt:kTransitServiceIn];
//        if ( totalTime < 12 )
//        {
////            _status = @"Limited Service";
//            _status = @"Not In Service";
//            return _status;
//        }
//        else
//        {
//            _status = @"In Service";
//            return _status;
//        }
//
//    }
//    else  // Not found
//    {
//        
////        tStatus = kTransitServiceOut;  // Out by default
//        transitServiceStatus = [NSNumber numberWithInt: kTransitServiceOut];
//        if ( firstTime == NO )  // Hours exist for service_id, but time was not between them
//        {
//            _status = @"Not In Service";
//            return _status;
//        }
//        else
//        {
//            _status = @"Not In Service";
//            return _status;
//        }
//    }
//    
//    return @"Mistake";
    
}


-(void) changeServiceStatus:(TransitServiceStatus) newStatus
{
    transitServiceStatus = [NSNumber numberWithInt:newStatus];
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
