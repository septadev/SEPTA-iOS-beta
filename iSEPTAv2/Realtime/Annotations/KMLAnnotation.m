//
//  KMLAnnotation.m
//  iSEPTA
//
//  Created by septa on 9/22/15.
//  Copyright © 2015 SEPTA. All rights reserved.
//

#import "KMLAnnotation.h"

@implementation KMLAnnotation


@synthesize coordinate=_coordinate;

@synthesize currentTitle;
@synthesize currentSubTitle;

@synthesize direction;
@synthesize vehicle_id;

@synthesize seconds;

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


//-(MKAnnotationView*) annotationView
//{
//    
//    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"BusAnnontationWithBlockID"];
//    
//    annotationView.enabled = YES;
//    annotationView.canShowCallout = YES;
//    
//    
//    return annotationView;
//    
//}



-(NSString*) description
{
    return [NSString stringWithFormat:@"title: %@, subtitle: %@, dir: %@, lat/lng: %6.3f, %6.3f", currentTitle, currentSubTitle, direction, _coordinate.latitude, _coordinate.longitude];
}

@end
