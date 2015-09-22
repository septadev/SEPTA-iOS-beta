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

-(id) initWithFilename:(NSString *)filename
{

    self = [super init];

    if ( self )
    {
        _flyTo = MKMapRectNull;
        points = [[NSMutableArray alloc] init];
        NSInteger pointCount = 0;
        NSString *pathStr = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
        NSDictionary *kmlData = [NSDictionary dictionaryWithContentsOfFile:pathStr];
        
        for (NSArray *path in kmlData)
        {
            pointCount += [[kmlData objectForKey:path] count];
            NSMutableArray *pointPath = [[NSMutableArray alloc] init];
            for (NSString *coords in [kmlData objectForKey:path])
            {
                CGPoint coord = CGPointFromString(coords);
                CLLocation *location = [[CLLocation alloc] initWithLatitude:coord.y longitude:coord.x];

//                NSLog(@"Size of %@: %zd",NSStringFromClass([location class]), malloc_size((__bridge const void *) location));
                [pointPath addObject:location];
                
                MKMapRect pointRect = MKMapRectMake(coord.y, coord.x, 0, 0);
                if ( MKMapRectIsNull(_flyTo) )
                    _flyTo = pointRect;
                else
                    _flyTo = MKMapRectUnion(_flyTo, pointRect);
            }  // for (NSString *coords in [kmlData objectForKey:path])
            
            if ( [pointPath count] > 2 )
                [points addObject:pointPath];
            
        } // for (NSArray *path in kmlData)

//        NSLog(@"# of points: %ld, size: %ld",pointCount,pointCount*16);
        
        NSLog(@"%8.6f", MKMapRectGetMinY(_flyTo));
        NSLog(@"%8.6f", MKMapRectGetMaxY(_flyTo));
        _midCoordinate = CLLocationCoordinate2DMake( MKMapRectGetMidX(_flyTo), MKMapRectGetMidY(_flyTo) );
        _overlayBoundingMapRect = _flyTo;
        
//        NSLog(@"Done");

    }
  
    
    return self;
    
}

@end
