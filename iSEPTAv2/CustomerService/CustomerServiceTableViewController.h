//
//  CustomerServiceTableViewController.h
//  iSEPTA
//
//  Created by septa on 5/20/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAShapeLayer.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface CustomerServiceTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgColorBarCall;
@property (weak, nonatomic) IBOutlet UIImageView *imgColorBarFacebook;
@property (weak, nonatomic) IBOutlet UIImageView *imgColorBarTwitter;
@property (weak, nonatomic) IBOutlet UIImageView *imgColorBarComments;

@property (weak, nonatomic) IBOutlet UIImageView *imgIconCall;
@property (weak, nonatomic) IBOutlet UIImageView *imgIconFacebook;
@property (weak, nonatomic) IBOutlet UIImageView *imgIconTwitter;
@property (weak, nonatomic) IBOutlet UIImageView *imgIconComments;


@end
