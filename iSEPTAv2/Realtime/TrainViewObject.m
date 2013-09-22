//
//  TrainViewObject.m
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "TrainViewObject.h"

@implementation TrainViewObject

@synthesize latitude;
@synthesize longitude;

@synthesize trainNo;

@synthesize startName;
@synthesize endName;

@synthesize late;

@synthesize distance;

-(NSString*) description
{
    return [NSString stringWithFormat:@"latitude: %@, longitude: %@, trainNo: %@, startName: %@, endName: %@, dist: %6.3f, late: %@", latitude, longitude, trainNo, startName, endName, [distance floatValue], late];
}

@end
