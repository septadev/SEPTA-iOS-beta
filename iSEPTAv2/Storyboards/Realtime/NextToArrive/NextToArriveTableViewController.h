//
//  NextToArriveTableViewController.h
//  iSEPTA
//
//  Created by septa on 7/19/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

// Subclasses
#import "LineHeaderView.h"
#import "CustomFlatBarButton.h"
#import "MenuAlertsImageView.h"

#import "UITableViewStandardHeaderLabel.h"


// Pods
#import <REMenu.h>
#import <SVProgressHUD.h>
#import <Reachability.h>
#import <ALAlertBanner.h>
#import <FMDatabase.h>


// Nibs
#import "NextToArriveItineraryCell.h"
#import "NextToArriveSingleTripCell.h"
#import "NextToArriveConnectionTripCell.h"
#import "NextToArriveTripHistoryCell.h"


// Data Models
#import "ItineraryObject.h"
#import "TableViewStore.h"


#import "NTASaveObject.h"
#import "NTASaveController.h"

#import "NextToArrivaJSONObject.h"


// Storyboards
#import "StopNamesTableViewController.h"
#import "FareViewController.h"
#import "CommonWebViewController.h"


#define DEFAULT_MESSAGE @"Touch to enter location"
#define DEFAULT_START_MESSAGE @"Enter Start"
#define DEFAULT_END_MESSAGE   @"Enter Destination"
#define JSON_REFRESH_RATE 20.0f


//  --==
//  --==  Enumerations
//  --==
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


// --==
// --==  Refreshing  ==--
// --==
#define REFRESH_NO_STOPS      @"select trips before refreshing"
#define REFRESH_READY         @"click to refresh data"
#define REFRESH_IN_UNKNOWN    @"refreshing in..."
#define REFRESH_IN_X_SECS     @"refreshing in X seconds"

#define REFRESH_NOW           @"refreshing now"
#define REFRESH_NO_CONNECTION @"no Internet connection detected"


typedef NS_ENUM(NSInteger, NextToArriveRefreshStatusMessage)
{
    kNextToArriveRefreshStatusNoStops,
    kNextToArriveRefreshStatusReady,
    kNextToArriveRefreshStatusInUnknown,
    kNextToArriveRefreshStatusInXSecs,
    kNextToArriveRefreshStatusNow,
    kNextToArriveRefreshStatusNoConeection,
};


// --==
// --==  Favorites  ==--
// --==
#define FAVORITE_SUBTITLE_ADD    @"add route to favorites"
#define FAVORITE_SUBTITLE_REMOVE @"remove route from favorites"
#define FAVORITE_SUBTITLE_NONE   @"no routes have been selected"
typedef NS_ENUM(NSInteger, NextToArriveFavoriteSubtitleState)
{
    kNextToArriveFavoriteSubtitleStatusUnknown,
    kNextToArriveFavoriteSubtitleAdded,
    kNextToArriveFavoriteSubtitleNotAdded,
};


//@interface NTAProgressObject : NSObject
//
//@property (nonatomic, assign) int count;
//@property (nonatomic, assign) NextToArriveTripHistoryCell  *cell;
//@property (nonatomic, strong) NSTimer *timer;
//
//
//-(void) setMax:(int) max;
//-(void) startWithCell:(NextToArriveTripHistoryCell*) cell;
//-(void) clear;
//-(void) incrementCell:(NextToArriveTripHistoryCell*)cell;
//
//@end



@interface NextToArriveTableViewController : UITableViewController <NextToArriveItineraryCellProtocol, StopNamesTableViewControllerProtocol, UIGestureRecognizerDelegate>


//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureDoubleTap;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *gestureLongPress;




@end
