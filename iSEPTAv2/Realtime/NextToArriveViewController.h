//
//  NextToArriveViewController.h
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "StopTimesCell.h"
#import "StopNamesTableController.h"

#import "ItineraryCell.h"


typedef NS_ENUM(NSInteger, NextToArriveLeftButtonPressed)
{
    kNextToArriveNoButtonPressed      = 0,
    kNextToArriveStartButtonPressed   = 1,
    kNextToArriveEndButtonPressed     = 2,
    // 4
    // 8, etc.
};

typedef NS_ENUM(NSInteger, NextToArriveSection)
{
    kNextToArriveSectionStartEndCells,
    kNextToArriveSectionFavorites,
    kNextToArriveSectionRecent,
    kNextToArriveSectionData,
};



#define REFRESH_NO_STOPS @"select trips before refreshing"
#define REFRESH_READY    @"click to refresh data"
#define REFRESH_IN_UNKNOWN @"refreshing in..."
#define REFRESH_IN_X_SECS  @"refreshing in X seconds"
#define REFRESH_NOW        @"refreshing now"

typedef NS_ENUM(NSInteger, NextToArriveRefreshStatusMessage)
{
    kNextToArriveRefreshStatusNoStops,
    kNextToArriveRefreshStatusReady,
    kNextToArriveRefreshStatusInUnknown,
    kNextToArriveRefreshStatusInXSecs,
    kNextToArriveRefreshStatusNow,
};


@interface NextToArriveViewController : UIViewController <UIGestureRecognizerDelegate, ItineraryCellProtocol, StopNamesDelegate, CurrentLocationProtocol>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentRouteType;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnRetrieveData;

@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *gestureLongPress;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureDoubleTap;




@end
