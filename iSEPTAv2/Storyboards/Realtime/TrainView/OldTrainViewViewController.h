//
//  TrainViewViewController.h
//  iSEPTA
//
//  Created by septa on 7/31/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TapableSegmentControl.h"


//#import "TransitMapViewController.h"
//#import "SimpleMapViewController.h"
#import "KMLMapsViewController.h"

#import "SVProgressHUD.h"
#import "mapAnnotation.h"


// --==  Custom Data Models
#import "TransitViewObject.h"
#import "TrainViewObject.h"


// --==  Custom Cells
#import "RealtimeVehicleInformationCell.h"


@interface OldTrainViewViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet TapableSegmentControl *segmentFilter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mapViewTapGesture;

@property (strong, nonatomic) NSString *travelMode;
@property (strong, nonatomic) NSString *routeName;
@property (strong, nonatomic) NSNumber *routeType;

@end
