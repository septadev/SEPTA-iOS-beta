//
//  RouteInfo.h
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DirectionInfo;  // Forward declaration for DirectionInfo object

@interface RouteInfo : NSObject

@property (nonatomic, strong) NSNumber *route_id;
@property (nonatomic, strong) NSString *route_short_name;
@property (nonatomic, strong) NSString *route_long_name;
@property (nonatomic, strong) NSNumber *route_type;

//@property (nonatomic, strong) DirectionInfo *direction0;
//@property (nonatomic, strong) DirectionInfo *direction1;

@property (nonatomic, strong) NSMutableArray *direction0;
@property (nonatomic, strong) NSMutableArray *direction1;


-(void) setCardinalDirection: (NSString*) direction withID: (int) directionID forHoursMin: (NSString *) min andMax: (NSString*) max;
-(BOOL) inServiceForDirectionID: (int) directionID;
-(BOOL) inService;

@end


@interface DirectionInfo : NSObject

@property (nonatomic, strong) NSString *cardinalDirection;
@property (nonatomic, strong) NSNumber *directionID;

@property (nonatomic, strong) NSString *minHours;
@property (nonatomic, strong) NSString *maxHours;

@end