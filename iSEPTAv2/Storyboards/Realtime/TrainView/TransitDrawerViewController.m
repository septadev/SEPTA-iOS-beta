//
//  TransitDrawerViewController.m
//  iSEPTA
//
//  Created by Administrator on 9/22/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TransitDrawerViewController.h"

@interface TransitDrawerViewController ()

@end

@implementation TransitDrawerViewController

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
    
    UIStoryboard *tdStoryboard = [UIStoryboard storyboardWithName:@"TransitDataStoryboard" bundle:nil];
    TransitDataViewController *tvVC = (TransitDataViewController*)[tdStoryboard instantiateInitialViewController];
    
    UIStoryboard *tmStoryboard = [UIStoryboard storyboardWithName:@"TrainMapStoryboard" bundle:nil];
    TrainMapViewController *tmVC = (TrainMapViewController*)[tmStoryboard instantiateInitialViewController];
    
//    MMDrawerController *drawerController = [[MMDrawerController alloc]
//                                             initWithCenterViewController:tmVC
//                                             leftDrawerViewController:nil
//                                             rightDrawerViewController:tvVC];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
