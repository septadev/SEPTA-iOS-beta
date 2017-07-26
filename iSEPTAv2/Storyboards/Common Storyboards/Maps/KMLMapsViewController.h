//
//  KMLMapsViewController.h
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


// Pods
#import <SVProgressHUD/SVProgressHUD.h>

// Custom Data Models
#import "RouteData.h"
#import "TrainViewObject.h"
#import "TransitViewObject.h"
#import "mapAnnotation.h"


// Custom Classes
#import "KMLParser.h"

#define JSON_REFRESH_RATE 20.0f



@interface KMLMapsViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSString *travelMode;
@property (strong, nonatomic) NSString *routeName;
@property (strong, nonatomic) NSNumber *routeType;

@end
