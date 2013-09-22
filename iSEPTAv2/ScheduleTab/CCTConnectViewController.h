//
//  CCTConnectViewController.h
//  iSEPTA
//
//  Created by septa on 5/3/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CCTParser.h"

#import "SVProgressHUD.h"

@interface CCTConnectViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
