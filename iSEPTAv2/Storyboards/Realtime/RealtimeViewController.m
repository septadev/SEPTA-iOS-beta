//
//  RealtimeViewController.m
//  iSEPTA
//
//  Created by septa on 7/19/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "RealtimeViewController.h"


@interface RealtimeViewController ()

@end

@implementation RealtimeViewController
{
    UIImageView *_backgroundImage;
    BOOL _startTest;
    int _counter;
//    MMDrawerController *_drawerController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{

    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
    {
        // Disable realtime buttons if no internet connection is available
        
//        [self.btnNextToArrive setEnabled:NO];
//        [self.btnSystemStatus setEnabled:NO];
//        [self.btnTrainView setEnabled:NO];
//        [self.btnTransitView setEnabled:NO];
//        [self.btnFindNearestLocation setEnabled:NO];
        
    }

    if ( _startTest )
    {
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(popTheVC) userInfo:nil repeats:NO];
    }
    
}


-(void) popTheVC
{
    _counter++;
    NSLog(@"Transition: %d", _counter);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MemoryTestStoryboard" bundle:nil];
    MapMemoryTestViewController *tvVC = (MapMemoryTestViewController*)[storyboard instantiateInitialViewController];
    [tvVC setCounter: _counter];
    [self.navigationController pushViewController:tvVC animated:YES];
}

//-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    if ( !UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) )
//    {
//        [_backgroundImage setTransform: CGAffineTransformMakeRotation( -0.5*M_PI )];
//        [_backgroundImage setFrame:CGRectMake(0, 0, 480, 300)];
//    }
//    else
//    {
//        [_backgroundImage setTransform: CGAffineTransformMakeRotation( 0 )];
//        [_backgroundImage setFrame:CGRectMake(0, 0, 320, 460)];
//    }
//}


//-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//
//    
//    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
//    {
//        [_backgroundImage setTransform: CGAffineTransformMakeRotation( -0.5*M_PI )];
//        [_backgroundImage setFrame:CGRectMake(0, 0, 480, 300)];
//    }
//    else
//    {
//        [_backgroundImage setTransform: CGAffineTransformMakeRotation( 0 )];
//        [_backgroundImage setFrame:CGRectMake(0, 0, 320, 460)];
//    }
//
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _startTest = NO;
    _counter = 0;
    
    // Do any additional setup after loading the view.

//    [self.view setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ] ];  // Does not work
    
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ];
//    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG_pattern.png"] ];
//    backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [backgroundImage setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [backgroundImage setFrame:CGRectMake(0, 0, 320, 460)];

//    [self.view addSubview:_backgroundImage];
//    [self.view sendSubviewToBack:_backgroundImage];
    
//    [[UINavigationBar appearance] setTintColor: [UIColor blackColor] ];
    
    
    // TabBar BS
//    UITabBarItem *tbi = self.tabBarController.tabBarItem;
//    [tbi setFinishedSelectedImage:[UIImage imageNamed:@"tabRealtimeIcon.png"] withFinishedUnselectedImage: [UIImage imageNamed:@"tabRealtimeIconSelected.png"] ];
    
    
//    [[[self tabBarController] tabBar] setSelectionIndicatorImage: [UIImage imageNamed:@"tabRealtimeIconSelected.png"] ];

    
//    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabMapIconSelected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabMapIcon.png"] ];
    
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.view setBackgroundColor: backgroundColor];
    
    
    UIImage *logo = [UIImage imageNamed:@"SEPTA_logo.png"];

    SEPTATitle *newView = [[SEPTATitle alloc] initWithFrame:CGRectMake(0, 0, logo.size.width, logo.size.height) andWithTitle:@"Realtime"];
    [newView setImage: logo];
    
    [self.navigationItem setTitleView: newView];
    [self.navigationItem.titleView setNeedsDisplay];
    
//    [self.view bringSubviewToFront:newView];
        
    
//    [[UITabBarItem appearance] setTitleTextAttributes:@{
//                                 UITextAttributeFont : [UIFont fontWithName:@"TrebuchetMS" size:40.0f],
//                            UITextAttributeTextColor : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],}
//                                             forState:UIControlStateNormal];
//    
//    [[UINavigationBar appearance] setTitleTextAttributes:@{
//                                    UITextAttributeFont : [UIFont fontWithName:@"TrebuchetMS" size:20.0f],
//                               UITextAttributeTextColor : [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]}];

//    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:107.0/256.0 green:145.0/256.0 blue:35.0/256.0 alpha:1.0]];
    
//    [self setTitle:@"Realtime"];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    
    [self setBtnNextToArrive:nil];
    [self setBtnTrainView:nil];
    [self setBtnTransitView:nil];
    
    [self setBtnFindNearestLocation:nil];
    [self setBtnSystemStatus:nil];
    [self setBtnGuide:nil];
    
    [super viewDidUnload];
    
}


#pragma mark -= Button Presses
- (IBAction)btnNextToArrivePressed:(id)sender
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NextToArriveStoryboard" bundle:nil];
    NextToArriveTableViewController *ntaVC = (NextToArriveTableViewController*)[storyboard instantiateInitialViewController];
    
    [self.navigationController pushViewController:ntaVC animated:YES];
    
}

- (IBAction)btnTrainViewPressed:(id)sender
{

//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TrainViewStoryboard" bundle:nil];
//    TrainViewViewController *tvVC = (TrainViewViewController*)[storyboard instantiateInitialViewController];
//    [self.navigationController pushViewController:tvVC animated:YES];
//    
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MemoryTestStoryboard" bundle:nil];
//    MapMemoryTestViewController *tvVC = (MapMemoryTestViewController*)[storyboard instantiateInitialViewController];
//    _startTest = YES;
//    [tvVC setCounter: _counter];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TrainSlidingStoryboard" bundle:nil];
    TrainViewViewController *tvVC = (TrainViewViewController*)[storyboard instantiateInitialViewController];
    [self.navigationController pushViewController:tvVC animated:YES];
    

}


- (IBAction)btnTransitViewPress:(id)sender
{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TransitViewStoryboard" bundle:nil];
    TransitViewViewController *tvVC = (TransitViewViewController*)[storyboard instantiateInitialViewController];
    
//    [tvVC setTravelMode:@"Rail"];
    
    [self.navigationController pushViewController:tvVC animated:YES];

    
}

- (IBAction)btnSystemStatusPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SystemStatusStoryboard" bundle:nil];
    SystemStatusViewController *ssVC = (SystemStatusViewController*)[storyboard instantiateInitialViewController];
    
    //    [tvVC setTravelMode:@"Rail"];
    
    [self.navigationController pushViewController:ssVC animated:YES];
}

- (IBAction)btnFindNearestLocationPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NearestLocationStoryboard" bundle:nil];
    NearestLocationViewController *nlVC = (NearestLocationViewController*)[storyboard instantiateInitialViewController];
    
    //    [tvVC setTravelMode:@"Rail"];
    
    [self.navigationController pushViewController:nlVC animated:YES];
    
}


- (IBAction)btnGuidePressed:(id)sender
{
    
}






@end
