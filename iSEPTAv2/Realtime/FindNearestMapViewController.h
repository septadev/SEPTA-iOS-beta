//
//  FindNearestMapViewController.h
//  iSEPTA
//
//  Created by apessos on 4/11/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


@interface FindNearestMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@property (strong, nonatomic) NSMutableArray *masterList;
@property (strong, nonatomic) NSString *filterType;

@property (strong, nonatomic) NSNumber *radius;

@end
