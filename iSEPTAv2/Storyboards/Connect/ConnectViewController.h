//
//  ConnectViewController.h
//  iSEPTA
//
//  Created by Administrator on 8/19/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


// --==  Connecting View Controllers  ==--
#import "FareViewController.h"
#import "TwitterViewController.h"
#import "FacebookViewController.h"

#import "FeedbackQuickViewController.h"


// --==  Helper Classes  ==--
#import "SEPTATitle.h"

// --==  PODs  ==--
#import <SVProgressHUD.h>


typedef NS_ENUM(NSInteger, ConnectCellOrder)  // According to the GTFS guidelines
{
    kConnectCellOrderFareInformation = 0,
    kConnectCellOrderCustomerService,
    kConnectCellOrderFacebook,
    kConnectCellOrderTwitter,
    kConnectCellOrderComments,
    kConnectCellOrderLeaveFeedback,
};


@interface ConnectViewController : UITableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>

@end
