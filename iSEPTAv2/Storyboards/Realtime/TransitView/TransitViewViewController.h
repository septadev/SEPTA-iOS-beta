//
//  TransitViewViewController.h
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// --==  View Controllers  ==--
#import "TrainViewViewController.h"
//#import "OldTrainViewViewController.h"
#import "TrainSlidingViewController.h"


// --==  Helper Classes  ==--
#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"


// --==  Pods  ==--
#import "FMDatabase.h"


// --==  Data Models  ==--
#import "RouteInfo.h"
#import "ServiceHours.h"

#import "SystemStatusObject.h"

// --==  Xib Models  ==--
#import "TransitRouteListCell.h"
#import "TransitServiceCell.h"


@interface TransitViewViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *lblRouteName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleServiceHours;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceHours;

@end
