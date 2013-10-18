//
//  BasicRouteObject.m
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "BasicRouteObject.h"

@implementation RouteDetailsObject
{
    
}


@synthesize route_short_name;
@synthesize route_type;


//-(NSComparisonResult) compareWithAnotherRoute:(RouteDetailsObject*) rdObject
//{
//    return [[self route_short_name] compare:[rdObject route_short_name] options: NSNumericSearch];
//}

-(NSString*) description
{
    return [NSString stringWithFormat:@"RDO: %@ is type %d", route_short_name, [route_type intValue] ];
}

@end


@implementation BasicRouteObject
{
    
}

@synthesize stop_id;
@synthesize stop_name;
@synthesize distance;

@synthesize routeData;


-(id) init
{
    
    if ( ( self = [super init] ) )
    {
        routeData = [[NSMutableArray alloc] init];
    }
    
    return self;
    
}


-(NSString*) description
{
    return [NSString stringWithFormat:@"BRO: %@ (%@), dist: %@, data: %@", stop_name, stop_id, distance, routeData];
}


-(void) addRouteInfo:(RouteDetailsObject*) detailedInfo
{
    // Let's do some checks!
    
    // Does route_short_name already exist?
    for (RouteDetailsObject *rdObj in routeData)
    {
        if ( [rdObj.route_short_name isEqualToString: detailedInfo.route_short_name] )
        {
            // It does!  Now, does it have the same dircode
            
            if ( [rdObj.directionDict objectForKey: [[detailedInfo.directionDict allKeys] objectAtIndex:0]] == nil )
            {
                [rdObj.directionDict addEntriesFromDictionary: detailedInfo.directionDict];
                return;
            }
            else
            {
                return;
            }
            
            
//            if ( [rdObj.dircode isEqualToString: detailedInfo.dircode] )
//                return;  // No need to add it as it already exists
//            else
//            {
//                return;
//            }
        }
    }
    
    // 10W, 10E, 13W, 13E
    // Do we store these are 4 different elements or as 2 different elements?
    
    
    [routeData addObject: detailedInfo];
    
}


-(NSInteger) count
{
    return [routeData count];
}


-(NSNumber*) routeTypeAtIndex:(NSInteger) index
{
    if ( index >= [routeData count] )
        return nil;
    
    return [(RouteDetailsObject*)[routeData objectAtIndex:index] route_type];
    
}

-(NSString*) routeNameAtIndex:(NSInteger) index
{
    if ( index >= [routeData count] )
        return nil;
    
    return [(RouteDetailsObject*)[routeData objectAtIndex:index] route_short_name];
}

-(void) sort
{
    [routeData sortedArrayUsingComparator:^NSComparisonResult(RouteDetailsObject *a, RouteDetailsObject *b)
     {
         return [[a route_short_name] compare:[b route_short_name] options:NSNumericSearch];
     }];
}

@end