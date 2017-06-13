//
//  CommentFormViewController.m
//  iSEPTA
//
//  Created by septa on 1/7/15.
//  Copyright (c) 2015 SEPTA. All rights reserved.
//

#import "CommentFormViewController.h"

@interface CommentFormViewController ()

@end

@implementation CommentFormViewController

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
    
    NSURL *url = [[NSURL alloc] initWithString:@"https://www3.septa.org/customerservice/VeritasFormMobile/"];
//    NSURL *url = [[NSURL alloc] initWithString:@"http://apitest.septa.org/Playground/awfz_captchaV2/"];
//    http://apitest.septa.org/Playground/awfz_captchaV2/
    
    
    
    [self.webView loadRequest: [NSURLRequest requestWithURL: url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f] ];
    [self.webView setHidden:NO];
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"commentsBack.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0,500, 32) withTitle:@"Comments"];
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
