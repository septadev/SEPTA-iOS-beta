//
//  NearestTimesViewController.h
//  iSEPTA
//
//  Created by septa on 9/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// --==  Data Models  ==--
#import "BasicRouteObject.h"
#import "BusScheduleData.h"


// --==  Helper Classes  ==--
#import "TableViewStore.h"
#import "GetAlertDataAPI.h"
#import "CustomFlatBarButton.h"


// --==  PODs  ==--
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <FMDB/FMDatabase.h>

// --==  Xibs  ==--
#import "NearestTimeCell.h"


// --==  ViewControllers  ==--
#import "SystemAlertsViewController.h"


@interface NearestTimesViewController : UIViewController <GetAlertDataAPIProtocol>

@property (weak, nonatomic) IBOutlet UILabel *lblRoute;
@property (weak, nonatomic) IBOutlet UILabel *lblAlerts;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) BasicRouteObject *routeData;

@end
