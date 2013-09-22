//
//  SeptaMapViewController.m
//  iSEPTA
//
//  Created by septa on 8/27/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "SeptaMapViewController.h"

@interface SeptaMapViewController ()

@end

@implementation SeptaMapViewController
{
    UIImageView *_systemMapView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.scrollView setZoomScale:0.5f];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage *systemMap = [UIImage imageNamed:@"System-Map.png"];
    CGSize mapSize = [systemMap size];
    
    
    UIImage *logo = [UIImage imageNamed:@"SEPTA_logo.png"];
    
    SEPTATitle *newView = [[SEPTATitle alloc] initWithFrame:CGRectMake(0, 0, logo.size.width, logo.size.height) andWithTitle:@"Map"];
    [newView setImage: logo];
    
    [self.navigationItem setTitleView: newView];
    [self.navigationItem.titleView setNeedsDisplay];

    
    
    _systemMapView = [[UIImageView alloc] initWithImage: systemMap];
    
    [self.scrollView setContentSize:mapSize];
    [self.scrollView setScrollEnabled:YES];

    [self.scrollView addSubview: _systemMapView];
    
    [self.scrollView setContentOffset:CGPointMake(mapSize.width/2, mapSize.height * (0.45) )];

    self.scrollView.minimumZoomScale=0.25;
    self.scrollView.maximumZoomScale=4.0;
    self.scrollView.delegate=self;
    
//    [self.scrollView setZoomScale: 0.25f];
    
    
    
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ];
    backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [backgroundImage setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
//    [self.view addSubview:backgroundImage];
//    [self.view sendSubviewToBack:backgroundImage];

    [self.scrollView setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"mainBackground.png"] ] ];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
}

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _systemMapView;
}


@end
