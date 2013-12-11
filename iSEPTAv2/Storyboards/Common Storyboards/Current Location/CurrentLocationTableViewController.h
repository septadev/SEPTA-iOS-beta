//
//  CurrentLocationTableViewController.h
//  iSEPTA
//
//  Created by septa on 7/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"


// PODs
#import <FMDatabase.h>
#import <SVPullToRefresh.h>


// Subclasses
#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"


// Custom Cells
//#import "BusRouteIndicatorCell.h"
#import "CurrentLocationCell.h"
#import "BasicRouteObject.h"
#import "GTFSCommon.h"

#import "RouteData.h"
#import "LocationObject.h"


//  --==  ViewControllers  ==--
#import <CurrentLocationProtocol.h>

#import "EnterAddressViewController.h"
#import "StopNamesTableViewController.h"






typedef NS_ENUM(NSInteger, CurrentLocationRouteType)
{
    kCurrentLocationRouteTypeBusOnly = 1,
    kCurrentLocationRouteTypeRailOnly = 2,
    kCurrentLocatinRouteTypeBoth = 3,
};


@interface CurrentLocationTableViewController : UITableViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDismiss;
@property (strong, nonatomic) NSNumber *routeType;
@property (strong, nonatomic) RouteData *routeData;

@property (nonatomic, strong) LocationObject *coordinates;

@property (nonatomic, weak) id <CurrentLocationProtocol> delegate;

@property (nonatomic, strong) NSString *backImageName;


//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureDoubleTap;
//@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *gestureLongPress;


@end
