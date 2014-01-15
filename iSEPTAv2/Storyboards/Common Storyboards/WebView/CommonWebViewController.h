//
//  CommonWebViewController.h
//  iSEPTA
//
//  Created by septa on 1/11/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// --==  Helper Classes  ==--
#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"


@interface CommonWebViewController : UIViewController <UIWebViewDelegate>

/* UIWebViewDelegate: optional
 
 - (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
 - (void)webViewDidStartLoad:(UIWebView *)webView;
 - (void)webViewDidFinishLoad:(UIWebView *)webView;
 - (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;
 
 */

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSString *backImageName;
@property (nonatomic, strong, setter = setHTML:) NSString *html;

@end
