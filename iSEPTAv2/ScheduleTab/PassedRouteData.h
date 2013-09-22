//
//  PassedRouteData.h
//  iSEPTA
//
//  Created by septa on 11/9/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PassedRouteData : NSObject

@property (nonatomic, strong) NSString *routeShortName;
@property (nonatomic, strong) NSString *routeID;

@property (nonatomic) NSInteger directionID;
@property (nonatomic) NSInteger startStopID;
@property (nonatomic) NSInteger endStopID;

@property (nonatomic, strong) NSString *startStopName;
@property (nonatomic, strong) NSString *endStopName;

-(void) flipStartEndStops;

@end
