//
//  PassedRouteData.m
//  iSEPTA
//
//  Created by septa on 11/9/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "PassedRouteData.h"

@implementation PassedRouteData
{
    // Private Variables
}

@synthesize routeShortName;
@synthesize routeID;

@synthesize directionID;
@synthesize startStopID;
@synthesize endStopID;

@synthesize startStopName;
@synthesize endStopName;

-(void) flipStartEndStops
{
    NSString *tmpStr = startStopName;
    startStopName = endStopName;
    endStopName = tmpStr;
    
    NSInteger tmpNum = startStopID;
    startStopID = endStopID;
    endStopID = tmpNum;
}

@end
