//
//  SystemAlertsViewController.h
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


#import "SystemStatusObject.h"
#import "SystemAlertObject.h"
#import "SVProgressHUD.h"

// Helper Classes
#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"
#import "ElevatorStatusObject.h"


// PODs
#import <Reachability/Reachability.h>


//  --==
//  --==  Enumerations
//  --==
typedef NS_ENUM(NSInteger, SystemAlertType)
{
    kSystemAlertTypeAlert      = 0,
    kSystemAlertTypeSuspend,
    kSystemAlertTypeDetour,
    kSystemAlertTypeAdvisory,
    kSystemAlertTypeElevator,
};


@interface SystemAlertsViewController : UIViewController <UIWebViewDelegate>
{
    
}


@property (nonatomic, strong) NSString *backImageName;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentAlertType;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

//@property (strong, nonatomic) NSNumber *numberOfAlerts;
//@property (strong, nonatomic) NSArray *alerts;
//@property (strong, nonatomic) NSString *route_id;

@property (strong, nonatomic) SystemStatusObject *ssObject;
@property (strong, nonatomic) NSMutableArray     *alertArr;

@property (weak, nonatomic) IBOutlet UIImageView *imgColorBar;


@end
