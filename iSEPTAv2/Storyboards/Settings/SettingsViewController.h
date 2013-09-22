//
//  SettingsViewController.h
//  iSEPTA
//
//  Created by septa on 9/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// --==  Connecting View Controllers  ==--


// --==  Helper Classes  ==--
#import "SEPTATitle.h"


// --==  PODs  ==--
#import <SVProgressHUD.h>


typedef NS_ENUM(NSInteger, SettingsCellOrder)  // According to the GTFS guidelines
{
    kSettingsCellOrderPushNotifications = 0,
    kSettingsCellOrderActiveAlarms,
    kSettingsCellOrder24HourTime,
    kSettingsCellOrderUpdate,
    kSettingsCellOrderAttributions,
};


@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *swt24Hour;


@end
