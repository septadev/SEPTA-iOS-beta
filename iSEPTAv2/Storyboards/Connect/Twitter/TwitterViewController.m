//
//  TwitterViewController.m
//  iSEPTA
//
//  Created by septa on 9/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TwitterViewController.h"

@interface TwitterViewController ()

@end

@implementation TwitterViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if ( self.startURL == nil )
    {
        self.startURL = [NSURL URLWithString:@"https://twitter.com/SEPTA_SOCIAL"];
    }
    
    [self.webView loadRequest: [NSURLRequest requestWithURL: self.startURL] ];
    [self.webView setHidden:NO];

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


#pragma mark - UIWebView Protocols
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"tVC - webView finished");
    [SVProgressHUD showWithStatus:@"Loading..."];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"tVC - webView finished");
    [SVProgressHUD dismiss];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"tVC - webView had errors: %@", error);
    [SVProgressHUD dismiss];    
}


@end
