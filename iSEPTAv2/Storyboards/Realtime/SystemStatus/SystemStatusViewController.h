//
//  SystemStatusViewController.h
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

// --==  Pods  ==--
#import <SVProgressHUD.h>
#import <Reachability.h>
#import <AFNetworking.h>


// --==  Data Models  ==--
#import "SystemStatusObject.h"
#import "SystemAlertObject.h"


// --==  Xibs  ==--
#import "SystemStatusCell.h"


// --==  Connected VCs  ==--
#import "SystemAlertsViewController.h"


// --==  Helper Classes
#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"
#import "TabbedButton.h"
#import "TableViewStore.h"


// --==  Categories  ==--
#import "UIColor+SEPTA.h"



//  --==
//  --==  Enumerations
//  --==
typedef NS_ENUM(NSInteger, SystemStatusFilterType)
{
    kSystemStatusFilterNone,
    kSystemStatusFilterByBusTrolley,
    kSystemStatusFilterByRail,
    kSystemStatusFilterByMFLBSLNHSL,
};




@interface SystemStatusViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, TabbedButtonProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeaderBar;
@property (weak, nonatomic) IBOutlet UILabel *lblHeader;

//@property (weak, nonatomic) IBOutlet UIButton *btnTransit;
//@property (weak, nonatomic) IBOutlet UIButton *btnRail;
//@property (weak, nonatomic) IBOutlet UIButton *btnMFLBSLNHSL;



// Unused
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentRouteType;

@end
