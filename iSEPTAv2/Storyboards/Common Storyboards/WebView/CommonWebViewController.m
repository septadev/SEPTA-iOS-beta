//
//  CommonWebViewController.m
//  iSEPTA
//
//  Created by septa on 1/11/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "CommonWebViewController.h"

@interface CommonWebViewController ()

@end

@implementation CommonWebViewController

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
    
//    NSString *cssBody = @"body{ color:#333;font-family:verdana,helvetica, arial, helvetica, sans-serif;line-height:18px;margin:0 10px 10px 10px;font-size:14px;}";
    
    [self.webView loadHTMLString:self.html baseURL:nil];
    
    // --=============================--
    // --==  Configure Back Button  ==--
    // --=============================--
    CustomFlatBarButton *backBarButtonItem;
    if ( self.backImageName != NULL )
    {
        backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:self.backImageName withTarget:self andWithAction:@selector(backButtonPressed:)];
    }
    else
    {
        backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"system_status-white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    }
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: self.title];
    [self.navigationItem setTitleView:titleView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
// 
//    [self.webView loadHTMLString:self.html baseURL:nil];
//    
//}


#pragma mark - Buttons Pressed
-(void) backButtonPressed:(id) sender
{
    
    //    NSLog(@"Custom Back Button -- %@", sender);
    //    [self dismissModalViewControllerAnimated:YES];  // Does not work
    //    [self removeFromParentViewController];   // Does nothing!
    //    [self.view removeFromSuperview];  // Removed from Superview but doesn't go back to previous VC
    
    
    //    [self.navigationController removeFromParentViewController];  // Does not work, does not do anything
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
