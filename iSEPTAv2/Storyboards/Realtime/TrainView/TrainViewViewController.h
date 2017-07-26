//
//  TrainViewViewController.h
//  iSEPTA
//
//  Created by septa on 8/8/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAShapeLayer.h>

// --==  Data Models  ==--
#import "TrainViewObject.h"
#import "TransitViewObject.h"
// - for KML Parsing
#import "RouteData.h"
#import "mapAnnotation.h"



// --==  Helper Classes  ==--
#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"
#import "KMLParser.h"


// --==  Xibs  ==--
#import "RealtimeVehicleInformationCell.h"


// --==  Common  ==--
#import "GTFSCommon.h"


// --==  PODs  ==--
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <Reachability/Reachability.h>


#define JSON_REFRESH_RATE 20.0f



@interface TrainViewViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *imgVerticalDivider;
@property (weak, nonatomic) IBOutlet UIImageView *imgTableViewBG;

@property (strong, nonatomic) NSNumber *travelMode;
@property (strong, nonatomic) NSString *routeName;

//@property (strong, nonatomic) NSString *backImageName;

@end
