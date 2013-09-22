//
//  SimpleMapViewController.h
//  iSEPTA
//
//  Created by septa on 7/31/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


#import "GetLocationsObject.h"
#import "mapAnnotation.h"


#define JSON_REFRESH_RATE 20.0f


@interface SimpleMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@property (strong, nonatomic) NSMutableArray *masterList;
@property (strong, nonatomic) NSString *filterType;

@property (strong, nonatomic) NSNumber *radius;

@end

