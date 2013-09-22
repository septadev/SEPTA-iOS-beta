//
//  TransitMapViewController.h
//  iSEPTA
//
//  Created by septa on 4/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "KMLParser.h"
#import "RouteData.h"


@interface TransitMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSString *travelMode;
@property (strong, nonatomic) NSString *routeName;
@property (strong, nonatomic) NSNumber *routeType;


@end
