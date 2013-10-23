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
    
}

-(void)viewWillAppear:(BOOL)animated
{

    UIStoryboard *storyboard;
    
    storyboard = [UIStoryboard storyboardWithName:@"TrainSlidingStoryboard" bundle:nil];
    
    TrainMapViewController *tmvc = [storyboard instantiateViewControllerWithIdentifier:@"Map"];
    
    [tmvc setRouteName: self.routeName];
    [tmvc setTravelMode:self.travelMode];
    [tmvc setBackImageName: self.backImageName];
    
    [self setTopViewController: tmvc ];

}


-(void)viewDidDisappear:(BOOL)animated
{

    
    [super viewDidDisappear:animated];
    NSLog(@"TSVC:vDD - view Did Disappear");
    
//    [self setTopViewController:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
//    [self setTopViewController: nil];
    
}

@end
