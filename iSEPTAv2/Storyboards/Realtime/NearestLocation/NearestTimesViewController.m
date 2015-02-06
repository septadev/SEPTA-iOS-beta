//
//  NearestTimesViewController.m
//  iSEPTA
//
//  Created by septa on 9/9/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NearestTimesViewController.h"

@interface NearestTimesViewController ()

@end

@implementation NearestTimesViewController
{
//    NSMutableArray *_tableData;
    
    TableViewStore *_dataStore;
    NSMutableDictionary *_alertsByRoute;
    
    AFHTTPRequestOperation *_jsonOperation;
    
    GetAlertDataAPI *_alertsAPI;
    NSDictionary *_alertNameLookUp;
    NSMutableDictionary *_routeLookup;
    
    int _numResults;
    NSMutableArray *_operationArr;
    BOOL _cancelAllOperations;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // --==  Register all the Xibs!  ===--
    [self.tableView registerNib:[UINib nibWithNibName:@"NearestTimeCell" bundle:nil] forCellReuseIdentifier:@"NearestTimeCell"];

//    _tableData = [[NSMutableArray alloc] init];
    _dataStore = [[TableViewStore alloc] init];
    _alertsByRoute = [[NSMutableDictionary alloc] init];
    _routeLookup = [[NSMutableDictionary alloc] init];
    _numResults = 5;
    
    
    // --==  Background  ==--
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ];
//    [backgroundImage setContentMode: UIViewContentModeScaleAspectFill];
//    backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    [self.view addSubview:backgroundImage];
//    [self.view sendSubviewToBack:backgroundImage];
    // --==  Background  ==--
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.tableView setBackgroundColor: backgroundColor];
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"Find_loc-white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    
    
//    NSArray *attArr = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"Attributions" ofType:@"plist"] ];
    _alertNameLookUp = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"RouteToAlertAPILookUp" ofType:@"plist"] ];
    

    
    _alertsAPI = [[GetAlertDataAPI alloc] init];
    [_alertsAPI setDelegate:self];
    
//    [alerts addRoute:@"17"];
//    [alerts addRoute:@"23"];
    
//    [alerts fetchAlert];
    
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: @"Find Locations"];
    [self.navigationItem setTitleView:titleView];

    
    [SVProgressHUD showWithStatus:@"Loading..."];  // This counters the [SVProgressHUD dismiss] from the previous VC

    
    [self loadJSONParallel];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setLblRoute:nil];
    [self setLblAlerts:nil];
    [self setLblTime:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}


-(void)viewDidDisappear:(BOOL)animated
{
    
    NSLog(@"NTVC - viewDidDisappear");
    [super viewDidDisappear:animated];
    
    [SVProgressHUD dismiss];
    
}


#pragma mark - UITableViewDataSource
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BusScheduleData *data = [_dataStore objectForIndexPath: indexPath];
    NSMutableArray *alertArr = [_alertsByRoute objectForKey: data.Route];
    
    NearestTimeCell *thisCell = (NearestTimeCell*)[self.tableView cellForRowAtIndexPath: indexPath];
    
    if ( [thisCell isAlert] )
    {
    
        NSString *storyboardName = @"SystemStatusStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        SystemAlertsViewController *saVC = (SystemAlertsViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SystemAlertsStoryboard"];

        [saVC setAlertArr: alertArr];
        [saVC setBackImageName:@"Find_loc-white.png"];
        
        [self.navigationController pushViewController:saVC animated:YES];
        
    }

}


-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataStore numOfSections];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return [_tableData count] + 2;  // Plus 2 for the Start and End cell
    //    NSLog(@"FNRVC -  # of rows :%d in section: %d", [_tData numberOfRowsInSection:section], section);
    //    return [_tData numberOfRowsInSection:section];
//    return [_tableData count];
//    NSLog(@"NTVC t:nORIS - numberOfRowsInSection: %d", [_dataStore numOfRowsForSection: section] );
    return [_dataStore numOfRowsForSection: section];
}

- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellName = @"NearestTimeCell";
    
    NearestTimeCell *thisCell = [thisTableView dequeueReusableCellWithIdentifier: cellName];

    BusScheduleData *data = [_dataStore objectForIndexPath: indexPath];
    [thisCell setSchedule: data];
    
    // Use data.Route to check if any alerts: a) have been loaded, b) are available
    // [thisCell setAlerts: alert];
//    NSLog(@"NTVC: t:cFRIP - route: %@", data.Route);
    [thisCell setAlerts: [_alertsByRoute objectForKey: data.Route] ];
    
    if ( [thisCell isAlert] )
        [thisCell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    else
        [thisCell setAccessoryType: UITableViewCellAccessoryNone];
    
    return thisCell;
    

//    BusScheduleData *data = [_tableData objectAtIndex: indexPath.row];s
//    FindSchedulesCell *thisCell = [thisTableView dequeueReusableCellWithIdentifier:cellName];
//    
//    if ( thisCell == nil )
//    {
//        thisCell = [[FindSchedulesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
//    }
//    
//    BusScheduleData *data = [_tableData objectAtIndex:indexPath.row];
//    [thisCell.lblRouteName setText: data.Route];
//    [thisCell.lblArrivalTime setText: data.date];
//    [thisCell.lblMinutesRemaining setText:@""];
//    
//    return thisCell;
    
}


-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//    return [NSString stringWithFormat:@"%d", section];
//    NSLog(@"NTVC t:tFHIS - title for section %d: %@", section, [_dataStore titleForSection: section]);
    return [_dataStore titleForSection: section];
}


#pragma mark - Asynchronous Requests
-(void) loadJSONParallel
{
    //    NSString *url = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/BusSchedules/?req1=%@&req6=%d", basicRoute.stop_id, NUMBER_OF_RESULTS ];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: url]];
        
    
    // One request per route
    
    NSMutableArray *routes = self.routeData.routeData;
//    [_tableData removeAllObjects];
    [_dataStore removeAllObjects];
    
    
    for (RouteDetailsObject *rdObj in routes)
    {
        
        // --==========================--
        // --==  Get Schedule Times  ==--
        // --==========================--
        
        NSMutableArray *urlArray = [[NSMutableArray alloc] init];
        if ( [rdObj.directionDict count] > 1 )
        {
            // Need two requests
            
            
            for (NSString *key in rdObj.directionDict)
            {
                NSString *req3;
                if ( [key isEqualToString:@"0"] )
                    req3 = @"o";
                else
                    req3 = @"i";
                
                [_routeLookup setObject:[NSString stringWithFormat:@"%@%@",rdObj.route_short_name, [rdObj.directionDict objectForKey:key] ] forKey: [NSString stringWithFormat:@"%@%@",rdObj.route_short_name, key] ];
                
                NSString *url = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/BusSchedules/?req1=%@&req2=%@&req3=%@&req6=%d", self.routeData.stop_id, rdObj.route_short_name, req3, _numResults];

                [urlArray addObject: url];
                
            }
            
        }
        else
        {
            // Only one request is needed
            
            NSString *key = [[[rdObj directionDict] allKeys] objectAtIndex:0];
            
            [_routeLookup setObject:[NSString stringWithFormat:@"%@%@",rdObj.route_short_name, [rdObj.directionDict objectForKey:key] ] forKey: [NSString stringWithFormat:@"%@%@",rdObj.route_short_name, key] ];
            
            NSString *url = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/BusSchedules/?req1=%@&req2=%@&req6=%d", self.routeData.stop_id, rdObj.route_short_name, _numResults];
            [urlArray addObject: url];
        }
        
        
//        NSString *url;
        for (NSString *url in urlArray)
        {
        
            //NSString *url = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/BusSchedules/?req1=%@&req6=%d", basicRoute.stop_id, _numResults ];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] ];
            
            NSLog(@"NTVC:lJP - |%@|", url);
            [SVProgressHUD showWithStatus: @"Loading..."];
            
            
            _jsonOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [_jsonOperation setResponseSerializer: [AFJSONResponseSerializer serializer] ];
            
            __weak typeof(self) weakSelf = self;
            [_jsonOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 NSLog(@"url: %@", url);
                 NSDictionary *jsonDict = (NSDictionary *) responseObject;
                 
                 [weakSelf loadIndividualScheduleData: jsonDict forRouteType: rdObj.route_type ];
                 [SVProgressHUD popActivity];
                 
             }failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 NSLog(@"NTVC - loadJSONParallel: System Status Failure Because %@", [error userInfo] );
             }
             ];
            
            [_jsonOperation start];
            [_operationArr addObject:_jsonOperation];
            
        }

        
        
        // The API is fucked and needs some TLC before we can use this feature.  Here's the problem: for stops that handling both incoming and outgoing
        //   vehicles (start/end of the line, rail stops, etc.) the JSON produced by the API is in-fucking-valid.  Invalid JSON gets crapped on by the parse,
        //   no data is available and everyone is unhappy!
        
        // Until the API starts returning valid JSON output for all routes, we can't reliably offer this feature.
        
        NSString *routeName;
        if ( [rdObj.route_type intValue] == 0 )
        {
            
            if ([rdObj.route_short_name isEqualToString:@"NHSL"])
            {
                routeName = [NSString stringWithFormat:@"rr_route_nhsl"];
            }
            else
            {
                routeName = [NSString stringWithFormat:@"trolley_route_%@",rdObj.route_short_name];
            }
        }
        else
        {
            routeName = rdObj.route_short_name;
        }
        
        [_alertsAPI addRoute: routeName];
        
        // For every route in each rdObj, make a call to both BusSchedules and Alerts
        
    }
    
    [_alertsAPI fetchAlert];
    
}

-(void) loadIndividualAlertData: (NSDictionary*) jsonDict
{
    
    
}


//-(NSString*) filePath
//{
//    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
//}


-(void) loadIndividualScheduleData: (NSDictionary*) jsonDict forRouteType:(NSNumber*) routeType
{
    
    // Setup NSDateFormatter once
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yy hh:mm a"];  // DateCalender format: 06/27/13 12:52 pm
    
    
    //    [_tableData removeAllObjects];
//    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    
//    [((NSMutableDictionary*)[[jsonDict allValues] objectAtIndex:0]) objectForKey:@"Direction"];
    
    
    NSString *route = [[jsonDict allKeys] objectAtIndex:0];
    
    NSMutableDictionary *dict = [[[jsonDict allValues] objectAtIndex:0] objectAtIndex:0];
    NSString *dir = [dict objectForKey:@"Direction"];
    
    NSString *header;
    
    if ( [_routeLookup objectForKey:[NSString stringWithFormat:@"%@%@", route, dir] ] != nil )
    {
        
        // Query bus_stop_directions for the destination of the bus
        
        NSString *destination;
        
        FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];

        if ( ![database open] )
        {
            [database close];
            return;
        }
        
        FMResultSet *results;
        
        NSString *queryStr = [NSString stringWithFormat:@"SELECT DirectionDescription FROM bus_stop_directions WHERE Route=\"%@\" AND dircode=%@",route, dir];
        results = [database executeQuery: queryStr];
        if ( [database hadError] )  // Check for errors
        {
            
            int errorCode = [database lastErrorCode];
            NSString *errorMsg = [database lastErrorMessage];
            
            NSLog(@"NLVC - query failure, code: %d, %@", errorCode, errorMsg);
            NSLog(@"NLVC - query str: %@", queryStr);
            
//            return;  // If an error occurred, just continue
            
        } // if ( [database hadError] )
        else
        {

            while ( [results next] )
            {
                destination = [results stringForColumnIndex:0];
            }

            
        }
        
        header = [NSString stringWithFormat:@"%@ - %@", [_routeLookup objectForKey: [NSString stringWithFormat:@"%@%@", route, dir] ], destination];

        
    }
    
    
    for (NSString *topKey in jsonDict)
    {
        
        NSLog(@"NTVC:lISD - new section title: %@", topKey);
        [_dataStore addSectionWithTitle: header];
        
        for (NSDictionary *subDict in [jsonDict objectForKey:topKey])
        {
            
            //            if ( [_jsonOperation isCancelled] )
            //                return;
            
            if ( _cancelAllOperations )
                return;
            
            BusScheduleData *data = [[BusScheduleData alloc] init];
            [data setValuesForKeysWithDictionary: subDict];
            
            [data setRouteType:routeType];
            [data setDateTime:[dateFormat dateFromString:data.DateCalender] ];
            
            NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
            [myFormatter setDateFormat:@"eee"]; // day, like "Saturday"
//            [myFormatter setDateFormat:@"c"]; // day number, like 7 for saturday
            
            NSString *dayOfWeek = [myFormatter stringFromDate: data.dateTime];
            [data setDayOfWeek: dayOfWeek];
            

            
//            [_tableData addObject:data];
            [_dataStore addObject: data forTitle: header];
            
            //            NSLog(@"%@", data);
        }
        
    }
    
//    [_tableData sortUsingComparator:^NSComparisonResult(BusScheduleData *a, BusScheduleData *b)
//     {
//         return [[a Route] compare:[b Route] ];  // Was dateTime
//     }];
    

    [_dataStore sortBySectionTitles];

    [self.tableView reloadData];
    
}


#pragma mark - GetAlertsAPIProtocol
-(void) alertFetched:(NSMutableArray *)alert
{
    
    if ( [alert count] == 0 )
        return;
    
    SystemAlertObject *saObject = (SystemAlertObject*)[alert objectAtIndex:0];
    NSString *key;
    
    NSMutableDictionary *routeIdLookup = [[NSMutableDictionary alloc] init];
    [routeIdLookup setObject:@"MFO" forKey:@"rr_route_mfo"];
    [routeIdLookup setObject:@"MFL" forKey:@"rr_route_mfl"];
    [routeIdLookup setObject:@"BSL" forKey:@"rr_route_bsl"];
    [routeIdLookup setObject:@"BSO" forKey:@"rr_route_bso"];
    
//    NSLog(@"NTVC - alert for route: %@ \n alert: %@", ((SystemAlertObject*)[alert objectAtIndex:0]).route_name, alert);
    
    // Add alerts to dictionary/array
    
    // The fun never stops here!  MFO route_name isn't MFO, it's Market Frankford Owl!  How random and horrible!  Need to add hooks for this.
    key = [routeIdLookup objectForKey: saObject.route_id];
    
    if ( key == nil )
        key = saObject.route_name;
    
    [_alertsByRoute setObject:alert forKey: key];
    
}


#pragma mark - CustomBackBarButtonProtocol
-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
