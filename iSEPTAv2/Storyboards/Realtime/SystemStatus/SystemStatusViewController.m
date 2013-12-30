//
//  SystemStatusViewController.m
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "SystemStatusViewController.h"

@interface SystemStatusViewController ()

@end

@implementation SystemStatusViewController
{
    
    SystemStatusObject *_elevatorStatus;
    
    NSMutableDictionary *_additionalStatus;
    
    NSMutableArray *_masterData;
    TableViewStore *_tableData;
    
    NSMutableArray *_alertData;
    NSMutableArray *_filteredData;
    
    NSString *_filterMode;
    
    BOOL _showAllRoutes;

    SystemStatusFilterType _filterType;
    
    NSMutableArray *_busSectionIndex;
    NSMutableArray *_busSectionTitle;
    
    TabbedButton *_tBtnTransit;
    
}

@synthesize tableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void) viewWillAppear:(BOOL)animated
{
    
    [_tBtnTransit changeFrameWidth: self.view.frame.size.width];
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    _tableData = [[TableViewStore alloc] init];
    _additionalStatus = [[NSMutableDictionary alloc] init];
    
    // --==  Register Your Nibs!  ==--
    [self.tableView registerNib: [UINib nibWithNibName:@"SystemStatusCell" bundle:nil] forCellReuseIdentifier:@"SystemStatusCell"];
    
//    [self.view setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"mainBackground.png"] ] ];

    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ];
    [backgroundImage setContentMode: UIViewContentModeScaleAspectFill];
    backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    
    _masterData = [[NSMutableArray alloc] init];
    
    _filterType = kSystemStatusFilterByBusTrolley;
    
    _busSectionIndex  = [[NSMutableArray alloc] init];
    _busSectionTitle  = [[NSMutableArray alloc] init];
    

    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"system_status-white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle:@"System Status"];
    [self.navigationItem setTitleView:titleView];


    CustomFlatBarButton *rightButton = [[CustomFlatBarButton alloc] initWithImageNamed:@"Filter.png" withTarget:self andWithAction:@selector(filterButtonPressed:) ];
    [rightButton addImage: [UIImage imageNamed:@"Filter_close.png"] forState:UIControlStateSelected];
    [self.navigationItem setRightBarButtonItem: rightButton];

    /*
     
     How I'd like to create the tabbed buttons
     
     */
    
    
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"SystemStatus:ShowAllRoutes"];
    
    if ( object == nil )
    {
        _showAllRoutes = YES;  // If it's nil, then the value hasn't been set and we'll use the initial condition
        [rightButton.button setSelected:NO];
    }
    else
    {
        _showAllRoutes = [object boolValue];
        [rightButton.button setSelected:!_showAllRoutes];
    }
            
    
    // This is arguably the ugliest code that I have ever written
    // TODO: Fix this.  Now.  Now!  NOW!!
    // First set of buttons
    UIButton *buttonBus = [[UIButton alloc] init];
    UIButton *buttonTrolley = [[UIButton alloc] init];
    UIButton *buttonRail    = [[UIButton alloc] init];
    
    UIButton *buttonMFL     = [[UIButton alloc] init];
    UIButton *buttonBSL     = [[UIButton alloc] init];
    UIButton *buttonNHSL    = [[UIButton alloc] init];
    
    
    // --==  Bus  ==--
    [buttonBus setImage:[UIImage imageNamed:@"Bus_white.png"] forState:UIControlStateNormal];
    [buttonBus setImage:[UIImage imageNamed:@"Bus_black.png"] forState:UIControlStateHighlighted];
    [buttonBus setImage:[UIImage imageNamed:@"Bus_black.png"] forState:UIControlStateSelected];
    
    [buttonBus setBackgroundColor: [UIColor colorForRouteType: kSEPTATypeBus] ];

    
    // --==  Trolley  ==--
    [buttonTrolley setImage:[UIImage imageNamed:@"Trolley_white.png"] forState:UIControlStateNormal];
    [buttonTrolley setImage:[UIImage imageNamed:@"Trolley_green.png"] forState:UIControlStateHighlighted];
    [buttonTrolley setImage:[UIImage imageNamed:@"Trolley_green.png"] forState:UIControlStateSelected];

    [buttonTrolley setBackgroundColor: [UIColor colorForRouteType: kSEPTATypeTrolley] ];
    
    
    // --==  Rail  ==--
    [buttonRail setImage:[UIImage imageNamed:@"RRL_white.png"] forState:UIControlStateNormal];
    [buttonRail setImage:[UIImage imageNamed:@"RRL.png"] forState:UIControlStateHighlighted];
    [buttonRail setImage:[UIImage imageNamed:@"RRL.png"] forState:UIControlStateSelected];
    
    [buttonRail setBackgroundColor: [UIColor colorForRouteType: kSEPTATypeRail] ];
    
    
    // --==  MFL  ==--
    [buttonMFL setImage:[UIImage imageNamed:@"MFL_white.png"] forState:UIControlStateNormal];
    [buttonMFL setImage:[UIImage imageNamed:@"MFL_Blue.png"] forState:UIControlStateHighlighted];
    [buttonMFL setImage:[UIImage imageNamed:@"MFL_Blue.png"] forState:UIControlStateSelected];
    
    [buttonMFL setBackgroundColor: [UIColor colorForRouteType: kSEPTATypeMFL] ];
    
    
    // --==  BSL  ==--
    [buttonBSL setImage:[UIImage imageNamed:@"BSL_white.png"] forState:UIControlStateNormal];
    [buttonBSL setImage:[UIImage imageNamed:@"BSL_Orange.png"] forState:UIControlStateHighlighted];
    [buttonBSL setImage:[UIImage imageNamed:@"BSL_Orange.png"] forState:UIControlStateSelected];
    
    [buttonBSL setBackgroundColor: [UIColor colorForRouteType: kSEPTATypeBSL] ];

    
    // --==  NHSL  ==--
    [buttonNHSL setImage:[UIImage imageNamed:@"NHSL_white.png"] forState:UIControlStateNormal];
    [buttonNHSL setImage:[UIImage imageNamed:@"NHSL_Purple.png"] forState:UIControlStateHighlighted];
    [buttonNHSL setImage:[UIImage imageNamed:@"NHSL_Purple.png"] forState:UIControlStateSelected];
    
    [buttonNHSL setBackgroundColor: [UIColor colorForRouteType: kSEPTATypeNHSL] ];
    
    
    _tBtnTransit = [[TabbedButton alloc] initWithFrame:CGRectMake(0, 3, self.view.frame.size.width, 36)];
    [_tBtnTransit setOffset: CGPointMake(0, -4)];
    [_tBtnTransit setDelegate:self];
    [_tBtnTransit setNumberOfTabs:3];
    CGFloat scaling[] = {0.3, 0.3, 0.4};  // Needs to add up to 1.0
    [_tBtnTransit setTabsScale:scaling ofSize:3];
    
    [_tBtnTransit setButtons: [NSArray arrayWithObjects:
                               [NSArray arrayWithObjects:buttonBus, buttonTrolley, nil],
                               [NSArray arrayWithObjects:buttonRail, nil],
                               [NSArray arrayWithObjects:buttonMFL, buttonBSL, buttonNHSL, nil],
                               nil]];
    
    
//    [_tBtnTransit setBackgroundColor:[UIColor darkGrayColor] forTab:0 forState:UIControlStateNormal];
    [_tBtnTransit setBackgroundColor:[UIColor whiteColor]    forTab:0 forState:UIControlStateSelected];
    [_tBtnTransit setBackgroundColor:[UIColor whiteColor]    forTab:0 forState:UIControlStateHighlighted];

//    [_tBtnTransit setBackgroundColor:[UIColor blueColor]  forTab:1 forState:UIControlStateNormal];
    [_tBtnTransit setBackgroundColor:[UIColor whiteColor] forTab:1 forState:UIControlStateSelected];
    [_tBtnTransit setBackgroundColor:[UIColor whiteColor] forTab:1 forState:UIControlStateHighlighted];
    
//    [_tBtnTransit setBackgroundColor:[UIColor orangeColor]  forTab:2 forState:UIControlStateNormal];
    [_tBtnTransit setBackgroundColor:[UIColor whiteColor] forTab:2 forState:UIControlStateSelected];
    [_tBtnTransit setBackgroundColor:[UIColor whiteColor] forTab:2 forState:UIControlStateHighlighted];

    
    
//    [self.view addSubview: _tBtnTransit];
    [self.view insertSubview:_tBtnTransit aboveSubview: backgroundImage];

    
    [buttonBus sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( [network isReachable] )
    {
        [self getSystemStatus];
    }
    // else try again?
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
    
    [SVProgressHUD dismiss];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    _masterData = nil;
    _filteredData = nil;
    
    _busSectionIndex = nil;
    _busSectionTitle = nil;
}


- (void)viewDidUnload
{
    
    [self setTableView:nil];
    [self setSegmentRouteType:nil];
    
    
    //    [self setBarFilter:nil];
    [self setImgHeaderBar:nil];
    [self setLblHeader:nil];
//    [self setBtnTransit:nil];
//    [self setBtnRail:nil];
//    [self setBtnMFLBSLNHSL:nil];
    [super viewDidUnload];
}

//-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return YES;
//}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

    [_tBtnTransit changeFrameWidth: self.view.frame.size.width];
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
    
}


//-(CGRect) updateFrame: (CGRect) frame withAspectRatio: (CGFloat) aspectRatio
//{
//    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width * aspectRatio, frame.size.height);
//}


-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    [self.view setNeedsDisplayInRect:CGRectMake(0, 0, self.view.frame.size.width, 36)];
//    NSLog(@"SSVC - didRotate, %@, %@", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.view.bounds));
}


#pragma mark - UITableViewDelegate
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    // Only when segmentedIndex is on Bus (0)
    
//    int index = [self.segmentRouteType selectedSegmentIndex];
//    
//    if ( index == 0 )
//    {
//        return _busSectionTitle;
//    }
//    else
//        return nil;

    if ( _filterType == kSystemStatusFilterByBusTrolley )
    {
        return _busSectionTitle;
    }
    else
        return nil;
    
}

- (NSInteger)tableView:(UITableView *)thisTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
//    int routeType = [self.segmentRouteType selectedSegmentIndex];
//    
//    if ( routeType == 0 )
//    {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[_busSectionIndex objectAtIndex:index] intValue] inSection:0];
//        [thisTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
//    
//    return -1;

    
    if ( _filterType == kSystemStatusFilterByBusTrolley )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[_busSectionIndex objectAtIndex:index] intValue] inSection:0];
        [thisTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    
    return -1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // If there are no alerts for this route, do not display the accessory.
    SystemStatusObject *ssObject = [_filteredData objectAtIndex:indexPath.row];
    if ( [ssObject numOfAlerts] == 0 )
    {
        [cell setAccessoryType: UITableViewCellAccessoryNone];
    }
    else
    {
        [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
    }
    
    
    //[cell setBackgroundColor: [UIColor colorWithRed:216.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1] ];
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_line.png"]];
    [separator setFrame: CGRectMake(separator.frame.origin.x, separator.frame.origin.y, self.tableView.frame.size.width, separator.frame.size.height)];
    [separator setContentMode: UIViewContentModeScaleToFill];
    
    UITableViewCell *newCell = (UITableViewCell*)cell;
    [separator setFrame: CGRectOffset(separator.frame, 0, newCell.frame.size.height-separator.frame.size.height)];
    [newCell.contentView addSubview: separator];
    
    
}


- (void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // If there are no alerts for this route, do not display the accessory.
    SystemStatusObject *ssObject = [_filteredData objectAtIndex: indexPath.row];
    if ( [ssObject numOfAlerts] == 0 )
        return;
    
    [self performSegueWithIdentifier:@"SystemAlertsSegue" sender:self];
    
    //    if ( ( indexPath.section == kNextToArriveSectionRecent ) || ( indexPath.section == kNextToArriveSectionFavorites ) )
    //    {
    //        // IF either Recent or Favorites has been selected, change stop/end values
    //        NTASaveObject *sObject = [_tData returnObjectAtIndexPath:indexPath];
    //
    //        [[[_tData data] objectAtIndex:0] replaceObjectAtIndex:0 withObject:[sObject startStopName] ];
    //        [[[_tData data] objectAtIndex:0] replaceObjectAtIndex:1 withObject:[sObject endStopName  ] ];
    //        [sObject setAddedDate:[NSDate date] ];
    //
    //
    //        if ( indexPath.section == kNextToArriveSectionRecent)
    //            [saveData makeSectionDirty:kNTASectionRecentlyViewed];
    //        else if ( indexPath.section == kNextToArriveSectionFavorites)
    //            [saveData makeSectionDirty:kNTASectionFavorites];
    //
    //
    //        [[[_tData data] objectAtIndex:indexPath.section] sortUsingComparator:sortNTASaveObjectByDate];
    //
    //        [self.tableView reloadData];
    //
    //        [self highlightRetrieveButton];
    //    }
    
    
}



//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    NSString *headerName = [_tData nameForSection:indexPath.section];
//
//
//    if ( [headerName isEqualToString:@"StartEndCells"] )
//    {
//        return 44.0f;
//    }
//    else if ( [headerName isEqualToString:@"Favorites"] )
//    {
//        return 44.0f;
//    }
//    else if ( [headerName isEqualToString:@"Recent"] )
//    {
//        return 44.0f;
//    }
//    else
//    {
//
//        //        NextToArrivaJSONObject *ntaObject = [_masterData objectAtIndex:indexPath.row-2];
//        NextToArrivaJSONObject *ntaObject = [_tData returnObjectAtIndexPath:indexPath];
//
//        if ( [ntaObject Connection] == nil )
//        {
//            return 44.0f;
//        }
//        else
//        {
//            return 118.0f;
//        }
//
//    }
//
//}


//-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//
//    if ( ( section == 0 ) || ( [_tData numberOfRowsInSection:section] == 0 ) )
//        return 0.0f;
//    else
//        return 22.0f;
//
//}
//
//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//
//    //    if ( [_showTimes numberOfSections] == 1 )  // Why do this?
//    //    {
//    //        //        self.tableView.tableHeaderView = nil;
//    //        //        [self.tableView reloadData];
//    //        return nil;
//    //    }
//    //    else
//    //    {
//
//    if ( section > 0 )  // First section consists of the start and end cells
//    {
//
//        UITableViewStandardHeaderLabel *label = [[UITableViewStandardHeaderLabel alloc] init];
//
//        [label setText: [_tData nameForSection:section] ];
//        [label setFont: [UIFont boldSystemFontOfSize:20] ];
//        [label setTextColor: [UIColor whiteColor] ];
//        [label setOpaque:NO];
//
//        [label setNumberOfLines:1];
//        [label setAdjustsFontSizeToFitWidth:YES];
//
//        return label;
//    }
//    else
//        return nil;
//
//}



-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
//    NSLog(@"SSVC - # of rows: %d", [_filteredData count]);
    return [_filteredData count];
    
}


#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellName = @"SystemStatusCell";
    
    SystemStatusCell *cell = (SystemStatusCell*)[thisTableView dequeueReusableCellWithIdentifier:cellName];
    
//    if ( ( indexPath.row == 7 ) || ( indexPath.row == 8 ) )  // What in the hell is this actually doing?
//    {
//        NSLog(@"section");
//    }
    
    SystemStatusObject *ssObject = [_filteredData objectAtIndex:indexPath.row];

    
    [cell addSystemStatusObject: ssObject];
    
    
    // There are instances where a NSNull object is written one of the properties of ssObject.  If it was a normal null,
    //   there wouldn't be an issue passing messages to it.  But because it's an NSNull object and not a null, it doesn't
    //   know how to responsd to a message passed to it.
    
    //[ssObject setIssuspend: [NSNull null] ];
    
    @try
    {
        
        if ( [[ssObject isadvisory] isEqualToString:@"Yes"] )
        {
            [[cell imgAdvisory] setHidden:NO];
        }
        else
        {
            [[cell imgAdvisory] setHidden:YES];
        }
        
        
        if ( [[ssObject isalert] isEqualToString:@"Y"] )
        {
            [[cell imgAlert] setHidden:NO];
        }
        else
        {
            [[cell imgAlert] setHidden:YES];
        }
        
        
        if ( [[ssObject isdetour] isEqualToString:@"Y"] )
        {
            [[cell imgDetour] setHidden:NO];
        }
        else
        {
            [[cell imgDetour] setHidden:YES];
        }
        
        
        if ( [[ssObject issuspend] isEqualToString:@"Y"] )
        {
            [[cell imgSuspended] setHidden:NO];
        }
        else
        {
            [[cell imgSuspended] setHidden:YES];
        }
        
        
    }
    @catch (NSException *exception)
    {
        [[cell imgAdvisory] setHidden:YES];
        [[cell imgAlert] setHidden:YES];
        [[cell imgDetour] setHidden:YES];
        [[cell imgSuspended] setHidden:YES];
    }
    @finally
    {
        
    }
    
    
    
    
    return cell;
    
}


#pragma mark - Web Request

-(void) getSystemStatus
{
    
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
        return;  // Don't bother continuing if no internet connection is available

    
    NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/Alerts/"];

    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"NTAVC - getSystemStatus -- api url: %@", webStringURL);
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    // Old code, use AFNetworking instead
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
//        
//        NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
//        [self performSelectorOnMainThread:@selector(processSystemStatusJSONData:) withObject: realTimeTrainInfo waitUntilDone:YES];
//        
//    });
    
    NSURLRequest *systemRequest = [NSURLRequest requestWithURL: [NSURL URLWithString: stringURL] ];
    
    AFJSONRequestOperation *jsonSystemOp;
    jsonSystemOp = [AFJSONRequestOperation JSONRequestOperationWithRequest: systemRequest
                                                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                       NSDictionary *jsonDict = (NSDictionary*) JSON;
                                                                       [self processSystemStatusJSONData:jsonDict];
                                                                   }
                                                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                       NSLog(@"System Status Failure Because %@", [error userInfo] );
                                                                   }];
    
    [jsonSystemOp start];
    
    
    NSString *elevatorURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/elevator/"];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: elevatorURL] ];
    
    AFJSONRequestOperation *jsonElevatorOp;
    jsonElevatorOp = [AFJSONRequestOperation JSONRequestOperationWithRequest: request
                                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                         
                                                                         NSDictionary *jsonDict = (NSDictionary*) JSON;
                                                                         [self processElevatorStatusJSONData: jsonDict];
                                                                         
                                                                     }
                                                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                         NSLog(@"Elevator Request Failure Because %@", [error userInfo] );
                                                                     }];
    
    
    [jsonElevatorOp start];

//    NSString *elevatorWebURL = [elevatorURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
//        
//        NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString: elevatorWebURL] ];
//        [self performSelectorOnMainThread:@selector(processElevatorStatusJSONData:) withObject: realTimeTrainInfo waitUntilDone:YES];
//        
//    });

    
    
}


//-(void) getAlertData
//{
//    
//    NSString *busRoute = @"bus_route_1";
//    NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/Alerts/get_alert_data.php?req1=%@", busRoute];
//    
//    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"NTAVC - getAlertData -- api url: %@", webStringURL);
//    
//    [SVProgressHUD showWithStatus:@"Loading..."];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
//        
//        NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
//        [self performSelectorOnMainThread:@selector(processSystemAlertJSONData:) withObject: realTimeTrainInfo waitUntilDone:YES];
//        
//    });
//    
//}


//-(void) processSystemAlertJSONData:(NSData*) returnedData
//{
//    [SVProgressHUD dismiss];
//    
//    // This method is called once the realtime positioning data has been returned via the API is stored in data
//    NSError *error;
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
//    
//    if ( json == nil )
//        return;
//    
//    if ( error != nil )
//        return;  // Something bad happened, so just return.
//    
//    [_alertData removeAllObjects];
//    for (NSDictionary *data in json)
//    {
//        SystemAlertObject *saObject = [[SystemAlertObject alloc] init];
//        
//        [saObject setRoute_id:   [data objectForKey:@"route_id"] ];
//        [saObject setRoute_name: [data objectForKey:@"route_name"] ];
//        
//        [saObject setCurrent_message:  [data objectForKey:@"current_message"] ];
//        [saObject setAdvisory_message: [data objectForKey:@"advisory_message"] ];
//        
//        [saObject setDetour_message:        [data objectForKey:@"detour_message"] ];
//        [saObject setDetour_start_location: [data objectForKey:@"detour_start_location"] ];
//        
//        [saObject setDetour_start_date_time: [data objectForKey:@"detour_start_date_time"] ];
//        [saObject setDetour_end_date_time:   [data objectForKey:@"detour_end_date_time"] ];
//        
//        [saObject setDetour_reason: [data objectForKey:@"detour_reason"] ];
//        [saObject setLast_updated:  [data objectForKey:@"last_updated"] ];
//        
//        [_alertData addObject: saObject];
//    }
//    
//}


//-(void) processElevatorStatusJSONData:(NSData*) returnedData
-(void) processElevatorStatusJSONData:(NSDictionary*) json
{
    
    NSError *error;

    if ( json == nil )  // Trying to serialize a nil object will generate an error
        return;
    
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( json == nil || [json count] == 0 )
        return;
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
//    _elevatorStatus = [json mutableCopy];
    
    SystemStatusObject *elevatorStatus = [[SystemStatusObject alloc] init];
    
//    NSString *jsonStr = @"{\"meta\":{\"elevators_out\":2,\"updated\":\"2013-11-2611:38:02\"},\"results\":[{\"line\":\"MarketFrankfordLine\",\"station\":\"Berks\",\"elevator\":\"Westbound\",\"message\":\"Noaccessto/fromstation\",\"alternate_url\":\"http://www.septa.org/access/alternate/mfl.html#berks\"},{\"line\":\"BroadStreetLine\",\"station\":\"CityHall\",\"elevator\":\"EastBound\",\"message\":\"Noaccessto/fromstation\",\"alternate_url\":\"http://www.septa.org/access/alternate/mfl.html#berks\"}]}";

    
    NSDictionary *meta = [json objectForKey:@"meta"];  // keys: elevators_out, updated
//    NSMutableArray   *results = [json objectForKey:@"results"];  // keys:  line, station, evelator, message, alternate_url
    
    [elevatorStatus setMode      : @"Elevator" ];
    [elevatorStatus setRoute_name: @"Elevators"];
    [elevatorStatus setRoute_id  : @"Elevator" ];
    [elevatorStatus setLast_updated: [meta objectForKey:@"updated"] ];
    
//    [meta setObject:[NSNumber numberWithInt:2] forKey:@"elevators_out"];
    
    if ( [[meta objectForKey:@"elevators_out"] integerValue] > 0 )
    {
        [elevatorStatus setIsalert:@"Y"];
    }

    [_additionalStatus setObject: elevatorStatus forKey:@"Elevator"];
    
    [self filterTableDataSourceBy: _filterType];

    
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
    
    [_masterData removeAllObjects];
    for (NSDictionary *data in json)
    {
        SystemStatusObject *ssObject = [[SystemStatusObject alloc] init];
    
        NSString *routeName = [data objectForKey:@"route_name"];
        if ( [routeName isEqualToString:@"CCT"] )  // || [routeName isEqualToString:@"Generic"]
            continue;
        else if ( [routeName isEqualToString:@"Generic"] )
        {

            [ssObject setRoute_id:  [data objectForKey:@"route_id"] ];
            [ssObject setRoute_name:@"General"];
            
            [ssObject setMode:      @"Generic"];
            
            [ssObject setIsadvisory:[data objectForKey:@"isadvisory"] ];
            [ssObject setIsalert:   [data objectForKey:@"isalert"   ] ];
            [ssObject setIssuspend: [data objectForKey:@"issuppend" ] ];
            [ssObject setIsdetour:  [data objectForKey:@"isdetour"  ] ];
            
            [ssObject setLast_updated:[data objectForKey:@"last_updated"] ];

            [_additionalStatus setObject:ssObject forKey:@"Generic"];
            continue;
            
        }
        else if ( [routeName isEqualToString:@"Market/ Frankford Line"] )
            routeName = @"Market-Frankford Line";
        else if ( [routeName isEqualToString:@"Market Frankford Owl"] )
            routeName = @"Market-Frankford Owl";
        
        [ssObject setRoute_id:  [data objectForKey:@"route_id"] ];
        [ssObject setRoute_name:routeName];
        
        [ssObject setMode:      [data objectForKey:@"mode"] ];
        
        [ssObject setIsadvisory:[data objectForKey:@"isadvisory"] ];
        [ssObject setIsalert:   [data objectForKey:@"isalert"] ];
        [ssObject setIssuspend: [data objectForKey:@"issuppend"] ];
        [ssObject setIsdetour:  [data objectForKey:@"isdetour"] ];
        
        [ssObject setLast_updated:[data objectForKey:@"last_updated"] ];
        
        [_masterData addObject:ssObject];
        
    }
    
    
    
    
//    [self filterTableDataSource];
    [self filterTableDataSourceBy: _filterType];
    
    
}

//#pragma mark - UISegementedControl
//- (IBAction)segmentRouteTypeChanged:(id)sender
//{
//    
//    [self filterTableDataSource];
//    
//}


-(void) filterTableDataSourceBy: (SystemStatusFilterType) filterType
{

    NSPredicate *currentPredicate;
    id sortBy;
    
    switch (filterType)
    {
        case kSystemStatusFilterByBusTrolley:
            _filterMode = @"(Bus|Trolley)";
            currentPredicate = [NSPredicate predicateWithFormat:@"mode MATCHES %@", _filterMode];
            sortBy = sortStatusByNumberString;
            break;
            
        case kSystemStatusFilterByMFLBSLNHSL:
            _filterMode = @"(Market/ Frankford|Broad Street Line|Norristown High Speed Line)";
            currentPredicate = [NSPredicate predicateWithFormat:@"mode MATCHES %@", _filterMode];
            sortBy = sortStatusByNumberString;
            
            break;
            
        case kSystemStatusFilterByRail:
            _filterMode = @"Regional Rail";
            currentPredicate = [NSPredicate predicateWithFormat:@"mode == %@", _filterMode];
            sortBy = sortStatusName;
 
            break;
        
        default:
            currentPredicate = [NSPredicate predicateWithValue:YES];
            sortBy = sortStatusByNumberString;
            
            break;
    }  // switch (filterType)
    
    
    _filteredData = [[ [_masterData filteredArrayUsingPredicate:currentPredicate] sortedArrayUsingComparator: sortBy] mutableCopy];
    
    
    // Check if routes without any alerts, advisories or detours should be removed
    if ( !_showAllRoutes )
    {

        NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
        for (SystemStatusObject *ssObject in _filteredData)
        {
            if ( [ssObject numOfAlerts] == 0 )
                [objectsToRemove addObject: ssObject];
        }
        [_filteredData removeObjectsInArray: objectsToRemove];
        
    }


    // If there is an elevator outage, add it to _filteredData
//    if ( _elevatorStatus != nil )
//        [_filteredData insertObject:_elevatorStatus atIndex:0];

//    for (SystemStatusObject *ssObject in _additionalStatus)
    for (NSString *key in _additionalStatus)
    {
        if ( [(SystemStatusObject*)[_additionalStatus objectForKey:key] numOfAlerts] || _showAllRoutes )
            [_filteredData insertObject: [_additionalStatus objectForKey:key] atIndex:0];
    }
    
    
    [self generateIndex];
    
    [self.tableView reloadData];
    
    if ( [_filteredData count] > 0 )
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}


//-(void) filterTableDataSource
//{
//    
//    NSPredicate *currentPredicate;
//    NSInteger index = [self.segmentRouteType selectedSegmentIndex];
//    id sortBy;
//    
//    switch (index) {
//        case 0:  // Bus
//            _filterMode = @"(Bus|Trolley)";
//            currentPredicate = [NSPredicate predicateWithFormat:@"mode MATCHES %@", _filterMode];
//            sortBy = sortStatusByNumberString;
//            
//            break;
//        case 1:  // Rail
//            _filterMode = @"Regional Rail";
//            currentPredicate = [NSPredicate predicateWithFormat:@"mode == %@", _filterMode];
//            sortBy = sortStatusName;
//            
//            break;
//        case 2:  // MFL/MFO
//            _filterMode = @"Market/ Frankford";
//            currentPredicate = [NSPredicate predicateWithFormat:@"mode == %@", _filterMode];
//            sortBy = sortStatusName;
//            
//            break;
//        case 3:  // BSS/BSO
//            _filterMode = @"Broad Street Line";
//            currentPredicate = [NSPredicate predicateWithFormat:@"mode == %@", _filterMode];
//            sortBy = sortStatusName;
//            
//            break;
//        case 4:  // NHSL
//            _filterMode = @"Norristown High Speed Line";
//            currentPredicate = [NSPredicate predicateWithFormat:@"mode == %@", _filterMode];
//            sortBy = sortStatusName;
//            
//            break;
//            
//        default:
//            break;
//    }
//    
//    //    currentPredicate = [NSPredicate predicateWithFormat:@"mode == %@", _filterMode];
//    _filteredData = [ [_masterData filteredArrayUsingPredicate:currentPredicate] sortedArrayUsingComparator: sortBy];
//    
//    
//    [self generateIndex];
//    
//    [self.tableView reloadData];
//    
//    if ( [_filteredData count] > 0 )
//    {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
//    
//}

#pragma mark - Generating UITableView Index
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
    
    for (SystemStatusObject *ssObject in _filteredData)
    {
        
        NSString *short_name = [ssObject route_name];
        
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
            [_busSectionIndex addObject: [NSNumber numberWithInt:index] ];
            
            //            NSLog(@"PNVC - title: %@, index: %d", newChar, index);
            
            lastChar = newChar;
        }
        index++;
    }
    
}


#pragma mark - NSComparison Blocks
NSComparisonResult (^sortStatusByNumberString)(SystemStatusObject*,SystemStatusObject*) = ^(SystemStatusObject *a, SystemStatusObject *b)
{
    
    return [[a route_name] compare:[b route_name] options:NSNumericSearch];
    
    //    int aInt = [[a route_name] intValue];
    //    int bInt = [[b route_name] intValue];
    //
    //    if ( !aInt && !bInt )
    //        return aInt > bInt;
    //    else if (aInt == 0)
    //        return 1;
    //    else if (bInt == 0)
    //        return -1;
    //    else
    //        return aInt > bInt;
};


NSComparisonResult (^sortStatusName)(SystemStatusObject*,SystemStatusObject*) = ^(SystemStatusObject *a, SystemStatusObject *b)
{
    return [[a route_name] compare: [b route_name] ];
};


#pragma mark - Preparing the Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue identifier] isEqualToString:@"SystemAlertsSegue"] )
    {
        
        // Find which row was selected
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        // Get the alert status of said row
        SystemStatusObject *ssObject = [_filteredData objectAtIndex: indexPath.row];
        
        // Build array of alerts to pass to SystemAlertViewController
        NSMutableArray *alerts = [[NSMutableArray alloc] init];
        
        NSDictionary *dict = [ssObject dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"isadvisory", @"isdetour", @"issuspend", @"isalert", nil] ];
        
        for (NSString *status in dict)
        {
            
            if ( [[dict objectForKey:status] isEqualToString:@"Yes"] || [[dict objectForKey:status] isEqualToString:@"Y"] )
            {
                [alerts addObject:status];
            }  // if ( status isEqualToString @"YES" or @"Y" )
            
        }  // for (NSString *status in dict)
        
        SystemAlertsViewController *savc = [segue destinationViewController];
//        [savc setAlerts: alerts];
//        [savc setRoute_id:[ssObject route_id] ];
        
        [savc setSsObject:ssObject];
//        [savc setTitle: ssObject.route_name];
        
    }
    
}


#pragma mark - UIButton Presses
//- (IBAction)btnTransitPressed:(id)sender
//{
//    [self.lblHeader setText:@"TRANSIT"];
//    [self filterTableDataSourceBy: kSystemStatusFilterByBusTrolley];
//    // Filter _masterData for only Bus and Trolley
//    
//    [self.btnTransit    setSelected:YES];
//    [self.btnRail       setSelected:NO];
//    [self.btnMFLBSLNHSL setSelected:NO];
//}
//
//
//- (IBAction)btnMFLBSLNHSLPressed:(id)sender
//{
//    [self.lblHeader setText:@"MFL, BSL, NHSL"];
//    [self filterTableDataSourceBy: kSystemStatusFilterByMFLBSLNHSL];
//    // Filter _masterData for only MFL, BSL, NHSL
//    
//    [self.btnTransit    setSelected:NO];
//    [self.btnRail       setSelected:NO];
//    [self.btnMFLBSLNHSL setSelected:YES];
//}
//
//
//- (IBAction)btnRailPressed:(id)sender
//{
//    [self.lblHeader setText:@"REGIONAL RAIL LINE"];
//    [self filterTableDataSourceBy: kSystemStatusFilterByRail];
//    // Filter _masterData for only Regional Rail
//    
//    [self.btnTransit    setSelected:NO];
//    [self.btnRail       setSelected:YES];
//    [self.btnMFLBSLNHSL setSelected:NO];
//}


-(void) backButtonPressed:(id) sender
{
    
    //    NSLog(@"Custom Back Button -- %@", sender);
    //    [self dismissModalViewControllerAnimated:YES];  // Does not work
    //    [self removeFromParentViewController];   // Does nothing!
    //    [self.view removeFromSuperview];  // Removed from Superview but doesn't go back to previous VC
    
    
    //    [self.navigationController removeFromParentViewController];  // Does not work, does not do anything
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

//-(void) createTabbedButtons: (NSArray*) buttonConfigurationArr
//{
//    // Array contains an Array of Dictionaries
//    
//    // Should be 3 tabs
//    for (NSArray *singleTabArr in buttonConfigurationArr)
//    {
//        
//        // Tab 1 - 2, Tab 2 - 1, Tab 3 - has 3 buttons
//        for (NSArray *eachTabArr in singleTabArr)
//        {
//            
//            for (NSDictionary *tabConfigDict in eachTabArr)
//            {
//                // eachTabArr object is a tabConfigDict
//                // Create a button in accordance to tabConfigDict
//            }
//            
//        }
//        
//    }
//    
//    
//    
//}

-(void) tabbedButtonPressed:(NSInteger) tab
{
    
    NSLog(@"tab pressed: %d", tab);
    switch (tab) {
        case 0:
            [self.lblHeader setText:@"TRANSIT"];
            _filterType = kSystemStatusFilterByBusTrolley;
            break;
        
        case 1:
            [self.lblHeader setText:@"REGIONAL RAIL LINE"];
            _filterType = kSystemStatusFilterByRail;
            break;
            
        case 2:
            [self.lblHeader setText:@"MFL, BSL, NHSL"];
            _filterType = kSystemStatusFilterByMFLBSLNHSL;
            break;
            
        default:
            [self.lblHeader setText:@"TRANSIT"];
            _filterType = kSystemStatusFilterByBusTrolley;
            break;
    }
    
    [self filterTableDataSourceBy: _filterType];
    
}

-(void) filterButtonPressed:(id) sender
{
//    NSLog(@"Filter Button Pressed");
    
    _showAllRoutes = !_showAllRoutes;

    CustomFlatBarButton *rightButton = (CustomFlatBarButton*)self.navigationItem.rightBarButtonItem;
    if ( _showAllRoutes )
        [rightButton.button setSelected:NO];
    else
        [rightButton.button setSelected:YES];

    
    // Save changes to toggle option to user preferences
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_showAllRoutes] forKey:@"SystemStatus:ShowAllRoutes"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self filterTableDataSourceBy: _filterType];
    
}


@end
