//
//  TrainSlidingViewController.m
//  iSEPTA
//
//  Created by septa on 9/23/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TrainSlidingViewController.h"

@interface TrainSlidingViewController ()

@end

@implementation TrainSlidingViewController
{
    TrainMapViewController *_tmvc;
    TrainRealtimeDataViewController *_trdvc;
}

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
    
    UIStoryboard *storyboard;

    storyboard = [UIStoryboard storyboardWithName:@"TrainSlidingStoryboard" bundle:nil];
    [self setTopViewController: [storyboard instantiateViewControllerWithIdentifier:@"Map"] ];
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"TSVC:vDD - view Did Disappear");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
