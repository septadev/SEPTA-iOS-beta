//
//  MapsViewController.m
//  iSEPTA
//
//  Created by septa on 7/12/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "MapsViewController.h"

@interface MapsViewController ()

@end

@implementation MapsViewController

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
    
    //[self.view setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ] ];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"]];
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
