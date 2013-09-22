//
//  BasicRouteObject.h
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RouteDetailsObject;


@interface BasicRouteObject : NSObject

// These values are the same across all the routes that stop at this stop_id
@property (nonatomic, strong) NSString *stop_name;
@property (nonatomic, strong) NSString *stop_id;
@property (nonatomic, strong) NSString *distance;

@property (nonatomic, strong) NSString *location_type;

//@property (nonatomic, strong) BasicRouteObject *basicRouteObject;
@property (nonatomic, strong) NSMutableArray *routeData;   // An array of DetailedRouteObjects



-(void) addRouteInfo:(RouteDetailsObject*) detailedInfo;

-(NSInteger) count;

-(NSNumber*) routeTypeAtIndex:(NSInteger) index;
-(NSString*) routeNameAtIndex:(NSInteger) index;

-(void) sort;

@end


@interface RouteDetailsObject : NSObject

@property (nonatomic, strong) NSString *route_short_name;
@property (nonatomic, strong) NSNumber *route_type;


//-(NSComparisonResult) compareWithAnotherRoute:(RouteDetailsObject*) rdObject;

@end
