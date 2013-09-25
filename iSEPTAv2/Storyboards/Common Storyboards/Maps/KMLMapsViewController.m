//
//  KMLMapsViewController.m
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "KMLMapsViewController.h"

@interface KMLMapsViewController ()

@end

@implementation KMLMapsViewController
{

    CLLocationManager *_locationManager;  // Used to center small map screenshot on current location
    
    KMLParser *kmlParser;  // KML Object used to read in .kml files and generate annotations for mapView to use
    
    int _previousIndex;
    BOOL _reverseSort;
    
    CLLocationCoordinate2D lastLocation;
    MKMapRect flyTo;
    
    BOOL _killAllTimers;
    
    NSOperationQueue *_mainQueue;
    
    //    NSArray *trains;  // Array of TrainViewObjects
    NSMutableArray *masterList; // Array of TrainViewObjects
    
    BOOL _stillWaitingOnWebRequest;
    NSTimer *updateTimer;
    
    NSBlockOperation *_kmlOp;
    
}


// --==  Synthesize Section
@synthesize mapView;
@synthesize travelMode;
@synthesize routeName;


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
    
    
    // --==
    // --==  Initialize
    // --==
    _mainQueue = [[NSOperationQueue alloc] init];
    
    masterList = [[NSMutableArray alloc] init];
    _previousIndex = 0;
    
    _reverseSort = NO;
    _killAllTimers = NO;
    
    // --======
    // ==--  Setting up MapKit
    // --======
    [mapView setShowsUserLocation: YES ];
    [mapView setScrollEnabled    : YES ];
    
    [mapView setDelegate:self];
    [self.navigationItem setTitle:@"Vehicle Locations"];
    
    // --==
    // ==--  Setting up CLLocation Manager
    // --==
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager startUpdatingLocation];
    
    float radiusInMiles = 2.0;
    [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor:radiusInMiles*2], [self milesToMetersFor:radiusInMiles*2] ) animated:YES];
    
    [mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    
    [mapView setShowsUserLocation:YES];
    
    //    [self getLatestJSONData];
    
    [self initialLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    
    [self setMapView:nil];
    [super viewDidUnload];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _killAllTimers = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
    
    
    // Cancel all queue operations before they begin executing.
    [_mainQueue cancelAllOperations];
    
    
    _killAllTimers = YES;
    
    
    // Dismiss any running HUDs.  If no HUDs are running, nothing happens.
    [SVProgressHUD dismiss];
    
    
    if ( updateTimer == nil )
        return;
    
    if ( [updateTimer isValid]  )
    {
        [updateTimer invalidate];
        updateTimer = nil;
        NSLog(@"TMVC - Killing updateTimer");
    }
    
}


-(void) initialLoad
{
    
    _kmlOp     = [[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOp = _kmlOp;  // weak reference avoids retain cycle when calling [self processJSONData:...]
    [weakOp addExecutionBlock:^{
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self loadkml];
                [SVProgressHUD dismiss];
            }];
        }
        else
        {
            NSLog(@"TMVC - getLatestJSONData: _jsonOp cancelled");
        }
        
    }];
    
    [_mainQueue addOperation: _kmlOp];
    
    [self getLatestRouteLocations];  // This method uses a asynchronous dispatch queue for now
    
}

#pragma mark - CLLocation Delegates
// Depreciated in iOS 6, needed to support iOS5.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"TMVC - Location (iOS5): %@", [newLocation description]);
    [manager stopUpdatingLocation];
    
}

// Use for iOS6
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        NSLog(@"TMVC - Location (iOS6):%@", location);
    }
    
    [manager stopUpdatingLocation];
    
}

#pragma mark - MapView
#pragma mark - MKMapViewDelegate Methods
-(MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    //    NSLog(@"TMVC -mapView viewForOverlay");
    return [kmlParser viewForOverlay: overlay];
}

//-(MKAnnotationView*) mapView:(MKMapView *)thisMapView viewForAnnotation:(id<MKAnnotation>)annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    //    NSLog(@"TMVC - viewForAnnotations");
    
    if ( [annotation isKindOfClass:[MKUserLocation class]] )
        return nil;
    
    static NSString *identifier = @"mapAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } else {
        annotationView.annotation = annotation;
    }
    
    [annotationView setEnabled: YES];
    [annotationView setCanShowCallout: YES];
    
    
    UIImage *image;
    if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"EastBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"SouthBound"] ) )
    {
        if ( [self.routeType intValue] == 0)
            image = [UIImage imageNamed:@"trolley_blue.png"];
        else
            image = [UIImage imageNamed:@"bus_blue.png"];
    }
    else if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"WestBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"NorthBound"] ) )
    {
        if ( [self.routeType intValue] == 0)
            image = [UIImage imageNamed:@"trolley_red.png"];
        else
            image = [UIImage imageNamed:@"bus_red.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainSouth"] )
    {
        image = [UIImage imageNamed:@"train_blue.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainNorth"] )
    {
        image = [UIImage imageNamed:@"train_red.png"];
    }
    else
    {
        if ( [self.routeType intValue] == 0)
            image = [UIImage imageNamed:@"trolley_yellow.png"];
        else
            image = [UIImage imageNamed:@"bus_yellow.png"];
    }
    
    [annotationView setImage: image];
    
    return annotationView;
    
}


- (void)mapView:(MKMapView *)thisMapView regionDidChangeAnimated:(BOOL)animated
{
    
    //    NSLog(@"TMVC - mapView regionDidChangeAnimated");
    MKCoordinateRegion mapRegion;
    // set the center of the map region to the now updated map view center
    mapRegion.center = thisMapView.centerCoordinate;
    
    mapRegion.span.latitudeDelta = 0.3; // you likely don't need these... just kinda hacked this out
    mapRegion.span.longitudeDelta = 0.3;
    
    // get the lat & lng of the map region
    //    double lat = mapRegion.center.latitude;
    //    double lng = mapRegion.center.longitude;
    
    // note: I have a variable I have saved called lastLocation. It is of type
    // CLLocationCoordinate2D and I initially set it in the didUpdateUserLocation
    // delegate method. I also update it again when this function is called
    // so I always have the last mapRegion center point to compare the present one with
    //    CLLocation *before = [[CLLocation alloc] initWithLatitude:lastLocation.latitude longitude:lastLocation.longitude];
    //    CLLocation *now = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    
    //    CLLocationDistance distance = ([before distanceFromLocation:now]) * 0.000621371192;
    
    
    //    NSLog(@"Scrolled distance: %@", [NSString stringWithFormat:@"%.02f", distance]);
    
    //    if( distance > SCROLL_UPDATE_DISTANCE )
    //    {
    //        // do something awesome
    //
    //        //        if(isSystemScroll)
    //        //        {
    //        //            isSystemScroll=NO;
    //        //            thisMapView.visibleMapRect = flyTo;
    //        //
    //        //            isSystemScroll=YES;
    //        //            NSLog(@"scrolled out of bounds");
    //        //            TransitmapView.frame = mapFrame;
    //        //        }
    //
    //    }
    
    // resave the last location center for the next map move event
    lastLocation.latitude = mapRegion.center.latitude;
    lastLocation.longitude = mapRegion.center.longitude;
    
}


#pragma mark - KMLParser
-(void)loadkml
{
    
    //    AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *path;
    
    //    if([appDelegate.busdata.mode isEqualToString:@"Bus"])
    //    {
    //        path = [[NSBundle mainBundle] pathForResource:appDelegate.busdata.routeName ofType:@"kml"];
    //    }
    //    else if([appDelegate.busdata.mode isEqualToString:@"Regional Rail"])
    //    {
    //        path = [[NSBundle mainBundle] pathForResource:@"regionalrail" ofType:@"kml"];
    //    }
    
    //    int index = [self.segmentSort selectedSegmentIndex];
    if ( [self.travelMode isEqualToString:@"Bus"] )
        path = [[NSBundle mainBundle] pathForResource:routeName ofType:@"kml"];  // Hardcoded for now
    else if ( [self.travelMode isEqualToString:@"Rail"] )
        path = [[NSBundle mainBundle] pathForResource:@"regionalrail" ofType:@"kml"];
    else
        path = nil;
    
    if ( path == nil )
        return;
    
    
    NSURL *url = [NSURL fileURLWithPath:path];
    kmlParser = [[KMLParser alloc] initWithURL:url];
    [kmlParser parseKML];
    
    NSLog(@"TMVC: %@", url);
    
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    NSArray *overlays = [kmlParser overlays];
    NSLog(@"TMVC: overlays - %d",[overlays count]);
    [mapView addOverlays:overlays];
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    NSArray *annotations = [kmlParser points];
    NSLog(@"TMVC: annotations - %d",[annotations count]);
    [mapView addAnnotations:annotations];
    
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    flyTo = MKMapRectNull;
    for (id <MKOverlay> overlay in overlays)
    {
        
        if (MKMapRectIsNull(flyTo))
        {
            flyTo = [overlay boundingMapRect];
        }
        else
        {
            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
        }
        
    }
    
    
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    
    // Position the map so that all overlays and annotations are visible on screen.
    mapView.visibleMapRect = flyTo;
    
    
}

#pragma mark - Custom Methods
-(float) milesToMetersFor: (float) miles
{
    return 1609.344f * miles;
}


-(void) kickOffAnotherMapKitJSONRequest
{
    
    if ( _killAllTimers )
    {
        [self invalidateTimer];
        return;
    }
    
    NSLog(@"TMVC -(void) kickOffAnotherMapKitJSONRequest");
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:JSON_REFRESH_RATE
                                                  target:self
                                                selector:@selector(getLatestRouteLocations)
                                                userInfo:nil
                                                 repeats:NO];
}


-(void) kickOffAnotherJSONRequest
{
    
    if ( _killAllTimers )
    {
        [self invalidateTimer];
        return;
    }
    
    //    NSLog(@"NTVVC - kickOffAnotherJSONRequest");
//    updateTimer =[NSTimer scheduledTimerWithTimeInterval:JSON_REFRESH_RATE
//                                                  target:self
//                                                selector:@selector(getLatestJSONData)
//                                                userInfo:nil
//                                                 repeats:NO];
}


//-(void) getLatestJSONData
//{
//
//    NSLog(@"NTVVC - getLatestJSONData");
//
//    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
//        return;
//    else
//        _stillWaitingOnWebRequest = YES;
//
//
//    NSString* webStringURL;
//    if ( [self.travelMode isEqualToString:@"Bus"] )  // Add MFL to this?  Need to investigate this further
//    {
//
//        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@", self.routeName];
//        webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"NTVVC - getLatestJSONData (bus) -- api url: %@", webStringURL);
//
//    }
//    else if ( [self.travelMode isEqualToString:@"Rail"] )
//    {
//
//        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TrainView/"];
//        webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"NTVVC - getLatestJSONData (rail) -- api url: %@", webStringURL);
//
//        [SVProgressHUD showWithStatus:@"Loading..."];
//
//    }
//    else
//    {
//        return;
//    }
//
//
//    _jsonOp     = [[NSBlockOperation alloc] init];
//
//    __weak NSBlockOperation *weakOp = _jsonOp;  // weak reference avoids retain cycle when calling [self processJSONData:...]
//    [weakOp addExecutionBlock:^{
//
//        NSData *realTimeJSONData = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
//
//        if ( ![weakOp isCancelled] )
//        {
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                [self processJSONData:realTimeJSONData];
//            }];
//        }
//        else
//        {
//            NSLog(@"NTVVC - getLatestJSONData: _jsonOp cancelled");
//        }
//
//    }];
//
//    [_jsonQueue addOperation: _jsonOp];
//
//}

-(void) getLatestRouteLocations
{
    
    NSLog(@"TMVC - getLatestRouteLocations");
    
    //    [kmlParser details];
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
    if ( [self.travelMode isEqualToString:@"Bus"] )  // Add MFL to this?  Need to investigate this further
    {
        
        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@", routeName];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"TMVC - getLatestRouteLocations (bus) -- api url: %@", webStringURL);
        
        [SVProgressHUD showWithStatus:@"Loading..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            
            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
            [self performSelectorOnMainThread:@selector(addAnnotationsUsingJSONBusLocations:) withObject: realtimeBusInfo waitUntilDone:YES];
            
        });
        
    }
    else if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        
        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TrainView/"];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"TMVC - getLatestRouteLocations (rail) -- api url: %@", webStringURL);
        
        [SVProgressHUD showWithStatus:@"Loading..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            
            NSError *error = nil;
            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] options:NSDataReadingUncached error:&error ];
            
            if ( error )
            {
                NSLog(@"TMVC - getLatestRouteLocations (rail) Error: %@", [error localizedDescription]);
            }
            else
            {
                //                NSLog(@"NTVVC - getLatestRouteLocations (rail) Loaded data");
                [self performSelectorOnMainThread:@selector(addAnnotationsUsingJSONRailLocations:) withObject: realtimeBusInfo waitUntilDone:YES];
            }
            
        });
        
    }
}


-(void) invalidateTimer
{
    
    if ( updateTimer != nil )
    {
        
        if ( [updateTimer isValid]  )
        {
            [updateTimer invalidate];
            updateTimer = nil;
            NSLog(@"TMVC - Killing updateTimer");
        }
        
    }  // if ( updateTimer != nil )
    
}


-(void) addAnnotationsUsingJSONRailLocations:(NSData*) returnedData
{
    
    NSLog(@"TMVC - addAnnotationsUsingJSONRailLocations");
    [SVProgressHUD dismiss];
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    if ( returnedData == nil )  // No data was returned; no need to go further
        return;
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    NSMutableArray *annotationsToRemove = [[mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [mapView userLocation] ];         // Keep the userLocation annotation on the map
    [mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
    
    
    //    for (NSDictionary *railData in [json objectForKey:@"bus"])
    for (NSDictionary *railData in json)
    {
        
        //        if ( [railData objectForKey:@"SOURCE"] isEqualToString:@")
        
        //        NSLog(@"DSTVC - Bus data: %@", busData);
        // Loop through all returned bus info...
        NSNumber *latitude   = [NSNumber numberWithDouble: [[railData objectForKey:@"lat"] doubleValue] ];
        NSNumber *longtitude = [NSNumber numberWithDouble: [[railData objectForKey:@"lon"] doubleValue] ];
        
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([latitude doubleValue], [longtitude doubleValue]);
        
        //        NSString *direction = [railData objectForKey:@"Direction"];
        
        
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
        
        // Determine the train's direction
        //        NSString *direction;
        if ( [[railData objectForKey:@"trainno"] intValue] % 2)
        {
            //            direction = @"S";
            [annotation setDirection      : @"TrainSouth"];  // Modulus returns 1 on odd
        }
        else
        {
            //            direction = @"N";
            [annotation setDirection      : @"TrainNorth"];  // Modulus returns 0 on even
        }
        
        // Create the annonation title
        NSString *annotationTitle;
        if ( [[railData objectForKey:@"late"] intValue] == 0 )
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (on time)", [railData objectForKey:@"trainno"] ];
        else
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (%@ min late)", [railData objectForKey:@"trainno"], [railData objectForKey:@"late"]];
        
        [annotation setCurrentTitle   : annotationTitle];
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"%@ to %@", [railData objectForKey:@"SOURCE"], [railData objectForKey:@"dest"] ] ];
        
        
        
        [mapView addAnnotation: annotation];
        
    }
    
}


//-(void) processJSONData:(NSData*) returnedData
//{
//
//    if ( returnedData == nil )
//        return;
//
//    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
//    [SVProgressHUD dismiss];
//
//    // This method is called once the realtime positioning data has been returned via the API is stored in data
//    NSError *error;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
//    NSMutableArray *readData = [[NSMutableArray alloc] init];
//
//    if ( error != nil )
//        return;  // Something bad happened, so just return.
//
//    //    [masterList removeAllObjects];
//    if ( [self.travelMode isEqualToString:@"Bus"] )
//    {
//
//        for (NSDictionary *data in [json objectForKey:@"bus"] )
//        {
//
//            if ( [_jsonOp isCancelled] )
//                return;
//
//
//            if ( [[data objectForKey:@"Direction"] isEqualToString:@" "] )
//                continue;
//
//            TransitViewObject *tvObject = [[TransitViewObject alloc] init];
//
//            [tvObject setLat: [data objectForKey:@"lat"] ];
//            [tvObject setLng: [data objectForKey:@"lng"] ];
//            [tvObject setLabel: [data objectForKey:@"label"] ];
//            [tvObject setVehicleID: [data objectForKey:@"VehicleID"] ];
//
//            [tvObject setBlockID: [data objectForKey:@"BlockID"] ];
//            [tvObject setDirection: [data objectForKey:@"Direction"] ];
//            [tvObject setDestination: [data objectForKey:@"destination"] ];
//            [tvObject setOffset: [data objectForKey:@"Offset"] ];
//
//            [readData addObject: tvObject];
//
//        }
//    }
//    else if ( [self.travelMode isEqualToString:@"Rail"] )
//    {
//
//        for (NSDictionary *data in json)
//        {
//
//            if ( [_jsonOp isCancelled] )
//                return;
//
//            TrainViewObject *tvObject = [[TrainViewObject alloc] init];
//            // These keys need to be exactly as they appear in the returned JSON data
//            [tvObject setStartName:[data objectForKey:@"SOURCE"] ];
//            [tvObject setEndName  :[data objectForKey:@"dest"] ];
//
//            [tvObject setLate     :[data objectForKey:@"late"] ];
//            [tvObject setTrainNo  :[data objectForKey:@"trainno"] ];
//
//            [readData addObject: tvObject];
//
//        }
//
//    }
//
//    masterList = [readData copy];
//    readData = nil;
//
//    trains = masterList;
//
//    [self kickOffAnotherJSONRequest];
//
//}


-(void) removeAnnotationsFromMapView
{
    NSMutableArray *annotationsToRemove = [[mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [mapView userLocation] ];         // Keep the userLocation annotation on the map
    [mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
}

-(void) addAnnotationsUsingJSONBusLocations:(NSData*) returnedData
{
    
    NSLog(@"TMVC - addAnnotationsUsingJSONBusLocations");
    [SVProgressHUD dismiss];
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    [self removeAnnotationsFromMapView];
    
    for (NSDictionary *busData in [json objectForKey:@"bus"])
    {
        
        // Loop through all returned bus info...
        NSNumber *latitude   = [NSNumber numberWithDouble: [[busData objectForKey:@"lat"] doubleValue] ];
        NSNumber *longtitude = [NSNumber numberWithDouble: [[busData objectForKey:@"lng"] doubleValue] ];
        
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([latitude doubleValue], [longtitude doubleValue]);
        
        NSString *direction = [busData objectForKey:@"Direction"];
        
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
        NSString *annotationTitle  = [NSString stringWithFormat: @"BlockID: %@ (%@ min)", [busData objectForKey:@"BlockID"], [busData objectForKey:@"Offset"]];
        
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"Destination: %@", [busData objectForKey:@"destination"]] ];
        [annotation setCurrentTitle   : annotationTitle];
        [annotation setDirection      : direction];
        
        [mapView addAnnotation: annotation];
        
    }
    
    [self kickOffAnotherMapKitJSONRequest];
    NSLog(@"TMVC - addAnnotationsUsingJSONBusLocations -- added %d annotations", [[json objectForKey:@"bus"] count]);
    
    //    [SVProgressHUD dismiss];  // We got data, even if it's nothing.  Dismiss the Loading screen...
    
}




@end
