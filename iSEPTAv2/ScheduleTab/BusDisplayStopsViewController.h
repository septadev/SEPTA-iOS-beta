//
//  BusDisplayStopsViewController.h
//  iSEPTA
//
//  Created by septa on 11/2/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "TapableSegmentControl.h"

//#import "PassedRouteData.h"
#import "DisplayedRouteData.h"

@interface BusDisplayStopsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate> //, UISearchDisplayDelegate>
{

    sqlite3 *db;
    
}

//@property (weak, nonatomic) IBOutlet UISegmentedControl *btnToFrom;
@property (weak, nonatomic) IBOutlet TapableSegmentControl *btnToFrom;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

//@property (strong, nonatomic) NSString *routeID;
//@property (strong, nonatomic) NSString *routeName;

@property (strong, nonatomic) DisplayedRouteData *routeData;

@property (nonatomic, strong) NSString *travelMode;


@end
