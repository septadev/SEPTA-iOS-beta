//
//  PassPerksViewController.m
//  iSEPTA
//
//  Created by Administrator on 9/12/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "PassPerksViewController.h"

@interface PassPerksViewController ()

@end

@implementation PassPerksViewController

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

    NSURL *url = [[NSURL alloc] initWithString:@"http://www.iseptaphilly.com/perks"];
        
    [self.webView loadRequest: [NSURLRequest requestWithURL: url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f] ];
    [self.webView setHidden:NO];
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"passPerks.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0,500, 32) withTitle:@"Pass Perks"];
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
