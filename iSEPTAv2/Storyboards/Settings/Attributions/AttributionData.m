//
//  AttributionData.m
//  iSEPTA
//
//  Created by septa on 9/13/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "AttributionData.h"

@implementation AttributionData

@synthesize license;
@synthesize library;

-(NSString*) description
{
    return [NSString stringWithFormat:@"%@ - %@", library, license];
}

@end
