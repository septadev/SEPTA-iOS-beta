//
//  CCTConnectViewController.m
//  iSEPTA
//
//  Created by septa on 5/3/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "CCTConnectViewController.h"

@interface CCTConnectViewController ()

@end

@implementation CCTConnectViewController
{

    NSOperationQueue *_webQueue;
    NSBlockOperation *_webOp;
    
}

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
    
    _webQueue = [[NSOperationQueue alloc] init];
    
    [self parseCCTDataInBackground];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_webQueue cancelAllOperations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) parseCCTDataInBackground
{
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    _webOp = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = _webOp;
    [weakOp addExecutionBlock:^{
        
        CCTParser *parse = [[CCTParser alloc] init];
        
        if ( ![weakOp isCancelled] )
        {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                [self displayCCTData: parse];
                
            }];
        }
        else
        {
            NSLog(@"CCVC - web request: _webOp cancelled");
        }
        
    }];
    
    [_webQueue addOperation: _webOp];
    
}


-(void) displayCCTData: (CCTParser*) parse
{
    [self.webView loadHTMLString:parse.html baseURL:nil];
    [SVProgressHUD dismiss];
}


- (void)viewDidUnload
{
    
    [self setWebView:nil];
    [super viewDidUnload];
    
}

#pragma mark - UIWebView
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

@end
