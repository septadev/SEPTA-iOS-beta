//
//  WalkingTourStops.m
//  iSEPTA
//
//  Created by septa on 6/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "WalkingTourStops.h"

@implementation PinLocation

@synthesize coordinate;
@synthesize subtitle;
@synthesize title;

@end


@implementation WalkingTourStops
{
    NSMutableArray *_walkingTourPoints;
}


-(id)init
{

    if ( ( self = [super init] ) )
    {
        
        [self createWalkingPoints];
        
    }
    
    return self;
    
}


-(void) createWalkingPoints
{
    
    /*
     
     39.95208
     -75.16131
     
     */
    
    
    _walkingTourPoints = [[NSMutableArray alloc] init];
    
    PinLocation *pinLoc = [[PinLocation alloc] init];
//    [pinLoc setCoordinate:CLLocationCoordinate2DMake(39.9525000, -75.1580556)];
    [pinLoc setCoordinate:CLLocationCoordinate2DMake(40.1208333, -75.1341667)];
    [pinLoc setMyTitle:@"Market East"];

    [_walkingTourPoints addObject: pinLoc];
    

    pinLoc = [[PinLocation alloc] init];
    [pinLoc setCoordinate:CLLocationCoordinate2DMake(39.9813889, -75.1494444)];
    [pinLoc setMyTitle:@"Temple"];

    [_walkingTourPoints addObject:pinLoc];

    pinLoc = [[PinLocation alloc] init];
    [pinLoc setCoordinate:CLLocationCoordinate2DMake(40.0222222, -75.1600000)];
    [pinLoc setMyTitle:@"Wayne Junction"];

    [_walkingTourPoints addObject:pinLoc];
    
    pinLoc = [[PinLocation alloc] init];
    [pinLoc setCoordinate:CLLocationCoordinate2DMake(40.0405556, -75.1347222)];
    [pinLoc setMyTitle:@"Fern Rock"];
    
    [_walkingTourPoints addObject:pinLoc];

    pinLoc = [[PinLocation alloc] init];
    [pinLoc setCoordinate:CLLocationCoordinate2DMake(40.1013889, -75.1536111)];
    [pinLoc setMyTitle:@"Glenside"];
    
    [_walkingTourPoints addObject:pinLoc];
    
    pinLoc = [[PinLocation alloc] init];
    [pinLoc setCoordinate:CLLocationCoordinate2DMake(40.1141667, -75.1530556)];
    [pinLoc setMyTitle:@"Ardsley"];
    
    [_walkingTourPoints addObject:pinLoc];
    
    pinLoc = [[PinLocation alloc] init];
    [pinLoc setCoordinate:CLLocationCoordinate2DMake(40.1208333, -75.1341667)];
    [pinLoc setMyTitle:@"Rosyln"];
    
    [_walkingTourPoints addObject:pinLoc];
    
    
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(39.9525000, -75.1580556)]];  // Market East
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(39.9813889, -75.1494444)]];  // Temple
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(40.0222222, -75.1600000)]];  // Wayne Junction
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(40.0405556, -75.1347222)]];  // Fern Rock
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(40.0594444, -75.1291667)]];  // Melrose Park
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(40.0713889, -75.1277778)]];  // Elkins Park
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(40.0927778, -75.1375000)]];  // Jenkintown Wyncote
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(40.1013889, -75.1536111)]];  // Glenside
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(40.1141667, -75.1530556)]];  // Ardsley
//    [stopCoords addObject:[NSValue valueWithCGPoint:CGPointMake(40.1208333, -75.1341667)]];  // Rosyln

    
//    for (NSDictionary *myDict in stopCoords)
//    {
//        pinLoc = [[PinLocation alloc] init];
//        [pinLoc setCoordinate:CLLocationCoordinate2DMake(0, 0)];
//        [pinLoc setTitle:@"Wayne Junction"];
//    }

    //    [_walkingTourPoints addObject:[NSValue valueWithCGPoint:CGPointMake(39.95211f, -75.16156f)]];  // 13th & Market Corner
    //    [_walkingTourPoints addObject:[NSValue valueWithCGPoint:CGPointMake(39.95225f, -75.16266f)]];  // City Hall West Side
    //    [_walkingTourPoints addObject:[NSValue valueWithCGPoint:CGPointMake(39.95164f, -75.16373f)]];  // City Hall South Side
    //    [_walkingTourPoints addObject:[NSValue valueWithCGPoint:CGPointMake(39.95168f, -75.16548f)]];  // 15th and Ranstead St
    //    [_walkingTourPoints addObject:[NSValue valueWithCGPoint:CGPointMake(39.95108f, -75.16563f)]];  // 15th and Chestnut St
    //    [_walkingTourPoints addObject:[NSValue valueWithCGPoint:CGPointMake(39.95090f, -75.16403f)]];  // 15th and Broad St

    
    
}


-(NSArray*) allStops
{
    return _walkingTourPoints;
}



@end
