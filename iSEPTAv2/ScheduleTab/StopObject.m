//
//  StopObject.m
//  iSEPTA
//
//  Created by septa on 4/8/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "StopObject.h"

@implementation StopObject
{
    BOOL _isComplete;
}
@synthesize startStopName;
@synthesize startStopID;

@synthesize endStopName;
@synthesize endStopID;


-(BOOL) isComplete
{
//    if ( ( startStopName != nil ) && ( startStopID != nil ) && ( endStopName != nil ) && ( endStopID != nil ) )
//        return YES;
    
//    return NO;
    
    return ( startStopName != nil ) && ( startStopID != nil ) && ( endStopName != nil ) && ( endStopID != nil );
}


-(void) clear
{
    
    startStopID = nil;
    startStopName = nil;
    
    endStopID = nil;
    endStopName = nil;
    
}

-(void) flipStops
{
    
    NSString *tempStr = startStopName;
    startStopName = endStopName;
    endStopName = tempStr;

    NSNumber *tempNum = startStopID;
    startStopID = endStopID;
    endStopID = tempNum;
    
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"start/end name: %@/%@,  start/end ID: %d/%d", startStopName, endStopName, [startStopID intValue], [endStopID intValue] ];
}

@end
