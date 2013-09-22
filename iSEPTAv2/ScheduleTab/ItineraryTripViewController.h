//
//  ItineraryTripViewController.h
//  iSEPTA
//
//  Created by septa on 3/5/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TapableSegmentControl.h"

#import "RouteData.h"

// --==  Header Files With Protocols  ==--
//#import "FindLocationsViewController.h"
#import "ItineraryCell.h"
#import "StopNamesForRouteTableController.h"
// --==  Header Files With Protocols  ==--


@interface ItineraryTripViewController : UIViewController <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, ItineraryCellProtocol, StopNamesForRouteDelegate>

//@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnFavorite;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentMapFavorite;


@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITableView *tableSequence;
@property (weak, nonatomic) IBOutlet UITableView *tableTrips;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UIView *viewTrips;
@property (weak, nonatomic) IBOutlet UIView *viewSequence;

@property (nonatomic, strong) NSString *travelMode;
@property (nonatomic, strong) RouteData *routeData;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rigthSwipe;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTap;

@property (weak, nonatomic) IBOutlet TapableSegmentControl *segmentService;

@end
