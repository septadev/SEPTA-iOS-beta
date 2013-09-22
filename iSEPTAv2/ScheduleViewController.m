//
//  SecondViewController.m
//  test
//
//  Created by Justin Brathwaite on 1/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScheduleViewController.h"

//#import "BusRoutesTableViewController.h"
#import "BusSelectRouteViewController.h"
#import "BusDisplayStopsViewController.h"
//#import "busRoutes.h"

#import "ItineraryTripViewController.h"

#import "DisplayedRouteData.h"

#import "AppDelegate.h"
@implementation ScheduleViewController

//#define OLD_MARKET_BUTTON
//#define OLD_BUS_BUTTON
//#define OLD_REGIONAL_RAIL_BUTTON
//#define OLD_NORRISTOWN_BUTTON
//#define OLD_BROAD_STREET_BUTTON

//busRoutes *viewcontroller;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
      self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"splashblank.png"]];
    [scrollview setScrollEnabled:YES];

//    NSLog(@"scrollview frame height: %6.2f, bound height: %6.2f", scrollview.frame.size.height, scrollview.bounds.size.height);
    [scrollview setContentSize: CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
//    [scrollview setContentSize: CGSizeMake(320, 970)];
    [scrollview setShowsVerticalScrollIndicator:YES];
    [self createMenu];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    float tabHeight = self.tabBarController.tabBar.frame.size.height;
    float navHeight = self.navigationController.navigationBar.frame.size.height;
    float viewHeight = self.view.frame.size.height;
    float scrollHeight = scrollview.frame.size.height;
    [scrollview setScrollIndicatorInsets: UIEdgeInsetsMake(0, 0, scrollHeight-viewHeight+tabHeight+navHeight, 0)]; // top, left, bottom, right

    NSLog(@"RVC - tabHeight: %6.2f, navHeight: %6.2f, viewHeight: %6.2f, scrollHeight: %6.2f", tabHeight, navHeight, viewHeight, scrollHeight);
    NSLog(@"RVC - view frame: %@", NSStringFromCGRect(self.view.frame));
    
    
//    NSLog(@"tab height: %6.2f, nav height: %6.2f, view height: %6.2f, scroll height: %6.2f", tabHeight, navHeight, viewHeight, scrollHeight);
//    NSLog(@"scrollInsets: t:%6.2f, l: %6.2f, b: %6.2f, r: %6.2f", scrollview.scrollIndicatorInsets.top, scrollview.scrollIndicatorInsets.left, scrollview.scrollIndicatorInsets.bottom, scrollview.scrollIndicatorInsets.right );
//    NSLog(@"scroll CS   : w: %6.2f, h: %6.2f", scrollview.contentSize.width, scrollview.contentSize.height);
}


- (void)createMenu
{
   // CGRect frameMFLButton = CGRectMake(0, 10.0, 95, 50.0);
   // MFLButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

#ifdef OLD_MARKET_BUTTON
    [MFLButton addTarget:self
                  action:@selector(goButtonPressed:)
        forControlEvents:UIControlEventTouchDown];
#endif
    
   // MFLButton.frame = frameMFLButton;
    //[MFLButton setTitle:@"MFL" forState:UIControlStateNormal];
    //[self.view addSubview:MFLButton];
    
    
   // CGRect frameBusButton = CGRectMake(0, 70.0, 95, 50.0);
    //BusButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
#ifdef OLD_BUS_BUTTON
    [BusButton addTarget:self 
                  action:@selector(goButtonPressed:)
        forControlEvents:UIControlEventTouchDown];
#endif
    
    //BusButton.frame = frameBusButton;
    //[BusButton setTitle:@"Bus" forState:UIControlStateNormal];
    //[self.view addSubview:BusButton];
    
    //CGRect frameBSSButton = CGRectMake(0, 125.0, 95, 50.0);
    //BSSButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

#ifdef OLD_BROAD_STREET_BUTTON
    [BSSButton addTarget:self
                  action:@selector(goButtonPressed:)
        forControlEvents:UIControlEventTouchDown];
#endif
    
    //BSSButton.frame = frameBSSButton;
    //[BSSButton setTitle:@"BSS" forState:UIControlStateNormal];
    //[self.view addSubview:BSSButton];
    
   // CGRect frameNHSLButton = CGRectMake(0, 185.0, 95, 50.0);
    //NHSLButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
#ifdef OLD_NORRISTOWN_BUTTON
    [NHSLButton addTarget:self 
                   action:@selector(goButtonPressed:)
         forControlEvents:UIControlEventTouchDown];
#endif
    
   // NHSLButton.frame = frameNHSLButton;
    //[NHSLButton setTitle:@"NHSL" forState:UIControlStateNormal];
    //[self.view addSubview:NHSLButton];
    
    //CGRect frameRegionalRailButton = CGRectMake(0, 250.0, 105, 50.0);
    //RegionalRailButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

#ifdef OLD_REGIONAL_RAIL_BUTTON
    [RegionalRailButton addTarget:self
                           action:@selector(goButtonPressed:)
                 forControlEvents:UIControlEventTouchDown];
#endif
    
    //RegionalRailButton.frame = frameRegionalRailButton;
    //[RegionalRailButton setTitle:@"Regional Rail" forState:UIControlStateNormal];
    //[self.view addSubview:RegionalRailButton];
    
}


-(void) goButtonPressed:(id)sender
{
    
//    viewcontroller=[[busRoutes alloc]initWithNibName:nil bundle:nil];
//    viewcontroller.title =@"Routes";
//    AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    
//    if(sender ==MFLButton)
//    {
//        appDelegate.busdata.mode = @"MFL";
////        appDelegate.busdata.mode = @"Bus";
//    }
//    if(sender ==BSSButton)
//    {
//        appDelegate.busdata.mode = @"BSS";
//    }
//    if(sender ==NHSLButton)
//    {
//        appDelegate.busdata.mode = @"NHSL";
//    }
//    if(sender ==BusButton)
//    {
//        appDelegate.busdata.mode = @"Bus";
//    }
//    if(sender ==RegionalRailButton)
//    {
//        appDelegate.busdata.mode = @"Regional Rail";
//    }
//    
//    NSLog(@"mfl pressed %@",appDelegate.busdata.mode);
//    [self.navigationController pushViewController:viewcontroller animated:YES];
    
}


- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}


//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//    } else {
//        return YES;
//    }
//}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Send travelMode to the new view controller
 
    if ( [[segue identifier] isEqualToString:@"BusSegueIdentifier"] )
    {
        BusSelectRouteViewController *scheduleVC = [segue destinationViewController];
        [scheduleVC setTravelMode:@"Bus"];
    }
    else if ( [[segue identifier] isEqualToString:@"TrolleySegue"] )
    {
        BusSelectRouteViewController *scheduleVC = [segue destinationViewController];
        [scheduleVC setTravelMode:@"Trolley"];
    }

    else if ( [[segue identifier] isEqualToString:@"MarketFrankfordIdentifier"])
    {
        BusSelectRouteViewController *scheduleVC = [segue destinationViewController];
        [scheduleVC setTravelMode:@"MFL"];

    }
    else if ( [[segue identifier] isEqualToString:@"RegionalRailSegueIdentifier"])
    {
        BusSelectRouteViewController *scheduleVC = [segue destinationViewController];
        [scheduleVC setTravelMode:@"Rail"];

    }
    else if ( [[segue identifier] isEqualToString:@"NorristownHighSpeedIdentifier"])
    {
        
        BusSelectRouteViewController *scheduleVC = [segue destinationViewController];
//        BusDisplayStopsViewController *scheduleVC = [segue destinationViewController];
        
        // The issue, skipping BusSelectRoute skips over Recently Viewed and Favorites too
        
//        DisplayedRouteData *routeData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingNHSL];
//        [[routeData current] setRoute_id:@"10795"];
//        [[routeData current] setRoute_short_name:@"NHSL"];
//        [[routeData current] setRoute_long_name:@"Norristown TC to 69th St TC"];
//        [[routeData current] setRoute_type:[NSNumber numberWithInt:0] ];
//        [[routeData current] setDatabase_type: kDisplayedRouteDataUsingDBBus];
//        
//        [scheduleVC setRouteData: routeData];
        
        
        [scheduleVC setTravelMode:@"NHSL"];

        
//        [_routeData.current setRoute_id        : [[ref objectAtIndex:index] route_id] ];
//        [_routeData.current setRoute_short_name: [[ref objectAtIndex:index] route_short_name] ];
//        [_routeData.current setRoute_type:       [[ref objectAtIndex:index] route_type] ];
//        [_routeData.current setDatabase_type:    _routeData.databaseType];
        
    }
    else if ( [[segue identifier] isEqualToString:@"BroadStreetSubwayIdentifier"] )
    {
        BusSelectRouteViewController *scheduleVC = [segue destinationViewController];
        [scheduleVC setTravelMode:@"BSS"];
    }
    
    
}




@end
