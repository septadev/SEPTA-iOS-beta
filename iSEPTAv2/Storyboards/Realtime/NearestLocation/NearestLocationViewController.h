//
//  NearestLocationViewController.h
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import "CoreLocation/CoreLocation.h"

#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAShapeLayer.h>


//  --==  Connectted VC  ==--
#import "SimpleMapViewController.h"
#import "NearestTimesViewController.h"


//  --==  Additional Supporting Classes  ==--
#import "CHDigitInput.h"
#import "SaveController.h"


// --==  Data Models  ==--
#import "FindNearestRouteSaveObject.h"

#import "BasicRouteObject.h"
#import "GetLocationsObject.h"

#import "mapAnnotation.h"


// --==  Helper Classes  ==--
#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"
#import "KMLParser.h"


// --==  Custom Views  ==--
#import "DistanceView.h"


// --==  Common  ==--
#import "GTFSCommon.h"


// --==  Pods  ==--
#import <FMDatabase.h>
#import <SVProgressHUD.h>
#import <Reachability.h>
#import <AFNetworking.h>


// --==  Xibs  ==--
#import "BusRouteIndicatorCell.h"


#define JSON_REFRESH_RATE 20.0f



@interface NearestLocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, DistanceViewProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIImageView *imgTableViewBG;
@property (weak, nonatomic) IBOutlet UIImageView *imgVerticalDivider;

//@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentTypes;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnRadius;

//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *mapTapGesture;

@end
