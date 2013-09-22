//
//  mapAnnotation.m
//  iSEPTA
//
//  Created by Justin Brathwaite on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "mapAnnotation.h"

@implementation mapAnnotation
{
    
}

@synthesize coordinate=_coordinate;

@synthesize currentTitle;
@synthesize currentSubTitle;

@synthesize direction;
@synthesize id;

- (NSString *)subtitle
{
	return currentSubTitle;
}

- (NSString *)title
{
    //	NSLog(@"currenttitle: %@",currentTitle);
	return currentTitle;//  @"Marker Annotation";
}


- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    self = [super init];
    if (self != nil)
    {
        _coordinate = coordinate;
    }
    
    return self;
    
}


-(NSString*) description
{
    return [NSString stringWithFormat:@"title: %@, subtitle: %@, dir: %@, lat/lng: %6.3f, %6.3f", currentTitle, currentSubTitle, direction, _coordinate.latitude, _coordinate.longitude];
}


@end
