//
//  KMLObject.m
//  iSEPTA
//
//  Created by Administrator on 9/22/15.
//  Copyright © 2015 SEPTA. All rights reserved.
//

#import "KMLObject.h"

@implementation KMLObject
{
    MKMapRect _flyTo;
    NSMutableArray *points;
}

-(id) initWithFilename:(NSString *)filename forMapView:(MKMapView *) mapView
{

    self = [super init];

    if ( self )
    {
        
        _flyTo = MKMapRectNull;
        points = [[NSMutableArray alloc] init];
        NSInteger pointCount = 0;
        NSString *pathStr = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
        NSDictionary *kmlData = [NSDictionary dictionaryWithContentsOfFile:pathStr];
        NSMutableArray *polyLineArr = [[NSMutableArray alloc] init];
        
        for (NSArray *path in kmlData)  // Loop through each path in the plist.  And there are way too many paths!
        {
            pointCount = [[kmlData objectForKey:path] count];
            
            if ( pointCount < 1 )
                continue;
            
            CLLocationCoordinate2D coordinates[pointCount];
            NSInteger i = 0;
            
            for (NSString *coords in [kmlData objectForKey:path])  // Loop through the coordinates in the current path
            {
                CGPoint coord = CGPointFromString(coords);  // Find coordinate string in the plist to a CGPoint
                CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.y longitude:coord.x];  // Create CLLocation object
                coordinates[i++] = location.coordinate;  // Store locations in an CLLocationCoordinate2D array.  Needed for MKPolyline
                
                // Create a _flyTo rectangle that covers all the coordinates in every path of the plist.
                MKMapRect pointRect = MKMapRectMake(coord.y, coord.x, 0, 0);
                if ( MKMapRectIsNull(_flyTo) )
                    _flyTo = pointRect;
                else
                    _flyTo = MKMapRectUnion(_flyTo, pointRect);
            }  // for (NSString *coords in [kmlData objectForKey:path])
            
            MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:pointCount];
            if ( polyLine != nil )
                [mapView addOverlay:polyLine];
            
        } // for (NSArray *path in kmlData)

        // At this point, polyLineArr should hold all the paths.
//        NSLog(@"Done");
        
       
//        NSLog(@"# of points: %ld, size: %ld",pointCount,pointCount*16);
//        
//        NSLog(@"Min: %8.6f, %8.6f", MKMapRectGetMinX(_flyTo), MKMapRectGetMinY(_flyTo));
//        NSLog(@"Max: %8.6f, %8.6f", MKMapRectGetMaxX(_flyTo), MKMapRectGetMaxY(_flyTo));

        _midCoordinate = CLLocationCoordinate2DMake( MKMapRectGetMidX(_flyTo), MKMapRectGetMidY(_flyTo) );
//        NSLog(@"Mid: %8.6f, %8.6f", _midCoordinate.latitude, _midCoordinate.longitude);
//        _flyTo.size.height = _flyTo.size.height*2;
        
        _overlayBoundingMapRect = _flyTo;
        _latDelta = MKMapRectGetMaxX(_flyTo) - MKMapRectGetMinX(_flyTo);

    }
  
    
    return self;
    
}

@end
