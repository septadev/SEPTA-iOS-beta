//
//  StopNamesTableViewController.h
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// Headers
#import "GTFSCommon.h"


// PODs
#import <FMDatabase.h>


// Data Models
#import "StopNamesObject.h"
#import "TripData.h"
#import "RouteData.h"


// Data Manager
#import "TableViewStore.h"


// --==  Custom Xibs  ==--
#import "StopNamesCLEACell.h"


// Subclasses
#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"


// Storyboards
#import "CurrentLocationTableViewController.h"
#import "EnterAddressViewController.h"


typedef NS_ENUM(NSInteger, StopNamesTableViewControllerSelectionType)
{
    kNextToArriveSelectionTypeStart,
    kNextToArriveSelectionTypeEnd,
    kNextToArriveSelectionTypeStartAndEnd,
    kNextToArriveSelectionNone,
};


typedef NS_ENUM(NSInteger, StopNamesSpecialCell)
{
    kStopNamesSpecialCurrentLocation = -100,
    kStopNamesSpecialEnterAddress    = -101,
};


typedef NS_ENUM(NSInteger, StopNamesTableViewControllerButtonPressed)
{
    kNextToArriveButtonTypeDone        = 1,
    kNextToArriveButtonTypeLongPress   = 2,
    kNextToArriveButtonTypeDoubleTap   = 4,
    kNextToArriveButtonTypeCancel      = 8,
    
    kNextToArriveButtonMask            = 15,  // Needs to be 2^n - 1 of all the valid options.  2^4 - 1 = 15
    
    kNextToArriveButtonTypeStartField  = 16,
    kNextToArriveButtonTypeEndField    = 32,
};


@protocol StopNamesTableViewControllerProtocol <NSObject>
    -(void) buttonPressed:(StopNamesTableViewControllerButtonPressed) buttonType withData:(StopNamesObject*) stopData;
@end


@interface StopNamesTableViewController : UITableViewController <CurrentLocationProtocol>

@property (nonatomic, weak) id<StopNamesTableViewControllerProtocol> delegate;
//@property (nonatomic, strong) StopNamesObject *stopData;
@property (nonatomic, strong) RouteData *stopData;
@property (nonatomic, assign) NSInteger selectionType;
@property (nonatomic, assign) SEPTARouteTypes routeType;
@property (nonatomic, strong) NSString *backImageName;

-(void) setSelectionType: (NSInteger) selectionType;
-(NSInteger) selectionType;

@end
