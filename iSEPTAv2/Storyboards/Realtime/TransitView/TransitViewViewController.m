//
//  TransitViewViewController.m
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TransitViewViewController.h"

@interface TransitViewViewController ()

@end

@implementation TransitViewViewController
{
    NSMutableArray *_tableData;  // Array of RouteInfos
    
    NSMutableArray *_busSectionTitle;
    NSMutableArray *_busSectionIndex;
    
    NSMutableDictionary *_statusLookup;
    
    AFHTTPRequestOperation *_jsonSystemOp;
    
    NSInteger _currentServiceID;
    NSArray  *_currentServiceIDs;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_jsonSystemOp cancel];
    [SVProgressHUD dismiss];     // Dismisses any active loading HUD
    
}


-(void) viewWillAppear:(BOOL)animated
{
 
    [super viewWillAppear:animated];
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
    
    
//    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"transitView-white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
//    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    
    // --===
    // ==--  Declaration Section
    // --===
    
    _statusLookup = [[NSMutableDictionary alloc] init];
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"transitViewBack.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: @"TransitView"];
    [self.navigationItem setTitleView:titleView];
    
    
    // --==  Register Your Nibs!  ==--
//    [self.tableView registerNib: [UINib nibWithNibName:@"TransitRouteListCell" bundle:nil] forCellReuseIdentifier:@"TransitRouteListCell"];
    [self.tableView registerNib: [UINib nibWithNibName:@"TransitServiceCell"   bundle:nil] forCellReuseIdentifier:@"TransitServiceCell"  ];

    
//    UIImageView *bgImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"mainBackground.png"] ];
//    [self.tableView setBackgroundView: bgImageView];
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.tableView setBackgroundColor: backgroundColor];

    
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    _tableData = [[NSMutableArray alloc] init];
    
    [self getSystemStatus];
    
    [self getBusRouteInfo];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"TVTC - didReceiveMemoryWarning");
    
    // Dispose of any resources that can be recreated.
    _tableData = nil;
    _busSectionIndex = nil;
    _busSectionTitle = nil;
    
}


-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
//    NSLog(@"titleView frame: %@", NSStringFromCGRect(titleView.frame));

    
}



#pragma mark - UITableViewDataSource
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _busSectionTitle;
}

- (NSInteger)tableView:(UITableView *)thisTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[_busSectionIndex objectAtIndex:index] intValue] inSection:0];
    [thisTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    return -1;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_tableData count];
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor: [UIColor colorWithWhite:1.0f alpha:.8] ];
}


- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellServiceIdentifier = @"TransitServiceCell";
    TransitServiceCell *serviceCell = (TransitServiceCell*) [thisTableView dequeueReusableCellWithIdentifier: cellServiceIdentifier];
    
    ServiceHours *sHours = [_tableData objectAtIndex: indexPath.row];
    

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HHmm"];
    int now = [[dateFormatter stringFromDate: [NSDate date] ] intValue];

    
//    _currentServiceID = 64;  // For testing purposes, makes app think that it's Sunday
    
    
    RouteInfo *route = [_tableData objectAtIndex: indexPath.row];
    
    if ( [[(SystemStatusObject*)[_statusLookup objectForKey:route.route_short_name] issuspend] isEqualToString:@"Y"] )
    {
        [sHours changeServiceStatus: kTransitServiceSuspended];
        [serviceCell setServiceHours:sHours];
    }
    else
    {
//        [sHours statusForTime:now andServiceID: (int)_currentServiceID];
        [sHours statusForTime:now andServiceIDs:_currentServiceIDs];
        [serviceCell setServiceHours: sHours];
    }

    return serviceCell;
    
}


-(void) tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self loadTrainViewVCWithIndexPath: indexPath];
    
}


-(void) loadTrainViewVCWithIndexPath: (NSIndexPath*) indexPath
{
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TrainViewStoryboard" bundle:nil];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TrainSlidingStoryboard" bundle:nil];
    TrainSlidingViewController *tvVC = (TrainSlidingViewController*)[storyboard instantiateInitialViewController];
    
    RouteInfo *rInfo = [_tableData objectAtIndex: indexPath.row];
    [tvVC setRouteName: rInfo.route_short_name];
    [tvVC setTravelMode: rInfo.route_type ];
    
    [tvVC setBackImageName: @"transitViewBack.png"];
    
//    [tvVC setRouteName: rInfo.route_short_name];
//    [tvVC setRouteType: rInfo.route_type];
//    [tvVC setTravelMode:@"Bus"];
//    [tvVC setTitle: @"TransitView"];
    
    [self.navigationController pushViewController:tvVC animated:YES];
    
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

-(NSArray*) getServiceIDs
{
    
    //    NSLog(@"filePath: %@", [GTFSCommon filePath]);
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return nil;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
    NSInteger weekday = [comps weekday];  // Sunday is (1), Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
    
    int dayOfWeek;
    dayOfWeek = pow(2,(7-weekday) );
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT service_id, days FROM calendarDB WHERE (days & %d)", dayOfWeek];
    
    queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"ITVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"ITVC - query str: %@", queryStr);
        
        return nil;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    NSInteger service_id = 0;
    NSMutableArray *sids = [NSMutableArray array];
    
    while ( [results next] )
    {
        service_id = [results intForColumn:@"service_id"];
        [sids addObject:[NSString stringWithFormat:@"%ld",(long)service_id]];
    }
    
    return [sids copy];
    
//    NSInteger service_id = 0;
//    [results next];
//    
//    service_id = [results intForColumn:@"service_id"];
//    
//    return (NSInteger)service_id;
    
}

    
-(NSInteger) getServiceID
{
    
//    NSLog(@"filePath: %@", [GTFSCommon filePath]);
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return 0;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
    NSInteger weekday = [comps weekday];  // Sunday is (1), Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
    
    int dayOfWeek;
    dayOfWeek = pow(2,(7-weekday) );
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT service_id, days FROM calendarDB WHERE (days & %d)", dayOfWeek];
    
    queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"ITVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"ITVC - query str: %@", queryStr);
        
        return 0;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    NSInteger service_id = 0;
    [results next];
    
    service_id = [results intForColumn:@"service_id"];
    
    return (NSInteger)service_id;
    
}
    
    
    
//-(NSString*) filePath
//{
//    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
//}


-(void) getBusRouteInfo
{
    
    // Clear _tableData
    [_tableData removeAllObjects];
    
    
    // Open the database
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    NSString *queryStr; // = [NSString stringWithFormat: @"SELECT route_id,service_id, MIN(min) as min, MAX(max) as max FROM serviceHours WHERE (service_id & %d) GROUP BY route_id, service_id", currentServiceID];
    
    queryStr = @"SELECT s.route_id, r.route_type, s.service_id, MIN(min) as min, MAX(max) as max FROM serviceHours s JOIN routes_bus r ON r.route_short_name = s.route_short_name GROUP BY s.route_id, service_id ORDER BY s.route_id";
    NSLog(@"TVVC: getBusRouteInfo: %@", queryStr);
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"TVTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"TVTC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
    }
    
    
    /*
     
     Herein lies the problem:
       Route 1 is going to have 3 entries: Sat, Sun, Weekday.  And either entry is going to be stored in its own index in _tableData.  
       That's not good.
     
     */
    
    
    ServiceHours *sPtr;
    
    while ( [results next] )
    {
        
        ServiceHours *sHours;
        NSString *route_id  = [results stringForColumn:@"route_id"];
        
        if ( [sPtr.route_id isEqualToString:route_id] )
        {
             // Add to exiting object in array   
            sHours = sPtr;
        }
        else
        {
            // Create new entry in the array
            sHours = [[ServiceHours alloc] init];
            [_tableData addObject: sHours];  // Add this to the array immediately.  Data can be added afterward
            
            [sHours setRoute_id: route_id];
            
            int route_type      = [results intForColumn:@"route_type"];
            [sHours setRoute_type: [NSNumber numberWithInt: route_type] ];
        }
        
        
        int minTime    = [results intForColumn:@"min"];
        int maxTime    = [results intForColumn:@"max"];
        int service_id = [results intForColumn:@"service_id"];

        [sHours addMin: minTime andMax: maxTime withServiceID: service_id];
        [sHours setRoute_short_name: route_id];
        
        sPtr = sHours;
        
    }
    
    _currentServiceIDs  = [self getServiceIDs];
    _currentServiceID   = [self getServiceID];
    
    
    // _currenteServiceID is used in tableView cellRowPath
    
    
   [self generateIndex];
    
    return;
    
}


//NSComparisonResult (^sortBusNames)(id,id) = ^(id a, id b)
//{
//    //  This sort here is good, and Imma gonna let you finish, but I just wanted to say that it won't properly handle numbers
//    //    return [[a start_stop_name] compare: [b start_stop_name]];
//
//    // NSComparisonResult...  -1 is Ascending, 0 is Ordered same and 1 is Descending
//
//    // a and b are PushObjects
//
//    int aInt = [[a route_short_name] intValue];  // Returns 0 if the a does not begin with a valid number
//    int bInt = [[b route_short_name] intValue];  // Returns 0 if the b does not being with a valid numbe
//
//    //    NSLog(@"a: %@, b: %@", a, b);
//
//    if ( aInt && bInt )             // As long as both aInt and bInt aren't 0, they're integers and we want to do a simple numeric comparsion
//        return (NSComparisonResult)(aInt > bInt);         // Straight up, dead simple numeric comparsion here
//    else if ( aInt && !bInt )       // If aInt is an integer and b isn't make sure that a comes first;  steadyfast rule: Integers Before Strings
//        return (NSComparisonResult)-1;                  // This means, a in relationship to b should be above b, or they need to be layed out in ascending order (-1)
//    else if ( bInt && !aInt )       // But if bInt is the integer and a isn't, make sure that b comes first
//        return (NSComparisonResult)1;                   // This means, a in relationship to b should be below b, or they need to be layed out in descending order (1)
//    else
//        return [[a route_short_name] compare: [b route_short_name] ];  // If we got to this point, both a and b are strings and we just want a simple string comparison
//
//
//};

-(void) generateIndex
{
    
    _busSectionIndex  = [[NSMutableArray alloc] init];
    _busSectionTitle  = [[NSMutableArray alloc] init];
    
    NSString *lastChar = @"";
    NSString *newChar;
    NSInteger index = 0;
    NSInteger len = 1;
    
    //    NSLog(@"PNVC - sequence length: %d", [[masterList objectAtIndex:0] count]);
    
    // Uncomment these two blocks of code to reduce the index size by half once the stop sequences exceed a certain length.  Avoids the solid circle between inserted inbetween letters
    //    BOOL everyOther = NO;
    //    if ( [_times count] > 26 )
    //    {
    //        everyOther = YES;
    //    }
    
    for (RouteInfo *route in _tableData)
    {
        
        NSString *short_name = [route route_short_name];
        
        len = 1;
        while ( ( [[short_name substringToIndex:len] intValue] ) && ( len < [short_name length] ) )
        {
            
            int newNum = [[short_name substringToIndex:len] intValue];
            
            if ( newNum == [[short_name substringToIndex:len+1] intValue] )
            {
                //newChar = [data.start_stop_name substringToIndex:len];
                break;
            }
            len++;
            
        }
        
        newChar = [short_name substringToIndex:len];
        
        
        if ( ![newChar isEqualToString:lastChar] )
        {
            [_busSectionTitle addObject: newChar];
            [_busSectionIndex addObject: [NSNumber numberWithLong:index] ];
            
            //            NSLog(@"PNVC - title: %@, index: %d", newChar, index);
            
            lastChar = newChar;
        }
        index++;
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
//    if ( [[segue identifier] isEqualToString:@"BusViewSegue"] )
//    {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        RouteInfo *route = [_tableData objectAtIndex: indexPath.row];
//        
//        TrainViewViewController *tvvc = [segue destinationViewController];
//        //        [tvvc setViewType: [NSString stringWithFormat:@"Bus:%@", route.route_short_name] ];
//        [tvvc setTravelMode: @"Bus"];
//        
//        //        NSLog( @"%@", [self stringForRouteType:[ [route route_type] integerValue] ] );
//        
//        [tvvc setTitle: [NSString stringWithFormat:@"%@ %@",[self stringForRouteType:[ [route route_type] integerValue] ], route.route_short_name] ];
//        
//        //        if ( [route.route_short_name isEqualToString:@"LUCYGO"] || [route.route_short_name isEqualToString:@"LUCYGR"] )
//        //        {
//        //            [route setRoute_short_name:@"LUCY"];
//        //        }
//        
//        [tvvc setRouteName: route.route_short_name];
//        [tvvc setRouteType: route.route_type];
//    }
    
}


-(NSString*) stringForRouteType: (NSInteger) routeType
{
    
    switch (routeType) {
        case 0:
            return @"Trolley";
            break;
        case 1:
            return @"Subway";
            break;
        case 2:
            return @"Rail";
            break;
        case 3:
            return @"Bus";
            break;
        case 4:
            return @"Ferry";
            break;
        case 5:
            return @"Cable Car";
            break;
        case 6:
            return @"Gondola";
            break;
        case 7:
            return @"Funicular";
            break;
        default:
            return nil;
            break;
    }
    
}




-(void) getSystemStatus
{
    
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
        return;  // Don't bother continuing if no internet connection is available
    
    
    NSString* stringURL = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/Alerts/"];
    
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"TVVC - getSystemStatus -- api url: %@", webStringURL);
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    // Old code, use AFNetworking instead
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
    //
    //        NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
    //        [self performSelectorOnMainThread:@selector(processSystemStatusJSONData:) withObject: realTimeTrainInfo waitUntilDone:YES];
    //
    //    });
    
    NSURLRequest *systemRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: stringURL] ];
    
    _jsonSystemOp = [[AFHTTPRequestOperation alloc] initWithRequest:systemRequest];
    [_jsonSystemOp setResponseSerializer: [AFJSONResponseSerializer serializer] ];
    
    __weak typeof(self) weakSelf = self;
    [_jsonSystemOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary *jsonDict = (NSDictionary*) responseObject;
         [weakSelf processSystemStatusJSONData:jsonDict];
         [weakSelf.tableView reloadData];  // Reload the table data when completed
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"TVVC - System Status Failure Because %@", [error userInfo] );
     }
     ];
    
    [_jsonSystemOp start];
    
}


-(void) processSystemStatusJSONData:(NSDictionary*) json
{
    
    [SVProgressHUD dismiss];
    //    _stillWaitingOnWebRequest = NO;
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    
    //    if ( returnedData == nil )  // Trying to serialize a nil object will generate an error
    //        return;
    //
    //    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( json == nil || [json count] == 0 )
    {
        return;
    }
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    [_statusLookup removeAllObjects];
    for (NSDictionary *data in json)
    {
        SystemStatusObject *ssObject = [[SystemStatusObject alloc] init];
        
        NSString *routeName = [data objectForKey:@"route_name"];
        
        if ( [routeName isEqualToString:@"CCT"] )  // || [routeName isEqualToString:@"Generic"]
            continue;
        else if ( [routeName isEqualToString:@"Generic"] )
        {
            
//            [ssObject setRoute_id:  [data objectForKey:@"route_id"] ];
//            [ssObject setRoute_name:@"General"];
//            
//            [ssObject setMode:      @"Generic"];
//            
//            [ssObject setIsadvisory:[data objectForKey:@"isadvisory"] ];
//            [ssObject setIsalert:   [data objectForKey:@"isalert"   ] ];
//            [ssObject setIssuspend: [data objectForKey:@"issuppend" ] ];
//            [ssObject setIsdetour:  [data objectForKey:@"isdetour"  ] ];
//            
//            [ssObject setLast_updated:[data objectForKey:@"last_updated"] ];
//            
//            [_additionalStatus setObject:ssObject forKey:@"Generic"];
            continue;
            
        }
        else if ( [routeName isEqualToString:@"Market/ Frankford Line"] )
            routeName = @"MFL";
        else if ( [routeName isEqualToString:@"Market Frankford Owl"] )
            routeName = @"MFO";
        else if ( [routeName isEqualToString:@"Broad Street Line"] )
            routeName = @"BSL";
        else if ( [routeName isEqualToString:@"Broad Street Line Owl"] )
            routeName = @"BSO";
        else if ( [routeName isEqualToString:@"Norristown High Speed Line"] )
            routeName = @"NHSL";
        else if ( [routeName isEqualToString:@"LUCY"] )
        {
            // Lucy only has one entry in Alerts, but it's two different routes.  Here's a quick and dirty way to ensure
            //   both are added to the lookup table (_statusLookup)
            routeName = @"LUCYGO";
            [ssObject setRoute_name:routeName];
            [ssObject setIssuspend: [data objectForKey:@"issuppend"] ];
            [_statusLookup setObject: ssObject forKey:routeName];
            
            routeName = @"LUCYGR";
        }
        
//        [ssObject setRoute_id:  [data objectForKey:@"route_id"] ];
        [ssObject setRoute_name:routeName];
        
//        [ssObject setMode:      [data objectForKey:@"mode"] ];
        
//        [ssObject setIsadvisory:[data objectForKey:@"isadvisory"] ];
//        [ssObject setIsalert:   [data objectForKey:@"isalert"] ];
        [ssObject setIssuspend: [data objectForKey:@"issuppend"] ];
//        [ssObject setIsdetour:  [data objectForKey:@"isdetour"] ];
        
//        [ssObject setLast_updated:[data objectForKey:@"last_updated"] ];
        
        [_statusLookup setObject: ssObject forKey:routeName];
        
    }
    
    
}



- (void)viewDidUnload
{
    
    [self setLblRouteName:nil];
    [self setLblTitleServiceHours:nil];
    [self setLblServiceHours:nil];
    
    [super viewDidUnload];
    
}


#pragma mark - Buttons Pressed
-(void) backButtonPressed:(id) sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


@end
