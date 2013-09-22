//
//  FindSchedulesViewController.h
//  iSEPTA
//
//  Created by septa on 6/27/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// Custom Class
#import "BasicRouteObject.h"  // Data sent over from previous view controller
#import "BusScheduleData.h"   // Holds JSON data


// Custom Cell
#import "FindSchedulesCell.h"


// POD Includes
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SVPullToRefresh.h"


@interface FindSchedulesViewController : UIViewController


@property (weak, nonatomic) IBOutlet UISegmentedControl *segFilter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) BasicRouteObject *basicRoute;

@end
