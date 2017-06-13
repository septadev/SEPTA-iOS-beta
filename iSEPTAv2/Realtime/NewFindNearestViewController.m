//
//  NewFindNearestViewController.m
//  iSEPTA
//
//  Created by apessos on 4/11/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NewFindNearestViewController.h"
#import "FindNearestMapViewController.h"
#import "FindSchedulesViewController.h"

#import "CHDigitInput.h"

#import "SaveController.h"
#import "FindNearestRouteSaveObject.h"

#import "SVProgressHUD.h"

#import "GetLocationsObject.h"
#import "mapAnnotation.h"

#import "FMDatabase.h"

#import "BusRouteIndicatorCell.h"


@interface NewFindNearestViewController ()

@end

@implementation NewFindNearestViewController
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
    
    CLRegion *_clRegion;
    CLLocationCoordinate2D _loc;
    
    BOOL locationEnabled;
    
    SaveController *userSave;
    FindNearestRouteSaveObject *savedInfo;
}

@synthesize mapView;
@synthesize tableView;

@synthesize btnRadius;
@synthesize segmentTypes;

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
    
    NSLog(@"NFNVC - viewDidLoad");
    
	// Do any additional setup after loading the view.
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BusRouteIndicatorCell" bundle:nil] forCellReuseIdentifier:@"BusRouteIndicatorCell"];
    

	// Do any additional setup after loading the view.
    
    _masterList = [[NSMutableArray alloc] init];
    
    _jsonQueue  = [[NSOperationQueue alloc] init];
    
    userSave = [[SaveController alloc] initWithKey:@"FindNearestRoute:Saves"];
    //    savedInfo = (FindNearestRouteSaveObject*)[userSave object];
    
    NSLog(@"NFNVC - FindNearestRoute:Saves - %@", savedInfo);
    
    radiusInMiles = 0.125;  // Default to 1/8th of a mile
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
    [mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
    [mapView setZoomEnabled:NO];
    [mapView setScrollEnabled:NO];
    
    [mapView setShowsUserLocation:NO];
    [mapView setDelegate:self];
    
    
    // A little background on span, thanks to http://stackoverflow.com/questions/7381783/mkcoordinatespan-in-meters
    
    float displayRadius = 2.0;
    [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor: displayRadius*2], [self milesToMetersFor: displayRadius*2] ) animated:YES];
    
    [mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
    [mapView setZoomEnabled:YES];
    
    
    [self getLatestJSONData];
        
    [self createRadiusView];

    
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

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


- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellName = @"BusRouteIndicatorCell";
    
    BusRouteIndicatorCell *thisCell = [thisTableView dequeueReusableCellWithIdentifier: cellName];
    
    if ( thisCell == nil )
    {
        thisCell = [[BusRouteIndicatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    //BasicRouteObject *rObj = [_tableData objectAtIndex:indexPath.row];

    [thisCell addRouteInfo: [_tableData objectAtIndex:indexPath.row] ];
        
    return thisCell;
    
}


- (void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"FindSchedulesSegue" sender:self];
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
    MKAnnotationView *ulv = [self.mapView viewForAnnotation:self.mapView.userLocation];
    ulv.hidden = YES;
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
    
//    for (CLLocation *location in locations)
//    {
////        NSLog(@"Location (iOS6):%@", location);
////        
////        [_tableData replaceObjectAtIndex:0 withObject: [NSString stringWithFormat:@"(lat,lon) = (%10.7f, %10.7f)", location.coordinate.latitude, location.coordinate.longitude] ];
//////        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
////
////        CLLocation *loc = [[CLLocation alloc] initWithLatitude:_loc.latitude longitude:_loc.longitude];
////        [_tableData replaceObjectAtIndex:2 withObject: [NSString stringWithFormat:@"Distance: %6.3fm", [location distanceFromLocation:loc] ] ];
////
////        [self.tableView reloadData];
//        
//        
//    }
    
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
    NSLog(@"Error: %@", [error description]);
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
    
    NSLog(@"FNRVC - getLatestBusJSONData");
    
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

    
    NSString* stringURL = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/locations/get_locations.php?lon=%9.6f&lat=%9.6f&radius=%6.3f&number_of_results=400", location.coordinate.longitude, location.coordinate.latitude, radiusInMiles];
    
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"FNRVC - getLatestJSONData -- api url: %@", webStringURL);
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    
    _jsonOp     = [[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOp = _jsonOp;
    [weakOp addExecutionBlock:^{
        
        NSError *error;
        NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] options:NSDataReadingUncached error:&error];
        
        if ( error )
        {
            NSLog(@"Could not get data");
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
            NSLog(@"FNRVC - getLatestJSONData: _jsonOp cancelled");
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


//-(NSString*) filePath
//{
//    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
//}


-(void) processJSONData:(NSData*) returnedData
{
    
    [SVProgressHUD dismiss];
    _stillWaitingOnWebRequest = NO;
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( json == nil )
        return;
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    //    NSMutableString *temp = [[NSMutableString alloc] init];
    NSString *queryStr;
    FMResultSet *results;
    
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *data in json)
    {
        
        if ( [_jsonOp isCancelled] )
        {
            NSLog(@"FNRVC - processJSONData: _jsonOp cancelled");
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
        
        
        queryStr = [NSString stringWithFormat:@"SELECT CASE route_short_name WHEN \"LUCYGO\" THEN \"LGO\" WHEN \"LUCYGR\" THEN \"LGR\" ELSE route_short_name END as route_short_name, stop_id, route_type FROM stopIDRouteLookup WHERE stop_id=%d", [glObject.location_id intValue] ];
        results = [database executeQuery: queryStr];
        if ( [database hadError] )  // Check for errors
        {
            
            int errorCode = [database lastErrorCode];
            NSString *errorMsg = [database lastErrorMessage];
            
            NSLog(@"FNRVC - query failure, code: %d, %@", errorCode, errorMsg);
            NSLog(@"FNRVC - query str: %@", queryStr);
            
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
            
            [rObj addRouteInfo: dObj ];
            
        }
        
        [rObj sort];

        
        
//        NSLog(@"FNRVC - temp: %@ for query: %@", temp, queryStr);
//        if ( [temp length] > 2 )
//            temp = [temp substringToIndex:[temp length] - 2];
//        [glObject setRouteStr:temp];
        
//        [tempArray addObject: glObject];
  
        
        
        
        // TODO: Sort by distance
        
        [tempArray addObject:rObj];
        
        
    }
    
    
//    NSLog(@"FNRVC - processJSONData: Finished reading JSON Data");
    
    _masterList = [tempArray copy];  // Implicitly remove all objects from the old memory location that _masterList pointed to
    tempArray = nil;
    
    [self filterData];
    
}


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
    NSInteger index = [self.segmentTypes selectedSegmentIndex];
    if ( index == -1 )
        index = 0;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"location_type == %@", [_locationType objectAtIndex:index ] ];
    _tableData = [[_masterList filteredArrayUsingPredicate:predicate] mutableCopy];
    
    if ( [_tableData count] == 0)
    {

        BasicRouteObject *rObj = [[BasicRouteObject alloc] init];
        
        // Give it the main information
        [rObj setDistance: @"0.00"];
//        [rObj setStop_name: [NSString stringWithFormat:@"There is no stop within %5.3f mile radius of your current location",radiusInMiles] ];
        [rObj setStop_name:@"No stops were found near you."];
        
        [_tableData addObject: rObj];
        
        //GetLocationsObject *glObject = [[GetLocationsObject alloc] init];
        //[glObject setLocation_name:[NSString stringWithFormat:@"Nothing found within a %5.3f mile radius of your current location",radiusInMiles] ];
        //[_tableData addObject:glObject];
        
//        [_tableData]
    }
    
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
    [self performSegueWithIdentifier:@"MapSegue" sender:self];
}


#pragma mark - Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue identifier] isEqualToString:@"MapSegue"] )
    {
        
        FindNearestMapViewController *fnmvc = [segue destinationViewController];
        
        [fnmvc setMasterList:_masterList];
        
        int index = (int)[self.segmentTypes selectedSegmentIndex];
        if ( index == -1 )
            index = 0;
        
        [fnmvc setFilterType: [_locationType objectAtIndex:index] ];
        [fnmvc setRadius: [NSNumber numberWithFloat:radiusInMiles] ];
        
    }
    else if ( [[segue identifier] isEqualToString:@"FindSchedulesSegue"] )
    {
//        NSLog(@"NFNVC - FindSchedulesSegue");
        
        BasicRouteObject *rObj;  // = [[BasicRouteObject alloc] init];
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        rObj = [_tableData objectAtIndex: indexPath.row];
        
        FindSchedulesViewController *fsvc = [segue destinationViewController];
        [fsvc setBasicRoute: rObj];
        
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
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
    
    [digitInput setDigitOverlayImage:    [UIImage imageNamed:@"digitOverlay"  ] ];
    [digitInput setDigitBackgroundImage: [UIImage imageNamed:@"digitControlBG"] ];
    
    [digitInput setPlaceHolderCharacter:@"0"];
    
    // we are using an overlayimage, so make the bg color clear color
    
    digitInput.digitOverlayImage = nil;
    digitInput.digitViewBackgroundColor = [UIColor clearColor];
    digitInput.digitViewHighlightedBackgroundColor = [UIColor clearColor];
    
    digitInput.digitViewTextColor = [UIColor whiteColor];
    digitInput.digitViewHighlightedTextColor = [UIColor orangeColor];
    
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
    [lblMiles setFont: [UIFont boldSystemFontOfSize:16] ];
    [lblMiles setTextColor:[UIColor whiteColor] ];
    [lblMiles setText:@"miles"];
    [lblMiles setOpaque:NO];
    [lblMiles setBackgroundColor:[UIColor clearColor] ];
    
    [radiusView addSubview:lblMiles];
    
    UILabel *lblDescription = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, radiusView.frame.size.width-5, 20)];
    
    [lblDescription setFont: [UIFont boldSystemFontOfSize:16] ];
    [lblDescription setTextColor:[UIColor whiteColor] ];

//    [lblDescription setMinimumFontSize:5.0f];
    [lblDescription setMinimumScaleFactor:5.0f/[UIFont labelFontSize] ];
    
    [lblDescription setAdjustsFontSizeToFitWidth:YES];
    
    [lblDescription setText:@"Distance from your current location to search:"];
    [lblDescription setOpaque:NO];
    [lblDescription setBackgroundColor:[UIColor clearColor] ];
    
    [radiusView addSubview: lblDescription];
    
    
}

-(void) showRadiusView
{
    CGRect frame = radiusView.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    
    frame.origin.y = 0;
    [radiusView setFrame: frame];
    
    [UIView commitAnimations];
    
}

-(void) hideRadiusView
{
    CGRect frame = radiusView.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    
    frame.origin.y = -frame.size.height;
    [radiusView setFrame: frame];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    [UIView commitAnimations];
}

-(void) animationDidStop:(NSString*) animationID finished:(BOOL) finished context:(void *) context
{
    NSLog(@"FNRVC - animationDidStop");
    //    [radiusView removeFromSuperview];
    //    radiusView = nil;
}

#pragma mark - Change Radius
- (IBAction)btnRadiusPressed:(id)sender
{
    
    if ( _digitInputActive )
    {
        [digitInput resignFirstResponder];
        [self hideRadiusView];
        _digitInputActive = NO;
        
        [self.btnRadius setTitle:@"Distance"];
        [self.btnRadius setTintColor:[UIColor clearColor] ];
        
        
        return;
    }
    
    [self.btnRadius setTitle:@"Done"];
    [self.btnRadius setTintColor:[UIColor blueColor] ];
    
    _digitInputActive = YES;
    
    [self showRadiusView];
    
}

// dismissing the keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [digitInput resignFirstResponder];
}

//-(void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    digitInput.frame = CGRectMake(10, 45, self.view.frame.size.width-20, 55);
//}

/////////// recating on demo events ///////////
-(void)didBeginEditing:(id)sender
{
    CHDigitInput *input = (CHDigitInput *)sender;
    NSLog(@"did begin editing %@",input.value);
}

-(void)didEndEditing:(id)sender
{
    CHDigitInput *input = (CHDigitInput *)sender;
    NSLog(@"did end editing %@",input.value);
    
    // If targets are not removed (and the endediting one in particular!) removeFromSuperview statement below will trigger the didEndEditing event which will trigger...
    //    [input removeTarget:self action:@selector(didEndEditing:) forControlEvents:UIControlEventAllEvents];
    
    //    [self performSelector:@selector(removeDigitInput:) withObject:input afterDelay:0.25];
    [self hideRadiusView];
    if ( radiusInMiles != [input.value floatValue] )
    {
        
        radiusInMiles = [input.value floatValue];
        [savedInfo setRadius:[NSNumber numberWithFloat:radiusInMiles] ];
        NSLog(@"FNRVC - setting object savedInfo");
        [userSave setObject: savedInfo];
        NSLog(@"FNRVC - object savedInfo set");
        
        [self getLatestJSONData];
        
        [self.btnRadius setTitle:@"Radius"];
        [self.btnRadius setTintColor:[UIColor clearColor] ];
    }
    
    
    _digitInputActive = NO;
    //    [input removeFromSuperview];
    
    //    for (UIView *subView in self.view.subviews)
    //    {
    //        if ( [subView isKindOfClass:[CHDigitInput class] ] )
    //        {
    //            NSLog(@"Removing %@", subView);
    //            [subView removeFromSuperview];
    //        }
    //    }
    
}

-(void) removeDigitInput:(id) sender
{
    CHDigitInput *input = (CHDigitInput*) sender;
    
    radiusInMiles = [input.value floatValue];
    [self getLatestJSONData];
    
    [input removeFromSuperview];
}


-(void)textDidChange:(id)sender
{
    CHDigitInput *input = (CHDigitInput *)sender;
    NSLog(@"text did change %@",input.value);
}

-(void)valueChanged:(id)sender
{
    CHDigitInput *input = (CHDigitInput *)sender;
    NSLog(@"value changed %@",input.value);
}

- (void)viewDidUnload {
    [self setMapTapGesture:nil];
    [super viewDidUnload];
}


@end
