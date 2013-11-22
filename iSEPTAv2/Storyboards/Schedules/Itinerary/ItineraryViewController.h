//
//  ItineraryViewController.h
//  iSEPTA
//
//  Created by septa on 8/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAShapeLayer.h>


// --==  Pods  ==--
#import <SVProgressHUD.h>
#import <FMDatabase.h>
#import <Reachability.h>
#import <REMenu.h>
// --==  Pods  ==--


// --==  Handy Helper Classes
#import "TapableSegmentControl.h"
#import "TabbedButton.h"
#import "CustomFlatBarButton.h"
#import "GetAlertDataAPI.h"
// --==  Handy Helper Classes


// --==  Data Models  ==--
#import "RouteData.h"
#import "ItineraryObject.h"
#import "TripObject.h"
#import "ActiveTrainObject.h"
#import "DisplayedRouteData.h"
#import "NTASaveObject.h"
// --==  Data Models  ==--


// --==  Xib Files
#import "NextToArriveItineraryCell.h"
#import "ItineraryCell.h"
#import "TripCell.h"
#import "ActiveTrainCell.h"
#import "NTASaveObjectCell.h"
// --==  Xib Files


// --==  Connected VCs  ==--
#import "StopNamesForRouteTableController.h"
#import "StopNamesTableViewController.h"
#import "FareViewController.h"
#import "SystemAlertsViewController.h"
// --==  Connected VCs  ==--


// --==  Categories  ==--
#import "NSString+Hashes.h"
#import "UIColor+SEPTA.h"
// --==  Categories  ==--


#import "MapViewController.h"
#import "TripDetailsTableController.h"


#define DEFAULT_START_MESSAGE @"Enter start stop"
#define DEFAULT_END_MESSAGE   @"Enter end stop"


// --==
// --==  Alerts  ==--
// --==
//#define REFRESH_NO_STOPS      @"select trips before refreshing"
//#define REFRESH_READY         @"click to refresh data"
//#define REFRESH_IN_UNKNOWN    @"refreshing in..."
//#define REFRESH_IN_X_SECS     @"refreshing in X seconds"
//
//#define REFRESH_NOW           @"refreshing now"
//#define REFRESH_NO_CONNECTION @"no Internet connection detected"

#define ALERTS_STARTUP    @"Fetching latest alerts..."
#define ALERTS_EMPTY      @"No alerts available for this route"
#define ALERTS_FOUND      @"Click to view alerts"



#define DEFAULT_MESSAGE @"Click to enter destination"
#define CELL_REFRESH_RATE 60.0f/6.0f   // 6 times a minute, 10 seconds refresh rate
#define JSON_REFRESH_RATE 60.0f/4.0f   // 4 times a minute, 15 seconds refresh rate


//  --==
//  --==  Enumerations
//  --==
typedef NS_ENUM(NSInteger, ItineraryFilterType)
{
    kItineraryFilterTypeNow,
    kItineraryFilterTypeWeekday,
    kItineraryFilterTypeSat,
    kItineraryFilterTypeSun,
};


// --==
// --==  Favorites  ==--
// --==
#define FAVORITE_SUBTITLE_ADD    @"add route to favorites"
#define FAVORITE_SUBTITLE_REMOVE @"remove route from favorites"
#define FAVORITE_SUBTITLE_NONE   @"no routes have been selected"
typedef NS_ENUM(NSInteger, ItineraryFavoriteSubtitleState)
{
    kNextToArriveFavoriteSubtitleStatusUnknown,
    kNextToArriveFavoriteSubtitleAdded,
    kNextToArriveFavoriteSubtitleNotAdded,
};

typedef NS_ENUM(NSInteger, ItineraryDropDownMenuOrder)
{
    kItineraryDropDownMenuOrderFavorites,
    kItineraryDropDownMenuOrderFare,
};


@interface ItineraryViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, ItineraryCellProtocol, StopNamesTableViewControllerProtocol, StopNamesForRouteDelegate, TabbedButtonProtocol, NextToArriveItineraryCellProtocol, GetAlertDataAPIProtocol>

@property (weak, nonatomic) IBOutlet UILabel *lblTabbedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgTabbedLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableTrips;

@property (nonatomic, strong) NSString *travelMode;
@property (nonatomic, strong) RouteData *routeData;



//@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnFavorite;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentMapFavorite;


//@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UITableView *tableSequence;


//@property (weak, nonatomic) IBOutlet MKMapView *mapView;
//@property (weak, nonatomic) IBOutlet UIView *viewTrips;
//@property (weak, nonatomic) IBOutlet UIView *viewSequence;


//@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe;
//@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rigthSwipe;
//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTap;

//@property (weak, nonatomic) IBOutlet TapableSegmentControl *segmentService;

@end
