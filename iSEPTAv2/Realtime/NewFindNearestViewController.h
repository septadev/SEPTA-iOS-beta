//
//  NewFindNearestViewController.h
//  iSEPTA
//
//  Created by apessos on 4/11/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreLocation/CoreLocation.h"

#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAShapeLayer.h>

#import "BasicRouteObject.h"

@interface NewFindNearestViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentTypes;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnRadius;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mapTapGesture;

@end
