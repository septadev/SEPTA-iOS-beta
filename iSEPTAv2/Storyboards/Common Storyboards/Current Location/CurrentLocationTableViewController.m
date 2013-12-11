//
//  CurrentLocationTableViewController.m
//  iSEPTA
//
//  Created by septa on 7/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "CurrentLocationTableViewController.h"


@interface CurrentLocationTableViewController ()

@end

@implementation CurrentLocationTableViewController
{
    
    CLLocationManager *_locationManager;
    CLLocation *_currentLocation;
    
    CLLocation *_useCoordinates;
    
    BOOL _locationEnabled;
    BOOL _ranOnce;
    
    NSInteger _rowLimit;
    
    NSMutableArray *_tableData;
    
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_jsonOpTrain;
    NSBlockOperation *_jsonOpTransit;
    
}


@synthesize routeType;
@synthesize routeData;

@synthesize delegate;
@synthesize backImageName;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{

    // self.view.frame will display the actual width and height based on the orientation here.
    // viewDidLoad will only show the portriat width and height, regardless of orientation.
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"mainBackground.png"] ];
    [bgImageView setAlpha:0.20f];
    [self.tableView setBackgroundView: bgImageView];

    
    // Configure back button
    if ( backImageName != NULL )
    {
        CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:backImageName withTarget:self andWithAction:@selector(backButtonPressed:)];
        self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }
    
    
    NSString *title = @"Nearest Stops";
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: title];
    [self.navigationItem setTitleView:titleView];

    
    // Disable DONE button initially
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    
    if ( routeType == nil )
    {
        routeType = [NSNumber numberWithInt:kCurrentLocatinRouteTypeBoth];
    }
    
    // Register all NIBs right here!   Do it!  Do it naaaaaaa-ow!
    [self.tableView registerNib:[UINib nibWithNibName:@"CurrentLocationCell" bundle:nil] forCellReuseIdentifier:@"CurrentLocationCell"];
    
    
    
    // Initialize Gestures
    UITapGestureRecognizer *gestureDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureDoubleTap:)];
    UILongPressGestureRecognizer *gestureLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureLongPress:)];
    
    // Configure Gestures
    [gestureDoubleTap setNumberOfTapsRequired:2];
//    [gestureLongPress setDelaysTouchesBegan:YES];
//    [gestureLongPress setMinimumPressDuration:0.325f];  // Default is 0.5 seconds
    
    // Add Gestures
    [self.tableView addGestureRecognizer: gestureDoubleTap];
    [self.tableView addGestureRecognizer: gestureLongPress];

    
    // Add Pull to Refresh
//    __weak CurrentLocationTableViewController* weakSauce = self;
//    
//    [self.tableView addPullToRefreshWithActionHandler:^{
//        NSLog(@"CLTVC - block for addPullToRefreshWithAchtionHandler!");
//        
//        [weakSauce resetRanOnce];
//        [weakSauce increaseRowLimit];
//        [weakSauce findNearestLocation];
//
////        [weakSauce.tableView.pullToRefreshView stopAnimating];
////        [weakSauce performSelector:@selector(increaseRowLimit) withObject:nil afterDelay:0.25f];
//        
//    }];

    
    
    
    
    
    // Add back button back
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];

//    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    

//    [[self navigationItem] setBackBarButtonItem: [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)] ];
//    [[self navigationItem] setLeftBarButtonItem: [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)] ];
    
//    NSLog(@"navCont: %@", self.navigationController);
//    NSLog(@"navItem: %@", self.navigationItem);
//    NSLog(@"backBar: %@", self.navigationItem.backBarButtonItem);
    
    
    _jsonQueue  = [[NSOperationQueue alloc] init];
    _tableData = [[NSMutableArray alloc] init];
    
    _ranOnce = NO;
    _rowLimit = 0;
    
    
    if ( [CLLocationManager locationServicesEnabled] && self.coordinates == nil)
    {
        
        _locationEnabled = YES;
        
        _locationManager = [[CLLocationManager alloc] init];
        
        [_locationManager setDelegate:self];
        [_locationManager startUpdatingLocation];
        
    }
    else
    {
        _locationEnabled = NO;
        [self findNearestLocation];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}


-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_line.png"]];
    UITableViewCell *newCell = (UITableViewCell*)cell;
    
    [separator setFrame: CGRectOffset(separator.frame, 0, newCell.frame.size.height-separator.frame.size.height)];
    [newCell.contentView addSubview: separator];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return _rowLimit;
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellName = @"CurrentLocationCell";
    
    CurrentLocationCell *thisCell = [thisTableView dequeueReusableCellWithIdentifier: cellName];
    
    if ( thisCell == nil )
    {
        thisCell = [[CurrentLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    //BasicRouteObject *rObj = [_tableData objectAtIndex:indexPath.row];
    
    [thisCell addRouteInfo: [_tableData objectAtIndex:indexPath.row] ];
    
    
    return thisCell;
    

    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    BasicRouteObject *rObj;
    rObj = [_tableData objectAtIndex: indexPath.row];
    NSLog(@"CLTVC - BRO: %@", rObj);
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
//    [self btnDismissPressed:nil];
    
}

- (void)viewDidUnload
{
    
    [self setBtnDismiss:nil];
    [super viewDidUnload];
    
}

#pragma mark - Dismiss Button
- (IBAction)btnDismissPressed:(id)sender
{
 
//    NSLog(@"delegate: %@", delegate);
//    NSLog(@"presented : %@", self.presentedViewController);
//    NSLog(@"presenting: %@", self.presentingViewController);
    
    
    BasicRouteObject *rObj;
    if ([delegate respondsToSelector:@selector(currentLocationSelectionMade:)])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        rObj = [_tableData objectAtIndex: indexPath.row];
        
        [delegate currentLocationSelectionMade:rObj];
    }
    
    
    if ( [delegate isKindOfClass: [EnterAddressViewController class] ] )
    {
        // Do stuff
        NSArray *vcs = [self.navigationController viewControllers];
        
        UIViewController *previousVC = [vcs objectAtIndex: [vcs count] - 3 ];
//        UIViewController *currentVC  = [vcs objectAtIndex: [vcs count] - 1 ];
        
        [(StopNamesTableViewController*)previousVC currentLocationSelectionMade: rObj];
        
        NSLog(@"CLTVC:btnDismissPressed - popToViewController");
        [self.navigationController popToViewController: previousVC animated:NO];
//        [self.navigationController popToViewController: currentVC animated:NO];
        
    }
    
    
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"CLTVC - dismissed!");
    
}




#pragma mark - CLLocationManagerDelegate
-(void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
//    NSLog(@"did start monitoring");
    [self findNearestLocation];
}


-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    NSLog(@"did update locations:");
//    NSLog(@"%@", locations);
//    [manager stopUpdatingLocation];
    _currentLocation = [locations objectAtIndex:0];
    
    [self findNearestLocation];
    
}


#pragma mark - FMDatabase
-(void) findNearestLocation
{
 
    if ( _ranOnce )
        return;
    
    _ranOnce = YES;
    

    // Determine which set of coordinates to use
    if ( _locationEnabled && self.coordinates == nil )
    {
        _useCoordinates = _currentLocation;
    }
    else
    {
//        _useCoordinates.latitude  = [self.coordinates.latitude  doubleValue];
//        _useCoordinates.longitude = [self.coordinates.longitude doubleValue];
        
        _useCoordinates = [[CLLocation alloc] initWithLatitude: [self.coordinates.latitude  doubleValue]
                                                     longitude: [self.coordinates.longitude doubleValue] ];
        
    }
    
    
    if ( [routeType intValue] & kCurrentLocationRouteTypeRailOnly )
    {
        _jsonOpTrain   = [[NSBlockOperation alloc] init];
        __weak NSBlockOperation *weakOpTrain = _jsonOpTrain;
        [weakOpTrain addExecutionBlock:^{
            
            NSArray *trainArr = [self findNearestTrainStop];
            
            if ( ![weakOpTrain isCancelled] )
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_tableData addObjectsFromArray:trainArr];
                    [self sort];
                    [self.tableView reloadData];
                }];
            }
            else
            {
                NSLog(@"FNRVC - getLatestJSONData: _jsonOp cancelled");
            }
            
        }];
        
        [_jsonQueue addOperation: _jsonOpTrain];        
    }
    
    
    if ( [routeType intValue] & kCurrentLocationRouteTypeBusOnly )
    {
        
        _jsonOpTransit = [[NSBlockOperation alloc] init];

        __weak NSBlockOperation *weakOpTransit = _jsonOpTransit;
        [weakOpTransit addExecutionBlock:^{
            
            NSArray *transitArr = [self findNearestTransitStop];
//            if ( [transitArr count] > 5 )
//                _rowLimit = 5;

//            NSLog(@"CLTVC - findNearestLocation:transit, stopAnimating");
//            [self.tableView.pullToRefreshView stopAnimating];
            
            if ( ![weakOpTransit isCancelled] )
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_tableData addObjectsFromArray:transitArr];
                    [self sort];
                    [self.tableView reloadData];
                }];
            }
            else
            {
                NSLog(@"FNRVC - getLatestJSONData: _jsonOp cancelled");
            }
            
        }];
        
        [_jsonQueue addOperation: _jsonOpTransit];
        
    }
    

    
    
}


/*
 
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
 
 */


-(NSArray*) findNearestTrainStop
{
 
    NSString *queryStr;
    
    
    if ( routeData.route_id == nil)  // If no route id was giving, look at them all
    {
        queryStr = [NSString stringWithFormat:@"SELECT *, ABS(%10.7f - stop_lat) + ABS(%10.7f - stop_lon) as dist FROM stops_rail ORDER BY dist ASC", _useCoordinates.coordinate.latitude, _useCoordinates.coordinate.longitude];
    }
    else  // Since a route id was giving, use that to narrow down the results
    {
        queryStr = [NSString stringWithFormat:@"SELECT *, ABS(%10.7f - stop_lat) + ABS(%10.7f - stop_lon) as dist FROM stops_rail WHERE stop_id IN (SELECT stop_id FROM stopIDRouteLookup WHERE route_short_name=\"%@\")  ORDER BY dist ASC", _useCoordinates.coordinate.latitude, _useCoordinates.coordinate.longitude, routeData.route_id];
    }
    
    
//    NSString *queryStr = [NSString stringWithFormat:@"SELECT *, ABS(%10.7f - stop_lat) + ABS(%10.7f - stop_lon) as dist FROM stops_rail ORDER BY dist ASC LIMIT 10 OFFSET %d", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude, _rowLimit];

//    NSLog(@"query: %@", queryStr);
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return nil;
    }
    
//    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM stops_rail WHERE stop_id IN (SELECT stop_id FROM stopIDRouteLookup WHERE route_short_name=\"%@\") ORDER BY distance(stop_lat, stop_lon, %10.7f, %10.7f);", routeData.route_short_name, _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];

    
    sqlite3 *sqlitePtr = [database sqliteHandle];
    sqlite3_create_function(sqlitePtr, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Basic DB error checking
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNFRTC - query str: %@", queryStr);
        
        return nil;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
                               
    while ( [results next] )  // Only one row should have been returned
    {
        
        BasicRouteObject *rObj = [[BasicRouteObject alloc] init];
        
        // Give it the main information
        [rObj setStop_id:        [results stringForColumn:@"stop_id"] ];
        
        float lat = [[results stringForColumn:@"stop_lat"] floatValue];
        float lon = [[results stringForColumn:@"stop_lon"] floatValue];
        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        CLLocationDistance dist = [_useCoordinates distanceFromLocation:stopLocation] / 1609.34f;
        [rObj setDistance:      [NSString stringWithFormat:@"%3.2f", dist] ];
        

        [rObj setStop_name:     [results stringForColumn:@"stop_name"] ];
        [rObj setLocation_type: [NSString stringWithFormat:@"%d", kRouteTypeRail] ];
        
        

        // --==  Determine what stops are associated with
//        NSString *routeStr = [NSString stringWithFormat:@"SELECT CASE route_short_name WHEN \"LUCYGO\" THEN \"LGO\" WHEN \"LUCYGR\" THEN \"LGR\" ELSE route_short_name END as route_short_name, stop_id, route_type FROM stopIDRouteLookup WHERE stop_id=%@", rObj.stop_id ];
        
//        FMResultSet *routeResults = [database executeQuery: routeStr];
//        if ( [database hadError] )  // Check for errors
//        {
//            
//            int errorCode = [database lastErrorCode];
//            NSString *errorMsg = [database lastErrorMessage];
//            
//            NSLog(@"FNRVC - query failure, code: %d, %@", errorCode, errorMsg);
//            NSLog(@"FNRVC - query str: %@", queryStr);
//            
//            return nil;  // If an error occurred, there's nothing else to do but exit
//            
//        } // if ( [database hadError] )
        
//        while ( [routeResults next] )
//        {
//            //            temp = [temp stringByAppendingString: [NSString stringWithFormat:@"%@, ", [results stringForColumn:@"route_short_name"] ] ];
//            
//            RouteDetailsObject *dObj = [[RouteDetailsObject alloc] init];
//            [dObj setRoute_short_name: [routeResults stringForColumn:@"route_short_name"] ];
//            [dObj setRoute_type: [NSNumber numberWithInt: [routeResults intForColumn:@"route_type"] ] ];
//            
//            [rObj addRouteInfo: dObj ];
//            
//        }
        
        
        [tempArr addObject: rObj];
        
    }
    
    [database close];
    
    
    return tempArr;
    
}


#define DEG2RAD(degrees) (degrees * 0.01745327) // degrees * pi over 180

static void distanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv)
{
    // check that we have four arguments (lat1, lon1, lat2, lon2)
    assert(argc == 4);
    // check that all four arguments are non-null
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }
    // get the four argument values
    double lat1 = sqlite3_value_double(argv[0]);
    double lon1 = sqlite3_value_double(argv[1]);
    double lat2 = sqlite3_value_double(argv[2]);
    double lon2 = sqlite3_value_double(argv[3]);
    // convert lat1 and lat2 into radians now, to avoid doing it twice below
    double lat1rad = DEG2RAD(lat1);
    double lat2rad = DEG2RAD(lat2);
    // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
    // 6378.1 is the approximate radius of the earth in kilometres
    sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 6378.1);
}


-(NSArray*) findNearestTransitStop
{

//    NSString *queryStr = [NSString stringWithFormat:@"SELECT *, ABS(%10.7f - stop_lat) + ABS(%10.7f - stop_lon) as dist FROM stops_bus ORDER BY dist ASC LIMIT 10", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];

    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    if ( ![database open] )
    {
        [database close];
        return nil;
    }
    
    sqlite3 *sqlitePtr = [database sqliteHandle];
    sqlite3_create_function(sqlitePtr, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
    
//    NSString *queryStr = [NSString stringWithFormat:@"SELECT stop_id, stop_name, stop_lat, stop_lon FROM stops_bus NATURAL JOIN stop_times_bus NATURAL JOIN trips_bus WHERE route_id=11532 GROUP BY stop_id ORDER BY distance(stop_lat, stop_lon, %10.7f, %10.7f);", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];

    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM stops_bus WHERE stop_id IN (SELECT stop_id FROM stopIDRouteLookup WHERE route_short_name=\"%@\") ORDER BY distance(stop_lat, stop_lon, %10.7f, %10.7f);", routeData.route_short_name, _useCoordinates.coordinate.latitude, _useCoordinates.coordinate.longitude];

    
//    NSLog(@"queryStr: %@", queryStr);
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Basic DB error checking
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNFRTC - query str: %@", queryStr);
        
        return nil;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    
    while ( [results next] )  // Only one row should have been returned
    {
        
        BasicRouteObject *rObj = [[BasicRouteObject alloc] init];
        
        // Give it the main information
        [rObj setStop_id:        [results stringForColumn:@"stop_id"] ];
        
        float lat = [[results stringForColumn:@"stop_lat"] floatValue];
        float lon = [[results stringForColumn:@"stop_lon"] floatValue];
        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        CLLocationDistance dist = [_useCoordinates distanceFromLocation:stopLocation] / 1609.34f;
        [rObj setDistance:      [NSString stringWithFormat:@"%3.2f", dist] ];
        
        
        [rObj setStop_name:     [results stringForColumn:@"stop_name"] ];
        [rObj setLocation_type: [NSString stringWithFormat:@"%d", kRouteTypeRail] ];
        
        [tempArr addObject: rObj];
        
    }
    
    [database close];
    
    return tempArr;
    
}

-(NSString*) filePath
{
    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
}



-(void) goBack
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - CustomBackBarButtonProtocol
-(void) backButtonPressed:(id) sender
{
    NSLog(@"CLTVC:backButtonPressed - popViewControllerAnimated");
    [self.navigationController popViewControllerAnimated:YES];
}




-(void) sort
{
    
    // Sort tableData by distance
    [_tableData sortUsingComparator:^NSComparisonResult(BasicRouteObject *obj1, BasicRouteObject *obj2)
     {
         if ( [obj1.distance floatValue] > [obj2.distance floatValue] )
             return (NSComparisonResult)NSOrderedDescending;
         else
             return (NSComparisonResult)NSOrderedAscending;
     }];

    NSLog(@"CLTVC - findNearestLocation:trains, stopAnimating");
    [self.tableView.pullToRefreshView stopAnimating];
    
}


#pragma mark - SVPullDownToRefresh Helper Methods

-(void) increaseRowLimit
{
    _rowLimit += 10;
    //    if ( _rowLimit >= [_tableData count])
    //    {
    //        _rowLimit = [_tableData count];
    //        self.tableView.showsPullToRefresh = NO;
    //    }
    
    //    [self.tableView.pullToRefreshView stopAnimating];
    //    [self.tableView reloadData];
}

-(void) resetRanOnce
{
    // Setting this inside the PullDownToRefresh block was generating warnings about retaining a reference to self in order to set _ranOnce.
    _ranOnce = NO;
}



#pragma mark - Gesture Recognizers

//- (IBAction)doubleTapRecognized:(id)sender
//{
//    
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    if ( indexPath == nil )
//    {
//        NSLog(@"No index path selected");
//    }
//    else
//    {
//        NSLog(@"Index Path: %d/%d", indexPath.section, indexPath.row);
//    }
//    
//}
//
//
//- (IBAction)longPressRecognized:(UILongPressGestureRecognizer*) gesture
//{
//
////    if ( gesture.state == UIGestureRecognizerStateRecognized )
////    {
////        
////        CGPoint touchPoint = [gesture locationInView:self.view];
////        NSIndexPath *row = [self.tableView indexPathForRowAtPoint:touchPoint];
//////        [self performSelector:@selector(highlightTheDamnRow:) withObject:row afterDelay:0.001f];  // Adding a delay works
////
////        if ( row != nil )
////        {
////            NSLog(@"Index Path: %d/%d", row.section, row.row);
////        }
////        else
////        {
////            NSLog(@"No row was long pressed");
////        }
////        
////    }
//    
//    
//    return;
//    
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    if ( indexPath == nil )
//    {
//        NSLog(@"No index path selected");
//    }
//    else
//    {
//        NSLog(@"Index Path: %d/%d", indexPath.section, indexPath.row);
//    }
//    
//}


//-(void) highlightTheDamnRow:(NSIndexPath*) indexPath
//{
//    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
//
//}


-(void) gestureLongPress:(UILongPressGestureRecognizer*) gesture
{
    NSLog(@"Long press: %d", gesture.state);
    
    
    
    if ( gesture.state == UIGestureRecognizerStateBegan )
    {
        NSIndexPath *currentSelection = [self.tableView indexPathForSelectedRow];
        
        CGPoint touchPoint = [gesture locationInView:self.view];
        NSIndexPath *row = [self.tableView indexPathForRowAtPoint:touchPoint];

        if ( row != currentSelection )
        {
            [self.tableView deselectRowAtIndexPath:currentSelection animated:NO];
            [self.tableView selectRowAtIndexPath:row animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self btnDismissPressed:nil];
        }
        
    }  // if ( gesture.state == UIGestureRecognizerStateBegan
//    else if ( gesture.state == UIGestureRecognizerStateRecognized )
//    {
//        CGPoint touchPoint = [gesture locationInView:self.view];
//        NSIndexPath *row = [self.tableView indexPathForRowAtPoint:touchPoint];
//        
//        if ( row != NULL )
//        {
//
//        }
//        
//    }
    
}

-(void) gestureDoubleTap:(UITapGestureRecognizer*) gesture
{
    NSLog(@"Double Tap");
    [self btnDismissPressed:nil];    
}


@end
