//
//  MoreDetailsViewController.h
//  iSEPTA
//
//  Created by septa on 9/5/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

// --==  PODs  ==--
#import <SVProgressHUD.h>


@interface MoreDetailsViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
