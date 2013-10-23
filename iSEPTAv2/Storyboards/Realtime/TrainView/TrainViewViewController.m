//
//  TrainViewViewController.m
//  iSEPTA
//
//  Created by septa on 8/8/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TrainViewViewController.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0f)

@interface TrainViewViewController ()

@end

@implementation TrainViewViewController
{
    NSMutableArray *_tableData;
    NSMutableDictionary *_annotationLookup;
    
    CLLocationManager *_locationManager;
    
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_jsonOp;
    
    BOOL _reverseSort;
    BOOL _killAllTimers;
    BOOL _stillWaitingOnWebRequest;
    BOOL _locationEnabled;
    
    NSTimer *updateTimer;
    
    
    // -- for KML Parsing
    KMLParser *kmlParser;
    NSBlockOperation *_kmlOp;
    NSOperationQueue *_mainQueue;
    
    MKMapRect flyTo;

    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization

    }
    return self;
}


//-(id) initWithCoder:(NSCoder *)aDecoder
//{
//    
//    self = [super initWithCoder:aDecoder];
//    if ( self )
//    {
//        
//    }
//    return self;
//    
//}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // self.view.frame will display the actual width and height based on the orientation here.
    // viewDidLoad will only show the portriat width and height, regardless of orientation.

    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
    
    [self updateViewsWithOrientation: [[UIApplication sharedApplication] statusBarOrientation] ];
    
    _killAllTimers = NO;
    
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _tableData = [[NSMutableArray alloc] init];
    _annotationLookup = [[NSMutableDictionary alloc] init];
    
    _mainQueue = [[NSOperationQueue alloc] init];
    
    
    
    // --==  Register Your Nibs!
    [self.tableView registerNib: [UINib nibWithNibName:@"RealtimeVehicleInformationCell" bundle:nil] forCellReuseIdentifier: @"RealtimeVehicleInformationCell"];

    
    
    NSString *imageName;
    
    if ( self.routeName == nil )
    {
        imageName = @"RRL_white.png";
    }
    else
    {
        imageName = @"RRL_white.png";
    }
    
//    if ( self.backImageName == nil )
//        [self setBackImageName: @"RRL_white.png"];
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed: @"RRL_white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    
    // --==  Determine title of view  ==--
    NSString *title = @"TrainView";
    if ( self.travelMode != nil )
    {
        if ( (GTFSRouteType)[self.travelMode intValue] == kGTFSRouteTypeRail )
        {
            title = @"TrainView";  // No change
        }
        else
        {
            title = @"TransitView";  // If it ain't rail, then it's Transit
        }
    }
    else
    {
        self.travelMode = [NSNumber numberWithInt: kGTFSRouteTypeRail];
    }
    
    
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: title];
    [self.navigationItem setTitleView:titleView];

    
    [self.imgTableViewBG setBackgroundColor: [UIColor blackColor] ];

    
    CAGradientLayer *l = [CAGradientLayer layer];

    l.frame = CGRectMake(0, 0, 320, 480);
    l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor], nil];

    l.startPoint = CGPointMake(0.0f, 0.0f);
    l.endPoint = CGPointMake(0.35f, 0.35f);
    
    //you can change the direction, obviously, this would be top to bottom fade
    self.imgTableViewBG.layer.mask = l;
 
    
    
    // --==
    // ==--  Setting up CLLocation Manager
    // --==
    if ( [CLLocationManager locationServicesEnabled] )
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager startUpdatingLocation];
        
        _locationEnabled = YES;
        
        
        // --==
        // ==--  Display Current Location On MapView Thumbnail  ==--
        // --==
        // A little background on span, thanks to http://stackoverflow.com/questions/7381783/mkcoordinatespan-in-meters
        float radiusInMiles = 2.0;
        [self.mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor:radiusInMiles*2], [self milesToMetersFor:radiusInMiles*2] ) animated:YES];
        
        [self.mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
        [self.mapView setZoomEnabled:YES];
        [self.mapView setScrollEnabled:YES];
        
        [self.mapView setShowsUserLocation:YES];
        [self.mapView setDelegate:self];
        
    }
    else
    {
        _locationEnabled = NO;
    }
    

    
    // --==  Initialize NSOperation Queue
    _jsonQueue = [[NSOperationQueue alloc] init];

    _reverseSort = NO;
    _killAllTimers = NO;
    _stillWaitingOnWebRequest = NO;
    
    
    
    if ( _locationEnabled )
    {
        // If the network is not reachable, try again in another 20 seconds
        [self getLatestJSONData];       // Grabs the last updated data on the vehciles of the requested route
    
        [self loadKMLInTheBackground];  // Loads the KML for the requested route in the background
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) viewWillDisappear:(BOOL)animated
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

-(void) viewDidUnload
{
    NSLog(@"TVVC - viewDidUnoad");
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
    
    NSString *orientation;
    if ( UIInterfaceOrientationIsLandscape( toInterfaceOrientation ) )
    {
        // Reposition views to Landscape layout
        orientation = @"L";
        [self.mapView setFrame: CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height)];
        [self.imgTableViewBG setFrame: CGRectMake(self.view.frame.size.width/2 - 20, 0, self.view.frame.size.width/2 + 20, self.view.frame.size.height)];
        [self.tableView setFrame: self.imgTableViewBG.frame];
        [self.imgVerticalDivider setFrame: CGRectMake(self.tableView.frame.origin.x + 73, 0, 2, self.tableView.frame.size.height)];
    }
    else
    {
        // Reposition views to Portrait layout
        
        orientation = @"P";
        [self.mapView setFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
        [self.imgTableViewBG setFrame: CGRectMake(0, self.view.frame.size.height/2 - 20, self.view.frame.size.width, self.view.frame.size.height/2 + 20)];
        [self.tableView setFrame: self.imgTableViewBG.frame];
        [self.imgVerticalDivider setFrame: CGRectMake(73, self.tableView.frame.origin.y, 2, self.tableView.frame.size.height)];
    }
    
    
//    NSLog(@"(%@) MapView   frame: %@", orientation, NSStringFromCGRect(self.mapView.frame));
    NSLog(@"(%@) Image     frame: %@", orientation, NSStringFromCGRect(self.tableView.frame));
    NSLog(@"(%@) Image    bounds: %@", orientation, NSStringFromCGRect(self.tableView.bounds));
    [self.tableView reloadData];
    
}


#pragma mark - UITableViewDelegate
#pragma mark - UITableViewDataSource
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    
//    if ( [self.travelMode isEqualToString:@"Bus"] )
//        return sectionTitle;
//    else
//        return nil;
//    
//}


//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    
//    
//    if ( [self.travelMode isEqualToString:@"Bus"] )
//    {
//        
//        //    NSInteger row = [stops getSectionForSection:segmentedIndex withIndex:index];
//        
//        //    NSInteger row = [stopData getSectionForSection:segmentedIndex withIndex:index];
//        NSInteger row = [[sectionIndex objectAtIndex:index] integerValue];
//        
//        // Calculate number of sections
//        NSInteger section = [_routeData numberOfSections] - 1;
//        
//        //    NSLog(@"sec/row: %d/%d, title: %@", section, row, [sectionTitle objectAtIndex:index]);
//        
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
//    
//    return -1;  // Yes, Virginia.  Keep this as -1 becaues we don't have multiple sections, which is what this method what designed for}
//    
//}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *annotationArr = [self.mapView selectedAnnotations];
    mapAnnotation *selectedAnnotation;
    mapAnnotation *newAnnotation;
    
    
    // Find the annotation displayed for a particular VehicleID or trainNo
    id object = [_tableData objectAtIndex:indexPath.row];
    if ( [object isKindOfClass:[TransitViewObject class] ] )
    {
        newAnnotation = [[_annotationLookup objectForKey: ((TransitViewObject*) object).VehicleID ] nonretainedObjectValue];
    }
    else if ( [object isKindOfClass: [TrainViewObject class] ] )
    {
        newAnnotation = [[_annotationLookup objectForKey: ((TrainViewObject*) object).trainNo] nonretainedObjectValue];
    }

    
    // Check if any annotations have been selected.  If so, deselect them (and maybe the tableView cell)
    if ( [annotationArr count] > 0 )
    {
        
        selectedAnnotation = (mapAnnotation*)[annotationArr objectAtIndex:0];
        
        if ( newAnnotation.id != selectedAnnotation.id )
        {
            // Nothing to do here
        }
        else  // Once to select, twice to deselect
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }

        // Always deselect the current annontation
        [self.mapView deselectAnnotation: selectedAnnotation animated:YES];
        
    }
    
    // Select the new annotation
    [self.mapView selectAnnotation: newAnnotation animated:YES];

    
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;  // Table only has one section, segmented control switches between data sources
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    NSLog(@"num of rows: %d", [trains count]);
    return [_tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    static NSString *vehicleCell = @"RealtimeVehicleInformationCell";
    
    
    RealtimeVehicleInformationCell *cell;
    
    cell = (RealtimeVehicleInformationCell*)[thisTableView dequeueReusableCellWithIdentifier: vehicleCell];
    
    
//    if ( [self.travelMode isEqualToString:@"Bus"] )
//    {
//        TransitViewObject *tvObject = [trains objectAtIndex: indexPath.row];
//        [cell addObjectToCell:tvObject];
//    }
//    else
    {
        TrainViewObject *tvObject = [_tableData objectAtIndex:indexPath.row];
        [cell addObjectToCell: tvObject];
        

//        if ( indexPath.row == 0 )
//        {
//            NSLog(@"f.str label : %@", NSStringFromCGRect(cell.lblStartName.frame));
//            NSLog(@"f.end label : %@", NSStringFromCGRect(cell.lblEndName.frame));
//            NSLog(@"b.end label : %@", NSStringFromCGRect(cell.lblEndName.bounds));
        

            if ( UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) )
            {
                [cell.lblEndName setFrame:CGRectMake(129, 22, 180, 21)];
                [cell.lblStartName setFrame:CGRectMake(129, 4, 180, 21)];
            }
            else
            {
                float aspectRatio = [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height;
                [cell.lblEndName   setFrame:CGRectMake(129, 22, 180 * aspectRatio, 21)];
                [cell.lblStartName setFrame:CGRectMake(129,  4, 180 * aspectRatio, 21)];
            }

            
//        }

        
//        NSLog(@"cell frame: %@", NSStringFromCGRect(self.imgTableViewBG.frame));
//        NSLog(@"cell bound: %@", NSStringFromCGRect(self.imgTableViewBG.bounds));
//        [cell setFrame: self.imgTableViewBG.frame];
//        
//        NSLog(@"f.end label : %@", NSStringFromCGRect(cell.lblEndName.frame));
//        NSLog(@"b.end label : %@", NSStringFromCGRect(cell.lblEndName.bounds));
//        [cell.lblEndName setBounds: CGRectMake(0, 0, 100, 21)];
  
        
        //        NSLog(@"%d/%d: %@", indexPath.section, indexPath.row, tvObject);
    }
    
    //    NSLog(@"%d/%d - cell: %@", indexPath.section, indexPath.row, cell);
    return cell;
    
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0f;
}


#pragma mark - Buttons Pressed
-(void) backButtonPressed:(id) sender
{
        
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - Custom Methods
-(float) milesToMetersFor: (float) miles
{
    return 1609.344f * miles;
}


#pragma mark - JSON Fetching and Processing
-(void) getLatestJSONData
{
    
//    NSLog(@"NTVVC - getLatestJSONData");
    
    
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
    {
        // Disable realtime buttons if no internet connection is available
        [self kickOffAnotherJSONRequest];
        return;
    }


    
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
    NSString* webStringURL;
    NSString *stringURL;
    GTFSRouteType routeType = (GTFSRouteType)[self.travelMode intValue];
    

    
    switch (routeType)
    {
        case kGTFSRouteTypeBus:
        case kGTFSRouteTypeTrolley:
            stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@", self.routeName];
            webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"NTVVC - getLatestJSONData (bus) -- api url: %@", webStringURL);
            
            break;
            
        case kGTFSRouteTypeRail:
            
            stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TrainView/"];
            webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSLog(@"NTVVC - getLatestJSONData (rail) -- api url: %@", webStringURL);

            break;
            
        default:
            return;
            break;
    }

    [SVProgressHUD showWithStatus:@"Loading..."];
    
    
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


-(void) processJSONData:(NSData*) returnedData
{
    
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    [SVProgressHUD dismiss];
    
    if ( returnedData == nil )
        return;
    
    // This method is called once the realtime positioning data has been returned via the API
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    NSMutableArray *readData = [[NSMutableArray alloc] init];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    //    [masterList removeAllObjects];
    GTFSRouteType routeType = (GTFSRouteType)[self.travelMode intValue];
    
    
    NSMutableArray *annotationsToRemove = [[self.mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [self.mapView userLocation] ];                // Keep the userLocation annotation on the map
    [self.mapView removeAnnotations: annotationsToRemove];                           // All annotations remaining in the array get removed
    annotationsToRemove = nil;
    
    
    switch (routeType)
    {
        case kGTFSRouteTypeBus:
        case kGTFSRouteTypeTrolley:
            
            [_annotationLookup removeAllObjects];
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
                
                CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:[[data objectForKey:@"lat"] doubleValue] longitude: [[data objectForKey:@"lng"] doubleValue] ];
                CLLocationDistance dist = [_locationManager.location distanceFromLocation: stopLocation] / 1609.34f;
                
                [tvObject setDistance: [NSNumber numberWithDouble: dist] ];
                
                [readData addObject: tvObject];
                [self addAnnotationUsingwithObject: tvObject];
                
            }
                        
            break;
            
        case kGTFSRouteTypeRail:
            
            for (NSDictionary *data in json)
            {
                
                if ( [_jsonOp isCancelled] )
                    return;
                
                TrainViewObject *tvObject = [[TrainViewObject alloc] init];
                // These keys need to be exactly as they appear in the returned JSON data
                [tvObject setStartName:[data objectForKey:@"SOURCE"] ];
                [tvObject setEndName  :[data objectForKey:@"dest"] ];

                [tvObject setLatitude :[data objectForKey:@"lat"] ];
                [tvObject setLongitude:[data objectForKey:@"lon"] ];
                
                [tvObject setLate     :[data objectForKey:@"late"] ];
                [tvObject setTrainNo  :[data objectForKey:@"trainno"] ];
                
                CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:[[data objectForKey:@"lat"] doubleValue] longitude: [[data objectForKey:@"lon"] doubleValue] ];
                CLLocationDistance dist = [_locationManager.location distanceFromLocation: stopLocation] / 1609.34f;

                [tvObject setDistance: [NSNumber numberWithDouble: dist] ];
                
                [readData addObject: tvObject];
                [self addAnnotationUsingwithObject: tvObject];
                
            }
            
            break;
            
        default:
            return;
            break;
    }
    
    
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    [readData sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
//    [readData sortUsingComparator:^NSComparisonResult(id a, id b)
//     {
//         if ( _reverseSort )
//             return [[b distance] compare: [a distance] ];  
//         else
//             return [[a distance] compare: [b distance] ];
//     }];

    
    
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


    _tableData = readData;
    
    [self kickOffAnotherJSONRequest];

    
//    masterList = [readData copy];
//    readData = nil;
//    
//    trains = masterList;
//    
//    [self kickOffAnotherJSONRequest];
//    
//    [self sortDataWithIndex: _previousIndex];
    
    [self.tableView reloadData];
 
}


-(void) addAnnotationUsingwithObject: (id) object
{
    

    if ( [object isKindOfClass:[TransitViewObject class] ] )
    {
        TransitViewObject *tvObject = (TransitViewObject*) object;
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([tvObject.lat doubleValue], [tvObject.lng doubleValue]);
        
        NSString *direction = tvObject.Direction;
        
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
        NSString *annotationTitle  = [NSString stringWithFormat: @"Vehicle: %@ (%@ min)", tvObject.VehicleID, tvObject.Offset];
        
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"Destination: %@", tvObject.destination ] ];
        [annotation setCurrentTitle   : annotationTitle];
        [annotation setDirection      : direction];
        
        [annotation setId: [NSNumber numberWithInt: [tvObject.VehicleID intValue] ] ];
        
        [_annotationLookup setObject: [NSValue valueWithNonretainedObject: annotation] forKey: tvObject.VehicleID];
        
        [self.mapView addAnnotation: annotation];
    }
    else if ( [object isKindOfClass:[TrainViewObject class] ] )
    {
        TrainViewObject *tvObject = (TrainViewObject*) object;

        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([tvObject.latitude doubleValue], [tvObject.longitude doubleValue]);
        
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
//        NSString *annotationTitle  = [NSString stringWithFormat: @"TrainNo: %@ (%d min)", tvObject.trainNo, [tvObject.late intValue] ];
//        
//        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"Destination: %@", tvObject.endName ] ];
//        [annotation setCurrentTitle   : annotationTitle];
//        [annotation setDirection      : direction];
        
        
        if ( [tvObject.trainNo intValue] % 2)
            [annotation setDirection      : @"TrainSouth"];  // Modulus returns 1 on odd
        else
            [annotation setDirection      : @"TrainNorth"];  // Modulus returns 0 on even
        
        // Create the annonation title
        NSString *annotationTitle;
        if ( [tvObject.late intValue] == 0 )
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (on time)", tvObject.trainNo ];
        else
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (%d min late)", tvObject.trainNo, [tvObject.late intValue] ];
        
        [annotation setCurrentTitle   : annotationTitle];
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"%@ to %@", tvObject.startName, tvObject.endName ] ];
        
        [_annotationLookup setObject: [NSValue valueWithNonretainedObject: annotation] forKey: tvObject.trainNo];
        
        [self.mapView addAnnotation: annotation];
        
    }
    
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



#pragma mark - Sorting Methods
-(void) sortDataWithIndex:(int) index
{
    
    GTFSRouteType routeType = (GTFSRouteType)[self.travelMode intValue];
    
    if ( routeType == kGTFSRouteTypeRail )
        [self sortRailDataWithIndex:2];
    else
        [self sortBusDataWithIndex:0];
    
    [self.tableView reloadData];
    
}


-(void) sortBusDataWithIndex:(int) index
{
    
    // Uses TransitViewObject
    switch (index)
    {
        case 0:  // Start
        {
            [_tableData sortUsingComparator:^NSComparisonResult(TransitViewObject *a, TransitViewObject *b)
                      {
                          if ( _reverseSort )
                              return [[b Direction] compare: [a Direction] ];
                          else
                              return [[a Direction] compare: [b Direction] ];
                      }];
        }  // case 0
            break;
            
//        case 1:  // End
//        {
//            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TransitViewObject *a, TransitViewObject *b)
//                      {
//                          if ( _reverseSort )
//                              return [ [b destination] compare: [a destination] ];
//                          else
//                              return [ [a destination] compare: [b destination] ];
//                      }];
//        }  // case 1
//            break;
//        case 2:  // Train #
//        {
//            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TransitViewObject *a, TransitViewObject *b)
//                      {
//                          int aInt = [[a VehicleID] intValue];
//                          int bInt = [[b VehicleID] intValue];
//                          
//                          if ( _reverseSort )
//                              return aInt < bInt;
//                          else
//                              return aInt > bInt;
//                      }];
//        }  // case 2
//            break;
//            
//        case 3:  // Status
//        {
//            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TransitViewObject *a, TransitViewObject *b)
//                      {
//                          int aInt = [[a Offset] intValue];
//                          int bInt = [[b Offset] intValue];
//                          
//                          if ( _reverseSort )
//                              return aInt > bInt;
//                          else
//                              return aInt < bInt;
//                      }];
//        }  // case 3
//            break;
            
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
            [_tableData sortUsingComparator:^NSComparisonResult(TrainViewObject *a, TrainViewObject *b)
                      {
                          if ( _reverseSort )
                              return [[b startName] compare: [a startName] ];
                          else
                              return [[a startName] compare: [b startName] ];
                      }];
        }  // case 0
            break;
            
            
//        case 1:  // End
//        {
//            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TrainViewObject *a, TrainViewObject *b)
//                      {
//                          if ( _reverseSort )
//                              return [[b endName] compare: [a endName] ];
//                          else
//                              return [[a endName] compare: [b endName] ];
//                      }];
//        }  // case 1
//            break;
        case 2:  // Train #
        {
            [_tableData sortUsingComparator:^NSComparisonResult(TrainViewObject *a, TrainViewObject *b)
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
//
//        case 3:  // Status
//        {
//            trains = [masterList sortedArrayUsingComparator:^NSComparisonResult(TrainViewObject *a, TrainViewObject *b)
//                      {
//                          int aInt = [[a late] intValue];
//                          int bInt = [[b late] intValue];
//                          
//                          if ( _reverseSort )
//                              return aInt > bInt;
//                          else
//                              return aInt < bInt;
//                      }];
//        }  // case 3
//            break;
            
        default:
            break;
    }  // switch (index)
    
}


#pragma mark - KML Fun (it isn't)
-(void) loadKMLInTheBackground
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
            NSLog(@"TVVC - getLatestJSONData: _jsonOp cancelled");
        }
        
    }];
    
    [_mainQueue addOperation: _kmlOp];
    
    //[self getLatestRouteLocations];  // This method uses a asynchronous dispatch queue for now
    
}


#pragma mark - KMLParser
-(void)loadkml
{
    
    NSString *path;
    
    GTFSRouteType routeType = (GTFSRouteType)[self.travelMode intValue];
    
    if ( routeType == kGTFSRouteTypeRail )
        path = [[NSBundle mainBundle] pathForResource:@"regionalrail" ofType:@"kml"];
    else if ( routeType == kGTFSRouteTypeTrolley || routeType == kGTFSRouteTypeBus )
        path = [[NSBundle mainBundle] pathForResource:self.routeName ofType:@"kml"];  // Hardcoded for now
    else
        path = nil;
    
    if ( path == nil )
        return;
    
    
    NSURL *url = [NSURL fileURLWithPath:path];
    kmlParser = [[KMLParser alloc] initWithURL:url];
    [kmlParser parseKML];
    
//    NSLog(@"TVVC: %@", url);
    
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    NSArray *overlays = [kmlParser overlays];
//    NSLog(@"TVVC: overlays - %d",[overlays count]);
    [self.mapView addOverlays:overlays];
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    NSArray *annotations = [kmlParser points];
    NSLog(@"TVVC: annotations - %d",[annotations count]);
    [self.mapView addAnnotations:annotations];
    
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
    self.mapView.visibleMapRect = flyTo;
    
}


-(void) removeAnnotationsFromMapView
{
    NSMutableArray *annotationsToRemove = [[self.mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [self.mapView userLocation] ];         // Keep the userLocation annotation on the map
    [self.mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
}


-(void) addAnnotationsUsingJSONBusLocations:(NSData*) returnedData
{
    
//    NSLog(@"TVVC - addAnnotationsUsingJSONBusLocations");
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
        
        [self.mapView addAnnotation: annotation];
        
    }
    
    [self kickOffAnotherMapKitJSONRequest];
//    NSLog(@"TVVC - addAnnotationsUsingJSONBusLocations -- added %d annotations", [[json objectForKey:@"bus"] count]);
    
    //    [SVProgressHUD dismiss];  // We got data, even if it's nothing.  Dismiss the Loading screen...
    
}


-(void) kickOffAnotherMapKitJSONRequest
{
    
    if ( _killAllTimers )
    {
        [self invalidateTimer];
        return;
    }
    
//    NSLog(@"TVVC -(void) kickOffAnotherMapKitJSONRequest");
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:JSON_REFRESH_RATE
                                                  target:self
                                                selector:@selector(getLatestRouteLocations)
                                                userInfo:nil
                                                 repeats:NO];
}



-(void) getLatestRouteLocations
{
    
//    NSLog(@"TVVC - getLatestRouteLocations");
    
    //    [kmlParser details];
    
    // Should never be in here!
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
    GTFSRouteType routeType = (GTFSRouteType)[self.travelMode intValue];
    
    NSString *stringURL;
    NSString *webStringURL;
    
    
    if ( routeType == kGTFSRouteTypeTrolley || routeType == kGTFSRouteTypeBus)
    {
        
        stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@", self.routeName];
        webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"TVVC - getLatestRouteLocations (bus) -- api url: %@", webStringURL);

        
        
        [SVProgressHUD showWithStatus:@"Loading..."];
        
    }
    else if ( routeType == kGTFSRouteTypeRail )
    {

        stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TrainView/"];
        webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"TVVC - getLatestRouteLocations (rail) -- api url: %@", webStringURL);
        
    }
    
    
    NSURL *url = [NSURL URLWithString: webStringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        // Success Block
        NSLog(@"IP Address: %@", [JSON valueForKeyPath:@"origin"]);
    }
                                                                                        failure:nil];
    
    [operation start];
    
    
    
//    if ( [self.travelMode isEqualToString:@"Bus"] )  // Add MFL to this?  Need to investigate this further
//    {
//        
//        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@", routeName];
//        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"TMVC - getLatestRouteLocations (bus) -- api url: %@", webStringURL);
//        
//        [SVProgressHUD showWithStatus:@"Loading..."];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
//            
//            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
//            [self performSelectorOnMainThread:@selector(addAnnotationsUsingJSONBusLocations:) withObject: realtimeBusInfo waitUntilDone:YES];
//            
//        });
//        
//    }
//    else if ( [self.travelMode isEqualToString:@"Rail"] )
//    {
//        
//        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TrainView/"];
//        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"TMVC - getLatestRouteLocations (rail) -- api url: %@", webStringURL);
//        
//        [SVProgressHUD showWithStatus:@"Loading..."];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
//            
//            NSError *error = nil;
//            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] options:NSDataReadingUncached error:&error ];
//            
//            if ( error )
//            {
//                NSLog(@"TMVC - getLatestRouteLocations (rail) Error: %@", [error localizedDescription]);
//            }
//            else
//            {
//                //                NSLog(@"NTVVC - getLatestRouteLocations (rail) Loaded data");
//                [self performSelectorOnMainThread:@selector(addAnnotationsUsingJSONRailLocations:) withObject: realtimeBusInfo waitUntilDone:YES];
//            }
//            
//        });
//        
//    }
}

#pragma mark - MKMapViewDelegate Methods
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    mapAnnotation *pin = (mapAnnotation*)view.annotation;
    
    int row = 0;
    for (id object in _tableData)
    {
        if ( [object isKindOfClass:[TransitViewObject class] ] )
        {
            if ( [((TransitViewObject*)object).VehicleID intValue] == [pin.id intValue] )
            {
//                NSLog(@"Found!");
                [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
                break;
            }
        }
        row++;
    }
    
//    NSLog(@"view selected: %@", pin.title );
}


- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
//    mapAnnotation *pin = (mapAnnotation*)view.annotation;
    [self.tableView deselectRowAtIndexPath: self.tableView.indexPathForSelectedRow animated:YES];
    
//    int row = 0;
//    for (id object in _tableData)
//    {
//        if ( [object isKindOfClass:[TransitViewObject class] ] )
//        {
//            if ( [((TransitViewObject*)object).VehicleID intValue] == [pin.id intValue] )
//            {
//                //                NSLog(@"Found!");
//                [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES];
//                break;
//            }
//        }
//        row++;
//    }
    
//    NSLog(@"view deselected: %@", pin.title );

}



-(MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
//    NSLog(@"TMVC -mapView viewForOverlay");
    return [kmlParser viewForOverlay: overlay];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    
    if ( [annotation isKindOfClass:[MKUserLocation class]] )
        return nil;

//    NSLog(@"TVVC - viewForAnnotations");
    
    static NSString *identifier = @"mapAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } else {
        annotationView.annotation = annotation;
    }
    
    [annotationView setEnabled: YES];
    [annotationView setCanShowCallout: YES];
    
    
    GTFSRouteType routeType = [self.travelMode intValue];
    UIImage *image;
    if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"EastBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"SouthBound"] ) )
    {
//        if ( [self.routeType intValue] == 0)
        if ( routeType == kGTFSRouteTypeTrolley )
            image = [UIImage imageNamed:@"transitView-Trolley-Blue.png"];
        else
            image = [UIImage imageNamed:@"transitView-Bus-Blue.png"];
    }
    else if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"WestBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"NorthBound"] ) )
    {
        if ( routeType == kGTFSRouteTypeTrolley )
            image = [UIImage imageNamed:@"transitView-Trolley-Red.png"];
        else
            image = [UIImage imageNamed:@"transitView-Bus-Red.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainSouth"] )
    {
        image = [UIImage imageNamed:@"trainView-RRL-Blue.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainNorth"] )
    {
        image = [UIImage imageNamed:@"trainView-RRL-Red.png"];
    }
    else
    {
        if ( routeType == kGTFSRouteTypeTrolley )
            image = [UIImage imageNamed:@"trolley_yellow.png"];
        else
            image = [UIImage imageNamed:@"bus_yellow.png"];
    }


    [annotationView setImage: image];
//    [annotationView setCenter:CGPointMake(image.size.width/2, image.size.height/2)];
//    [annotationView setCenterOffset:CGPointMake(image.size.width/2, image.size.height/2)];
//    NSLog(@"image size: %@", NSStringFromCGSize( image.size));
    
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
//    lastLocation.latitude = mapRegion.center.latitude;
//    lastLocation.longitude = mapRegion.center.longitude;
    
}



@end
