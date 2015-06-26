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
    
    // @"http://septa.org/service/septa-app.html"
//    NSURL *url = [[NSURL alloc] initWithString:@"http://www.septa.org/m/"];
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.septa.org/service/septa-app-mobile.html"];
        
    [self.webView loadRequest: [NSURLRequest requestWithURL: url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f] ];
    [self.webView setHidden:NO];
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"tipsBack.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0,500, 32) withTitle:@"Tips"];
    [self.navigationItem setTitleView:titleView];
    
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


-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
