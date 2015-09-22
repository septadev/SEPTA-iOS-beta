//
//  KMLOverlay.m
//  iSEPTA
//
//  Created by septa on 9/22/15.
//  Copyright © 2015 SEPTA. All rights reserved.
//

#import "KMLOverlay.h"
#import "KMLObject.h"

@implementation KMLOverlay

@synthesize coordinate;
@synthesize boundingMapRect;

-(instancetype) initWithKML:(KMLObject *)kmlObject
{
    
    self = [super init];
    if ( self )
    {
        boundingMapRect = kmlObject.overlayBoundingMapRect;
        coordinate = kmlObject.midCoordinate;
    }
    return self;
    
}

@end
