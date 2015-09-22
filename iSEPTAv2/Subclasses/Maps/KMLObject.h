//
//  KMLObject.h
//  iSEPTA
//
//  Created by Administrator on 9/22/15.
//  Copyright © 2015 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <malloc/malloc.h>

@interface KMLObject : NSObject

@property (nonatomic, readonly) CLLocationCoordinate2D *boundary;
@property (nonatomic, readonly) NSInteger boundaryPointsCount;

@property (nonatomic, readonly) CLLocationCoordinate2D midCoordinate;

@property (nonatomic, readonly) MKMapRect overlayBoundingMapRect;

@property (nonatomic, strong) NSString *name;

-(id)initWithFilename:(NSString *) filename;

@end
