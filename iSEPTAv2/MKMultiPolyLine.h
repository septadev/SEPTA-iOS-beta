//
//  MKMultiPolyLine.h
//  iSEPTA
//
//  Created by septa on 1/18/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MKMultiPolyLine : NSObject <MKOverlay>
{
    NSMutableArray *_polylines;
    MKMapRect _boundingMapRect;
}

@property (nonatomic, readonly) NSMutableArray *polylines;

-(id) initWithPolylines:(NSMutableArray*) polylines;
-(void) clearPolylines;
-(void) addPolyline:(MKShape*)polyline;

@end

@interface MKMultiPolylineView: MKOverlayPathView
{
    
}

@end