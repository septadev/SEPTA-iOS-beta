//
//  MoreDetailsViewController.m
//  iSEPTA
//
//  Created by septa on 9/5/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "MoreDetailsViewController.h"

@interface MoreDetailsViewController ()

@end

@implementation MoreDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.septa.org/m/fares/"];
    [self.webView loadRequest: [NSURLRequest requestWithURL: url] ];
    [self.webView setHidden:NO];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    
    [self setWebView:nil];
    [super viewDidUnload];
    
}


//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    
//}


#pragma mark - UIWebView Protocols
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    NSLog(@"MDVC - webView finished");
    [SVProgressHUD dismiss];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"MDVC - webView had errors: %@", error);
    [SVProgressHUD dismiss];
}


@end
