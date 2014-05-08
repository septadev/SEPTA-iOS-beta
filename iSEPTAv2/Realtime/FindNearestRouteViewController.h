//
//  FindNearestRouteViewController.h
//  iSEPTA
//
//  Created by septa on 1/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreLocation/CoreLocation.h"

#import "GTFSCommon.h"

@interface FindNearestRouteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentTypes;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnRadius;

@end
