//
//  FacebookViewController.h
//  iSEPTA
//
//  Created by septa on 9/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// --==  PODs  ==--
#import <SVProgressHUD/SVProgressHUD.h>


@interface FacebookViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *startURL;

@end
