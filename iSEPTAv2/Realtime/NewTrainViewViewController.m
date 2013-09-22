//
//  NewTrainViewViewController.m
//  iSEPTA
//
//  Created by septa on 4/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NewTrainViewViewController.h"
#import "TransitMapViewController.h"

#import "SVProgressHUD.h"
#import "mapAnnotation.h"

// --==  Custom Objects
#import "TransitViewObject.h"
#import "TrainViewObject.h"

// --==  Custom Cells
#import "TrainViewCell.h"


#define JSON_REFRESH_RATE 20.0f


@interface NewTrainViewViewController ()

@end

@implementation NewTrainViewViewController
{
    
    CLLocationManager *_locationManager;  // Used to center small map screenshot on current location

    NSArray *trains;  // Array of TrainViewObjects
    NSMutableArray *masterList; // Array of TrainViewObjects
    
    BOOL _stillWaitingOnWebRequest;
    NSTimer *updateTimer;
    
    int _previousIndex;
    BOOL _reverseSort;
    
    CLLocationCoordinate2D lastLocation;
    MKMapRect flyTo;
    
    BOOL _killAllTimers;
    
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_jsonOp;
    
}

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

    
//    if ( ![travelMode isEqualToString:@"Bus"] )
//    {
//        travelMode = @"Rail";
//        routeName = @"";
//    }
    
    
    // --==
    // ==--  Setting up CLLocation Manager
    // --==
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager startUpdatingLocation];
    
    
    // --==
    // ==--  Display Current Location On MapView Thumbnail  ==--
    // --==
    // A little background on span, thanks to http://stackoverflow.com/questions/7381783/mkcoordinatespan-in-meters
    float radiusInMiles = 2.0;
    [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor:radiusInMiles*2], [self milesToMetersFor:radiusInMiles*2] ) animated:YES];
    
    [mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
    [mapView setZoomEnabled:NO];
    [mapView setScrollEnabled:NO];

    [mapView setShowsUserLocation:NO];
    [mapView setDelegate:self];
    
    
    // --==
    // --==  Initialization
    // --==
    
    _jsonQueue = [[NSOperationQueue alloc] init];
    
    masterList = [[NSMutableArray alloc] init];
    _previousIndex = 0;
    
    _reverseSort   = NO;
    _killAllTimers = NO;
    
    
    // --==
    // ==--  UISegementControl change
    // --==
    if ( [travelMode isEqualToString:@"Bus"] )  // Bus has differently named fields
    {
        [self.segmentFilter setTitle:@"Direction" forSegmentAtIndex:0];
        [self.segmentFilter setTitle:@"Destination" forSegmentAtIndex:1];
        [self.segmentFilter setTitle:@"Vehicle ID" forSegmentAtIndex:2];
        [self.segmentFilter setTitle:@"Status" forSegmentAtIndex:3];
    }
    
    [self getLatestJSONData];
    
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _killAllTimers = NO;
}


-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_jsonQueue cancelAllOperations];
    _killAllTimers = YES;
    
    // Dismiss any running HUDs.  If no HUDs are running, nothing happens.
    [SVProgressHUD dismiss];
    
    
    if ( updateTimer == nil )
        return;
    
    if ( [updateTimer isValid]  )
    {
        [updateTimer invalidate];
        updateTimer = nil;
        NSLog(@"NTVVC - Killing updateTimer");
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    masterList = nil;
}

- (void)viewDidUnload
{
    
    [self setMapView:nil];
    [self setSegmentFilter:nil];
    [self setTableView:nil];
    
    [self setMapViewTapGesture:nil];
    [super viewDidUnload];
}


#pragma mark - UITableViewDelegate
#pragma mark - UITableViewDataSource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;  // Table only has one section, segmented control switches between data sources
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [trains count];
}


- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TrainViewCell *cell = [thisTableView dequeueReusableCellWithIdentifier:@"NewNewTrainViewViewCell"];
    
    if ( cell == nil )
        cell = [[TrainViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewNewTrainViewViewCell"];
    
    if ( [self.travelMode isEqualToString:@"Bus"] )
    {
        TransitViewObject *tvObject = [trains objectAtIndex: indexPath.row];
        [cell addObjectToCell:tvObject];
    }
    else
    {
        TrainViewObject *tvObject = [trains objectAtIndex:indexPath.row];
        [cell addObjectToCell: tvObject];
//        NSLog(@"%d/%d: %@", indexPath.section, indexPath.row, tvObject);
    }
    
    return cell;
    
}



#pragma mark - MapView
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *ulv = [self.mapView viewForAnnotation:self.mapView.userLocation];
    ulv.hidden = YES;
}



#pragma mark - CCLocationManager
#pragma mark - CLLocation Delegates
// Depreciated in iOS 6, needed to support iOS5.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"TVVC - Location (iOS5): %@", [newLocation description]);
    [manager stopUpdatingLocation];
    
}

// Use for iOS6
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        NSLog(@"TVVC - Location (iOS6):%@", location);
    }
    
    [manager stopUpdatingLocation];
    
}



#pragma mark - Segment Control
- (IBAction)segmentSortChanged:(id)sender
{
    
    int index = [(TapableSegmentControl*)self.segmentFilter selectedSegmentIndex];
    if ( index == _previousIndex )
        _reverseSort = !_reverseSort;
    else
        _reverseSort = NO;
    
    [self sortDataWithIndex:index];
    
    _previousIndex = index;
    
}


#pragma mark - Gesture Recognizer
- (IBAction)mapViewTapped:(id)sender
{
    NSLog(@"NTVVC - MapView has been tapped");
    
    [SVProgressHUD setStatus:@"Loading..."];
    [self performSegueWithIdentifier:@"MapMapSegue" sender:self];
}


#pragma mark - Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue identifier] isEqualToString:@"MapMapSegue"] )
    {
        TransitMapViewController *tmvc = [segue destinationViewController];
        
        [tmvc setTravelMode: self.travelMode];
        [tmvc setRouteName: self.routeName];
        [tmvc setRouteType: self.routeType];
        // TODO: Should be passing RouteData object around, not routeName and routeType.
    }
    
}


#pragma mark - Custom Methods
-(float) milesToMetersFor: (float) miles
{
    return 1609.344f * miles;
}


// --==  Starts another JSON Request only when the previous one has finished
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


-(void) getLatestJSONData
{
    
    NSLog(@"NTVVC - getLatestJSONData");
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
    NSString* webStringURL;
    if ( [self.travelMode isEqualToString:@"Bus"] )  // Add MFL to this?  Need to investigate this further
    {
        
        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@", self.routeName];
        webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"NTVVC - getLatestJSONData (bus) -- api url: %@", webStringURL);
        
    }
    else if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        
        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TrainView/"];
        webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"NTVVC - getLatestJSONData (rail) -- api url: %@", webStringURL);
        
        [SVProgressHUD showWithStatus:@"Loading..."];
        
    }
    else
    {
        return;
    }
    
    
    _jsonOp     = [[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOp = _jsonOp;  // weak reference avoids retain cycle when calling [self processJSONData:...]
    [weakOp addExecutionBlock:^{
        
        NSData *realTimeJSONData = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self processJSONData:realTimeJSONData];
            }];
        }
        else
        {
            NSLog(@"NTVVC - getLatestJSONData: _jsonOp cancelled");
        }
        
    }];
    
    [_jsonQueue addOperation: _jsonOp];
    
}

-(void) getLatestRouteLocations
{
    
    NSLog(@"NTVVC - getLatestRouteLocations");
    
    //    [kmlParser details];
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
    if ( [self.travelMode isEqualToString:@"Bus"] )  // Add MFL to this?  Need to investigate this further
    {
        
        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@", routeName];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"NTVVC - getLatestRouteLocations (bus) -- api url: %@", webStringURL);
        
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
        NSLog(@"NTVVC - getLatestRouteLocations (rail) -- api url: %@", webStringURL);
        
        [SVProgressHUD showWithStatus:@"Loading..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            
            NSError *error = nil;
            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] options:NSDataReadingUncached error:&error ];
            
            if ( error )
            {
                NSLog(@"NTVVC - getLatestRouteLocations (rail) Error: %@", [error localizedDescription]);
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
            NSLog(@"NTVVC - Killing updateTimer");
        }
        
    }  // if ( updateTimer != nil )
    
}


-(void) addAnnotationsUsingJSONRailLocations:(NSData*) returnedData
{
    
    NSLog(@"NTVVC - addAnnotationsUsingJSONRailLocations");
    [SVProgressHUD dismiss];
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    
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


-(void) processJSONData:(NSData*) returnedData
{
    
    if ( returnedData == nil )
        return;
    
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    [SVProgressHUD dismiss];
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    NSMutableArray *readData = [[NSMutableArray alloc] init];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    //    [masterList removeAllObjects];
    if ( [self.travelMode isEqualToString:@"Bus"] )
    {
        
        for (NSDictionary *data in [json objectForKey:@"bus"] )
        {
            
            if ( [_jsonOp isCancelled] )
                return;
            
            
            if ( [[data objectForKey:@"Direction"] isEqualToString:@" "] )
                continue;
            
            TransitViewObject *tvObject = [[TransitViewObject alloc] init];
            
            [tvObject setLat: [data objectForKey:@"lat"] ];
            [tvObject setLng: [data objectForKey:@"lng"] ];
            [tvObject setLabel: [data objectForKey:@"label"] ];
            [tvObject setVehicleID: [data objectForKey:@"VehicleID"] ];
            
            [tvObject setBlockID: [data objectForKey:@"BlockID"] ];
            [tvObject setDirection: [data objectForKey:@"Direction"] ];
            [tvObject setDestination: [data objectForKey:@"destination"] ];
            [tvObject setOffset: [data objectForKey:@"Offset"] ];
            
            [readData addObject: tvObject];
            
        }
    }
    else if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        
        for (NSDictionary *data in json)
        {
            
            if ( [_jsonOp isCancelled] )
                return;
            
            TrainViewObject *tvObject = [[TrainViewObject alloc] init];
            // These keys need to be exactly as they appear in the returned JSON data
            [tvObject setStartName:[data objectForKey:@"SOURCE"] ];
            [tvObject setEndName  :[data objectForKey:@"dest"] ];
            
            [tvObject setLate     :[data objectForKey:@"late"] ];
            [tvObject setTrainNo  :[data objectForKey:@"trainno"] ];
            
            [readData addObject: tvObject];
            
        }
        
    }
    
    masterList = [readData copy];
    readData = nil;
    
    trains = masterList;
    
    [self kickOffAnotherJSONRequest];
    
    [self sortDataWithIndex: _previousIndex];
    
    [self.tableView reloadData];
    
}

#pragma mark - Sorting Methods
-(void) sortDataWithIndex:(int) index
{
    
    if ( [travelMode isEqualToString:@"Bus"] )
        //        return;  // No sort for you. One year!  (Bus and Rail have two different data sources and thus can't be sorted the same way)
        [self sortBusDataWithIndex:index];
    else
        [self sortRailDataWithIndex:index];
    
    [self.tableView reloadData];
    
}


-(void) sortBusDataWithIndex:(int) index
{
    
    // Uses TransitViewObject
    switch (index)
    {
        case 0:  // Start
        {
            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TransitViewObject *a, TransitViewObject *b)
                      {
                          if ( _reverseSort )
                              return [[b Direction] compare: [a Direction] ];
                          else
                              return [[a Direction] compare: [b Direction] ];
                      }];
        }  // case 0
            break;
        case 1:  // End
        {
            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TransitViewObject *a, TransitViewObject *b)
                      {
                          if ( _reverseSort )
                              return [ [b destination] compare: [a destination] ];
                          else
                              return [ [a destination] compare: [b destination] ];
                      }];
        }  // case 1
            break;
        case 2:  // Train #
        {
            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TransitViewObject *a, TransitViewObject *b)
                      {
                          int aInt = [[a VehicleID] intValue];
                          int bInt = [[b VehicleID] intValue];
                          
                          if ( _reverseSort )
                              return aInt < bInt;
                          else
                              return aInt > bInt;
                      }];
        }  // case 2
            break;
            
        case 3:  // Status
        {
            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TransitViewObject *a, TransitViewObject *b)
                      {
                          int aInt = [[a Offset] intValue];
                          int bInt = [[b Offset] intValue];
                          
                          if ( _reverseSort )
                              return aInt > bInt;
                          else
                              return aInt < bInt;
                      }];
        }  // case 3
            break;
            
        default:
            break;
    }  // switch (index)
    
    
}


-(void) sortRailDataWithIndex:(int) index
{
    
    // Uses TrainViewObject
    switch (index)
    {
        case 0:  // Start
        {
            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TrainViewObject *a, TrainViewObject *b)
                      {
                          //                NSLog(@"a.start: %@, b.start: %@", [a startName], [b startName]);
                          if ( _reverseSort )
                              return [[b startName] compare: [a startName] ];
                          else
                              return [[a startName] compare: [b startName] ];
                      }];
        }  // case 0
            break;
        case 1:  // End
        {
            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TrainViewObject *a, TrainViewObject *b)
                      {
                          if ( _reverseSort )
                              return [[b endName] compare: [a endName] ];
                          else
                              return [[a endName] compare: [b endName] ];
                      }];
        }  // case 1
            break;
        case 2:  // Train #
        {
            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TrainViewObject *a, TrainViewObject *b)
                      {
                          int aInt = [[a trainNo] intValue];
                          int bInt = [[b trainNo] intValue];
                          
                          if ( _reverseSort )
                              return aInt < bInt;
                          else
                              return aInt > bInt;
                      }];
        }  // case 2
            break;
            
        case 3:  // Status
        {
            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TrainViewObject *a, TrainViewObject *b)
                      {
                          int aInt = [[a late] intValue];
                          int bInt = [[b late] intValue];
                          
                          if ( _reverseSort )
                              return aInt > bInt;
                          else
                              return aInt < bInt;
                      }];
        }  // case 3
            break;
            
        default:
            break;
    }  // switch (index)
    
}

@end
