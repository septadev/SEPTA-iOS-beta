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