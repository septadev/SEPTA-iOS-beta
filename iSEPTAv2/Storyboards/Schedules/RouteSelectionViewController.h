//
//  RouteSelectionViewController.h
//  iSEPTA
//
//  Created by septa on 8/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "sqlite3.h"

// --==  Xibs  ==--
#import "RouteSelectionCell.h"



#import "PassedRouteData.h"

#import "DisplayedRouteData.h"


#import "ItineraryViewController.h"
#import "NextToArriveAlerts.h"

// --==  Objects  ==--
#import "SystemStatusObject.h"
// --==  Objects  ==--


// --==  Helper Classes  ==--
#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"
#import "TableCellAlertsView.h"

#import "AlertMessage.h"
// --==  Helper Classes  ==--



typedef NS_ENUM(NSInteger, QueryTypeUsed)
{
    kQueryNotYet,
    kQueryFailure,
    
    kQueryNormalBus,
    kQuerySearchBus,
    
};


@interface RouteSelectionViewController : UIViewController <RouteSelectionCellProtocol>
{
    NSMutableArray *unfilteredList;
    NSMutableArray *filteredList;
    
    sqlite3 *dbh;
    
    NSString *busFilterStr;
    NSString *searchStr;
    int queryType;
    BOOL _segueInAction;
    
    BusRouteSorterView *sorterBar;
    
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentBusSorter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navbarSearchButton;

@property (nonatomic, strong) NSString *travelMode;

-(CAShapeLayer*) formatCell:(UITableViewCell*) cell forIndexPath:(NSIndexPath*) indexPath;

@end
