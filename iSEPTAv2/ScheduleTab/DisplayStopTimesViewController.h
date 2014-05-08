//
//  DisplayStopTimesViewController.h
//  iSEPTA
//
//  Created by septa on 11/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "TapableSegmentControl.h"  // TapableSegmentControl responds to touches on the selected/active segment
#import "DisplayedRouteData.h"

#import "sqlite3.h"
#import "KMLParser.h"

#import "FindLocationsViewController.h"
//#import "ShowTimesStartCell.h"

// For Stop Sequence Table View
#import "StopSequenceCell.h"

// For Stop Times Table View
//#import "StopTimesStartCell.h"
//#import "StopTimesEndCell.h"
#import "StopTimesCell.h"
//#import "DisplayTimesCell.h"

#import "UITableViewStandardHeaderLabel.h"
#import "TapableSegmentControl.h"

#import "SVProgressHUD.h"

#import "FMDatabase.h"

#import "ShowTimesModel.h"
#import "TripData.h"

#import "GTFSCommon.h"

// For MapKit
#import "mapAnnotation.h"
#import <CoreLocation/CoreLocation.h>


@interface DisplayStopTimesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, FindLocationsDelegate, StopSequenceProtocol, StopTimesCellProtocol>
{
    sqlite3 *db;
    KMLParser *kmlParser;
}

@property (weak, nonatomic) IBOutlet TapableSegmentControl *segmentDays;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *viewSeq;
@property (weak, nonatomic) IBOutlet UITableView *tableSeq;

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *gestureLeftSwipe;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *gestureRightSwipe;


@property (nonatomic, strong) DisplayedRouteData *routeData;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnFavorite;

@property (nonatomic, strong) NSString *travelMode;

-(void) getStopTimes;

@end
