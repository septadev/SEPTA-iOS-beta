//
//  ItineraryObject.m
//  iSEPTA
//
//  Created by septa on 3/4/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "ItineraryObject.h"

@implementation ItineraryObject
{

    BOOL _isReversed;
    BOOL _isComplete;
    
    StopObject *pointer;
    
    StopObject *reverseStops;
    StopObject *currentStops;
        
}


@synthesize directionID;

@synthesize routeID;
@synthesize routeShortName;
@synthesize routeLongName;


-(id) init
{
    if ( ( self = [super init] ) )
    {
        _isReversed = NO;
        _isComplete = NO;
        
        currentStops = [[StopObject alloc] init];
        reverseStops = [[StopObject alloc] init];
        
        pointer = currentStops;
    }
    
    return self;
}


-(BOOL) isComplete
{
    return [currentStops isComplete] && [reverseStops isComplete];
}


#pragma mark - Getter/Setter Methods for startStopName
-(NSString*) startStopName
{
    return [pointer startStopName];
}

-(void) setStartStopName:(NSString *)name
{
//    if ( pointer == currentStops )
//        reverseStops.startStopName = nil;
    
    [pointer setStartStopName:name];
}


#pragma mark - Getter/Setter Methods for startStopNumber
-(NSNumber*) startStopID
{
    return [pointer startStopID];
}

-(void) setStartStopID:(NSNumber *)num
{
//    if ( pointer == currentStops )
//        reverseStops.startStopID = nil;
    
    [pointer setStartStopID:num];
}


#pragma mark - Getter/Setter Methods for endStopName
-(NSString*) endStopName
{
    return [pointer endStopName];
}

-(void) setEndStopName:(NSString *)name
{
//    if ( pointer == currentStops )
//        reverseStops.endStopName = nil;
    
    [pointer setEndStopName:name];
}


#pragma mark - Getter/Setter Methods for endStopNumber
-(NSNumber*) endStopID
{
    return [pointer endStopID];
}


-(void) setEndStopID:(NSNumber *)num
{
    
//    if ( pointer == currentStops )
//        reverseStops.endStopID = nil;
    
    [pointer setEndStopID:num];
    
}


-(void) flipStops
{
    [currentStops flipStops];
    [reverseStops flipStops];
}


-(BOOL) isReverse
{
    return _isReversed;
}


-(void) setReverse:(BOOL)yesNo
{
    _isReversed = yesNo;

    if ( _isReversed )
        pointer = reverseStops;
    else
        pointer = currentStops;
}


//-(void) reverse
//{
//    _isReversed = !_isReversed;
//    if ( !_isReversed )
//        pointer = currentStops;
//    else
//        pointer = reverseStops;
//}


-(void) reset
{
    // Move object back to initial settings without deleting any data
    _isReversed = NO;
    pointer = currentStops;
}

-(void) clearStops
{
    currentStops.startStopName = NULL;
    currentStops.startStopID   = NULL;
    
    currentStops.endStopName   = NULL;
    currentStops.endStopID     = NULL;

    
    reverseStops.startStopName = NULL;
    reverseStops.startStopID   = NULL;
    
    reverseStops.endStopName   = NULL;
    reverseStops.endStopID     = NULL;
}

-(NSString*) description
{
    
    return [NSString stringWithFormat:@"IO - route id/short %@/%@, isReverse: %d, dir: %d\nCurrent: %@\nReverse: %@", routeID, routeShortName, _isReversed, [directionID intValue], currentStops, reverseStops ];
    
//    return [NSString stringWithFormat:@"IO - route id/short %@/%@, %@, dir: %d", routeID, routeShortName, pointer, [directionID intValue] ];
}


//-(void) flipStops
//{
//
//    NSString *tempStr = startStopName;
//    startStopName = endStopName;
//    endStopName = tempStr;
//    
//    NSNumber *tempNum = startStopID;
//    startStopID = endStopID;
//    endStopID = tempNum;
//    
//}

@end
