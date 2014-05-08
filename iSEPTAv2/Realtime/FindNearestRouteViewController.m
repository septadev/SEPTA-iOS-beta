//
//  FindNearestRouteViewController.m
//  iSEPTA
//
//  Created by septa on 1/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "FindNearestRouteViewController.h"
#import "SVProgressHUD.h"

#import "GetLocationsObject.h"
#import "mapAnnotation.h"

#import "CHDigitInput.h"

#import "SaveController.h"
#import "FindNearestRouteSaveObject.h"

#import "FMDatabase.h"

@interface FindNearestRouteViewController ()

@end

@implementation FindNearestRouteViewController
{
    NSMutableArray *_tableData;
    NSMutableArray *_masterList;
//    CLLocationCoordinate2D *_currentLocation;
    CLLocationManager *_locationManager;
    
    BOOL _stillWaitingOnWebRequest;
    NSArray *_locationType;
 
    CHDigitInput *digitInput;
    BOOL _digitInputActive;
    float radiusInMiles;
    
    UIView *radiusView;
 
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_jsonOp;
    
    SaveController *userSave;
    FindNearestRouteSaveObject *savedInfo;
        
}

@synthesize tableView;
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        NSLog(@"FNRVC - initWithNibName!");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"FNRVC - viewDidLoad");
	// Do any additional setup after loading the view.
    
    _masterList = [[NSMutableArray alloc] init];
    
    _jsonQueue  = [[NSOperationQueue alloc] init];        
    
    userSave = [[SaveController alloc] initWithKey:@"FindNearestRoute:Saves"];
//    savedInfo = (FindNearestRouteSaveObject*)[userSave object];
    
    NSLog(@"FNRVC - FindNearestRoute:Saves - %@", savedInfo);
    
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
    
    // --======
    // ==--  Setting up ScrollView
    // --======
    [self.scrollView setContentSize: CGSizeMake(self.scrollView.frame.size.width*2, self.scrollView.frame.size.height) ];  // Only two pages
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * 0;  // Initially show the page 0
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:NO];
    
    _locationType = [NSArray arrayWithObjects:@"bus_stops", @"rail_stations", @"perk_locations", @"trolley_stops", @"sales_locations", nil];
    
    
    // --======
    // ==--  Setting up MapKit
    // --======
    [mapView setShowsUserLocation: YES ];
    [mapView setScrollEnabled    : YES ];
    
    [mapView setDelegate:self];
    
    
    // --==
    // ==--  Setting up CLLocation Manager
    // --==
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager startUpdatingLocation];

    
    // A little background on span, thanks to http://stackoverflow.com/questions/7381783/mkcoordinatespan-in-meters
    [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, MilesToMeters(radiusInMiles*2), MilesToMeters(radiusInMiles*2) ) animated:YES];
    
    [mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
    [mapView setZoomEnabled:YES];
    
    
    [self getLatestJSONData];
    
    // --=======
    // ==--  Setting up PageControl
    // --=======
    [self.pageControl setCurrentPage:0];  // Only two pages for now.  Page 0 is the tableview, Page 1 is the mapView
    
    [self createRadiusView];
    
}

float MilesToMeters(float miles)
{
    return 1609.344f * miles;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"FNRVC - didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
    
    _masterList = nil;
    _jsonQueue  = nil;
    _jsonOp     = nil;
    
    userSave = nil;
    savedInfo = nil;
    
    _locationType = nil;
    _locationManager = nil;
    
//    mapView = nil;
    
}

- (void)viewDidUnload
{
    
    NSLog(@"FNRVC - viewDidUnload");
    [self setScrollView:nil];
    [self setTableView:nil];
    [self setMapView:nil];
    [self setPageControl:nil];
    
    
    [self setSegmentTypes:nil];
    [self setBtnRadius:nil];
    [super viewDidUnload];
    
}


-(void) viewDidDisappear:(BOOL)animated
{

    [super viewDidDisappear:animated];  // Must call super viewDidDisappear when this viewDidDisappear is overloaded
    
    [SVProgressHUD dismiss];
    [_jsonQueue cancelAllOperations];
    
    // Error persisted even with the [userSave save] line commented out.  Tenative solution: NSBlockOperation, cancelAllOperations and checking isCancelled
    NSLog(@"FNRVC - viewDidDisappear: userSave: %p, %p", userSave, savedInfo);
    [userSave save];
    NSLog(@"FNRVC - viewDidDisappear: user data saved!");
    
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
    [[cell textLabel] setText: [NSString stringWithFormat:@"%@ - %@",[glObject location_name], [glObject routeStr] ] ];
    return cell;
    
}


#pragma mark - UIPageControl
- (IBAction)pageControlChanged:(id)sender
{
    
    int page = [self.pageControl currentPage];
    
    // update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
}

#pragma mark - CLLocation Delegates
// Depreciated in iOS 6, needed to support iOS5.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location (iOS5): %@", [newLocation description]);
    [manager stopUpdatingLocation];
    
}

// Use for iOS6
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        NSLog(@"Location (iOS6):%@", location);
    }
    
    [manager stopUpdatingLocation];
    
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error description]);
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

    if ( radiusInMiles < 1 )
        [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, MilesToMeters(radiusInMiles*2), MilesToMeters(radiusInMiles*2) ) animated:YES];
    else
        [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, MilesToMeters(radiusInMiles), MilesToMeters(radiusInMiles) ) animated:YES];

    NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/locations/get_locations.php?lon=%9.6f&lat=%9.6f&radius=%6.3f&number_of_results=400", location.coordinate.longitude, location.coordinate.latitude, radiusInMiles];
    
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"FNRVC - getLatestJSONData -- api url: %@", webStringURL);
    
    [SVProgressHUD showWithStatus:@"Loading..."];

    
    _jsonOp     = [[NSBlockOperation alloc] init];

    __weak NSBlockOperation *weakOp = _jsonOp;
    [weakOp addExecutionBlock:^{
    
        NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
        
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
        
        NSDictionary *baseDict = [data dictionaryWithValuesForKeys:someKeys];
        NSDictionary *dataDict = [[data objectForKey:@"location_data"] dictionaryWithValuesForKeys:dataKeys];
        //            [baseDict setValue:dataDict forKey:@"location_data"];
        
        [glObject setValuesForKeysWithDictionary: baseDict];
        [(LocationData*)[glObject location_data] setValuesForKeysWithDictionary: dataDict];
        
        
        // --==  Determine what stops are associated with
        queryStr = [NSString stringWithFormat:@"SELECT route_short_name, stop_id FROM stopIDRouteLookup WHERE stop_id=%d", [glObject.location_id intValue] ];
        results = [database executeQuery: queryStr];
        if ( [database hadError] )  // Check for errors
        {
            
            int errorCode = [database lastErrorCode];
            NSString *errorMsg = [database lastErrorMessage];
            
            NSLog(@"FNRVC - query failure, code: %d, %@", errorCode, errorMsg);
            NSLog(@"FNRVC - query str: %@", queryStr);
            
            return;  // If an error occurred, there's nothing else to do but exit
            
        } // if ( [database hadError] )
        
        NSString *temp = @"";
        while ( [results next] )
        {
            temp = [temp stringByAppendingString: [NSString stringWithFormat:@"%@, ", [results stringForColumn:@"route_short_name"] ] ];
        }
        
        NSLog(@"FNRVC - temp: %@ for query: %@", temp, queryStr);
        if ( [temp length] > 2 )
            temp = [temp substringToIndex:[temp length] - 2];
        [glObject setRouteStr:temp];
        
        [tempArray addObject: glObject];
        
    }
    
    
    NSLog(@"FNRVC - processJSONData: Finished reading JSON Data");
    
//    [_masterList removeAllObjects];
    _masterList = [tempArray copy];  // Implicitly remove all objects from the old memory location that _masterList pointed to
    tempArray = nil;
    
    [self filterData];
    
}


NSComparisonResult (^sortGetLocationObjectByDistance)(GetLocationsObject*,GetLocationsObject*) = ^(GetLocationsObject *a, GetLocationsObject *b)
{
    return [[a distance] compare: [b distance] options:NSNumericSearch];
};


NSComparisonResult (^sortGetLocationObjectByLocationName)(GetLocationsObject*,GetLocationsObject*) = ^(GetLocationsObject *a, GetLocationsObject *b)
{
    return [[a location_name] compare: [b location_name] options:NSNumericSearch];
};


#pragma mark - UISegmentControl Changed
- (IBAction)segmentChanged:(id)sender
{
    // Filter _tableData
    [self filterData];
    
    
}

-(void) filterData
{
    int index = [self.segmentTypes selectedSegmentIndex];
    if ( index == -1 )
        index = 0;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"location_type == %@", [_locationType objectAtIndex:index ] ];
    _tableData = [[_masterList filteredArrayUsingPredicate:predicate] mutableCopy];
    
//    for (GetLocationsObject *glObject in _tableData)
//    {
//        NSLog(@"%@", glObject);
//    }
    
//    [_tableData sortUsingComparator:sortGetLocationObjectByLocationName];
    
//    NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];  // But this won't do an NSNumericSearch sort
//    [_tableData sortUsingDescriptors:[NSArray arrayWithObject:desc] ];

    
    [self updateAnnotations];
    [self.tableView reloadData];
}



-(void) updateAnnotations
{

    // --==
    // ==--  Annontations
    // --==
    NSMutableArray *annotationsToRemove = [[mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [mapView userLocation] ];         // Keep the userLocation annotation on the map
    [mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
    
    
    for (GetLocationsObject *glObject in _tableData)
    {
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([[glObject location_lat] doubleValue], [[glObject location_lon] doubleValue]);
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
        //            NSString *annotationTitle  = [NSString stringWithFormat: @"BlockID: %@ (%@ min)", [busData objectForKey:@"BlockID"], [busData objectForKey:@"Offset"]];
        
        NSString *annotationTitle = [NSString stringWithFormat:@"%@", [glObject location_name] ];
        
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"Stop ID: %@", [glObject location_id] ] ];
        [annotation setCurrentTitle   : annotationTitle];
        
//        NSLog(@"FNRVC -(void) updateAnnotations: %@", glObject);
        
        [mapView addAnnotation: annotation];
        [mapView selectAnnotation:annotation animated:YES];
    }
    
}

#pragma mark - MKMapViewDelegate Methods
//-(MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
//{
    //    NSLog(@"FNRVC -mapView viewForOverlay");
//    return [kmlParser viewForOverlay: overlay];
//}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    //    NSLog(@"FNRVC - viewForAnnotations");
    
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
    
    
//    UIImage *image;
//    if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"EastBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"SouthBound"] ) )
//    {
//        image = [UIImage imageNamed:@"bus_blue.png"];
//    }
//    else if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"WestBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"NorthBound"] ) )
//    {
//        image = [UIImage imageNamed:@"bus_red.png"];
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
//        image = [UIImage imageNamed:@"bus_yellow.png"];
//    }
//    [annotationView setImage: image];
    
    
    
    return annotationView;
    
}


//- (void)mapView:(MKMapView *)thisMapView regionDidChangeAnimated:(BOOL)animated
//{
//    //    NSLog(@"FNRVC - mapView regionDidChangeAnimated");
//    MKCoordinateRegion mapRegion;
//    // set the center of the map region to the now updated map view center
//    mapRegion.center = thisMapView.centerCoordinate;
//    
//    mapRegion.span.latitudeDelta = 0.3; // you likely don't need these... just kinda hacked this out
//    mapRegion.span.longitudeDelta = 0.3;
//    
//    // get the lat & lng of the map region
//    //    double lat = mapRegion.center.latitude;
//    //    double lng = mapRegion.center.longitude;
//    
//    // note: I have a variable I have saved called lastLocation. It is of type
//    // CLLocationCoordinate2D and I initially set it in the didUpdateUserLocation
//    // delegate method. I also update it again when this function is called
//    // so I always have the last mapRegion center point to compare the present one with
//    //    CLLocation *before = [[CLLocation alloc] initWithLatitude:lastLocation.latitude longitude:lastLocation.longitude];
//    //    CLLocation *now = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
//    
//    //    CLLocationDistance distance = ([before distanceFromLocation:now]) * 0.000621371192;
//    
//    
//    //    NSLog(@"Scrolled distance: %@", [NSString stringWithFormat:@"%.02f", distance]);
//    
//    //    if( distance > SCROLL_UPDATE_DISTANCE )
//    //    {
//    //        // do something awesome
//    //
//    //        //        if(isSystemScroll)
//    //        //        {
//    //        //            isSystemScroll=NO;
//    //        //            thisMapView.visibleMapRect = flyTo;
//    //        //
//    //        //            isSystemScroll=YES;
//    //        //            NSLog(@"scrolled out of bounds");
//    //        //            TransitmapView.frame = mapFrame;
//    //        //        }
//    //
//    //    }
//    
//    // resave the last location center for the next map move event
//    lastLocation.latitude = mapRegion.center.latitude;
//    lastLocation.longitude = mapRegion.center.longitude;
//    
//}




-(void) createRadiusView
{
    
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
    [lblDescription setMinimumFontSize:5.0f];
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


@end
