//
//  BusSelectRouteViewController.h
//  iSEPTA
//
//  Created by septa on 10/22/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

#import "BusRouteSorterView.h"
#import "PassedRouteData.h"

#import "DisplayedRouteData.h"

enum
{
    kQueryNotYet,
    kQueryFailure,
    
    kQueryNormalBus,
    kQuerySearchBus,
    
} QueryTypeUsed;

@interface BusSelectRouteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, BusRouteSorterProtocol>
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

@end
