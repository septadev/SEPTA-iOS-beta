//
//  NewTrainViewViewController.h
//  iSEPTA
//
//  Created by septa on 4/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TapableSegmentControl.h"


@interface NewTrainViewViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet TapableSegmentControl *segmentFilter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mapViewTapGesture;

@property (strong, nonatomic) NSString *travelMode;
@property (strong, nonatomic) NSString *routeName;
@property (strong, nonatomic) NSNumber *routeType;

@end
