//
//  MKMultiPolyLine.m
//  iSEPTA
//
//  Created by septa on 1/18/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "MKMultiPolyLine.h"

@implementation MKMultiPolyLine

@synthesize polylines = _polylines;

-(id) init
{
    if ( ( self = [super init] ) )
    {
        // Do initialization here...
        _polylines = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(id) initWithPolylines:(NSMutableArray *)polylines
{
    
    if ( ( self = [super init] ) )
    {
        _polylines = [polylines copy];
        
        NSUInteger polyCount = [_polylines count];
        if ( polyCount )
        {
            _boundingMapRect = [[_polylines objectAtIndex:0] boundingMapRect];
            NSUInteger i;
            for (i = 1; i < polyCount; i++)
            {
                _boundingMapRect = MKMapRectUnion(_boundingMapRect, [[_polylines objectAtIndex:i] boundingMapRect]);
            } // for (i = 1; i < polyCount; i++)
            
        }  // if ( polyCount )
        
    } // if ( ( self = [super init] ) )
    
    return self;
    
}

-(void) clearPolylines
{
    [_polylines removeAllObjects];
    _boundingMapRect = MKMapRectNull;
}

-(void) addPolyline:(MKShape*)polyline
{
    
    if ( [_polylines count] )
    {
        // If true, _polylines already contains data.  We need to distinguish between no data and some data
        // because of how we build the _boundingMapRect.  First polyline, the MKMapRectUnion is the rect of the line.
        // Each subsequent polyline is the union of the current _boundingMapRect and the _boundingMapRect specific to the new polyline
        [_polylines addObject:polyline ];
        _boundingMapRect = MKMapRectUnion(_boundingMapRect, [(id)polyline boundingMapRect]);
    }
    else
    {
        // Otherwise, _polylines does not contain any data
        [_polylines addObject:polyline ];
        _boundingMapRect = [(id)polyline boundingMapRect];
    }
    
}

-(MKMapRect) boundingMapRect
{
    return _boundingMapRect;
}


-(CLLocationCoordinate2D) coordinate
{
    return MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMidX(_boundingMapRect), MKMapRectGetMidY(_boundingMapRect) ) );
}

@end



@implementation MKMultiPolylineView

-(id) initWithOverlay:(id<MKOverlay>)overlay
{
    
    if ( ( self = [super initWithOverlay:overlay] ) )
    {
        // Do any initialization work here
    }
    return self;
    
}

-(CGPathRef) newPolyPath:(MKPolyline *) polyline
{
    
    MKMapPoint *points    = [polyline points];
    NSUInteger pointCount = [polyline pointCount];
    NSUInteger i;
    
    if ( pointCount < 2 )
        return NULL;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint relativePoint = [self pointForMapPoint:points[0] ];
    CGPathMoveToPoint(path, NULL, relativePoint.x, relativePoint.y);
    
    for (i = 1; i < pointCount; i++)
    {
        relativePoint = [self pointForMapPoint:points[i] ];
        CGPathAddLineToPoint(path, NULL, relativePoint.x, relativePoint.y);
    }
    
    return path;
    
}

-(void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    
    MKMultiPolyLine *multiPolyLine = (MKMultiPolyLine*)self.overlay;
    for (MKPolyline *polyline in multiPolyLine.polylines)
    {
        CGPathRef path = [self newPolyPath:polyline];
        if ( path )
        {
            [self applyFillPropertiesToContext:context atZoomScale:zoomScale];
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextDrawPath(context, kCGPathStroke);
            [self applyStrokePropertiesToContext:context atZoomScale:zoomScale];
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextStrokePath(context);
            CGPathRelease(path);
        }
    }
    
}

@end