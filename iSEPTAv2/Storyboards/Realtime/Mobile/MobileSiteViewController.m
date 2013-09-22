//
//  MobileSiteViewController.m
//  iSEPTA
//
//  Created by Administrator on 9/12/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "MobileSiteViewController.h"

@interface MobileSiteViewController ()

@end

@implementation MobileSiteViewController

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
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.septa.org/m/"];
    [self.webView loadRequest: [NSURLRequest requestWithURL: url] ];
    [self.webView setHidden:NO];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
