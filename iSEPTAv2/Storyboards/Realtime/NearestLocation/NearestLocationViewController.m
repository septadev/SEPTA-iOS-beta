//
//  NearestLocationViewController.m
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NearestLocationViewController.h"

@interface NearestLocationViewController ()

@end

@implementation NearestLocationViewController
{
    
    NSMutableArray *_tableData;
    NSMutableArray *_masterList;
    
    CLLocationManager *_locationManager;
    
    BOOL _stillWaitingOnWebRequest;
    NSArray *_locationType;
    
    CHDigitInput *digitInput;
    BOOL _digitInputActive;
    float radiusInMiles;
    
    UIView *radiusView;
    
    
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_jsonOp;
    BOOL _cancelOperations;
    
    
    CLRegion *_clRegion;
    CLLocationCoordinate2D _loc;
    
    BOOL locationEnabled;
    
    SaveController *userSave;
    FindNearestRouteSaveObject *savedInfo;
    
    
    // --==  For Refresh Timer  ==--
    NSTimer *updateTimer;
    NSDate *_updateFireDate;
    BOOL _killAllTimers;

    // --==  SVProgressHUD  ==--
    int _dismissCounter;
    
    // --==  AFNetworking Queue List  ==--
    
    
    // --==  DistanceView  ==--
    DistanceView *_dView;
    
    
    // --==  Button in the View that is in the Right Bar Button Item  ==--
    UIButton *_button;
    
}

@synthesize mapView;
@synthesize tableView;

//@synthesize btnRadius;
//@synthesize segmentTypes;


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
    
    [super viewWillAppear:animated];

    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
    
    [self updateViewsWithOrientation: [[UIApplication sharedApplication] statusBarOrientation] ];
    

    _cancelOperations = NO;
    _killAllTimers = NO;
    
    
    if (_updateFireDate == nil )
    {
//        [self getLatestJSONData];  // Kick it off immediately
        NSLog(@"NLVC:vWA - FIRST KICK OFF!");
        return;
    }
    
    // Otherwise continue...
    NSDateFormatter *hoursFormat = [[NSDateFormatter alloc] init];
    [hoursFormat setDateFormat:@"HHmm"];
    
    // This won't work when now or then are separated by a day.  ;_;
    int now = [[hoursFormat stringFromDate:[NSDate date] ] intValue];
    int then = [[hoursFormat stringFromDate: _updateFireDate] intValue];
    
    if ( now > then )  // If the updateFireData is older than now, kick off another one otherwise wait for it to kick in
    {
//        [self getLatestJSONData];
        NSLog(@"NLVC:vWA - SECOND KICK OFF!");
        return;
    }
//        [self kickOffAnotherJSONRequest];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"NLVC - viewDidDisappear");
    [super viewDidDisappear:animated];
    
    [_jsonQueue cancelAllOperations];
    _dismissCounter = 0;
    
    [SVProgressHUD popActivity];
    
    [userSave save];
    
    _killAllTimers = YES;
    [self invalidateTimer];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"NFNVC - viewDidLoad");
    
	// Do any additional setup after loading the view.
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusRouteIndicatorCell" bundle:nil] forCellReuseIdentifier:@"BusRouteIndicatorCell"];
    
    
	// Do any additional setup after loading the view.
    
//    _masterList = [[NSMutableArray alloc] init];
    _tableData = [[NSMutableArray alloc] init];
    
    _jsonQueue  = [[NSOperationQueue alloc] init];
    
    userSave = [[SaveController alloc] initWithKey:@"FindNearestRoute:Saves"];
    //    savedInfo = (FindNearestRouteSaveObject*)[userSave object];
    
    NSLog(@"NFNVC - FindNearestRoute:Saves - %@", savedInfo);
    
    radiusInMiles = 0.250;  // Default to 1/4 of a mile
    if ( [userSave object] == nil )
    {
        savedInfo = [[FindNearestRouteSaveObject alloc] init];
        [savedInfo setRadius: [NSNumber numberWithFloat:radiusInMiles] ];
        [userSave setObject: savedInfo];
    }
    else
    {
        
        /*
         NSData *favoriteData = [saves objectForKey:FAVORITES];  // Read the data
         favorites = [NSKeyedUnarchiver unarchiveObjectWithData:favoriteData];  // Convert data to array
         */
        
        savedInfo = (FindNearestRouteSaveObject*)[NSKeyedUnarchiver unarchiveObjectWithData:[userSave object] ];
        
        radiusInMiles = [[savedInfo radius] floatValue];
        
        //        [savedInfo setRadius:[NSNumber numberWithFloat:0.0f] ];
        //        [userSave setObject: savedInfo];
        //        [userSave save];
    }
    
    
    _locationType = [NSArray arrayWithObjects:@"bus_stops", @"rail_stations", @"perk_locations", @"trolley_stops", @"sales_locations", nil];
    
    
    // --==
    // ==--  Setting up CLLocation Manager
    // --==
    
    
    if ( [CLLocationManager locationServicesEnabled])
    {
        
        locationEnabled = YES;
        
        _locationManager = [[CLLocationManager alloc] init];
        
        [_locationManager setDelegate:self];
        [_locationManager startUpdatingLocation];
        
        
        //        UILocalNotification *localNote = [[UILocalNotification alloc] init];
        //        NSDate *fireWhen = [NSDate date];
        //        NSTimeInterval seconds = 10;
        //        fireWhen = [fireWhen dateByAddingTimeInterval:seconds];
        //
        //        [localNote setFireDate: fireWhen];
        //
        //        [localNote setAlertBody:@"Testing"];
        //        [localNote setAlertAction:@"Notification"];
        //
        //        [localNote setSoundName: @"Train.caf"];
        //
        //        [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
        
    }
    else
    {
        locationEnabled = NO;
    }
    
    
    // --======
    // ==--  Setting up MapKit
    // --======
    // A little background on span, thanks to http://stackoverflow.com/questions/7381783/mkcoordinatespan-in-meters
    
    float displayRadius = 2.0;
    [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor: displayRadius*2], [self milesToMetersFor: displayRadius*2] ) animated:YES];
    
    [mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    
    [mapView setShowsUserLocation:YES];
    [mapView setDelegate:self];
    
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"Find_loc-white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    
//    CustomFlatBarButton *rightBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"Distance.png" withTarget:self andWithAction:@selector(rightButtonPressed:)];
    
//    [rightBarButtonItem.button setBackgroundColor:[UIColor redColor] ];
//    [rightBarButtonItem.button setFrame:CGRectOffset(rightBarButtonItem.button.frame, -40, 0)];  // Doesn't work
//    [rightBarButtonItem.button setFrame:CGRectMake(0, 0, 80, 30)];  // Works but now the touchable area is huge!
//    self.navigationItem.rightBarButtonItem = rightBarButtonItem;    
    
    
    
    // --=======================--
    // --==  Distance Button  ==--
    // --=======================--
    UIView *rightBarButtonItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 32)];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [_button setFrame: CGRectMake(0, 0, 40, 32)];
    
    [_button setImage:[UIImage imageNamed:@"Distance.png"] forState:UIControlStateNormal];
    [_button setImage:[UIImage imageNamed:@"Done.png"]     forState:UIControlStateSelected];
    [_button addTarget:self action:@selector(rightButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [rightBarButtonItem addSubview: _button];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView: rightBarButtonItem];
    
    self.navigationItem.rightBarButtonItem = rightButton;

    
    
    
//    [rightBarButtonItem.button setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateHighlighted];
//    [rightBarButtonItem.button setImage:[UIImage imageNamed:@"Done.png"] forState:UIControlStateSelected];
    
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: @"Find Locations"];
    [self.navigationItem setTitleView:titleView];
    
    
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = self.imgTableViewBG.bounds;
    l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor], nil];
    
    l.startPoint = CGPointMake(0.0f, 0.0f);
    l.endPoint = CGPointMake(0.35f, 0.35f);
    
    //you can change the direction, obviously, this would be top to bottom fade
//    self.imgTableViewBG.layer.mask = l;
    
    [self.imgTableViewBG setBackgroundColor: [UIColor blackColor] ];
    
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    _killAllTimers = NO;
    [self getLatestJSONData];
    
    
//    DistanceView *dView = [[DistanceView alloc] initWithFrame:CGRectMake(0, 240, 320, 107)];
    
    
    _dView = [[[NSBundle mainBundle] loadNibNamed:@"DistanceView" owner:self options:nil] objectAtIndex:0];
    NSLog(@"view: %@", _dView);
    [_dView setFrame:CGRectMake(0, -167, 320, 107)];
    [_dView setDelegate:self];
    [self.navigationController.view addSubview: _dView];
    
    [_dView setRadius: radiusInMiles];
    
}





-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
//    NSLog(@"titleView frame: %@", NSStringFromCGRect(titleView.frame));
    
    [self updateViewsWithOrientation: toInterfaceOrientation];
    
}


-(void) updateViewsWithOrientation: (UIInterfaceOrientation) toInterfaceOrientation
{
    
//    NSString *orientation;
    if ( UIInterfaceOrientationIsLandscape( toInterfaceOrientation ) )
    {
        // Reposition views to Landscape layout
//        orientation = @"L";
        [self.mapView setFrame: CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height)];
        [self.imgTableViewBG setFrame: CGRectMake(self.view.frame.size.width/2 - 10, 0, self.view.frame.size.width/2 + 10, self.view.frame.size.height)];
        [self.tableView setFrame: self.imgTableViewBG.frame];
        [self.imgVerticalDivider setFrame: CGRectMake(self.tableView.frame.origin.x + 45, 0, 2, self.tableView.frame.size.height)];
    }
    else
    {
        // Reposition views to Portrait layout
        
//        orientation = @"P";
        [self.mapView setFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
        [self.imgTableViewBG setFrame: CGRectMake(0, self.view.frame.size.height/2 - 10, self.view.frame.size.width, self.view.frame.size.height/2 + 10)];
        [self.tableView setFrame: self.imgTableViewBG.frame];
        [self.imgVerticalDivider setFrame: CGRectMake(45, self.tableView.frame.origin.y, 2, self.tableView.frame.size.height)];
    }
    
    
    //    NSLog(@"(%@) MapView   frame: %@", orientation, NSStringFromCGRect(self.mapView.frame));
//    NSLog(@"(%@) Image     frame: %@", orientation, NSStringFromCGRect(self.imgTableViewBG.frame));
//    NSLog(@"(%@) Image    bounds: %@", orientation, NSStringFromCGRect(self.imgTableViewBG.bounds));
    [self.tableView reloadData];
    
}


#pragma mark - UITableViewDataSource
#pragma mark - UITableViewDelegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    //    NSLog(@"FNRVC - # of sections: %d", [_tData numberOfSections] );
    //    return [_tData numberOfSections];
    return 1;  // Table only has one section, segmented control switches between data sources
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return [_tableData count] + 2;  // Plus 2 for the Start and End cell
    //    NSLog(@"FNRVC -  # of rows :%d in section: %d", [_tData numberOfRowsInSection:section], section);
    //    return [_tData numberOfRowsInSection:section];
    return [_tableData count];
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_line.png"]];
    UITableViewCell *newCell = (UITableViewCell*)cell;
    
    [separator setFrame: CGRectOffset(separator.frame, 0, newCell.frame.size.height-separator.frame.size.height)];
    [newCell.contentView addSubview: separator];
}


- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellName = @"BusRouteIndicatorCell";
    
    BusRouteIndicatorCell *thisCell = [thisTableView dequeueReusableCellWithIdentifier: cellName];
    [thisCell setBackgroundColor:[UIColor clearColor] ];
    if ( thisCell == nil )
    {
        thisCell = [[BusRouteIndicatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    //BasicRouteObject *rObj = [_tableData objectAtIndex:indexPath.row];
    
    [thisCell addRouteInfo: [_tableData objectAtIndex:indexPath.row] ];
    
    
    return thisCell;
    
    
    
    static NSString *cellIdentifier = @"FindNearestRouteCell";
    
    id cell = [thisTableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    GetLocationsObject *glObject;
    glObject = [_tableData objectAtIndex:indexPath.row];
    
    [[cell textLabel] setMinimumFontSize:5.0f];
    [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
    
    // [glObject location_id]
    if ( [glObject routeStr] != NULL )
        [[cell textLabel] setText: [NSString stringWithFormat:@"%@ - %@",[glObject location_name], [glObject routeStr] ] ];
    else
        [[cell textLabel] setText: [NSString stringWithFormat:@"%@",[glObject location_name] ] ];
    
    return cell;
    
}


- (void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self performSegueWithIdentifier:@"NearestTimesSegue" sender:self];

}





#pragma mark - MapView and Supoort Methods
//-(void) updateAnnotations
//{
//
//    // --==
//    // ==--  Annontations
//    // --==
//    NSMutableArray *annotationsToRemove = [[mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
//    [annotationsToRemove removeObject: [mapView userLocation] ];         // Keep the userLocation annotation on the map
//    [mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
//
//
//    for (GetLocationsObject *glObject in _tableData)
//    {
//        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([[glObject location_lat] doubleValue], [[glObject location_lon] doubleValue]);
//        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
//        //            NSString *annotationTitle  = [NSString stringWithFormat: @"BlockID: %@ (%@ min)", [busData objectForKey:@"BlockID"], [busData objectForKey:@"Offset"]];
//
//        NSString *annotationTitle = [NSString stringWithFormat:@"%@", [glObject location_name] ];
//
//        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"Stop ID: %@", [glObject location_id] ] ];
//        [annotation setCurrentTitle   : annotationTitle];
//
//        //        NSLog(@"FNRVC -(void) updateAnnotations: %@", glObject);
//
//        [mapView addAnnotation: annotation];
//        [mapView selectAnnotation:annotation animated:YES];
//    }
//
//}

#pragma mark - MKMapViewDelegate Methods
//-(MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
//{
//    NSLog(@"FNRVC -mapView viewForOverlay");
//    return [kmlParser viewForOverlay: overlay];
//}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
//    MKAnnotationView *ulv = [self.mapView viewForAnnotation:self.mapView.userLocation];
//    ulv.hidden = YES;
}


//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
//{
//
//    //    NSLog(@"FNRVC - viewForAnnotations");
//
//    if ( [annotation isKindOfClass:[MKUserLocation class]] )
//        return nil;
//
//    static NSString *identifier = @"mapAnnotation";
//
//    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: identifier];
//    if (annotationView == nil) {
//        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//    } else {
//        annotationView.annotation = annotation;
//    }
//
//    [annotationView setEnabled: YES];
//    [annotationView setCanShowCallout: YES];
//
//    return annotationView;
//
//}


#pragma mark - CLLocation Delegates
// Depreciated in iOS 6, needed to support iOS5.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
    //    NSLog(@"Location (iOS5): %@", [newLocation description]);
    ////    [manager stopUpdatingLocation];
    //
    //    [_tableData replaceObjectAtIndex:0 withObject: [NSString stringWithFormat:@"(lat,lon) = (%8.5f, %8.5f)", newLocation.coordinate.latitude, newLocation.coordinate.longitude] ];
    //    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    //    [self.tableView reloadData];
    
}

// Use for iOS6
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    for (CLLocation *location in locations)
    {
        //        NSLog(@"Location (iOS6):%@", location);
        //
        //        [_tableData replaceObjectAtIndex:0 withObject: [NSString stringWithFormat:@"(lat,lon) = (%10.7f, %10.7f)", location.coordinate.latitude, location.coordinate.longitude] ];
        ////        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        //
        //        CLLocation *loc = [[CLLocation alloc] initWithLatitude:_loc.latitude longitude:_loc.longitude];
        //        [_tableData replaceObjectAtIndex:2 withObject: [NSString stringWithFormat:@"Distance: %6.3fm", [location distanceFromLocation:loc] ] ];
        //
        //        [self.tableView reloadData];
        
        
    }
    
    //    [manager stopUpdatingLocation];
    
}


//-(void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
//{
//    NSLog(@"Monitoring new region: %@ - (lat,lon) = (%10.7f, %10.7f)", region.identifier, region.center.latitude, region.center.longitude);
//
////    UIAlertView *alr = [[UIAlertView alloc] initWithTitle:@"Monitoring Region" message:[NSString stringWithFormat:@"%@ (lat,lon) = (%10.7f, %10.7f)", region.identifier, region.center.latitude, region.center.longitude] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
////    [alr show];
//}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"NLVC - Error: %@", [error description]);
}


-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
    //    NSLog(@"Entered region!");
    //    UIAlertView *alr = [[UIAlertView alloc] initWithTitle:@"Did Enter Region" message:@"You entered selected region" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    //    [alr show];
    
    return;
    
    //    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    //
    //    [localNote setFireDate: [NSDate date] ];
    //
    //    [localNote setAlertBody:@"Approaching station"];
    //    [localNote setAlertAction:@"Notification"];
    //
    //    [localNote setSoundName: @"Train.caf"];
    //
    //    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
    //
    //    [manager stopMonitoringForRegion:region];
    
}


-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
    return;
    
    //    NSLog(@"Left region!");
    //    UIAlertView *alr = [[UIAlertView alloc] initWithTitle:@"Did Leave Region" message:@"You left selected region" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    //    [alr show];
    
}


#pragma mark - Realtime/JSON Methods
-(void) getLatestJSONData
{
    
    NSLog(@"NLVC - getLatestBusJSONData");
    _updateFireDate = [NSDate date];
    
    
    
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
    {
        // Disable realtime buttons if no internet connection is available
        [self kickOffAnotherJSONRequest];  // A bit of code is needed to continue to retry
        return;
    }
    
    
    
    // If start and end points haven't been entered, do nothing
    //    if ( ( _startObject.stop_name == nil ) || ( _endObject.stop_name == nil ) )
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
    CLLocation *location = [_locationManager location];
    
    
    //    if ( radiusInMiles < 1 )
    //        [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor:radiusInMiles*2], [self milesToMetersFor:radiusInMiles*2] ) animated:YES];
    //    else
    //        [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor:radiusInMiles], [self milesToMetersFor:radiusInMiles] ) animated:YES];
    

//    NSMutableArray *urlArr = [[NSMutableArray alloc] init];
    NSArray *typeArr = [NSArray arrayWithObjects:@"bus_stops",@"rail_stations",@"trolley_stops", nil];
//    NSArray *typeArr = [NSArray arrayWithObjects:@"trolley_stops", nil];
    
//    [SVProgressHUD showWithStatus:@"Loading..."];
    
    [_tableData removeAllObjects];
    _dismissCounter = 0;
    
    for (NSString *type in typeArr)
    {
        
        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/locations/get_locations.php?lon=%9.6f&lat=%9.6f&radius=%6.3f&number_of_results=400&type=%@", location.coordinate.longitude, location.coordinate.latitude, radiusInMiles, type];
        
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString: webStringURL];
        NSURLRequest *request = [NSURLRequest requestWithURL: url];
        
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
        {
            // Success Block
//            NSLog(@"NLVC:gLJS - JSON Success for URL: %@", webStringURL);
            [self processJSONData: JSON];
        }
                                                                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
        {
            // Failure Block, this should be quite familiar to you...
            NSLog(@"NLVC:gLJS - JSON Failure for URL: %@ -- %@", webStringURL, [error userInfo]);
            _dismissCounter--;
            
            if ( _dismissCounter == 0 )
                [SVProgressHUD dismiss];
        }];
        
        _dismissCounter++;
//        [operation start];
        [_jsonQueue addOperation: operation];
        
    }

    
    return;
    
    NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/locations/get_locations.php?lon=%9.6f&lat=%9.6f&radius=%6.3f&number_of_results=400", location.coordinate.longitude, location.coordinate.latitude, radiusInMiles];
    
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"NLVC - getLatestJSONData -- api url: %@", webStringURL);

    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    
    _jsonOp     = [[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOp = _jsonOp;
    [weakOp addExecutionBlock:^{
        
        NSError *error;
        NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] options:NSDataReadingUncached error:&error];
        
        if ( error )
        {
            NSLog(@"NLVC - Could not get data");
            return;
        }
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self processJSONData:realTimeTrainInfo];
            }];
        }
        else
        {
            NSLog(@"NLVC - getLatestJSONData: _jsonOp cancelled");
        }
        
    }];
    
    [_jsonQueue addOperation: _jsonOp];
    
    
    
    
    //        [_jsonQueue addOperationWithBlock:^{
    //
    //            //            NSLog(@"Getting JSON data");
    //            NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
    //            //            NSLog(@"Got JSON data!  %@", realTimeTrainInfo);
    //
    //            //            if ( _jsonQueue is)
    //
    //
    //            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    //                [self processJSONData:realTimeTrainInfo];
    //            }];
    //
    //        }];
    
    
    
    
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
    //
    //            NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
    ////            [self performSelectorOnMainThread:@selector(processJSONData:) withObject: realTimeTrainInfo waitUntilDone:YES];
    //
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //
    //                [self processJSONData: realTimeTrainInfo];
    //
    //            });
    //
    //
    //        });
    
}


-(NSString*) filePath
{
    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
}


-(void) processJSONData:(NSData*) returnedData
{
    
    if ( --_dismissCounter <= 0 )
        [SVProgressHUD dismiss];
    
    _stillWaitingOnWebRequest = NO;
    
    if ( returnedData == nil )
        return;
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    NSDictionary *json = (NSDictionary*)returnedData;
    
    if ( json == nil )
        return;
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    NSMutableArray *annotationsToRemove = [[self.mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [self.mapView userLocation] ];                // Keep the userLocation annotation on the map
    [self.mapView removeAnnotations: annotationsToRemove];                           // All annotations remaining in the array get removed
    annotationsToRemove = nil;
    
    
    //    NSMutableString *temp = [[NSMutableString alloc] init];
    NSString *queryStr;
    FMResultSet *results;
    
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *data in json)
    {
        
//        if ( [_jsonOp isCancelled] )
        if ( _cancelOperations )
        {
            NSLog(@"NLVC - processJSONData: _jsonOp cancelled");
            return;
        }
        
        
        // TODO: Determine all possible error messages from the API
        if ( [data objectForKey:@"error"] != nil )
            return;
        
        NSArray *keys = [data allKeys];
        NSMutableArray *someKeys = [keys mutableCopy];
        [someKeys removeObject:@"location_data"];
        
        GetLocationsObject *glObject = [[GetLocationsObject alloc] init];
        //            NSLog(@"%@", glObject);
        
        NSArray *dataKeys;
        if ( [data objectForKey:@"location_data"] != [NSNull null] )
            dataKeys = [[data objectForKey:@"location_data"] allKeys];
        
        
        // Move the raw JSON data from data into baseDict and dataDict
        NSDictionary *baseDict = [data dictionaryWithValuesForKeys:someKeys];
        NSDictionary *dataDict = [[data objectForKey:@"location_data"] dictionaryWithValuesForKeys:dataKeys];
        
        
        [glObject setValuesForKeysWithDictionary: baseDict];
        [(LocationData*)[glObject location_data] setValuesForKeysWithDictionary: dataDict];
        
        
        
        // --==  Determine what stops are associated with
        //        if ( [glObject.location_id intValue] == 90006 )
        //        {
        //            NSLog(@"ARGH!");
        //        }
        
        queryStr = [NSString stringWithFormat:@"SELECT CASE route_short_name WHEN \"LUCYGO\" THEN \"LGO\" WHEN \"LUCYGR\" THEN \"LGR\" ELSE route_short_name END as route_short_name, stop_id, route_type, Direction, dircode FROM stopIDRouteLookup WHERE stop_id=%d", [glObject.location_id intValue] ];
        results = [database executeQuery: queryStr];
        if ( [database hadError] )  // Check for errors
        {
            
            int errorCode = [database lastErrorCode];
            NSString *errorMsg = [database lastErrorMessage];
            
            NSLog(@"NLVC - query failure, code: %d, %@", errorCode, errorMsg);
            NSLog(@"NLVC - query str: %@", queryStr);
            
            return;  // If an error occurred, there's nothing else to do but exit
            
        } // if ( [database hadError] )
        
        
        //        NSString *temp = @"";
        
        
        // Initialize our BasicRouteObject
        //        NSLog(@"queryStr: %@", queryStr);
        
        BasicRouteObject *rObj = [[BasicRouteObject alloc] init];
        
        // Give it the main information
        [rObj setStop_id:       glObject.location_id];
        [rObj setDistance:      glObject.distance];
        [rObj setStop_name:     glObject.location_name];
        [rObj setLocation_type: glObject.location_type];
        
        
        //        if ( [glObject.location_type isEqualToString:@"rail_stations"] )
        //        {
        //            NSLog(@"Break here!");
        //        }
        
        
        // Now load in all the routes that stop at this location
        while ( [results next] )
        {
            //            temp = [temp stringByAppendingString: [NSString stringWithFormat:@"%@, ", [results stringForColumn:@"route_short_name"] ] ];
            
            RouteDetailsObject *dObj = [[RouteDetailsObject alloc] init];
            [dObj setRoute_short_name: [results stringForColumn:@"route_short_name"] ];
            [dObj setRoute_type: [NSNumber numberWithInt: [results intForColumn:@"route_type"] ] ];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[results stringForColumn:@"Direction"] forKey:[results stringForColumn:@"dircode"] ];
            [dObj setDirectionDict: dict];
            
//            [dObj setDirection: [results stringForColumn:@"Direction"] ];
//            [dObj setDircode: [results stringForColumn:@"dircode"] ];
            
            [rObj addRouteInfo: dObj ];
            
        }
        
        [rObj sort];
        
        
        
        //        NSLog(@"FNRVC - temp: %@ for query: %@", temp, queryStr);
        //        if ( [temp length] > 2 )
        //            temp = [temp substringToIndex:[temp length] - 2];
        //        [glObject setRouteStr:temp];
        
        //        [tempArray addObject: glObject];
        
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([glObject.location_lat doubleValue], [glObject.location_lon doubleValue]);
        [self addAnnontationWithCoord: coord andTitle: glObject.location_name withRoutes: rObj];

        
        // TODO: Sort by distance
        
        [tempArray addObject:rObj];
//        [_tableData addObject: rObj];
        
    }
    
    
    //    NSLog(@"FNRVC - processJSONData: Finished reading JSON Data");
    
    //    [_masterList removeAllObjects];
//    _masterList = [tempArray copy];  // Implicitly remove all objects from the old memory location that _masterList pointed to
//    tempArray = nil;
    
//    [self filterData];

    
//    NSLog(@"Cells: %@", [self.tableView visibleCells] );
    
//    if ( [[self.tableView visibleCells] count] == 0 )
    [self.tableView beginUpdates];
    
    [_tableData addObjectsFromArray: tempArray];
    [_tableData sortUsingComparator:^NSComparisonResult(BasicRouteObject *a, BasicRouteObject *b)
     {
         return [[a distance] compare:[b distance] options:NSNumericSearch];
     }];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
  
    
//    [self.tableView reloadData];
    
//    else
//        [self.tableView reloadRowsAtIndexPaths:[self.tableView visibleCells] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


-(void)  addAnnontationWithCoord: (CLLocationCoordinate2D) coord andTitle: (NSString*) title withRoutes: (BasicRouteObject*) rObj
{
    
    mapAnnotation *annotation = [[mapAnnotation alloc] initWithCoordinate: coord];
    [annotation setCurrentTitle: title];
    
    NSMutableString *routeInfo = [[NSMutableString alloc] init];

    [routeInfo appendString:@"Routes: "];
    for (RouteDetailsObject *rdObj in rObj.routeData)
    {
        [routeInfo appendFormat:@"%@, ", rdObj.route_short_name];
    }
    
    [annotation setCurrentSubTitle: [routeInfo substringToIndex:[routeInfo length] -2] ];

    [mapView addAnnotation: annotation];
    
}


//-(void) addAnnontationUsingObject:(GetLocationsObject*) glObject
//{
//    
//    
//    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([glObject.location_lat doubleValue], [glObject.location_lon doubleValue]);
//    mapAnnotation *annotation = [[mapAnnotation alloc] initWithCoordinate: coord];
//    
//    [annotation setCurrentTitle: glObject.location_name];
//    
//    
//}



//NSComparisonResult (^sortGetLocationObjectByDistance)(GetLocationsObject*,GetLocationsObject*) = ^(GetLocationsObject *a, GetLocationsObject *b)
//{
//    return [[a distance] compare: [b distance] options:NSNumericSearch];
//};


//NSComparisonResult (^sortGetLocationObjectByLocationName)(GetLocationsObject*,GetLocationsObject*) = ^(GetLocationsObject *a, GetLocationsObject *b)
//{
//    return [[a location_name] compare: [b location_name] options:NSNumericSearch];
//};


#pragma mark - UISegmentControl Changed
- (IBAction)segmentChanged:(id)sender
{
    // Filter _tableData
    [self filterData];
    
    
}

-(void) filterData
{
    
//    int index = [self.segmentTypes selectedSegmentIndex];
//    if ( index == -1 )
//        index = 0;
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"location_type == %@", [_locationType objectAtIndex:index ] ];
//    _tableData = [[_masterList filteredArrayUsingPredicate:predicate] mutableCopy];

//    _tableData = _masterList;
    
//    if ( [_tableData count] == 0)
//    {
//                
//        BasicRouteObject *rObj = [[BasicRouteObject alloc] init];
//        
//        // Give it the main information
//        [rObj setDistance: @"0.00"];
//        //        [rObj setStop_name: [NSString stringWithFormat:@"There is no stop within %5.3f mile radius of your current location",radiusInMiles] ];
//        [rObj setStop_name:@"No stops were found near you."];
//        
//        [_tableData addObject: rObj];
//        
//        //GetLocationsObject *glObject = [[GetLocationsObject alloc] init];
//        //[glObject setLocation_name:[NSString stringWithFormat:@"Nothing found within a %5.3f mile radius of your current location",radiusInMiles] ];
//        //[_tableData addObject:glObject];
//        
//        //        [_tableData]
//    }
    
    
    //    for (GetLocationsObject *glObject in _tableData)
    //    {
    //        NSLog(@"%@", glObject);
    //    }
    
    //    [_tableData sortUsingComparator:sortGetLocationObjectByLocationName];
    
    //    NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];  // But this won't do an NSNumericSearch sort
    //    [_tableData sortUsingDescriptors:[NSArray arrayWithObject:desc] ];
    
    
    //    [self updateAnnotations];
    [self.tableView reloadData];
}

#pragma mark - MapTap Gesture Recognizer
- (IBAction)mapTapGestureTapped:(id)sender
{
    
    return;  // Don't uncomment this... _masterList contains BasicRouteObjects but SimpleMapController is expecting GetLocationsObject
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SimpleMapStoryboard" bundle:nil];
    SimpleMapViewController *smVC = (SimpleMapViewController*)[storyboard instantiateInitialViewController];
    
//    [smVC setMasterList: _masterList];  // Use _tableData now
//    int index = [self.segmentTypes selectedSegmentIndex];
//    if ( index < 0 )  // Was index == -1
        int index = 0;
    
    [smVC setFilterType: [_locationType objectAtIndex:index] ];
    [smVC setRadius: [NSNumber numberWithFloat:radiusInMiles] ];
    
    [self.navigationController pushViewController:smVC animated:YES];
    
}


#pragma mark - Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue identifier] isEqualToString: @"NearestTimesSegue"] )
    {
        
        NearestTimesViewController *ntVC = [segue destinationViewController];
        
        // Configure NearestTimesVC here
        // Pass all routes belonging to the current select.  Routes stored in BasicRouteObject
        
        BasicRouteObject *routeObj = (BasicRouteObject*)[_tableData objectAtIndex: self.tableView.indexPathForSelectedRow.row];
        [ntVC setRouteData: routeObj];
        
    }
    
    
//    if ( [[segue identifier] isEqualToString:@"MapSegue"] )
//    {
//        
//        FindNearestMapViewController *fnmvc = [segue destinationViewController];
//        
//        [fnmvc setMasterList:_masterList];
//        
//        int index = [self.segmentTypes selectedSegmentIndex];
//        if ( index == -1 )
//            index = 0;
//        
//        [fnmvc setFilterType: [_locationType objectAtIndex:index] ];
//        [fnmvc setRadius: [NSNumber numberWithFloat:radiusInMiles] ];
//        
//    }
//    else if ( [[segue identifier] isEqualToString:@"FindSchedulesSegue"] )
//    {
//        //        NSLog(@"NFNVC - FindSchedulesSegue");
//        
//        BasicRouteObject *rObj = [[BasicRouteObject alloc] init];
//        
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        rObj = [_tableData objectAtIndex: indexPath.row];
//        
//        FindSchedulesViewController *fsvc = [segue destinationViewController];
//        [fsvc setBasicRoute: rObj];
//        
//    }
//    
//    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
}


#pragma mark - Custom Methods
-(float) milesToMetersFor: (float) miles
{
    return 1609.344f * miles;
}


#pragma mark - Radius Button Methods
-(void) createRadiusView
{
    
    // TODO: Forgot there was a built-in keyboard!  Use that instead... jerk.
    /*
     
     From: http://stackoverflow.com/questions/9079815/trying-to-add-done-button-to-numeric-keyboard
     
     - (void)viewDidLoad
     {
     [super viewDidLoad];
     
     UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
     numberToolbar.barStyle = UIBarStyleBlackTranslucent;
     numberToolbar.items = [NSArray arrayWithObjects:
     [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
     [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
     [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
     nil];
     [numberToolbar sizeToFit];
     numberTextField.inputAccessoryView = numberToolbar;
     }
     
     -(void)cancelNumberPad{
     [numberTextField resignFirstResponder];
     numberTextField.text = @"";
     }
     
     -(void)doneWithNumberPad{
     NSString *numberFromTheKeyboard = numberTextField.text;
     [numberTextField resignFirstResponder];
     }
     
     
     
     
     */
    
    
    
    // TODO: Create a nib to do this
    // Manually setting UI components bothers me greatly
    
    float height = 100;
    CGRect radiusViewRect = CGRectMake(0, -height, self.view.frame.size.width, height);
    radiusView = [[UIView alloc] initWithFrame: radiusViewRect];
    if ( radiusView == nil )
        return;  // radiusView needs to exist otherwise there's nothing to add the DigitInput onto
    
    [radiusView setBackgroundColor: [UIColor scrollViewTexturedBackgroundColor] ];
    
    [self.view addSubview: radiusView];
    
    digitInput = [[CHDigitInput alloc] initWithNumberOfDigits:5];
    [digitInput setDecimalPosition: kCHDecimalPositionThousandths withPlaceholder: @"."];
    
//    [digitInput setDigitOverlayImage:    [UIImage imageNamed:@"digitOverlay"  ] ];
    [digitInput setDigitOverlayImage: nil];
    [digitInput setDigitBackgroundImage: [UIImage imageNamed:@"Find_Loc_Distance.png"] ];
    
    [digitInput setPlaceHolderCharacter:@"0"];
    
    // we are using an overlayimage, so make the bg color clear color
    
    digitInput.digitViewBackgroundColor = [UIColor redColor];
    digitInput.digitViewHighlightedBackgroundColor = [UIColor blueColor];
    
    digitInput.digitViewTextColor = [UIColor whiteColor];
    digitInput.digitViewHighlightedTextColor = [UIColor orangeColor];
    
    [digitInput setDigitViewFont: [UIFont fontWithName:@"TrebuchetMS" size:34.0f] ];
    
    [digitInput redrawControl];
    
    digitInput.frame = CGRectMake(10, radiusView.frame.size.height * .25, radiusView.frame.size.width-20, 55);
    
    [radiusView addSubview: digitInput];
    
    [digitInput setValue:[NSString stringWithFormat:@"%05.3f", radiusInMiles] ];
    
    
    // adding the target,actions for available events
    [digitInput addTarget:self action:@selector(didBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [digitInput addTarget:self action:@selector(didEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    [digitInput addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [digitInput addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *lblMiles = [[UILabel alloc] initWithFrame:CGRectMake(radiusView.frame.size.width-45, radiusView.frame.size.height - 22, 45, 20)];
    [lblMiles setFont: [UIFont fontWithName:@"TrebuchetMS" size:16.0f] ];
    [lblMiles setTextColor:[UIColor whiteColor] ];
    [lblMiles setText:@"miles"];
    [lblMiles setOpaque:NO];
    [lblMiles setBackgroundColor:[UIColor clearColor] ];
    
    [radiusView addSubview:lblMiles];
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, radiusView.frame.size.width-5, 20)];
    
    [lblDescription setFont: [UIFont fontWithName:@"TrebuchetMS" size:16.0f] ];
    [lblDescription setTextColor:[UIColor whiteColor] ];
    [lblDescription setMinimumFontSize:5.0f];
    [lblDescription setAdjustsFontSizeToFitWidth:YES];
    
    [lblDescription setText:@"Distance from your current location to search:"];
    [lblDescription setOpaque:NO];
    [lblDescription setBackgroundColor:[UIColor clearColor] ];
    
    [radiusView addSubview: lblDescription];
    
    
}


-(void)didBeginEditing:(id)sender
{
    
}

-(void)didEndEditing:(id)sender
{
    
}

-(void)valueChanged:(id)sender
{
    
}

//-(void) showRadiusView
//{
//    CGRect frame = radiusView.frame;
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.25f];
//    
//    frame.origin.y = 0;
//    [radiusView setFrame: frame];
//    
//    [UIView commitAnimations];
//    
//}
//
//-(void) hideRadiusView
//{
//    CGRect frame = radiusView.frame;
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.25f];
//    
//    frame.origin.y = -frame.size.height;
//    [radiusView setFrame: frame];
//    
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
//    
//    [UIView commitAnimations];
//}

//-(void) animationDidStop:(NSString*) animationID finished:(BOOL) finished context:(void *) context
//{
//    NSLog(@"NLVC - animationDidStop");
//    //    [radiusView removeFromSuperview];
//    //    radiusView = nil;
//}

#pragma mark - Change Radius
//- (IBAction)btnRadiusPressed:(id)sender
//{
//    
//    if ( _digitInputActive )
//    {
//        [digitInput resignFirstResponder];
//        [self hideRadiusView];
//        _digitInputActive = NO;
//        
//        [self.btnRadius setTitle:@"Distance"];
//        [self.btnRadius setTintColor:[UIColor clearColor] ];
//        
//        
//        return;
//    }
//    
//    [self.btnRadius setTitle:@"Done"];
//    [self.btnRadius setTintColor:[UIColor blueColor] ];
//    
//    _digitInputActive = YES;
//    
//    [self showRadiusView];
//    
//}


// dismissing the keyboard
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [digitInput resignFirstResponder];
//}

//-(void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    digitInput.frame = CGRectMake(10, 45, self.view.frame.size.width-20, 55);
//}

/////////// recating on demo events ///////////
//-(void)didBeginEditing:(id)sender
//{
//    CHDigitInput *input = (CHDigitInput *)sender;
//    NSLog(@"NLVC:dBE - did begin editing %@",input.value);
//}

//-(void)didEndEditing:(id)sender
//{
//    CHDigitInput *input = (CHDigitInput *)sender;
//    NSLog(@"NLVC:dEE - did end editing %@",input.value);
//    
//    // If targets are not removed (and the endediting one in particular!) removeFromSuperview statement below will trigger the didEndEditing event which will trigger...
//    //    [input removeTarget:self action:@selector(didEndEditing:) forControlEvents:UIControlEventAllEvents];
//    
//    //    [self performSelector:@selector(removeDigitInput:) withObject:input afterDelay:0.25];
//    [self hideRadiusView];
//    if ( radiusInMiles != [input.value floatValue] )
//    {
//        
//        radiusInMiles = [input.value floatValue];
//        [savedInfo setRadius:[NSNumber numberWithFloat:radiusInMiles] ];
//        NSLog(@"NLVC:dEE - setting object savedInfo");
//        [userSave setObject: savedInfo];
//        NSLog(@"NLVC:dEE - object savedInfo set");
//        
//        [self getLatestJSONData];
//        
////        [self.btnRadius setTitle:@"Radius"];
////        [self.btnRadius setTintColor:[UIColor clearColor] ];
//    }
//    
//    
//    _digitInputActive = NO;
//    //    [input removeFromSuperview];
//    
//    //    for (UIView *subView in self.view.subviews)
//    //    {
//    //        if ( [subView isKindOfClass:[CHDigitInput class] ] )
//    //        {
//    //            NSLog(@"Removing %@", subView);
//    //            [subView removeFromSuperview];
//    //        }
//    //    }
//    
//}

//-(void) removeDigitInput:(id) sender
//{
//    NSLog(@"NLVC:rDI - remove");
//    CHDigitInput *input = (CHDigitInput*) sender;
//    
//    radiusInMiles = [input.value floatValue];
//    [self getLatestJSONData];
//    
//    [input removeFromSuperview];
//}


//-(void)textDidChange:(id)sender
//{
//    CHDigitInput *input = (CHDigitInput *)sender;
//    NSLog(@"NLVC:tDC - text did change %@",input.value);
//}
//
//-(void)valueChanged:(id)sender
//{
//    CHDigitInput *input = (CHDigitInput *)sender;
//    NSLog(@"NLVC:vC - value changed %@",input.value);
//}


- (void)viewDidUnload
{

    [self setImgTableViewBG:nil];
    [self setImgVerticalDivider:nil];
    
    [super viewDidUnload];
    
}


#pragma mark - Update Timer
-(void) invalidateTimer
{
    
    if ( updateTimer != nil )
    {
        
        if ( [updateTimer isValid]  )
        {
            [updateTimer invalidate];
            updateTimer = nil;
            NSLog(@"NLVC - Killing updateTimer");
        }
        
    }  // if ( updateTimer != nil )
    
}


-(void) kickOffAnotherJSONRequest
{
    
    if ( _killAllTimers )
    {
        [self invalidateTimer];
        return;
    }
    
    //    NSLog(@"NTVVC - kickOffAnotherJSONRequest");
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:JSON_REFRESH_RATE
                                                  target:self
                                                selector:@selector(getLatestJSONData)
                                                userInfo:nil
                                                 repeats:NO];
}



#pragma mark - Buttons Pressed
-(void) backButtonPressed:(id) sender
{
    
    [_jsonQueue cancelAllOperations];
    _cancelOperations = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void) rightButtonPressed:(id) sender
{
    
    if ( [_dView isHidden] )
    {
        [_dView show];
        [(UIButton*)sender setSelected:YES];
    }
    else
    {
        [_dView hide];
        
        [self updateRadiusWith: [_dView getRadius] ];
        
        [(UIButton*)sender setSelected:NO];
    }
    
//    NSLog(@"Right button pressed");
    
}


-(void) updateRadiusWith: (CGFloat) radius
{
    
    if ( radiusInMiles != radius )
    {
        radiusInMiles = radius;
        [savedInfo setRadius:[NSNumber numberWithFloat:radiusInMiles] ];
        [userSave setObject: savedInfo];
        
        [self getLatestJSONData];
    }
    
}

#pragma mark - DistanceViewProtocol
-(void) inputComplete:(CGFloat)radius
{
    
    NSLog(@"NLVC:iC - radius: %6.3f", radius);
    [self rightButtonPressed: _button];
    
    [self updateRadiusWith: radius];
    
}


#pragma mark - NKMapViewDelegate Methods
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    
    if ( [annotation isKindOfClass:[MKUserLocation class]] )
        return nil;
    
    static NSString *identifier = @"mapAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: identifier];
    if (annotationView == nil)
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    else
        annotationView.annotation = annotation;

    
    [annotationView setEnabled: YES];
    [annotationView setCanShowCallout: YES];
    
//    GTFSRouteType routeType = [self.travelMode intValue];
//    UIImage *image;
//    if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"EastBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"SouthBound"] ) )
//    {
//        //        if ( [self.routeType intValue] == 0)
//        if ( routeType == kGTFSRouteTypeTrolley )
//            image = [UIImage imageNamed:@"trolley_blue.png"];
//        else
//            image = [UIImage imageNamed:@"bus_blue.png"];
//    }
//    else if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"WestBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"NorthBound"] ) )
//    {
//        if ( routeType == kGTFSRouteTypeTrolley )
//            image = [UIImage imageNamed:@"trolley_red.png"];
//        else
//            image = [UIImage imageNamed:@"bus_red.png"];
//    }
//    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainSouth"] )
//    {
//        image = [UIImage imageNamed:@"train_blue.png"];
//    }
//    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainNorth"] )
//    {
//        image = [UIImage imageNamed:@"train_red.png"];
//    }
//    else
//    {
//        if ( routeType == kGTFSRouteTypeTrolley )
//            image = [UIImage imageNamed:@"trolley_yellow.png"];
//        else
//            image = [UIImage imageNamed:@"bus_yellow.png"];
//    }
//    
//    [annotationView setImage: image];
    
    return annotationView;
    
}


@end
