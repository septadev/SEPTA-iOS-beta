//
//  ItineraryViewController.m
//  iSEPTA
//
//  Created by septa on 8/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "ItineraryViewController.h"

@interface ItineraryViewController ()

@end

@implementation ItineraryViewController
{
    
    /*
     This VC will contain three sections: itinerary, active trains, trips.
     itinerary - holds start/end stops (name and id), direction_id, route_id and contains the various buttons this VC will respond to
     active trains - an array of tripObjects.  Loaded from TrainView, inserts data into the VC 5-10 seconds after VC has finished loading
     trips - holds the start/end time, train #, route_id, direction_id, service_id, start/end sequence
     */
    
    NSMutableArray *_currentAlert;
    GetAlertDataAPI *_alertsAPI;
    
    ItineraryFavoriteSubtitleState _favoriteStatus;
    
    ItineraryObject *itinerary;
    
    NSMutableArray *activeTrainsArr;  // Array of TripObjects
    NSMutableArray *masterTripsArr;   // Master list of all TripObjects based on ItineraryObject
    NSMutableArray *currentTripsArr;  // Filtered from master list based on direction_id and service_id
    
    BOOL _startENDButtonPressed;
    BOOL _inDarkTerritory;
    
    NSInteger _currentDisplayDirection;
    NSMutableString *_servicePredicate;
//    NSInteger _currentSegmentIndex;
    
    // --==  Runs SQL queries in a background thread  ==--
    NSOperationQueue *_sqlQueue;
    NSBlockOperation *_sqlOp;
    
    // --==  Runs JSON queries in a background thread  ==--
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_jsonOp;
    
    
    NSMutableDictionary *_masterTrainLookUpDict;
    NSMutableArray *_masterJSONTrainArr;
    
    NSTimer *cellRefreshTimer;  // Refreshes time for each cell
    NSTimer *jsonRefreshTimer;  // Refreshes JSON data
    
    BOOL _findLocationsSegue;
    BOOL _use24HourTime;
    BOOL _stillWaitingOnWebRequest;
    
    BOOL _viewIsClosing;
    
    NSString *_message;
    
    ItineraryFilterType _currentFilter;
    NSInteger _currentServiceID;
    NSMutableArray *toFromDirection;
    NSString *_headerDirection;
    
    
    // Used to store the header titles for the current bus direction
    NSMutableArray *_nameForSection;

    TabbedButton *_tBtnTransit;
    
    // --==  CustomBarButton
    NSString *_backButtonImage;
    
    SEPTARouteTypes _routeType;
    
    
    // Drop down window controller
    REMenu *_menu;
    
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
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - viewDidLoad");
#endif
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Check if we should use military time or AM/PM
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:24HourTime"];
    if ( object == nil )
    {
        _use24HourTime = NO;  // If nil, no data is in @"Settings:24HourTime" so default to NO
    }
    else
    {
        _use24HourTime = [object boolValue];
    }
    
    _inDarkTerritory = NO;  // Default to this
    
    _message = nil;
    
    
    // Registering xib
    [self.tableTrips registerNib:[UINib nibWithNibName:@"NextToArriveItineraryCell"      bundle:nil] forCellReuseIdentifier:@"NextToArriveItineraryCell"];

    [self.tableTrips registerNib:[UINib nibWithNibName:@"ActiveTrainCell" bundle:nil] forCellReuseIdentifier:@"ActiveTrainCell"];
    [self.tableTrips registerNib:[UINib nibWithNibName:@"ItineraryCell"   bundle:nil] forCellReuseIdentifier:@"ItineraryCell"];
    [self.tableTrips registerNib:[UINib nibWithNibName:@"TripCell"        bundle:nil] forCellReuseIdentifier:@"TripCell"];
    
    
    _favoriteStatus = kNextToArriveFavoriteSubtitleStatusUnknown;

    // Dismiss any active SVProgressHUD.  Previous VC could have started one.
    _startENDButtonPressed = 0;
    

    _currentDisplayDirection    = -1;  // Default current direction to a non-zero number
    _stillWaitingOnWebRequest = NO;
    _viewIsClosing = NO;
    
    
    if ( [[self.routeData route_type] intValue] == 3 )
        self.travelMode = @"Bus";
    

    
    // Creating NSOperationQueue so user can cancel out of it
    _sqlQueue  = [[NSOperationQueue alloc] init];
    _jsonQueue  = [[NSOperationQueue alloc] init];
    
    
    // --==  TableView Sections  ==--
    itinerary       = [[ItineraryObject alloc] init];
    masterTripsArr  = [[NSMutableArray alloc] init];
    activeTrainsArr = [[NSMutableArray alloc] init];
    currentTripsArr = [[NSMutableArray alloc] init];
    _masterJSONTrainArr = [[NSMutableArray alloc] init];
    
    _masterTrainLookUpDict = [[NSMutableDictionary alloc] init];
    
    toFromDirection = [[NSMutableArray alloc] init];
    [self loadToFromDirections];
    
    // --== The first three fields below should have data
    [itinerary setRouteID: self.routeData.route_id];
    [itinerary setRouteShortName: self.routeData.route_short_name];
    [itinerary setRouteLongName : self.routeData.route_long_name ];
    
    _headerDirection = @""; //_routeData.route_id;
    
    // --== Only the following fields will be filled if Favorites or Recently were touched
    if ( self.routeData.start_stop_name == nil )
    {
        [itinerary setStartStopName: DEFAULT_START_MESSAGE];
        [itinerary setEndStopName  : DEFAULT_END_MESSAGE];
        
        [itinerary setStartStopID :[NSNumber numberWithInt:0] ];
        [itinerary setEndStopID   :[NSNumber numberWithInt:0] ];
    }
    else
    {
        [itinerary setStartStopName: self.routeData.start_stop_name];
        [itinerary setStartStopID:[NSNumber numberWithInt: self.routeData.start_stop_id] ];
        
        [itinerary setEndStopName: self.routeData.end_stop_name];
        [itinerary setEndStopID:[NSNumber numberWithInt:self.routeData.end_stop_id] ];
        
        [itinerary setDirectionID:[NSNumber numberWithInt:self.routeData.direction_id] ];
        
        _currentDisplayDirection = self.routeData.direction_id;
        
        // If either Start or End stop_id is invalid, the SQL query will return nothing and nothing will be changed.
        [self reverseStopLookUpForStart:YES];
        [self reverseStopLookUpForStart:NO];
        
        
        //        NSString *key = [NSString stringWithFormat:@"%@%@%@", itinerary.routeID, itinerary.startStopName, itinerary.endStopName];
        //        NSLog(@"MD5 hash for %@ = %@", key, [key md5]);
        //        NSLog(@"SHA1 hash for %@ = %@", key, [key sha1]);
        
    }
    
    
    _nameForSection = [[NSMutableArray alloc] init];  // Needs to be initialized before [self loadHeaderNames]
    [self loadHeaderNamesWith: itinerary];  // Itinerary Object needs to be defined before this;  Or I can do that and explicitly state what it needs
    // Except, butthead, you forgot to pass _nameForSection into it as well.
    
    
    
    NSString *title;
//    CGFloat fontSize = 45.0f/2.0f;
    if ( [self.travelMode isEqualToString:@"Rail"] )
    {
//        title = @"Regional Rail Lines";
        title = [NSString stringWithFormat:@"%@", self.routeData.route_short_name];
        _backButtonImage = @"RRL_white.png";
        _routeType = kSEPTATypeRail;
    }
    else if ( [self.travelMode isEqualToString:@"Bus"] )
    {

        if ( [self.routeData.route_short_name isEqualToString:@"MFO"] )
        {
            _routeType = kSEPTATypeMFL;
        }
        else if ( [self.routeData.route_short_name isEqualToString:@"BSO"] )
        {
            _routeType = kSEPTATypeBSL;
        }
        else
        {
            _routeType = kSEPTATypeBus;
        }
        
        title = [NSString stringWithFormat:@"Route %@", self.routeData.route_short_name];
        _backButtonImage = @"Bus_white.png";

    }
    else if ( [self.travelMode isEqualToString:@"Trolley"] )
    {
        title = [NSString stringWithFormat:@"Route %@", self.routeData.route_short_name];
        _backButtonImage = @"Trolley_white.png";
        _routeType = kSEPTATypeTrolley;
    }
    else if ( [self.travelMode isEqualToString:@"MFL"] )
    {
        title = @"MFL";
        _backButtonImage = @"MFL_white.png";
        _routeType = kSEPTATypeMFL;
    }
    else if ( [self.travelMode isEqualToString:@"BSL"] )
    {
        title = @"Broad Street Line";
        _backButtonImage = @"BSL_white.png";
        _routeType = kSEPTATypeBSL;
    }
    else if ( [self.travelMode isEqualToString:@"NHSL"] )
    {
        title = @"NHSL";
        _backButtonImage = @"NHSL_white.png";
        _routeType = kSEPTATypeNHSL;
    }
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:_backButtonImage
                                                                                  withTarget:self
                                                                               andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: title];
    [self.navigationItem setTitleView:titleView];
    
    
//    DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
    //    NSLog(@"RouteData: %@", routeData.current);
    
    // Check if flipped stop names are a favorite location
//    if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
//        [self setFavoriteHighlight:YES];
//    else
//        [self setFavoriteHighlight:NO];

    
    _alertsAPI = [[GetAlertDataAPI alloc] init];
    [_alertsAPI setDelegate:self];

    
    [self configureDropDownMenu];

    [self configureTabs];
    
    [self updateServiceID];
    
    [self checkIfInDarkTerritory];
    [self loadTripsInTheBackground];
//    [self getAdvisories];
    
    
}


-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - willAnimateRotationToInterfaceOrientation");
#endif

    
    [_tBtnTransit changeFrameWidth: self.view.frame.size.width];
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];

//    [self.tableTrips reloadRowsAtIndexPaths:[self.tableTrips indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableTrips reloadData];  // This refreshes the Header View when the orientation changes, the above statement didn't
    
}


-(void) viewWillAppear:(BOOL)animated
{

#if FUNCTION_NAMES_ON
    NSLog(@"IVC - viewWillAppear");
#endif


    [_tBtnTransit changeFrameWidth: self.view.frame.size.width];

    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
    
    
    cellRefreshTimer =[NSTimer scheduledTimerWithTimeInterval:CELL_REFRESH_RATE
                                                       target:self
                                                     selector:@selector(refreshCellsTime)
                                                     userInfo:nil
                                                      repeats:YES];
    
    [self updateTimeSettings];
    
    
    if ( _viewIsClosing == YES )
        NSLog(@"IVC - It's nil man!  NIL!!");
    else
        NSLog(@"IVC - It's active, baby!");
    
//    [self loadJSONDataIntheBackground];
    
    _findLocationsSegue = NO;
    _viewIsClosing = NO;
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC viewWilLDisappear");
#endif
    
    _viewIsClosing = YES;
    
    NSLog(@"IVC - viewWilLDisappear");
    if ( cellRefreshTimer != nil )  // Might not be necessary but for now, better safe than CRASH!
    {
        
        if ( [cellRefreshTimer isValid]  )
        {
            [cellRefreshTimer invalidate];
            cellRefreshTimer = nil;
            NSLog(@"IVC - Killing updateTimer");
        }
        
    }
    
    
    // Cancel all operations.  If operations are nil, nothing untoward happens!
    [_sqlQueue  cancelAllOperations];
    
    [_jsonQueue cancelAllOperations];
    [jsonRefreshTimer invalidate];
    
    if ( !_findLocationsSegue )  // Only true if the segue goes to FindLocationsVC, otherwise we're leaving this VC.  Later punks!
    {
        
        DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
        if ( routeData.current.start_stop_id == 0 || routeData.current.end_stop_id == 0 )
        {
            // Do nothing
        }
        else
        {
            [routeData addCurrentToSection: kDisplayedRouteDataRecentlyViewed];
        }
        
    }  // if ( !_findLocationsSegue )
    
}


-(void) configureDropDownMenu
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC configureDropDownMenu");
#endif

//    CustomFlatBarButton *rightButton = [[CustomFlatBarButton alloc] initWithImageNamed:@"second-menu.png"
//                                                                            withTarget:self
//                                                                         andWithAction:@selector(dropDownMenuPressed:)];
//    [self.navigationItem setRightBarButtonItem: rightButton];
    
    
    MenuAlertsImageView *mView = [[MenuAlertsImageView alloc] initWithFrame: CGRectMake(0, 0, 50, 37.5)];
    
    [mView setBaseImage: [UIImage imageNamed:@"second-menu.png"] ];
    [mView addTarget:self action:@selector(dropDownMenuPressed:) forControlEvents:UIControlEventTouchDown];
    
//    [mView addAlert: kMenuAlertsImageAlerts];
//    [mView addAlert: kMenuAlertsImageDetours];
    //    [mView addAlert: kMenuAlertsImageAdvisories];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView: mView];
    [self.navigationItem setRightBarButtonItem: rightButton];

    
    REMenuItem *favoritesItem = [[REMenuItem alloc] initWithTitle:@"Favorite"
                                                         subtitle:FAVORITE_SUBTITLE_NONE
                                                            image:[UIImage imageNamed:@"Favorite.png"]
                                                 highlightedImage:nil
                                                           action:^(REMenuItem *item) {
                                                               [self selectedFavorites];
                                                           }];
    
    REMenuItem *fareItem = [[REMenuItem alloc] initWithTitle:@"Fare"
                                                    subtitle:@"Fare Information"
                                                       image:[UIImage imageNamed:@"Fare.png"]
                                            highlightedImage:nil
                                                      action:^(REMenuItem *item) {
                                                          [self loadFareVC];
                                                      }];
    
    
    // Can init with CustomView, display the icon for which alerts are available
    REMenuItem *advisoryItem = [[REMenuItem alloc] initWithTitle:@"Service Advisory"
                                            subtitle:ALERTS_STARTUP
                                               image:[UIImage imageNamed:@"Advisory.png"]
                                    highlightedImage:nil
                                              action:^(REMenuItem *item) {
                                                  [self loadAdvisories];
                                                  }];
    
    
    REMenuItem *disclaimerItem = [[REMenuItem alloc] initWithTitle:@"Real Time"
                                                          subtitle: @"Regional Rail Service"                                                           image:[UIImage imageNamed:@"tipsBack.png"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              [self loadDisclaimer];
                                                          }];
    
    
    
    _menu = [[REMenu alloc] initWithItems:@[favoritesItem, fareItem, advisoryItem, disclaimerItem] ];
    _menu.cornerRadius = 4;
    _menu.shadowRadius = 4;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 1);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(5, -1);
    _menu.itemHeight = 40.0f;
    _menu.waitUntilAnimationIsComplete = NO;
    
    _menu.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f];
    _menu.subtitleFont = [UIFont fontWithName:@"TrebuchetMS" size:15.0f];
    
    _menu.textColor = [UIColor whiteColor];
    _menu.subtitleTextColor = [UIColor whiteColor];
    
    
}



-(void) configureTabs
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC configureTabs");
#endif
    
    // Load background image
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ];
//    [backgroundImage setContentMode: UIViewContentModeScaleAspectFill];
//    backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    
//    [self.view addSubview:backgroundImage];
//    [self.view sendSubviewToBack:backgroundImage];

    UIColor *bgColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.view setBackgroundColor: bgColor];
    
    
    //  --==  Tabbed Button Configuration  ==--
    UIColor *selectedBGColor;
    UIColor *backgroundColor = [UIColor colorWithRed:213.0f/255.0f green:214.0f/255.0f blue:213.0f/255.0f alpha:1.0f];
    switch ([_routeData.route_type intValue])
    {
        case kGTFSRouteTypeBus:
            selectedBGColor = [UIColor colorForRouteType: kSEPTATypeBus];
            break;
            
        case kGTFSRouteTypeTrolley:
            
            if ( [_routeData.route_short_name isEqualToString:@"NHSL"] )
            {
                selectedBGColor = [UIColor colorForRouteType: kSEPTATypeNHSL];
            }
            else
                selectedBGColor = [UIColor colorForRouteType: kSEPTATypeTrolley];
            
            break;
            
        case kGTFSRouteTypeRail:
            selectedBGColor = [UIColor colorForRouteType: kSEPTATypeRail];
            break;
            
        case kGTFSRouteTypeSubway:
            
            if ( [_routeData.route_short_name isEqualToString:@"MFL"] )
            {
                selectedBGColor = [UIColor colorForRouteType: kSEPTATypeMFL];
            }
            else if ( [_routeData.route_short_name isEqualToString:@"BSL"] )
            {
                selectedBGColor = [UIColor colorForRouteType: kSEPTATypeBSL];
            }
            else
                selectedBGColor = [UIColor colorForRouteType: kSEPTATypeBus];

            break;
            
        default:
            selectedBGColor = [UIColor colorForRouteType: kSEPTATypeBus];
            break;
    }
    

    [self.imgTabbedLabel setBackgroundColor: selectedBGColor];
//    [self.lblTabbedLabel setText: @"Test - aAmMtT"];


    UIColor *textColor       = [UIColor whiteColor];
    
    UIButton *btnNow = [[UIButton alloc] init];
    [btnNow setBackgroundColor: backgroundColor];
    [btnNow.titleLabel setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f]];
    
    [btnNow setTitle:@"Now" forState:UIControlStateNormal];
    [btnNow setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btnNow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // TODO: Need UIColor to UIImage routine here
//    [btnNow setBackgroundImage: normalBGImage   forState:UIControlStateNormal];
//    [btnNow setBackgroundImage: selectedBGImage forState:UIControlStateSelected];

    
    UIButton *btnWeekday = [[UIButton alloc] init];
    [btnWeekday setTitle:@"Weekday" forState:UIControlStateNormal];
    [btnWeekday setBackgroundColor:  backgroundColor ];
    [btnWeekday.titleLabel setTextColor: textColor];
    [btnWeekday.titleLabel setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f]];

    [btnWeekday setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btnWeekday setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    
    
    UIButton *btnSat = [[UIButton alloc] init];
    [btnSat setTitle:@"Sat" forState:UIControlStateNormal];
    [btnSat setBackgroundColor: backgroundColor ];
    [btnSat.titleLabel setTextColor: textColor];
    [btnSat.titleLabel setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f]];

    [btnSat setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btnSat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    
    UIButton *btnSun = [[UIButton alloc] init];
    [btnSun setTitle:@"Sun" forState:UIControlStateNormal];
    [btnSun setBackgroundColor: backgroundColor ];
    [btnSun.titleLabel setTextColor: textColor];
    [btnSun.titleLabel setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f]];
    
    [btnSun setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btnSun setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        
    _tBtnTransit = [[TabbedButton alloc] initWithFrame:CGRectMake(0, 3, self.view.frame.size.width, 36)];
    [_tBtnTransit setOffset: CGPointMake(0, -4)];
    [_tBtnTransit setDelegate:self];
    
    // TODO: This could be consolidated, no need to list the number of tabs multiple times
    [_tBtnTransit setNumberOfTabs:4];
    CGFloat scaling[] = {0.2, 0.4, 0.2, 0.2};  // Needs to add up to 1.0
    [_tBtnTransit setTabsScale:scaling ofSize:4];
    
    [_tBtnTransit setButtons: [NSArray arrayWithObjects:
                               [NSArray arrayWithObject:btnNow],
                               [NSArray arrayWithObject:btnWeekday],
                               [NSArray arrayWithObject:btnSat],
                               [NSArray arrayWithObject: btnSun],
                               nil]];
    
    
    //    [_tBtnTransit setBackgroundColor:[UIColor darkGrayColor] forTab:0 forState:UIControlStateNormal];
//    UIColor *highColor = [UIColor colorForRouteType: [_routeData.route_type intValue] ];
    [_tBtnTransit setBackgroundColor:selectedBGColor  forTab: kItineraryFilterTypeNow forState:UIControlStateSelected];
    [_tBtnTransit setBackgroundColor:selectedBGColor  forTab: kItineraryFilterTypeNow forState:UIControlStateHighlighted];
    
    //    [_tBtnTransit setBackgroundColor:[UIColor blueColor]  forTab:1 forState:UIControlStateNormal];
    [_tBtnTransit setBackgroundColor:selectedBGColor forTab: kItineraryFilterTypeWeekday forState:UIControlStateSelected];
    [_tBtnTransit setBackgroundColor:selectedBGColor forTab: kItineraryFilterTypeWeekday forState:UIControlStateHighlighted];
    
    //    [_tBtnTransit setBackgroundColor:[UIColor orangeColor]  forTab:2 forState:UIControlStateNormal];
    [_tBtnTransit setBackgroundColor:selectedBGColor forTab: kItineraryFilterTypeSat forState:UIControlStateSelected];
    [_tBtnTransit setBackgroundColor:selectedBGColor forTab: kItineraryFilterTypeSat forState:UIControlStateHighlighted];

    [_tBtnTransit setBackgroundColor:selectedBGColor forTab: kItineraryFilterTypeSun forState:UIControlStateSelected];
    [_tBtnTransit setBackgroundColor:selectedBGColor forTab: kItineraryFilterTypeSun forState:UIControlStateHighlighted];

    
    [self.view addSubview: _tBtnTransit];
//    [self.view insertSubview:_tBtnTransit aboveSubview: backgroundImage];


    // Select which button should be initially selected
    [btnNow sendActionsForControlEvents:UIControlEventTouchUpInside];
    _currentFilter = kItineraryFilterTypeNow;
    
    NSLog(@"Stop here");

}


-(void) loadHeaderNamesWith: (ItineraryObject*) itin
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC loadHeaderNamesWith:");
#endif
    
//    if ( !([self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Trolley"] ) )
    if ( [self.travelMode isEqualToString:@"Rail"] )
        return;
    
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM bus_stop_directions WHERE Route='%@' ORDER BY dircode", itinerary.routeShortName];
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNFRTC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    [_nameForSection removeAllObjects];
    while ( [results next] )
    {
        NSString *header = [results stringForColumn:@"DirectionDescription"];
        [_nameForSection addObject:[NSString stringWithFormat:@"To %@", header] ];
        NSLog(@"IVC: loadHeaderNames: %@", header);
    }
    
}


-(DisplayedRouteData*) convertItineraryObjectToDisplayedRouteData
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC convertItineraryObjectToDisplayedRouteData");
#endif
    
    NSInteger dbType;
    
////    if ( [self.travelMode isEqualToString:@"Bus"] )
//    if ( [self.routeData database_type] == kDisplayedRouteDataUsingDBBus)
//    {
//        dbType = kDisplayedRouteDataUsingDBBus;
//    }
////    else if ( [self.travelMode isEqualToString:@"Rail"] )
//    else if ( [self.routeData database_type] == kDisplayedRouteDataUsingDBRail)
//    {
//        dbType = kDisplayedRouteDataUsingDBRail;
//    }
////    else if ( [self.travelMode isEqualToString:@"Trolley"] )
//    else if ( [self.routeData database_type] == kDisplayedRouteDataUsingTrolley)
//    {
//        dbType = kDisplayedRouteDataUsingTrolley;
//    }
////    else if ( [self.travelMode isEqualToString:@"MFL"] )
//    else if ( [self.routeData database_type] == kDisplayedRouteDataUsingMFL)
//    {
//        dbType = kDisplayedRouteDataUsingMFL;
//    }
////    else if ( [self.travelMode isEqualToString:@"BSL"] )
//    else if ( [self.routeData database_type] == kDisplayedRouteDataUsingBSS)
//    {
//        dbType = kDisplayedRouteDataUsingBSS;
//    }
////    else if ( [self.travelMode isEqualToString:@"NHSL"] )
//    else if ( [self.routeData database_type] == kDisplayedRouteDataUsingNHSL)
//    {
//        dbType = kDisplayedRouteDataUsingNHSL;
//    }
//    else
//        return nil;

    
    switch (_routeType)
    {
        case kSEPTATypeRail:
            dbType = kDisplayedRouteDataUsingDBRail;
            break;
        case kSEPTATypeTrolley:
            dbType = kDisplayedRouteDataUsingTrolley;
            break;
        case kSEPTATypeMFL:
            dbType = kDisplayedRouteDataUsingMFL;
            break;
        case kSEPTATypeBSL:
            dbType = kDisplayedRouteDataUsingBSS;
            break;
        case kSEPTATypeNHSL:
            dbType = kDisplayedRouteDataUsingNHSL;
            break;
        default:
            dbType = kDisplayedRouteDataUsingDBBus;
            break;

    }
    
    // dbType = self.routeData.database_type  // Can't use this because, for some reason, clicking on the BSO from the BSL selection has database_type set to 0
    
    DisplayedRouteData *routeData = [[DisplayedRouteData alloc] initWithDatabaseType:dbType];
    
    [routeData.current setRoute_id: itinerary.routeID];
    [routeData.current setRoute_short_name: itinerary.routeShortName];
    [routeData.current setRoute_type: _routeData.route_type ];
    
    [routeData.current setDatabase_type: dbType];
    
    [routeData.current setStart_stop_id: [itinerary.startStopID intValue] ];
    [routeData.current setStart_stop_name: itinerary.startStopName];
    
    [routeData.current setEnd_stop_id : [itinerary.endStopID intValue] ];
    [routeData.current setEnd_stop_name: itinerary.endStopName];
    
    [routeData.current setDirection_id: [itinerary.directionID intValue] ];
    
    return routeData;
    
}


- (void)didReceiveMemoryWarning
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC didReceiveMemoryWarning");
#endif
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    currentTripsArr = nil;
    masterTripsArr  = nil;
    itinerary = nil;
    
    //    _sqlQueue = nil;
    
}

- (void)viewDidUnload
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC viewDidUnload");
#endif
    
//    [self setBtnFavorite:nil];
    
//    [self setTableSequence:nil];
    
//    [self setMapView:nil];
    
//    [self setScrollView:nil];
    
//    [self setPageControl:nil];
//    [self setSegmentService:nil];
    
//    [self setViewTrips:nil];
//    [self setViewSequence:nil];
    
//    [self setLeftSwipe:nil];
//    [self setRigthSwipe:nil];
//    [self setDoubleTap:nil];
//    [self setSegmentService:nil];
//    
//    [self setSegmentMapFavorite:nil];

    [_alertsAPI setDelegate:nil];
    _alertsAPI = nil;
    
    [self setTableTrips:nil];
    [self setImgTabbedLabel:nil];
    
    [self setLblTabbedLabel:nil];
    [super viewDidUnload];
    
}


#pragma mark - Refresh Time in Cells
-(void) refreshCellsTime
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC refreshCellsTime");
#endif
    
    //    NSLog(@"IVC - refreshCellsTime");
    
    BOOL _removeTopMostCell = NO;
    // Only update the visibleCells from section 2!
    NSArray *rowPaths = [self.tableTrips indexPathsForVisibleRows];
    
    for (NSIndexPath *path in rowPaths)
    {
        
        if ( path.section == 2 )
        {
            // Only update visible Rows that are part of section 2
            TripCell *tripCell = (TripCell*)[self.tableTrips cellForRowAtIndexPath:path];
            
            if ( [tripCell use24HourTime] != _use24HourTime )
            {
                [tripCell setUse24HourTime:_use24HourTime];
                [tripCell updateTimeFormats];
            }
            
            [tripCell updateCell];
            
            // Post update processing
            
            // TODO: This needs to be put back
//            NSLog(@"FFS: timeBeforeArrival: %@", [[tripCell lblTimeBeforeArrival] text]);
            if ( ( [ [tripCell lblTimeBeforeArrival] text] == nil || [[ [tripCell lblTimeBeforeArrival] text] length] < 1 ) && ( _currentFilter == kItineraryFilterTypeNow ) )  // Only remove empty TimeBeforeArrival cells when "Now" has been selected
            {
                _removeTopMostCell = YES;
            }
            
        }  // if ( path.section != 2 )
        
    }  // for (NSIndexPath *path in rowPaths)
    
    if ( _removeTopMostCell )
        [self removeTopMostCell];
    
}  // -(void) refreshCellsTime


#pragma mark - Check Settings
-(void) updateTimeSettings
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC updateTimeSettings");
#endif
    
    // Get 24HourTime setting
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:24HourTime"];
    if ( object == nil )
    {
        _use24HourTime = NO;  // Defaults to NO.
    }
    else
    {
        if ( _use24HourTime != [object boolValue] )
        {
            // Update all visible cells
            _use24HourTime = [object boolValue];
            [self refreshCellsTime];
        }
            

    }
    
}


#pragma mark -
#pragma mark Load Data
-(void) loadTripsInTheBackground
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - loadTripsInTheBackground");
#endif
    
    
    [_jsonQueue cancelAllOperations];  // Since _jsonQueue depends on loadTrips, if we're about to reload loadTrips, all JSON operations needs to be cancelled
    [jsonRefreshTimer invalidate];
    
    _sqlOp = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = _sqlOp;
    [weakOp addExecutionBlock:^{
        
        [self loadTrips];  // Run just this in a thread
        
        if ( ![weakOp isCancelled] )
        {
            
            // --==  Main Queue Time  ==--
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [SVProgressHUD dismiss];     // Dismisses any active loading HUD
                
                if ( !( ([itinerary.startStopID intValue] == 0 && [itinerary.endStopID intValue] == 0) || itinerary.routeID == nil ) )
                {
                    
                    [self filterCurrentTrains];  // Updates currentTrainsArr and reloaded self.tableTrips
                    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];  // Forced update of To/From Header
                    
                    [self changeTitleBar];

                    [self createMasterJSONLookUpTable];  // Do I even use this anymore (why is this even here?)
                    
                    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Rail"] || [self.travelMode isEqualToString:@"Trolley"] )  // MFL, BSS and NHSL do not have realtime data
                        [self loadJSONDataIntheBackground];  // This should only be called once loadTrips has been loaded
                        
                }
                
            }];
            
        }
        else
        {
            NSLog(@"IVC - running SQL Query: _sqlOp cancelled");
        }
        
    }];
    
    
    if ( !( ([itinerary.startStopID intValue] == 0 && [itinerary.endStopID intValue] == 0) || itinerary.routeID == nil ) )
        [SVProgressHUD showWithStatus:@"Loading..."];
    
    [_sqlQueue addOperation: _sqlOp];
    
}


-(void) createMasterJSONLookUpTable
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC createMasterJSONLookUpTable");
#endif
    

    // This creates a simple LUT for every trips throughout the week that matches the Itinerary
    // _masterTrainLookUp stores a reference to the pointer of a trip
    //   E.g.  402 will have 3 entries - Mon-Fri, Sat, Sun
    
    if ( ![self.travelMode isEqualToString:@"Rail"] )
        return;
    
    NSLog(@"IVC - createMasterJSONLookUpTable");  // This table only needs to be run when masterTripsArr gets populated or repopulated
    
    // Load all TripObjects
    for (TripObject *trip in masterTripsArr )
    {
        NSString *tripKey = [NSString stringWithFormat:@"%d", [trip.trainNo intValue] ];
        
        if ( [_masterTrainLookUpDict objectForKey:tripKey] == nil )  // If tripKey does not exist, add it
        {
            NSMutableArray *newArr = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithNonretainedObject:trip], nil];
            [_masterTrainLookUpDict setObject:newArr forKey:tripKey];
        }
        else
        {
            
            // If the key already exists in _masterTrainLookUpDict, add the current trip to the array
            BOOL isFound = NO;
            for (NSValue *value in [_masterTrainLookUpDict objectForKey:tripKey] )
            {
                if ( [trip isEqual:[value nonretainedObjectValue] ] )
                {
                    isFound = YES;
                }
            }  // for (NSValue *value in [_masterTrainLookUpDict objectForKey:tripKey] )
            
            if ( !isFound )
            {
                NSMutableArray *storedArr = [_masterTrainLookUpDict objectForKey:tripKey];
                [storedArr addObject:[NSValue valueWithNonretainedObject:trip] ];
            }  // if ( !isFound )
            
        }  // else if ( [_masterTrainLookUpDict objectForKey:tripKey] == nil )
        
    } // for (TripObject *trip in masterTripsArr)
    NSLog(@"IVC - createMasterJSONLookUpTable (end)");
    
}


-(void) loadTrips
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC loadTrips");
#endif
    
    BOOL _forceLoad = 0;
    BOOL _firstTime = 1;
    
    if ( !_forceLoad )
    {
        // As long as _forceLoad is not true, check if startStopName and endStopName are nil.  If they're nil, don't load
        if ( ([itinerary.startStopID intValue] == 0 && [itinerary.endStopID intValue] == 0) || itinerary.routeID == nil )
        {
            return;  // If either is nil, there's nothing to do.
        }
        
    }
    
    
    [masterTripsArr removeAllObjects];
    [_masterTrainLookUpDict removeAllObjects];  // This will trigger _masterTrainLookUpDict to repopulate itself during the next JSON request
    
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    // loadTrips will now be broken up into two parts: when start stop is valid and when end stop is valid.
    // If neither are valid, nothing happens.  If one is valid, load just that data
    
    // --== Common Variables between the Parts  ==--
    NSString *queryStr;
    NSMutableDictionary *tripDict = [[NSMutableDictionary alloc] init];
    FMResultSet *results;
    NSDate *startTime = [NSDate date];

    
    //  --==  Part 1: Is start stop id valid?  ==--
    if ( [itinerary.startStopID intValue] != 0 )
    {
        
        NSLog(@"IVC - Starting at %@", startTime);
        
        queryStr = [NSString stringWithFormat:@"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_timesDB.trip_id trip_id FROM stop_timesDB JOIN tripsDB ON tripsDB.trip_id=stop_timesDB.trip_id WHERE tripsDB.trip_id IN (SELECT trip_id FROM tripsDB WHERE route_id=\"%@\" ) AND route_id=\"%@\" AND stop_id=%d ORDER BY arrival_time", itinerary.routeShortName, itinerary.routeShortName, [itinerary.startStopID intValue] ];
        
        if ( [self.travelMode isEqualToString:@"Rail"] )
            queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
        else if ( [self.travelMode isEqualToString:@"MFL"] )
            queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_MFL"];
        else
            queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
        
        NSLog(@"IVC - queryStr: %@", queryStr);
        results = [database executeQuery: queryStr];
        if ( [database hadError] )  // Check for errors
        {
            
            int errorCode = [database lastErrorCode];
            NSString *errorMsg = [database lastErrorMessage];
            
            NSLog(@"IVC - query failure, code: %d, %@", errorCode, errorMsg);
            NSLog(@"IVC - query str: %@", queryStr);
            
            return;  // If an error occurred, there's nothing else to do but exit
            
        } // if ( [database hadError] )
        
        
        
        while ( [results next] )
        {
            
            if ( [_sqlOp isCancelled] )  // If the operation has been cancelled, no need to continue reading from the database
                return;
            
            NSString *tripID       = [results stringForColumnIndex:6];
            
            if ( [tripDict objectForKey:tripID] == nil )
            {
                TripObject *trip = [[TripObject alloc] init];
                
                [trip setRouteName: [results stringForColumnIndex:0] ];
                
                [trip setTrainNo: [NSNumber numberWithInt: [results intForColumnIndex:1] ] ];
                [trip setStartSeq: [NSNumber numberWithInt: [results intForColumnIndex:2] ] ];
                
                //            [trip setStartTime: [results stringForColumnIndex:3] ];
                [trip setStartTime: [NSNumber numberWithInt: [results intForColumnIndex:3] ] ];
                
                [trip setDirectionID:[NSNumber numberWithInt:[results intForColumnIndex:4] ] ];
                [trip setServiceID: [NSNumber numberWithInt:[results intForColumnIndex:5] ] ];
                [trip setTripID: tripID];
                
                [tripDict setObject:trip forKey:tripID];
            }
            
        }  // while ( [results next] )
        
        NSTimeInterval diff = [ [NSDate date] timeIntervalSinceDate: startTime];
        NSLog(@"IVC - %6.3f seconds have passed.", diff);
        NSLog(@"IVC - Loaded and stored");
        
    }
    
    
    
    
    //    queryStr = @"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_times_rail.trip_id trip_id FROM stop_times_rail JOIN trips_rail ON trips_rail.trip_id=stop_times_rail.trip_id WHERE trips_rail.trip_id IN (SELECT trip_id FROM trips_rail WHERE route_id=\"WAR\" ) AND stop_id=90413 ORDER BY arrival_time";
    
//    queryStr = [NSString stringWithFormat:@"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_timesDB.trip_id trip_id FROM stop_timesDB JOIN tripsDB ON tripsDB.trip_id=stop_timesDB.trip_id WHERE tripsDB.trip_id IN (SELECT trip_id FROM tripsDB WHERE route_id=\"%@\" AND direction_id=%d ) AND stop_id=%d ORDER BY arrival_time", itinerary.routeID, _currentDisplayDirection, [itinerary.endStopID intValue] ];

    if ( [itinerary.endStopID intValue] != 0 )
    {

        if ( [self.travelMode isEqualToString:@"Rail"] )
        {
            queryStr = [NSString stringWithFormat:@"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_timesDB.trip_id trip_id FROM stop_timesDB JOIN tripsDB ON tripsDB.trip_id=stop_timesDB.trip_id WHERE tripsDB.trip_id IN (SELECT trip_id FROM tripsDB WHERE route_id=\"%@\" ) AND route_id=\"%@\" AND stop_id=%d ORDER BY arrival_time", itinerary.routeID, itinerary.routeID, [itinerary.endStopID intValue] ];
            
            queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
        }
        else if ( [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSL"] || [self.travelMode isEqualToString:@"NHSL"] )
        {
            queryStr = [NSString stringWithFormat:@"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_timesDB.trip_id trip_id FROM stop_timesDB JOIN tripsDB ON tripsDB.trip_id=stop_timesDB.trip_id WHERE tripsDB.trip_id IN (SELECT trip_id FROM tripsDB WHERE route_id=\"%@\" ) AND route_id=\"%@\" AND stop_id=%d ORDER BY arrival_time", itinerary.routeShortName, itinerary.routeShortName, [itinerary.endStopID intValue] ];
            
            queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:[NSString stringWithFormat:@"_%@", self.travelMode] ];
        }
        else
        {
            queryStr = [NSString stringWithFormat:@"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_timesDB.trip_id trip_id FROM stop_timesDB JOIN tripsDB ON tripsDB.trip_id=stop_timesDB.trip_id WHERE tripsDB.trip_id IN (SELECT trip_id FROM tripsDB WHERE route_id=\"%@\" AND direction_id=%d ) AND route_id=\"%@\" AND stop_id=%d ORDER BY arrival_time", itinerary.routeShortName, _currentDisplayDirection, itinerary.routeShortName, [itinerary.endStopID intValue] ];
            
            queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
        }
        
        
        
        NSLog(@"IVC - queryStr: %@", queryStr);
        results = [database executeQuery: queryStr];
        if ( [database hadError] )  // Check for errors
        {
            
            int errorCode = [database lastErrorCode];
            NSString *errorMsg = [database lastErrorMessage];
            
            NSLog(@"IVC - query failure, code: %d, %@", errorCode, errorMsg);
            NSLog(@"IVC - query str: %@", queryStr);
            
            return;  // If an error occurred, there's nothing else to do but exit
            
        } // if ( [database hadError] )
        
        
        // Process the first query
        //    int count = 0;
        BOOL flippedOnce = 0;
        while ( [results next] )
        {
            
            if ( [_sqlOp isCancelled] )
                return;
            
            NSString *tripID = [results stringForColumnIndex:6];
            
            if ( [tripDict objectForKey:tripID] != nil )
            {
                
                TripObject *trip = [tripDict objectForKey:tripID];
                [trip setDirectionID:[NSNumber numberWithInt:[results intForColumnIndex:4] ] ];
                
                int startSeq = [[trip startSeq] intValue];
                int endSeq   = [results intForColumnIndex:2];
                //            NSString *endRoute = [results stringForColumnIndex:0];
                
                if ( startSeq < endSeq )
                {
                    // Sequences are in the proper order, fill in the endSeq/Time and be done with it
                    [trip setEndSeq: [NSNumber numberWithInt: [results intForColumnIndex:2] ] ];
                    [trip setEndTime: [NSNumber numberWithInt: [results intForColumnIndex:3] ] ];
                    //                [trip setEndTime: [results stringForColumnIndex:3] ];
                    
                    
                    
                    // The first time we find a complete trip with the start and end sequence in the right
                    // order, we need to determine if this is To/From some point.  What that point is differs
                    // for different travel types.
                    
                    if ( _firstTime )
                    {
                        
                        if ( [self.travelMode isEqualToString:@"Rail"] )  // Determine Rail To/From points
                        {
                            // I don't know what this is supposed to do anymore
                        }
                        
                        _firstTime = 0;
                    }
                    _currentDisplayDirection = [trip.directionID intValue];
                    
                    
                    
                    
                }
                else
                {
                    //                // Sequences are not in the proper order, assign startSeq/Time to endSeq/Time then populate startSeq/Time
                    [trip setEndSeq: trip.startSeq];
                    [trip setEndTime:trip.startTime];
                    
                    [trip setStartSeq : [NSNumber numberWithInt: [results intForColumnIndex:2] ] ];
                    [trip setStartTime: [NSNumber numberWithInt: [results intForColumnIndex:3] ] ];
                    
                    
                    // Please explain the logic behind this, so when I change this, I know if I'm $@!%ing something up!
                    
                    // The problem here, is the user selected 19th Street as the start then 22nd Street as the end stop.
                    // Unfortunately, the default direction 0, goes in the opposite direction 22nd->19th street.
                    
                    if ( [self.travelMode isEqualToString:@"Trolley"] || [self.travelMode isEqualToString:@"Bus"] )
                    {
                        if ( !flippedOnce )
                        {
                            NSLog(@"IVC - flipped trips!");
                            flippedOnce = 1;
                            [itinerary flipStops];
                            //                        [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                    }
                    else if ( [self.travelMode isEqualToString:@"Rail"] )
                    {
                        // Do nothing
                    }
                    else
                    {
                        if ( [trip.directionID intValue] == 0 )
                            _currentDisplayDirection = 1;
                        else
                            _currentDisplayDirection = 0;
                    }
                    
                }
                
                
                //            if ( count++ < 10 )
                //                NSLog(@"%@", trip);
                
                
                [masterTripsArr addObject:trip];
                [tripDict removeObjectForKey:tripID];
                
            }
            
        }  // while ( [results next] )
        
        NSTimeInterval diff = [ [NSDate date] timeIntervalSinceDate: startTime];
        NSLog(@"IVC - %6.3f seconds have passed.", diff);
        
    }
    
    
//    for (NSString *tripKey in tripDict)
//    {
//        [masterTripsArr addObject: [tripDict objectForKey:tripKey] ];
//    }
    
//    [tripDict removeAllObjects];
    
    
}


-(void) changeTitleBar
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC:cTB - changeTitleBar");
#endif
    

    if ( [_nameForSection count] == 0 )
    {
        [self loadHeaderNamesWith:itinerary];
        
        if ( [_nameForSection count] == 0 && ![itinerary.endStopName isEqualToString:DEFAULT_END_MESSAGE] )
        {
            [self.lblTabbedLabel setText: [NSString stringWithFormat:@"To %@", itinerary.endStopName] ];
        }
        
        return;
        
    }
    
    if ( [_nameForSection count] > [itinerary.directionID intValue] )
        [self.lblTabbedLabel setText: [NSString stringWithFormat:@"%@", [_nameForSection objectAtIndex: [itinerary.directionID intValue] ] ] ];
    // else/otherwise no change
    
}



-(NSString*) filePath
{
#if FUNCTION_NAMES_ON
    NSLog(@"IVC filePath");
#endif
    
    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
}


-(void) filterActiveTrains
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC filterActiveTrains");
#endif
    
    //    NSPredicate *predicateFilter = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"(serviceID LIKE '%@') AND (directionID == %d)", _currentServiceID, _currentDisplayDirection] ];
    
    if ( [_masterJSONTrainArr count] == 0 )  // If it has no active vehiciles, nothing below will have any effect
        return;
    
    if ( [self getServiceIDFor:kItineraryFilterTypeNow] != _currentServiceID )
    {
        activeTrainsArr = nil;
        [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    NSPredicate *predicateFilter = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"(serviceID == %d) AND (directionID == %d)", _currentServiceID, _currentDisplayDirection] ];
    
    NSLog(@"IVC - filter active trains: %@", predicateFilter);
    activeTrainsArr = nil;
    activeTrainsArr = [[_masterJSONTrainArr filteredArrayUsingPredicate:predicateFilter] mutableCopy];
    
    [activeTrainsArr sortUsingComparator:^NSComparisonResult(ActiveTrainObject *at1, ActiveTrainObject *at2)
     {
         
         if ( [at1.trainNo intValue] > [at2.trainNo intValue] )
             return (NSComparisonResult)NSOrderedDescending;
         if ( [at1.trainNo intValue] < [at2.trainNo intValue] )
             return (NSComparisonResult)NSOrderedAscending;
         return (NSComparisonResult)NSOrderedSame;
         
     }];
    
    NSLog(@"activeTrains: %@", activeTrainsArr);
    
    // Now display that filtered data...
    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


-(void) filterCurrentTrains
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC filterCurrentTrains");
#endif
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSString *now = @"00:00";
    int now = 0;  // Always show times greater than 00:00 unless a new time has been added.
    
    if ( _currentFilter == kItineraryFilterTypeNow )
    {
        [dateFormatter setDateFormat:@"HHmm"];
        now = [[dateFormatter stringFromDate: [NSDate date] ] intValue];
    }
    else
    {
        now = 0;
    }
    
//    _currentDisplayDirection = 0;
//    NSNumber *displayDirection = [NSNumber numberWithInt:0];
    
    
    NSLog(@"IVC:fCT - %@", _servicePredicate);
    
//    NSPredicate *predicateFilter = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"(serviceID == %d)  AND (directionID == %d) AND (startTime > %d)", _currentServiceID, _currentDisplayDirection, now] ];

    NSPredicate *predicateFilter = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"%@  AND (directionID == %d) AND (startTime > %d)", _servicePredicate, _currentDisplayDirection, now] ];

    
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES];
    
    // Need a mutable copy of the filtered dataset
    
    currentTripsArr = [ [ [masterTripsArr filteredArrayUsingPredicate:predicateFilter] sortedArrayUsingDescriptors:[NSArray arrayWithObject:timeSort] ] mutableCopy];
    
    int sectionToLoad = 2;
    _message = nil;
    
    if ( ( [currentTripsArr count] == 0 ) && !( [itinerary.startStopName isEqualToString: DEFAULT_START_MESSAGE] || [itinerary.endStopName isEqualToString:DEFAULT_END_MESSAGE] ) )
    {
        // Now filter that data...
        _message = @"No remaining service for today";
        sectionToLoad = 3;
    }

    // Now filter that data...
    //[self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex: sectionToLoad] withRowAnimation:UITableViewRowAnimationAutomatic];  // This will cause a crash going from Now to Weekday
    [self.tableTrips reloadData];
   
    NSLog(@"%@", currentTripsArr);
    
    
    // User Preferences
//    if ( itinerary.routeID != nil && itinerary.startStopName != nil && itinerary.endStopName != nil )
//    {
    
        //        NSString *newKey = [NSString stringWithFormat:@"%@%@%@",itinerary.routeID,itinerary.startStopName,itinerary.endStopName];
        //        NSDictionary *saves = [[NSUserDefaults standardUserDefaults] objectForKey: @"CachedItinerary"];
        //
        //        if ( [saves objectForKey:newKey] )           // If Favorites exist in NSUserDefaults
        //        {
        //            NSData *cachedData = [saves objectForKey:newKey];  // Read the data
        //            NSArray *cachedArr = [NSKeyedUnarchiver unarchiveObjectWithData:cachedData];  // Convert data to array
        //            NSLog(@"cachedArr: %@", cachedArr);
        //        }
        
        
        // Save
        
        
        //        NSData *cachedData = [NSKeyedArchiver archivedDataWithRootObject: masterTripsArr];
        //        [saveDict setObject:cachedData forKey: newKey];
        //
        //        [[NSUserDefaults standardUserDefaults] setObject:saveDict forKey: @"CachedItinerary"];
        //        [[NSUserDefaults standardUserDefaults] synchronize];
        
//    }
    
    
    // Why, why, why are we changing the direciton!?  NO!  Bad Greg!  Bad!
    [itinerary setDirectionID: [NSNumber numberWithInt:_currentDisplayDirection] ];
    
    //    DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
    //    NSLog(@"RouteData: %@", routeData.current);
    
}

#pragma mark -
#pragma mark Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC prepareForSegue");
#endif
    
    return;
    
    if ( [[segue identifier] isEqualToString:@"StopTimesSegue"] || [[segue identifier] isEqualToString:@"StopTimesSegue"] )
    {
        
        NSLog(@"IVC - Seguing to %@", [segue identifier] );
        
        //        UINavigationController *navController = [segue destinationViewController];
        //        StopNamesForRouteTableController *snarfvc = (StopNamesForRouteTableController*)[navController topViewController];
        
        StopNamesForRouteTableController *snarfvc = [segue destinationViewController];
        
        if ( [[segue identifier] isEqualToString:@"StopTimesSegue"] )
        {
            [snarfvc setTitle:@"Select Start"];
        }
        else if ( [[segue identifier] isEqualToString:@"StopTimesSegue"] )
        {
            [snarfvc setTitle:@"Select End"];
        }
        
        
        [snarfvc setDelegate:self];
        _findLocationsSegue = YES;
        
        NSString *queryStr = [self returnQueryStringForTravelMode];
        NSLog(@"IVC - queryStr: %@", queryStr);
        
        //        [SVProgressHUD showWithStatus:@"Disabled due to 3 minute long query ;_;"];
        
        [snarfvc setQueryStr: queryStr ];
        [snarfvc setTravelMode: self.travelMode];
        [snarfvc setItinerary: itinerary];
        
        //        if ( [itinerary.startStopName isEqualToString: DEFAULT_MESSAGE] && [itinerary.endStopName isEqualToString:DEFAULT_MESSAGE] )
        if ( [itinerary.startStopID intValue] == 0 && [itinerary.endStopID intValue] == 0 )
        {
            // Stop names undefined, don't set direction
            [snarfvc setDirection:nil];
        }
        else
        {
            // One or both fields have something other then the DEFAULT_MESSAGE, pass it the current direction
            [snarfvc setDirection:[NSNumber numberWithInt:_currentDisplayDirection] ];
        }
        
        
    }
    else if ( [[segue identifier] isEqualToString:@"TripDetailsSegue"] )
    {
        
        TripDetailsTableController *tdtc = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self.tableTrips indexPathForSelectedRow];
        
        TripObject *thisTrip;
        ActiveTrainObject *activeTrain;
        
        NSString *tripID;
        
        switch (indexPath.section)
        {
            case 1:
                activeTrain = [activeTrainsArr objectAtIndex:indexPath.row];
                
                for (NSValue *object in [_masterTrainLookUpDict objectForKey: [NSString stringWithFormat:@"%d",[activeTrain.trainNo intValue] ] ])
                {
                    TripObject *trip = [object nonretainedObjectValue];
                    if ( activeTrain.tripID == trip.tripID )
                    {
                        thisTrip = trip;
                        break;
                    }
                }
                
                //                for (TripObject *trip in currentTripsArr)
                //                {
                //
                //                    if ( activeTrain.tripID == trip.tripID )
                //                    {
                //                        thisTrip = trip;
                //                        break;
                //                    }
                //
                //                }
                
                tripID = [activeTrain tripID];
                break;
                
            case 2:
                thisTrip = [currentTripsArr objectAtIndex:indexPath.row];
                tripID = [thisTrip tripID];
                break;
                
            default:
                thisTrip = nil;
                break;
        }
        
        [tdtc setTripID: tripID];
        [tdtc setTrip: thisTrip];
        [tdtc setTravelMode: self.travelMode];
        
    }
    else if ( [[segue identifier] isEqualToString:@"MapViewSegue"] )
    {
        
        MapViewController *mvc = [segue destinationViewController];
        
        [mvc setItinerary : itinerary];
        [mvc setTravelMode: self.travelMode];
        
    }
    
    
    
}


-(NSString*) returnQueryStringForTravelMode
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC returnQueryStringForTravelMode");
#endif
    
    NSString *queryStr;
    
    
    queryStr = [NSString stringWithFormat:@"SELECT stopsDB.stop_name, stopsDB.stop_id FROM tripsDB JOIN stop_timesDB ON tripsDB.trip_id=stop_timesDB.trip_id JOIN stopsDB ON stop_timesDB.stop_id=stopsDB.stop_id WHERE route_short_name=\"%@\" GROUP BY stopsDB.stop_id ORDER BY stopsDB.stop_name;", self.routeData.route_short_name];
    
    if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
    }
    else if ( [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSL"] || [self.travelMode isEqualToString:@"NHSL"] )
    {
        //        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_MFL"];
        queryStr = @"SELECT stops_bus.stop_name, stop_times_DB.stop_id FROM trips_DB JOIN stop_times_DB ON trips_DB.trip_id=stop_times_DB.trip_id NATURAL JOIN stops_bus GROUP BY stop_times_DB.stop_id ORDER BY stops_bus.stop_name;";
        
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString: self.travelMode];
    }
    else // If it's not rail, it's from the bus GTFS data
    {
        //        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
        
        // If both start and end stop names are set to the default message, do not filter by direction
        if ( [itinerary.startStopName isEqualToString:DEFAULT_START_MESSAGE] && [itinerary.endStopName isEqualToString: DEFAULT_END_MESSAGE] )
        {
            
//            queryStr = [NSString stringWithFormat:@"SELECT * FROM stopNameLookUpTable NATURAL JOIN stops_bus WHERE route_id=%@ ORDER BY stop_name", self.routeData.route_id];  // Was
            
            queryStr = [NSString stringWithFormat:@"SELECT * FROM stopNameLookUpTable NATURAL JOIN stops_bus WHERE route_short_name=%@ ORDER BY stop_name", self.routeData.route_short_name];
            
        }
        else
        {
            // Since either one or two of the stop names have been filled in, the direction is now known
//            queryStr = [NSString stringWithFormat:@"SELECT * FROM stopNameLookUpTable NATURAL JOIN stops_bus WHERE route_id=%@ AND direction_id=%d ORDER BY stop_name", self.routeData.route_id, _currentDisplayDirection];  // Was self.routeData.direction_id instead of _currentDisplayDirection
            
            queryStr = [NSString stringWithFormat:@"SELECT * FROM stopNameLookUpTable NATURAL JOIN stops_bus WHERE route_short_name=%@ AND direction_id=%d ORDER BY stop_name", self.routeData.route_short_name, _currentDisplayDirection];  // Was self.routeData.direction_id instead of _currentDisplayDirection

            
        }
        
    }
    
    
    return queryStr;
}


#pragma mark - UITableViewDataSource

//-(void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    
//    if (_menu.isOpen)
//    {
//        return [_menu close];
//    }
//    
//}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tV:willDisplayCell");
#endif
    
    [cell setBackgroundColor: [UIColor colorWithWhite:1.0f alpha:0.8f] ];
    return;
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_line.png"]];
//    [separator setAutoresizesSubviews:YES];
//    [separator setAutoresizingMask: (UIViewAutoresizingFlexibleWidth) ];
//    [separator setContentMode: UIViewContentModeScaleAspectFit];

    UITableViewCell *newCell = (UITableViewCell*)cell;
    
    [separator setFrame: CGRectOffset(separator.frame, 0, newCell.frame.size.height-separator.frame.size.height)];
    [newCell.contentView addSubview: separator];
    
}


// Allow editing of only the Itinerary Cell
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tV:commitEditingStyle");
#endif
    
    if ( editingStyle != UITableViewCellEditingStyleDelete )
        return;
    
    [itinerary clearStops];  // Clear out the stop information for itinerary
    
    [itinerary setStartStopName: DEFAULT_START_MESSAGE];  // Put the default messages back
    [itinerary setEndStopName  : DEFAULT_END_MESSAGE];
    
    [itinerary setStartStopID :[NSNumber numberWithInt:0] ];
    [itinerary setEndStopID   :[NSNumber numberWithInt:0] ];
    
    // Refresh just the affected section
    //    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // Cancel any pending operations
    [_jsonQueue cancelAllOperations];
    
    [currentTripsArr removeAllObjects];
    [masterTripsArr removeAllObjects];
    
    // Remove all JSON (Active Trains) now
    [activeTrainsArr removeAllObjects];
    [_masterJSONTrainArr removeAllObjects];
    [_masterTrainLookUpDict removeAllObjects];
    
    [self.tableTrips reloadData];
    
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tv:caneditRowAtIndexPath");
#endif
    
    // Return NO if you do not want the specified item to be editable.
    //    NSInteger section = indexPath.section;
    
    if ( indexPath.section == 0 )
        return YES;
    else
        return NO;
}



-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tV:accessoryButtonTappedForRowWithIndexPath");
#endif
    
    NSLog(@"IVC - accessoryButtonTappedForSection/Row: %d/%d", indexPath.section, indexPath.row);
}


- (void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

#if FUNCTION_NAMES_ON
    NSLog(@"IVC tv:didSelectRowAtIndexPath");
#endif
    return;
    
    if ( ( indexPath.section == 1 ) || ( indexPath.section == 2 ) )
    {
        NSLog(@"IVC - section 1, row %d selected", indexPath.row);
        [self performSegueWithIdentifier:@"TripDetailsSegue" sender:self];
    }
    
    //    if ( indexPath.section == 2 )
    //    {
    //        TripObject *trip = [currentTripsArr objectAtIndex:indexPath.row];
    ////        NSLog(@"IVC - selected %d.%d : %@", indexPath.section, indexPath.row, trip);
    //    }
    
}

-(void) disclaimerButtonPressed: (id) sender
{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableTrips];
    NSIndexPath *indexPath = [self.tableTrips indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        [self loadDisclaimer];
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tV:cellForRowAtIndexPath");
#endif
    
    static NSString *tripStr      = @"TripCell";
    static NSString *ntaItineraryStr = @"NextToArriveItineraryCell";
    
    id cell;
    
    
    if ( ( indexPath.section == 0 ) )
    {
        
        cell = (NextToArriveItineraryCell*)[self.tableTrips dequeueReusableCellWithIdentifier: ntaItineraryStr];
        
        [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
        [cell setDelegate:self];

        [[cell btnStartDestination] setTitle: itinerary.startStopName forState:UIControlStateNormal];
        [[cell btnEndDestination]   setTitle: itinerary.endStopName   forState:UIControlStateNormal];
        
        float x = 4.0;
        float y = 4.0;
        
        NextToArriveItineraryCell *nCell = (NextToArriveItineraryCell*)cell;
        CGRect bound = nCell.bounds;
        bound.size.width = self.view.frame.size.width - 5;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bound
                                                       byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight
                                                             cornerRadii: CGSizeMake(x, y)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = bound;
        maskLayer.path= maskPath.CGPath;
        
        nCell.layer.mask = maskLayer;
        
    }
    else if ( indexPath.section == 1 )
    {
        
        cell = (ActiveTrainCell*)[self.tableTrips dequeueReusableCellWithIdentifier:@"ActiveTrainCell"];
        if ( cell == nil )
        {
            cell = [self.tableTrips dequeueReusableCellWithIdentifier:@"ActiveTrainCell" forIndexPath:indexPath];
        }
        
        ActiveTrainObject *atObject = [activeTrainsArr objectAtIndex: indexPath.row];
        [[cell lblTrainNo]    setText: [NSString stringWithFormat:@"%d", [atObject.trainNo intValue] ] ];
        
        NSLog(@"_inDarkTerritory: %d, %d/%d", _inDarkTerritory, indexPath.section, indexPath.row);
        
        if ( _inDarkTerritory )
        {
            [[cell btnDisclaimer] addTarget:self action:@selector(disclaimerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [[cell btnDisclaimer] setHidden:NO];
        }
        else
        {
            [[cell btnDisclaimer] addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
            [[cell btnDisclaimer] setHidden:YES];
        }
        
        int delay = [atObject.trainDelay intValue];
        //        NSLog(@"IVC - ActiveTrain delay: %d", delay);
        if ( delay == 0 )
        {
            [[cell lblTrainDelay] setTextColor:[UIColor colorWithRed:29.0f/255.0f green:138.0f/255.0f blue:36.0f/255.0f alpha:1.0f] ];
            [[cell lblTrainDelay] setText: @"On time" ];
        }
        else
        {
            [[cell lblTrainDelay] setTextColor:[UIColor colorWithRed:179.0f/255.0f green:14.0f/255.0f blue:14.0f/255.0f alpha:1.0f] ];
            [[cell lblTrainDelay] setText: [NSString stringWithFormat:@"%d mins", delay] ];
        }
        
        [[cell lblNextStop] setText: atObject.nextStop];
        [[cell lblDestination] setText: atObject.destination];
        
        
        ActiveTrainCell *atCell = (ActiveTrainCell*)cell;
        UIRectCorner corner = 0;
        
        if ( indexPath.row == 0 )
        {
            corner |= UIRectCornerTopRight;
        }
        
        if ( indexPath.row == ([activeTrainsArr count] - 1) )
        {
            corner |= UIRectCornerBottomRight;
        }
        
//        if ( corner == 0 )
//        {
//            atCell.layer.mask = nil;
//        }
//        else
//        {
            float x = 4.0;
            float y = 4.0;
            CGRect bound = atCell.bounds;
            bound.size.width = self.view.frame.size.width - 5;
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bound
                                                           byRoundingCorners: corner
                                                                 cornerRadii: CGSizeMake(x, y)];
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.frame = bound;
            maskLayer.path= maskPath.CGPath;
            
            atCell.layer.mask = maskLayer;
//        }

        return cell;
        
    }
    else if (indexPath.section == 2 )
    {
        
        TripCell *tCell = (TripCell*)[self.tableTrips dequeueReusableCellWithIdentifier: tripStr];
        
        TripObject *thisTrip = [currentTripsArr objectAtIndex:indexPath.row];
        
//        if ( [thisTrip.serviceID intValue] == 4 )
//        if ( 0 )
//        {
//            NSLog(@"Holy shit, McGee!");
//        }
        
        [[tCell lblTrainNo] setText: [NSString stringWithFormat:@"%d", [thisTrip.trainNo intValue] ] ];

        [[tCell lblNextDay] setHidden:YES];
        
        [tCell setUse24HourTime: _use24HourTime];
        [tCell setDisplayCountdown:YES];
        
//        [cell addArrivalTimeStr: thisTrip.startTime];
//        [cell addDepartureTimeStr: thisTrip.endTime];

        [tCell addArrivalTime: [thisTrip.startTime intValue] ];
        [tCell addDepartureTime: [thisTrip.endTime intValue] ];
        
        [tCell updateCell];
     

        
        // TODO: Note, if the first and last cell are the same, only the top corner will be rounded
        UIRectCorner corner = 0;
        
        if ( indexPath.row == 0 )
        {
            corner |= UIRectCornerTopRight;
        }
        
        if ( indexPath.row == [currentTripsArr count] - 1 )
        {
            corner |= UIRectCornerBottomRight;
        }

        CGRect bound = tCell.bounds;
        bound.size.width = self.view.frame.size.width - 5;

//        if ( corner == 0 )
//        {
//            tCell.layer.mask = nil;
//        }
//        else
//        {
            float x = 4.0;
            float y = 4.0;
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bound
                                                           byRoundingCorners: corner
                                                                 cornerRadii: CGSizeMake(x, y)];
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.frame = bound;
            maskLayer.path= maskPath.CGPath;
            
            tCell.layer.mask = maskLayer;
//        }
        
        cell = tCell;
        
    }
    else if ( indexPath.section == 3 )
    {
        
        cell = [self.tableTrips dequeueReusableCellWithIdentifier:@"Message"];
        
        if ( cell == nil )
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Message"];
        
        [[cell textLabel] setText: _message];
        [[cell textLabel] setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f] ];
        
        [cell setBackgroundColor:[UIColor clearColor] ];
        
    }
    
    
    return cell;
    
}


-(id) roundCell:(UITableViewCell*) cell withIndexPath:(NSIndexPath*) indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC roundCell:withIndexPath");
#endif
    
    UITableViewCell *tCell = (UITableViewCell*)cell;
    UIRectCorner corner = 0;
    
    if ( indexPath.row == 0 )
    {
        corner |= UIRectCornerTopRight;
    }
    
    if ( indexPath.row == [currentTripsArr count] - 1 )
    {
        corner |= UIRectCornerBottomRight;
    }
    
    if ( corner == 0 )
    {
        tCell.layer.mask = nil;
    }
    else
    {
        float x = 4.0;
        float y = 4.0;
        CGRect bound = tCell.bounds;
//        bound.size.width = self.view.frame.size.width - 5;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bound
                                                       byRoundingCorners: corner
                                                             cornerRadii: CGSizeMake(x, y)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = bound;
        maskLayer.path= maskPath.CGPath;
        
        tCell.layer.mask = maskLayer;
    }

    return tCell;
    
}


//-(void) removeCellAtIndexPath: (NSTimer*) theTimer
-(void) removeTopMostCell
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC removeTopMostCell");
#endif
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    NSLog(@"IVC - removing cell at %d/%d", indexPath.section, indexPath.row);
    [currentTripsArr removeObjectAtIndex: [indexPath row] ];
    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex: [indexPath section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    //    [cellRemoverTimer invalidate];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tV:numberOfRowsInSection");
#endif
    
    switch (section)
    {
        case 0:  // First section only has one row
            return 1;
            break;
        case 1:  // Second section is for active trains
            return [activeTrainsArr count];
            break;
        case 2:  // Third section is for all trips based on the selected criteria
            return [currentTripsArr count];
            break;
        case 3:
            if ( _message == nil )
                return 0;
            else
                return 1;
        default:
            return 0;
            break;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC numberOfSectionsInTableView");
#endif
    
    if ( tableView == self.tableTrips )
    {
        if ( _message == nil )
            return 3;  // This stays hardcoded.  It should never change unless a major redesign is happening
        else
            return 4;
    }
//    else if ( tableView == self.tableSequence )
//    {
//        return 0;
//    }
    else
        return 0;
    
}

//-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return nil;
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tv:heightForRowAtIndexPath");
#endif
    
    switch (indexPath.section)
    {
        case 0:
            return 62.0f;
            break;
//        case 3:
//            if ( _message == nil )
//                return 0.0f;
        default:
            return 44.0f;
            break;
    }
    
}



#pragma mark - UITableView Footer
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

#if FUNCTION_NAMES_ON
    NSLog(@"IVC tV:heightForFooterInSection");
#endif
    
    switch (section)
    {
        case 0:
            return 5.0f;  // Section 0 will always be visible
            break;
        case 1:
            if ( [activeTrainsArr count] == 0 )
                return 0.0f;
            break;
        case 2:
            if ( [currentTripsArr count] == 0 )
                return 0.0f;
            break;
//        case 3:
//            if ( _message != nil )
//                return 10.0f;
        default:
            break;
    }
    
    return 5.0f;
    
}


-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tV:viewForFooterInSection");
#endif
    
    switch (section)
    {
        case 0:
            break;
        case 1:
            if ( [activeTrainsArr count] == 0 )
                return nil;
            break;
        case 2:
            if ( [currentTripsArr count] == 0 )
                return nil;
            break;
        default:
            break;
    }
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0f)];
    [footer setBackgroundColor: [UIColor clearColor] ];
    
    return footer;
    
}

#pragma mark - UITableView Header
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tV:heightForHeaderInSection");
#endif
 
    switch (section)
    {
        case 0:
            return 0.0f;
            break;
        case 1:
            if ( [activeTrainsArr count] > 0 )
                return 22.0f;
            break;
        case 2:
            if ( [currentTripsArr count] > 0 )
                return 22.0f;
            break;
        case 3:
            if ( _message == nil )
                return 22.0f;
        default:
//            return 0.0f;
            break;
    }
    
    return 0.0f;
    
}


-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC tV:viewForHeaderInSection");
#endif
    
    // Section 0 - Itinerary Cell
    // Section 1 - In Service Trains
    // Section 2 - Trips

//    [headerLabel setFrame:CGRectMake(0, 0, self.view.frame.size.width - 5, 22)];

    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(6, 0, self.view.frame.size.width - 5, 22)];
    [headerLabel setFont:    [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f] ];
    [headerLabel setTextColor: [UIColor whiteColor] ];
    [headerLabel setBackgroundColor: [UIColor clearColor] ];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height -5, 22)];
    
    switch (section)
    {
            
        case 0:  // Color bar is header, don't need another one
        {
            return nil;
            break;
        }
            
        case 1:
        {
    
            if ( [activeTrainsArr count] > 0 )
            {
                [headerLabel setText: @"IN SERVICE TRAINS"];
                [headerView setBackgroundColor: [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:74.0f/255.0f alpha:0.6f]];
//                [headerLabel2 setBackgroundColor: [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:74.0f/255.0f alpha:0.6f]];
            }
            else
                return nil;
    
        }
            break;
            
        case 2:
        {

            NSString *title;
            if ( [currentTripsArr count] == 0 )
            {
                return nil;
            }
            else
            {

                switch ( _currentFilter )
                {
                    case kItineraryFilterTypeNow:
                        title = @"REMAINING TRIPS FOR TODAY";
                        break;
                    case kItineraryFilterTypeWeekday:
                        title = @"WEEKDAY";
                        break;
                    case kItineraryFilterTypeSat:
                        title = @"SATURDAY";
                        break;
                    case kItineraryFilterTypeSun:
                        title = @"SUNDAY";
                        break;
                    default:
                        title = @"Trips";
                        break;
                }
                
            }
            
            [headerLabel setText: title];
            [headerView setBackgroundColor: [UIColor colorWithRed:240.0f/255.0f green:78.0f/255.0f blue:67.0f/255.0f alpha:0.6f]];
//            headerLabel.layer.cornerRadius = 5;
            
        }
            break;
            
            default:
            return nil;
            break;
            
    }  // switch (section)
    
    
    [headerView addSubview: headerLabel];
    
    float x = 4.0;
    float y = 4.0;
    CGRect bound = CGRectMake(0, 0, self.view.frame.size.width - 5, 22);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bound
                                                   byRoundingCorners: UIRectCornerBottomRight | UIRectCornerTopRight
                                                         cornerRadii: CGSizeMake(x, y)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bound;
    maskLayer.path= maskPath.CGPath;
    
    headerView.layer.mask = maskLayer;

    return headerView;
    
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    
//    return nil;
//    switch (section)
//    {
//            
//        case 0:
//        {
//            
//            NSString *toFrom = @"From";
//            if ( _currentDisplayDirection == 0 )
//            {
//                toFrom = @"To";
//            }
//            
//            //            // This is an annoyance.  Stupid change happens to the Rails portion of the GTFS changing the short name to the long name
//            //            // For Buses, the route_id is just a 5 digit number that changes every GTFS update.  Whereas the short name is the actual
//            //            // bus number.  For Rail, the id is the three digit abbreviation of that route (the same as the short name) but now it's
//            //            // the full route name, e.g. Lansdale/Doylestown Line.  Joy.  >.>   <.<
//            
//            if ( [self.travelMode isEqualToString:@"Rail"] )
//                return [NSString stringWithFormat:@"%@ %@", _headerDirection, itinerary.routeID];
//            //                return _headerDirection;
//            else
//            {
//                
//                if ( _currentDisplayDirection >= [_nameForSection count] )
//                    return [NSString stringWithFormat:@"%@ %@", toFrom, itinerary.routeShortName];
//                else
//                    return [_nameForSection objectAtIndex:_currentDisplayDirection];
//            }
//            
//        }  // case 0:
//            
//            break;
//        case 1:
//            if ( [activeTrainsArr count] == 0 )
//            {
//                return nil;
//            }
//            else
//            {
//                return @"IN SERVICE TRAINS";
//            }
//            break;
//        case 2:
//            if ( [currentTripsArr count] == 0 )
//            {
//                return nil;
//            }
//            else
//            {
//
//                switch ( _currentFilter ) {
//                    case kItineraryFilterTypeNow:
//                        return @"REMAINING TRIPS FOR TODAY";
//                        break;
//                    case kItineraryFilterTypeWeekday:
//                        return @"WEEKDAY";
//                        break;
//                    case kItineraryFilterTypeSat:
//                        return @"SATURDAY";
//                        break;
//                    case kItineraryFilterTypeSun:
//                        return @"SUNDAY";
//                        break;
//                    default:
//                        return @"Trips";
//                        break;
//                }
//
//                return nil;
//                
//            }
//            break;
//            
//        default:
//            return nil;
//            break;
//    }  // switch
//    
//}



#pragma mark - ItineraryCellProtocol

-(void) switchDirectionButtonTapped
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC switchDirectionButtonTapped (doesn't do anything)");
#endif
    
//    NSLog(@"IVC - switch to/from direction");
    //    if ( [itinerary.directionID  intValue] == 0 )
    //        [itinerary setDirectionID:[NSNumber numberWithInt:1] ];
    //    else
    //        [itinerary setDirectionID:[NSNumber numberWithInt:0] ];
    //
    //    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


-(void) flipStopNamesButtonTapped
{

#if FUNCTION_NAMES_ON
    NSLog(@"IVC - flip start and end stop names");
#endif

    
    [SVProgressHUD setStatus:@"Loading"];
    
    /*
     * --======
     * --==  BUS ONLY:  NO TRAINS ALLOWED!  ==--
     * --=======
     */
    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Trolley"] )
    {
        
        // For Buses, in order to ensure two flips in a row get us back to the original stop(1)
        // itinerary was modified to hold not only the current stop but the closest stop in the
        // opposite direction.  Thus, when a stop flip is triggered, all that needs to be done
        // is toggle the reverse BOOL and then flip the stops.
        [itinerary setReverse: !itinerary.isReverse];
        [itinerary flipStops];
        
        //        [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // (1) In case you don't realize why two flips might not get use back to the original stop: in
        // order to flip stops for Buses, we need to find the closest stop on the opposite side of the
        // road.  Sometimes, that'll be the opposite corner at the same intersection.  But sometimes,
        // like when a stop is on a one-way street, that closest stop in the opposite direction could
        // be farther away.
        
        // But that covers up to the first flip.  When the second flip occurs, a lookup of the closest
        // stop in the opposite direction is not guaranteed to return us back to the original stop.
        // Because of this very real possibility, itinerary needs to hold both the original stop and the
        // reverse lookup and cycle between each when a flip is triggered.
        
        // Only when a new stop is selected will a new reverse stop need to be found.
        
        
    }  // if ( [self.travelMode isEqualToString:@"Bus"] )
    else // For Rail, Trolley, MFL, BSS and NHSL flipping the stop name will work as advertised
    {
        [itinerary flipStops];
    }
    
    
    
    // Switch To and From text in the Header
    if ( [_headerDirection isEqualToString:@"To"] )
    {
        _headerDirection = @"From";
    }
    else
    {
        _headerDirection = @"To";
    }
    
    // Switch we're flipping, switch directions as well
    if ( _currentDisplayDirection == 0 )
    {
        _currentDisplayDirection = 1;
    }
    else if ( _currentDisplayDirection == 1 )
    {
        _currentDisplayDirection = 0;
    }
    
    [itinerary setDirectionID:[NSNumber numberWithInt: _currentDisplayDirection] ];
    
    [self changeTitleBar];
    
    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Trolley"] )
    {
        // Because we're not just swapping start and end stop ids like we are with rails, every flip with bus needs
        // a new reload.  The smart way is handle this is to cache them the first time they're loaded to avoid
        // incurring the large overhead of accessing the database
        [self loadTripsInTheBackground];  // SVProgressHUD dismiss is built in
    }
    else
    {
        [self filterCurrentTrains]; // Filters and reloads section;  Do this for everything that is not-bus
        [self filterActiveTrains];  // Filters and reloads section
        
        // Reload the top section
        [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [SVProgressHUD dismiss];
    }
    
    
    NSLog(@"IVC - Flipped (Itinerary): %@", itinerary);
    
    
    DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
    // Check if flipped stop names are a favorite location
    //    NSLog(@"RouteData: %@", routeData.current);
    if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
        [self setFavoriteHighlight:YES];
    else
        [self setFavoriteHighlight:NO];
    
    
//    [self.lblTabbedLabel setText: [NSString stringWithFormat:@"To %@", itinerary.endStopName] ];
    
    if ( itinerary.startStopName == NULL )
    {
        NSLog(@"We have a fucking problem!");
    }
    
    
}


-(void) getStopNamesButtonTapped:(NSInteger) startEND  // start = 1, END = 0
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - getStopNamesButtonTapped:%d",startEND);
#endif

    
    // Stop JSON reloading and cancel any pending/ongoing Operations
    [_jsonQueue cancelAllOperations];
    [jsonRefreshTimer invalidate];
    

    StopNamesTableViewControllerSelectionType selType;
    
    
    if ( startEND )
    {
        selType = kNextToArriveSelectionTypeStart;
        _startENDButtonPressed = 1;
    }
    else
    {
        selType = kNextToArriveSelectionTypeEnd;
        _startENDButtonPressed = 0;
    }
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StopNamesStoryboard" bundle:nil];
    StopNamesTableViewController *sntvc = (StopNamesTableViewController*)[storyboard instantiateInitialViewController];
    
    
    [sntvc setStopData: _routeData];
    [sntvc setSelectionType: selType];
    [sntvc setDelegate: self];
    
    
//    if ( startEND )
//    {
//        NSLog(@"IVC - load start stop names");
//        _startENDButtonPressed = 1;
//        [self performSegueWithIdentifier:@"StopTimesSegue" sender:self];
//    }
//    else
//    {
//        NSLog(@"IVC - load end stop names");
//        _startENDButtonPressed = 0;
//        [self performSegueWithIdentifier:@"StopTimesSegue" sender:self];
//    }
    
    [self.navigationController pushViewController:sntvc animated:YES];
    
    
}


#pragma mark - StopNameTableViewControllerProtocol
-(void) buttonPressed:(StopNamesTableViewControllerButtonPressed) buttonType withData:(StopNamesObject*) stopData
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: buttonPressed - stopData: %@, buttonType: %d", stopData, buttonType);
#endif

    
    switch (buttonType & kNextToArriveButtonMask)
    {
        case kNextToArriveButtonTypeDone:
        case kNextToArriveButtonTypeDoubleTap:
        case kNextToArriveButtonTypeLongPress:
        
        
            // TODO: Consider the case when the end stop is entered first, followed by the start stop
            // Code is setup only to reverse the last stop.  Should make it universal.

        
            if ( _currentDisplayDirection == -1 )
            {
                _currentDisplayDirection = [stopData.direction_id intValue];  // If the default value is still loaded, assign it the current selected direction
                [itinerary setDirectionID: stopData.direction_id];
            }
        
        
            if ( buttonType & kNextToArriveButtonTypeStartField )
            {
                
                // First stop selection the direction_id's will always match; Second stop selection they might not
                if ( [itinerary.directionID intValue] != [stopData.direction_id intValue] && ( ![itinerary.endStopName isEqualToString:DEFAULT_END_MESSAGE] ) )
                {
                    // The user selected a stop for a bus going in the opposite direction of their initial selection
                    
                    StopNamesObject *sObject = [self reverseStopLookUpForStopID: [stopData.stop_id intValue] ];
                    
                    if ( sObject == nil )
                    sObject = stopData;  // This is horrible!  It fixes a special case (FTC to Logan (in the other direction) but might break more things!

                    [itinerary setEndStopID   : sObject.stop_id];
                    [itinerary setEndStopName : sObject.stop_name];
                    
                }
                else
                {
                
                    [itinerary setStartStopID  : stopData.stop_id  ];
                    [itinerary setStartStopName: stopData.stop_name];
                    [itinerary setDirectionID  : stopData.direction_id];
                    _currentDisplayDirection = [stopData.direction_id intValue];
                }
                
                [self reverseStopLookUpForStart:YES];  // Now that the start name has changed, we need to find its reverse lookup (Bus ONLY)
                
            }
            else if ( buttonType & kNextToArriveButtonTypeEndField )
            {
                
                if ( [itinerary.directionID intValue] != [stopData.direction_id intValue] && ( ![itinerary.startStopName isEqualToString:DEFAULT_START_MESSAGE] ) )
                {
                    // The user selected a stop for a bus going in the opposite direction of their initial selection
                    
                    StopNamesObject *sObject = [self reverseStopLookUpForStopID: [stopData.stop_id intValue] ];

                    if ( sObject == nil )
                        sObject = stopData;  // This is horrible!  It fixes a special case (FTC to Logan (in the other direction) but might break more things!
                    
                    [itinerary setEndStopID   : sObject.stop_id];
                    [itinerary setEndStopName : sObject.stop_name];

                }
                else
                {
                    [itinerary setEndStopID  : stopData.stop_id  ];
                    [itinerary setEndStopName: stopData.stop_name];
                    [itinerary setDirectionID: stopData.direction_id];
                    _currentDisplayDirection = [stopData.direction_id intValue];
                }
                
                [self reverseStopLookUpForStart:NO];  // Now that the end name has changed, we need to find its reverse lookup (Bus ONLY)
                
                [self.lblTabbedLabel setText: [NSString stringWithFormat:@"To %@", itinerary.endStopName] ];
            }
            
            [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        case kNextToArriveButtonTypeCancel:
            break;
            
            
        default:
            break;
    }
    
    
    [self checkIfInDarkTerritory];
    
    
    if ( ( itinerary.startStopID != nil ) && ( itinerary.endStopID !=  nil ) )
    {
        [self loadTripsInTheBackground];
        //        [self filterCurrentTrains];
    }
    else
    {
        [SVProgressHUD dismiss];
    }
    
    
    // We don't get the reverse data here
    
    
    _startENDButtonPressed = 0;
    
    
//    if ( _currentDisplayDirection != [directionID intValue] )
//    {
//        _currentDisplayDirection = [directionID intValue];
//        //        [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
    
    
    // If the Start Stop was just selected and the End Stop is still blank, reload the popup window for the end stops
    //    if ( ( itinerary.startStopID != nil ) && ( [itinerary.endStopID intValue] == 0 ) )
    //    {
    //        [self performSegueWithIdentifier:@"EndStopTimesSegue" sender:nil];
    //    }
    
    
    if ( itinerary.startStopName == NULL )
    {
        NSLog(@"We have a problem!");
    }
    
    // Reload just the first section, with it's one giant cell.
//    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}


-(void) checkIfInDarkTerritory
{
    
    // All the stop ids from Thorndale to Overbrook, Newark to Darby and Trenton to North Philadelphia
    NSString *darkTerritoryStopIDs = @"90501,90502,90503,90504,90505,90506,90507,90508,90509,90510,90511,90512,90513,90514,90515,90516,90517,90518,90519,90520,90521,90522,90201,90202,90203,90204,90205,90206,90207,90209,90210,90211,90212,90213,90214,90215,90216,90217,90701,90702,90703,90704,90706,90707,90708,90709,90710,90711";
    
    NSArray *darkTerritoryStopIDArray = [darkTerritoryStopIDs componentsSeparatedByString:@","];
    
    
    NSString *startID;
    NSString *endID;
    
    @try
    {
        startID = [itinerary.startStopID stringValue];
        endID   = [itinerary.endStopID stringValue];
    }
    @catch (NSException *e)
    {
        NSLog(@"Exception: %@", e);
        startID = @"NA";
        endID = @"NA";
    }
    @finally
    {
        // Cleanup code; executes whether or not an exception was found
    }
    
    
    if ( [darkTerritoryStopIDArray containsObject: startID ] || [darkTerritoryStopIDArray containsObject: endID ] )
        _inDarkTerritory = YES;
    else
        _inDarkTerritory = NO;
    
}

#pragma mark - StopNamesForRoute Protocol
-(void) doneButtonPressed:(StopNamesForRouteTableController *)view WithStopName:(NSString *)selectedStopName andStopID:(NSInteger)selectedStopID withDirectionID:(NSNumber*)directionID
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: doneButtonPressed:WithStopName:%@ andStopID:%d withDirectionID:%d", selectedStopName, selectedStopID, [directionID intValue]);
#endif

    
    
    // StopNamesForRoutesVC triggers this when the Done button is pressed
    
    
    
    
    // Which stop name and stop id should this be assigned to?  Start or End?
    if ( _startENDButtonPressed )  // The start button was pressed!  Great job!
    {
        //        [itinerary setReverse:NO];  //  Explicitly ensure the current object gets updated; 5/16/13 not needed anymore
        
        itinerary.startStopName = selectedStopName;
        itinerary.startStopID   = [NSNumber numberWithInt:selectedStopID];
        [self reverseStopLookUpForStart:YES];  // Now that the start name has changed, we need to find its reverse lookup (Bus ONLY)
    }
    else  // Oh, so you pressed the end button.  How... quaint.
    {
        //        [itinerary setReverse:NO]; // Explicitly ensure the current object gets updated; 5/16/13 not needed anymore
        itinerary.endStopName = selectedStopName;
        itinerary.endStopID   = [NSNumber numberWithInt:selectedStopID];
        [self reverseStopLookUpForStart:NO];  // Now that the end name has changed, we need to find its reverse lookup (Bus ONLY)
    }
    
    
    // Ensure that the VC only gets dismissed once.  (I.e. When the user taps Done repeatedly if the app ever runs sluggishly.)
    if ( [[self modalViewController] isBeingDismissed] )
    {
        return;  // VC is being dismissed, ignore additionally requests
    }
    else
    {
        if ( [itinerary.startStopID intValue] != 0 && [itinerary.endStopID intValue] == 0 )
        {
            [view setTitle:@"Now Select End"];
        }
        else
        {
            //[view dismissModalViewControllerAnimated:YES];  // VC has not been dismissed yet; this is the initial press
            [view.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
    _startENDButtonPressed = 0;  // This variable should be cleared until it's next use
    
    
    if ( ( itinerary.startStopID != nil ) && ( itinerary.endStopID !=  nil ) )
    {
        [self loadTripsInTheBackground];
        //        [self filterCurrentTrains];
    }
    else
    {
        [SVProgressHUD dismiss];
    }
    
    
    if ( _currentDisplayDirection != [directionID intValue] )
    {
        _currentDisplayDirection = [directionID intValue];
        //        [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    
    // If the Start Stop was just selected and the End Stop is still blank, reload the popup window for the end stops
    //    if ( ( itinerary.startStopID != nil ) && ( [itinerary.endStopID intValue] == 0 ) )
    //    {
    //        [self performSegueWithIdentifier:@"EndStopTimesSegue" sender:nil];
    //    }
    
    
    if ( itinerary.startStopName == NULL )
    {
        NSLog(@"We have a problem!");
    }
    
    // Reload just the first section, with it's one giant cell.
    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

-(void) doneButtonPressed:(StopNamesForRouteTableController *)view WithStopName:(NSString *)selectedStopName andStopID:(NSInteger)selectedStopID
{
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: doneButtonPressedWithStopName:%@ andStopID:%d", selectedStopName, selectedStopID);
#endif

    [self doneButtonPressed:view WithStopName:selectedStopName andStopID:selectedStopID withDirectionID:NULL];
    
}

-(void) cancelButtonPressed:(StopNamesForRouteTableController *)view
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: cancelButtonPressed");
#endif

    
    if ( [[self modalViewController] isBeingDismissed] )
        return;
    else
        [view dismissModalViewControllerAnimated:YES];
    
    _startENDButtonPressed = 0;
    
}


-(StopNamesObject*) reverseStopLookUpForStopID:(int) stopID
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: reverseStopLookUpForStopID:%d", stopID);
#endif
    
    
    StopNamesObject *sObject = [[StopNamesObject alloc] init];
    
    if ( !([self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Trolley"]) )
        return nil;
    
    // Perform a bus stop reverse lookup to find the closest stop_id in the opposite direction
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return nil;
    }
    

    // Look up the reverse stop ID for the active stop
    NSString *queryStr = [NSString stringWithFormat:@"SELECT reverseStopSearch.stop_id,reverse_stop_id,distance,stop_name FROM reverseStopSearch JOIN stops_bus ON reverseStopSearch.reverse_stop_id=stops_bus.stop_id WHERE reverseStopSearch.stop_id=%d AND route_short_name=\"%@\"", stopID, itinerary.routeShortName];

    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Basic DB error checking
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNFRTC - query str: %@", queryStr);
        
        return nil;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    while ( [results next] )  // Only one row should have been returned
    {
        
//        int stopID         = [results intForColumn   :@"stop_id"];
        NSString *stopName = [results stringForColumn:@"stop_name"];
        
        int reverseID      = [results intForColumn   :@"reverse_stop_id"];
        
        [sObject setStop_name: stopName];
        [sObject setStop_id: [NSNumber numberWithInt:reverseID] ];
        
    }  // while ( [results next] )
    
    [database close];
    
    return sObject;
}
    
// --==
// --==  Find the Reverse Stop for the Start (yesNo == YES) or End (yesNo == NO)
// --==
-(void) reverseStopLookUpForStart:(BOOL) yesNO;
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: reverseStopLookUpForStart");
#endif
    
    if ( !([self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Trolley"] ) )
        return;
    
    
    // Perform a bus stop reverse lookup to find the closest stop_id in the opposite direction
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    // Store active start/end IDs
    int itineraryStartID = [itinerary.startStopID intValue];
    int itineraryEndID   = [itinerary.endStopID   intValue];
    
    // Store reverse state of itinerary
    BOOL isReverse = [itinerary isReverse];
    
    
    //    [itinerary setReverse:NO];  // Ensure pointer points to the current object
    
    
    // Gets stop IDs for the active stop (either current or reverse)
    int numID;
    if ( yesNO )
        numID = itineraryStartID;
    else
        numID = itineraryEndID;
    
    
    // Look up the reverse stop ID for the active stop
    NSString *queryStr = [NSString stringWithFormat:@"SELECT reverseStopSearch.stop_id,reverse_stop_id,distance,stop_name FROM reverseStopSearch JOIN stops_bus ON reverseStopSearch.reverse_stop_id=stops_bus.stop_id WHERE reverseStopSearch.stop_id=%d AND route_short_name=\"%@\"", numID, itinerary.routeShortName];
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Basic DB error checking
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNFRTC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    while ( [results next] )  // Only one row should have been returned
    {
        
        int stopID         = [results intForColumn   :@"stop_id"];
        NSString *stopName = [results stringForColumn:@"stop_name"];
        
        int reverseID      = [results intForColumn   :@"reverse_stop_id"];
        
        [itinerary setReverse:!isReverse];  // Now switch from the active stop (whether it be reverse or current)
        if ( stopID == itineraryStartID )
        {
            itinerary.startStopID   = [NSNumber numberWithInt:reverseID];
            itinerary.startStopName = stopName;
        }
        
        if ( stopID == itineraryEndID )
        {
            itinerary.endStopID   = [NSNumber numberWithInt:reverseID];
            itinerary.endStopName = stopName;
        }
        
        // Switch itinerary back to previous active state
        [itinerary setReverse: isReverse];
        
        
    }  // while ( [results next] )
    
    [database close];
    
}


#pragma mark -
#pragma mark UISegment Control


- (IBAction)segmentMapFavoritePressed:(id)sender
{
    
    
    
    return;
    
//    switch ([self.segmentMapFavorite selectedSegmentIndex])
//    {
//        case 0:
//            NSLog(@"IVC - Map Button Pressed");
//            [self performSegueWithIdentifier:@"MapViewSegue" sender:self];
//            break;
//        case 1:
//            NSLog(@"IVC - Favorite Button Pressed");
//            [self favoriteButtonSelected];
//            break;
//        default:
//            break;
//    }
    
}

-(void) favoriteButtonSelected
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: favoriteButtonSelected");
#endif
    
    
    DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
    
    if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
    {
        [routeData removeObject:routeData.current fromSection:kDisplayedRouteDataFavorites];
        [self setFavoriteHighlight:NO];
    }
    else
    {
        [routeData addCurrentToSection:kDisplayedRouteDataFavorites];
        [self setFavoriteHighlight: YES];
    }
}



- (IBAction)segmentServiceChanged:(id)sender
{
    
//    if ( _currentSegmentIndex != [self.segmentService selectedSegmentIndex] )
//    {
//        _currentSegmentIndex = [self.segmentService selectedSegmentIndex];
//        
//        [self updateServiceID];
//        [self filterCurrentTrains];
//        [self filterActiveTrains];
//    }
    
}


    
    
-(NSInteger) getServiceIDFor:(ItineraryFilterType) type
{

#if FUNCTION_NAMES_ON
    NSLog(@"iVC: getServiceIDFor:%d", type);
#endif
    
//    NSLog(@"filePath: %@", [self filePath]);
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return 0;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
    int weekday = [comps weekday];  // Sunday is 1, Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
    
    int dayOfWeek;
    
    switch (type) {
        case kItineraryFilterTypeNow:
            dayOfWeek = pow(2,(7-weekday) );
        break;
        
        case kItineraryFilterTypeSat:
        dayOfWeek = pow(2,0); // 000 0001 (SuMoTu WeThFrSa), Saturday
        break;
        
        case kItineraryFilterTypeSun:
        dayOfWeek = pow(2,6); // 100 0000 (SuMoTu WeThFrSa), Sunday
        break;
        
        case kItineraryFilterTypeWeekday:
        dayOfWeek = pow(2,5) + pow(2,4) + pow(2,3) + pow(2,2) + pow(2,1); // 010 0000 (SuMoTu WeThFrSa), Monday
        break;
        
        default:
        break;
    }
    
//    int dayOfWeek = pow(2,(7-weekday) );
    
    
    /*
     
     Now:
      Mon-Thu uses one service_id
      Fri     uses two service_ids
     
     Weekday
      Mon-Fri uses two service_ids, second service_id must indicate Friday only times
     
     */
    
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT service_id, days FROM calendar_rail WHERE (days & %d) AND (start <= strftime('%%Y%%m%%d') AND (end >= strftime('%%Y%%m%%d') ));", dayOfWeek];
//    NSString *queryStr = [NSString stringWithFormat:@"SELECT service_id, days FROM calendarDB WHERE (days & %d)", dayOfWeek];
    
    if ( [self.travelMode isEqualToString:@"Rail"] )
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
    else
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"IVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"IVC - query str: %@", queryStr);
        
        return 0;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    // Friday only train 
    NSInteger service_id = 0;
//    [results next];
    
    
    _servicePredicate = [[NSMutableString alloc] initWithString:@"("];
    // (service_id == 62 or service_id == 2)
    while ( [results next] )
    {
        service_id = [results intForColumn:@"service_id"];
        [_servicePredicate appendFormat:@"serviceID == %d or ", service_id];
    }

    // Remove the last four characters, the ' or '
    [_servicePredicate deleteCharactersInRange:NSMakeRange([_servicePredicate length]-4, 4)];
    
    [_servicePredicate appendString:@")"];

//    NSLog(@"%@", _servicePredicate);

    return (NSInteger)service_id;
    
    [database close];
    
}
    
    
-(NSInteger) isHoliday
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: isHoliday");
#endif
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];  // Format is YYYYMMDD, e.g. 20131029
    NSString *now = [dateFormatter stringFromDate: [NSDate date]];
//    now = @"20131128";
    
    NSLog(@"filePath: %@", [self filePath]);
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return 0;
    }
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT service_id, date FROM holidayDB WHERE date=%@", now];
    
    if ( [self.travelMode isEqualToString:@"Rail"] )
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
    else
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"IVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"IVC - query str: %@", queryStr);
        
        return 0;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    NSInteger service_id = 0;
    while ( [results next] )
    {
        service_id = [results intForColumn:@"service_id"];
    }

    [database close];
    
    return service_id;
    

    
}


-(void) updateServiceID
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: updateServiceID");
#endif
    
    _currentServiceID = [self getServiceIDFor:_currentFilter];
    
    return;
    
    
    
    // --  This is no longer in production  --

    switch ( _currentFilter )
    {
        case kItineraryFilterTypeNow: // Now
            
        {
            
            if ( (_currentServiceID = [self isHoliday]) )
            {
                
            }
            else
            {

//                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//                NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
//                int weekday = [comps weekday];  // Sunday is 1, Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
//
//                int dayOfWeek = pow(2,(7-weekday) );
                
//                _currentServiceID = [self getServiceID];
//                
////                _currentServiceID = pow(2,(7-weekday));
//                NSLog(@"weekday: %d, currentServiceID: %d", weekday, _currentServiceID);
                
            }
            
        }
            break;
            
        case kItineraryFilterTypeWeekday: // Week
            _currentServiceID = 62;  // 011 1110
            
            break;
            
        case kItineraryFilterTypeSat: // Sat
            _currentServiceID = 1;   // 000 0001 (SuMoTu WeThFrSa)
            
            break;
            
        case kItineraryFilterTypeSun: // Sun
            _currentServiceID = 64;  // 100 0000 (Sunday,Monday,Tuesday  Wednesday,Thursday,Friday,Saturday)
            
            break;
            
        default:
            break;
    }
    
    
//    NSLog(@"serviceID: %d", _currentServiceID);
    
    return;
    
    
    if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        
        
        //        switch (_currentSegmentIndex) {
        //            case 0:
        //
        //            {
        //                // Need to determine what day it is to select the appropriate S1 value
        ////                _currentServiceID = @"S1";
        //
        //                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        //                NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
        //                int weekday = [comps weekday];  // Sunday is 1, Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
        //
        //                switch (weekday) {
        //                    case 7:  // Saturday
        //                        _currentServiceID = @"S2";
        //                        break;
        //                    case 1:  // Sunday
        //                        _currentServiceID = @"S3";
        //                        break;
        //                    default: // Every other day
        //                        _currentServiceID = @"S1";
        //                        break;
        //                }
        //
        //
        //            }
        //
        //                break;
        //            case 1:
        //                _currentServiceID = @"S1";
        //                break;
        //            case 2:
        //                _currentServiceID = @"S2";
        //                break;
        //            case 3:
        //                _currentServiceID = @"S3";
        //                break;
        //
        //            default:
        //                break;
        //        }  // switch (_currentSegmentIndex) {
        
        
    }  // if ( [self.travelMode isEqualToString:@"Rail"] )
    else
    {
        
        
        //        switch (_currentSegmentIndex) {
        //            case 0:  // Now Segment Selected
        //            {
        //
        //                // Need to determine what day it is to select the appropriate serviceID value
        //
        //                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        //                NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
        //                int weekday = [comps weekday];  // Sunday is 1, Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
        //
        //                switch (weekday) {
        //                    case 7:  // Saturday
        //                        _currentServiceID = @"5";
        //                        break;
        //                    case 1:  // Sunday
        //                        _currentServiceID = @"7";
        //                        break;
        //                    default: // Every other day
        //                        _currentServiceID = @"1";
        //                        break;
        //                }
        //
        //
        //            }
        //                break;
        //            case 1:
        //                _currentServiceID = @"1";
        //                break;
        //            case 2:
        //                _currentServiceID = @"5";
        //                break;
        //            case 3:
        //                _currentServiceID = @"7";
        //                break;
        //
        //            default:
        //                break;
        //        }  // switch (_currentSegmentIndex) {
        
        
    }  // if ( [self.travelMode isEqualToString:@"Rail"] )
    
}



#pragma mark - Favorite Button
- (IBAction)btnFavoritesPressed:(id)sender
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: btnFavoritesPressed");
#endif
    
    DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
    
    if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
    {
        [routeData removeObject:routeData.current fromSection:kDisplayedRouteDataFavorites];
        [self setFavoriteHighlight:NO];
    }
    else
    {
        [routeData addCurrentToSection:kDisplayedRouteDataFavorites];
        [self setFavoriteHighlight: YES];
    }
    
}


-(void) setFavoriteHighlight: (BOOL) yesNO
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: setFavoriteHighlight");
#endif
    
    //    if ( [self.segmentMapFavorite set ])
    
    //    if ( yesNO )
    //        [self.btnFavorite setTintColor:[UIColor yellowColor] ];
    //    else
    //        [self.btnFavorite setTintColor:[UIColor clearColor] ];
    
//    if ( yesNO )
//        [self.segmentMapFavorite setTintColor:[UIColor yellowColor] ];
//    else
//        [self.segmentMapFavorite setTintColor:[UIColor clearColor] ];
    
}


#pragma mark - Realtime Data
-(void) kickOffAnotherJSONRequest
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC: kickOffAnotherJSONRequest");
#endif
    
    jsonRefreshTimer =[NSTimer scheduledTimerWithTimeInterval:JSON_REFRESH_RATE
                                                       target:self
                                                     selector:@selector(loadJSONDataIntheBackground)
                                                     userInfo:nil
                                                      repeats:NO];  // Ensures always JSON_REFRESH_RATE seconds after each successful operation.  Keeps everything in sync.
}


-(void) loadJSONDataIntheBackground
{
    
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC - loadJSONDataInTheBackground");
#endif
    

    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
    {
        [self kickOffAnotherJSONRequest];  // Network might be unreachable for a short time, try again in a bit
        return;  // Nothing to do, just return
    }
    
    [self getAdvisories];
    
    if ( [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSL"] || [self.travelMode isEqualToString:@"NHSL"] || [self.travelMode isEqualToString:@"Bus"] )  // Bus is only temporary; I'll add that in later.
    {
        NSLog(@"IVC - loadJSONDataInTheBackground - Current Route Does Not Support RealTime Data");
        return;
    }
    
    _jsonOp = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = _jsonOp;
    [weakOp addExecutionBlock:^{
        
        if ( !_viewIsClosing )
        {
            [self loadLatestJSONData];
        }
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                //                [self filterCurrentTrains];  // Updates currentTrainsArr and reloaded self.tableTrips
                //                [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];  // Forced update of To/From Header
                
                // Load Active Train
                NSLog(@"IVC - Crash #1");
                [self filterActiveTrains];
                
                // TODO:  Build in a fail safe, if a minute passes without a refresh, Reload JSON data (in the background, if you would please).
                if ( !_viewIsClosing )
                {
                    NSLog(@"IVC - Crash #2");
                    [self kickOffAnotherJSONRequest];
                }  // if ( !_viewIsClosing )
                
                NSLog(@"IVC - Crash #3");
            }];
        }
        else
        {
            NSLog(@"IVC - running SQL Query: _sqlOp cancelled");
        }
        
    }];
    
    [_jsonQueue addOperation: _jsonOp];
    
    
}

-(void) loadLatestJSONData
{
    
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC - loadLatestJSONData");
#endif


    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    

    
//    if ( [self.travelMode isEqualToString:@"Bus"] )  // Add MFL to this?  Need to investigate this further
//    {
//
//        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@",routeData.current.route_short_name];
//        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"DSTVC - getLatestBusJSONData -- api url: %@", webStringURL);
//
//        //    [SVProgressHUD showWithStatus:@"Retrieving data..."];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
//
//            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
//            [self performSelectorOnMainThread:@selector(addAnnotationsUsingJSONBusData:) withObject: realtimeBusInfo waitUntilDone:YES];
//
//        });
//
//    }
//    else
    
    
    if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TrainView/"];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"IVC - loadLatestRailJSONData -- api url: %@", webStringURL);
        
        NSData *realtimeData = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
        [self processJSONData:realtimeData];
    }
    
    
    
}

-(void) processJSONData:(NSData*) returnedData
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC - processJSONData");
#endif
    
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    if ( [_jsonOp isCancelled] )  // As the JSON pull can take upwards of a few seconds, before we even process the data, check if the JSON operation has been cancelled
        return;
    
    if ( returnedData == nil )  // If returnedData is nil, don't even continue.
    {
        NSLog(@"IVC - processJSONData, returnedData is nil.  Returning");
        return;
    }
    
    if (_masterTrainLookUpDict == nil )  // If the Itinerar is swipe deleted just prior to a JSON pull, there's nothing to compare to
        return;
    
//    if ( [itinerary isComplete] == NO )
//        return;
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    // Clear out old _masterJSONTrainArr cause we're about to fill it back up with more recent data!
    [_masterJSONTrainArr removeAllObjects];
    
    for (NSDictionary *railData in json)
    {
        
        if ( [_jsonOp isCancelled] )
            return;
        
        NSString *trainNo = [railData objectForKey:@"trainno"];
        //        NSString *tripKey = [NSString stringWithFormat:@"%@%d", trainNo, _currentServiceID];
        //
        //        NSLog(@"Looking for %@ in _masterTrainLookUpDict", tripKey);
        //        if ( [_masterTrainLookUpDict objectForKey:tripKey ] != nil )
        //        {
        //
        //            NSString *delay   = [railData objectForKey:@"late"];
        //            NSString *service = [railData objectForKey:@"service"];
        //            NSString *nextStop = [railData objectForKey:@"nextstop"];
        //            NSString *destination = [railData objectForKey:@"dest"];
        //
        //            TripObject *trip = [[_masterTrainLookUpDict objectForKey:tripKey] nonretainedObjectValue];
        //
        //
        //            ActiveTrainObject *atObject = [[ActiveTrainObject alloc] init];
        //            // TrainView JSON related fields
        //            [atObject setTrainDelay : [NSNumber numberWithInt:[delay intValue] ] ];
        //            [atObject setTrainNo    : [NSNumber numberWithInt:[trainNo intValue] ] ];
        //            [atObject setServiceType: service];
        //            [atObject setNextStop   : nextStop];
        //            [atObject setDestination: destination];
        //
        //            // These three values are the criteria used to filter _masterTrainArr into _currentTrainArr
        //            // We'll use the same criteria.  So if the user switches to Sat or Sun, the active trains for the weekday will not be displayed
        //            [atObject setStartTime: trip.startTime];     // ordered by this
        //            [atObject setServiceID: [NSNumber numberWithInt: trip.serviceID] ];     // sorted by this
        //            [atObject setDirectionID:trip.directionID];  // and sorted by this
        //
        //            [_masterJSONTrainArr addObject: atObject];
        //
        //        }  // if ( [_masterTrainLookUpDict objectForKey:[NSNumber numberWithInt:[trainNo intValue] ] ] == nil )
        
        
        NSMutableArray *trainNoArray = [_masterTrainLookUpDict objectForKey:trainNo];
        
        if ( trainNoArray == nil )  // If trainNoArray, perhaps trainNo contains a P
        {
            // Make a second pass through, first by converting the trainNo to an integer, then by using that integer as a key against _masterTrainLookUpDict
            int tNum = [trainNo intValue];
            trainNoArray = [_masterTrainLookUpDict objectForKey:[NSString stringWithFormat:@"%d", tNum] ];
        }
        
        for (NSValue *newTrip in trainNoArray)
        {
            
            TripObject *trip = [newTrip nonretainedObjectValue];
            
            // Find the trip that matches the trainNo AND the currentServiceID
            if ( [trip.serviceID intValue] & _currentServiceID )
            {
                NSString *delay   = [railData objectForKey:@"late"];
                NSString *service = [railData objectForKey:@"service"];
                NSString *nextStop = [railData objectForKey:@"nextstop"];
                NSString *destination = [railData objectForKey:@"dest"];
                
                ActiveTrainObject *atObject = [[ActiveTrainObject alloc] init];
                // TrainView JSON related fields
                [atObject setTrainDelay : [NSNumber numberWithInt:[delay intValue] ] ];
                [atObject setTrainNo    : [NSNumber numberWithInt:[trainNo intValue] ] ];
                [atObject setServiceType: service];
                [atObject setNextStop   : nextStop];
                [atObject setDestination: destination];
                
                // These three values are the criteria used to filter _masterTrainArr into _currentTrainArr
                // We'll use the same criteria.  So if the user switches to Sat or Sun, the active trains for the weekday will not be displayed
                [atObject setStartTime: [NSString stringWithFormat:@"%d", [trip.startTime intValue] ] ];     // ordered by this
                [atObject setServiceID: trip.serviceID ];     // sorted by this
                [atObject setDirectionID:trip.directionID];  // and sorted by this
                [atObject setTripID: trip.tripID];
                
                [_masterJSONTrainArr addObject: atObject];
                //                NSLog(@"IVC - processJSONData, added trip: %@", atObject);
            }
            
        }
        
        
        
    }  // for (NSDictionary *railData in json)
    
}



-(void) loadToFromDirections
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"iVC - loadToFromDirections");
#endif
    
    return;
    
    // Only proceed if travelMode has been set to Bus or Trolley
    if ( ![self.travelMode isEqualToString:@"Bus"] || ![self.travelMode isEqualToString:@"Trolley"] )
    {
        return;
    }
    
    
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT Route, Direction, DirectionDescription FROM bus_stop_directions WHERE Route=%@ ORDER BY dircode", itinerary.routeShortName];
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"IVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"IVC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    while ( [results next] )
    {
        //        NSString *route_short_name = [results stringForColumn:@"Route"];
        //        NSString *direction        = [results stringForColumn:@"Direction"];
        //        NSString *description      = [results stringForColumn:@"DirectionDescription"];
        
        [toFromDirection addObject:@"To Dir"];
        [toFromDirection addObject:@"From Dir"];
        
    }
    
    
    [database close];
    
}


-(void) addAnnotationsUsingJSONRailData:(NSData*) returnedData
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - addAnnotationsUsingJSONRailData");
#endif
    
    
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    
    //    // This method is called once the realtime positioning data has been returned via the API is stored in data
    //    NSError *error;
    //    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    //    
    //    if ( error != nil )
    //        return;  // Something bad happened, so just return.
    //    
    //    NSMutableArray *annotationsToRemove = [[mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    //    [annotationsToRemove removeObject: [mapView userLocation] ];         // Keep the userLocation annotation on the map
    //    [mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
    //    
    //    
    //    for (NSDictionary *railData in json)
    //    {
    //        
    //        //        NSString *trainno = [railData objectForKey:@"trainno"];
    //        //        if ( [trainNoArray containsObject:trainno] )
    //        //        {
    //        //            NSLog(@"Found %@ in JSON stream", trainno);
    //        //        }
    //        //        else
    //        //        {
    //        //            NSLog(@"Could not find %@ in JSON stream", trainno);
    //        //        }
    //        
    //        
    //        // Loop through all returned bus info...
    //        NSNumber *latitude   = [NSNumber numberWithDouble: [[railData objectForKey:@"lat"] doubleValue] ];
    //        NSNumber *longtitude = [NSNumber numberWithDouble: [[railData objectForKey:@"lon"] doubleValue] ];
    //        
    //        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([latitude doubleValue], [longtitude doubleValue]);
    //        
    //        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
    //        NSString *annotationTitle;
    //        if ( [[railData objectForKey:@"late"] intValue] == 0 )
    //            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (on time)", [railData objectForKey:@"trainno"] ];
    //        else
    //            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (%@ min late)", [railData objectForKey:@"trainno"], [railData objectForKey:@"late"]];
    //        
    //        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"%@ to %@", [railData objectForKey:@"SOURCE"], [railData objectForKey:@"dest"] ] ];
    //        [annotation setCurrentTitle   : annotationTitle];
    //        
    //        if ( [[railData objectForKey:@"trainno"] intValue] % 2)
    //            [annotation setDirection      : @"TrainSouth"];  // Modulus returns 1 on odd
    //        else
    //            [annotation setDirection      : @"TrainNorth"];  // Modulus returns 0 on even
    //        
    //        
    //        [mapView addAnnotation: annotation];
    //        
    //    }
    //    
    //    NSLog(@"DSTVC - addAnntoationsUsingJSONRailData -- added %d annotations", [json count]);
    
    
}

#pragma mark -= Tabbed Button
-(void) tabbedButtonPressed:(NSInteger) tab
{
    
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - tabbedButtonPressed:%d", tab);
#endif
    
    _currentFilter = tab;
    
    [self updateServiceID];
    [self filterCurrentTrains];
    [self filterActiveTrains];
    
    
}


#pragma mark - Buttons Pressed
-(void) backButtonPressed:(id) sender
{
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - backButtonPressed");
#endif

    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - NextToArriveItinerary Protocol
-(void) itineraryButtonPressed:(NSInteger) buttonType
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - itineraryButtonPressed:%d", buttonType);
#endif

    
    StopNamesTableViewControllerSelectionType selType;
    switch (buttonType)
    {
            
        case kNextToArriveButtonTypeStart:
            //            NSLog(@"NtATVC - start label pressed");
            
            // If the start label was pressed but the end is empty, then let's get the user to complete both of them.
            //            if ( [_itinerary.endStopID intValue] <= 0 )
            if ( [itinerary.startStopName isEqualToString: DEFAULT_START_MESSAGE] )
                selType = kNextToArriveSelectionTypeStartAndEnd;
            else
                selType = kNextToArriveSelectionTypeStart;
            
            break;
            
        case kNextToArriveButtonTypeEnd:
            //            NSLog(@"NtATVC - end label pressed");
            //            [self loadStopNamesVC];
            selType = kNextToArriveSelectionTypeEnd;
            break;
            
        case kNextToArriveButtonTypeStartEnd:
            //            NSLog(@"NtATVC - start/end button pressed");
            //            [self loadStopNamesVC];
            selType = kNextToArriveSelectionTypeStartAndEnd;
            break;
            
        case kNextToArriveButtonTypeReverse:
            //            NSLog(@"NtATVC - reverse button pressed");
//            _lastSelectedType = kNextToArriveSelectionNone;
            
//            [itinerary flipStops];
//            [self updateItinerary];
            
            [self flipStopNamesButtonTapped];
            
            return;
            break;
            
        default:
            // The code should never reach this point
            return;
            break;
    }
    
    
//    _lastSelectedType = selType;
    
    NSString *storyboardName = @"StopNamesStoryboard";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    StopNamesTableViewController *sntvc = (StopNamesTableViewController*)[storyboard instantiateInitialViewController];
    
    [sntvc enableFilter:YES];
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    [colorArray addObject: self.imgTabbedLabel.backgroundColor];
    [colorArray addObject: self.imgTabbedLabel.backgroundColor];
    [sntvc setHeaderColorArray: colorArray];

    
    // Pass information to the stopNames VC
    [sntvc setStopData: _routeData];          // Contains: start/end stop names and id, along with routeType -- the data
    [sntvc setSelectionType: selType];   // Determines its behavior, whether to show only the start, end or both start/end stops information
    [sntvc setDelegate:self];
    
    [sntvc setBackImageName: _backButtonImage];
    [sntvc setRouteType: _routeType];
    
    [self.navigationController pushViewController:sntvc animated:YES];
    
}


#pragma mark - Update Itinerary
-(void) updateItinerary
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - updateItinerary");
#endif

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    NextToArriveItineraryCell *myCell = (NextToArriveItineraryCell*)[self.tableTrips cellForRowAtIndexPath:indexPath];
    
    [[myCell btnStartDestination] setTitle: itinerary.startStopName forState:UIControlStateNormal];
    [[myCell btnEndDestination  ] setTitle: itinerary.endStopName   forState:UIControlStateNormal];
    
}


#pragma mark - REMenu Selection
-(void) updateFavoritesStatus
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - updateFavoriteStatus");
#endif

    
    // Compare the list of Favorites to that of _itinerary
    
//    NSArray *tempArr = [_tableData objectForSectionWithTitle:@"Favorites"];
//    if (tempArr == nil)
//    {
//        
//        if ( [itinerary.startStopName isEqualToString:DEFAULT_MESSAGE] && [itinerary.endStopName isEqualToString:DEFAULT_MESSAGE] )
//            _favoriteStatus = kNextToArriveFavoriteSubtitleStatusUnknown;  // If either are not set, set status to unknown
//        else
//            _favoriteStatus = kNextToArriveFavoriteSubtitleNotAdded;  // If both have data, set not added for now.  We'll be checked for Added below.
//        
//    }
//    
//    
//    for (NTASaveObject *sObject in [_tableData objectForSectionWithTitle:@"Favorites"] )
//    {
//        
//        if ( [itinerary.startStopName isEqualToString: [sObject startStopName] ] && [itinerary.endStopName isEqualToString: [sObject endStopName] ] )
//        {
//            _favoriteStatus = kNextToArriveFavoriteSubtitleAdded;
//            break;  // Once a match is found, no reason to continue searching
//        }
//        
//    }
    
    
    // --==  Update Favorites subtitle
    REMenuItem *refreshItem = [[_menu items] objectAtIndex: kItineraryDropDownMenuOrderFavorites];
    NSString *status;
    
    
    switch (_favoriteStatus)
    {
            
        case kNextToArriveFavoriteSubtitleNotAdded:
            status = FAVORITE_SUBTITLE_ADD;
            break;
            
        case kNextToArriveFavoriteSubtitleAdded:
            status = FAVORITE_SUBTITLE_REMOVE;
            break;
        case kNextToArriveFavoriteSubtitleStatusUnknown:
            status = FAVORITE_SUBTITLE_NONE;
            break;
        default:
            break;
    }
    
    
    [refreshItem setSubtitle: status ];
    // If the _favoriteStatus is at "Added" then display the REMOVE message.  Likewise, if it's not "Added" display the Add Me message
    
    
}


-(void) selectedFavorites
{

#if FUNCTION_NAMES_ON
    NSLog(@"IVC - selectedFavorites");
#endif

    
    // This code is a mess!
    // Here we convert from one data model to another, for fun!
    DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
    
    
    // Is the route already Favorited?  If so, remove it
    if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
    {
        [routeData removeObject:routeData.current fromSection:kDisplayedRouteDataFavorites];
        _favoriteStatus = kNextToArriveFavoriteSubtitleNotAdded;
    }
    else  // Otherwise, add it to Favorites
    {
        [routeData addCurrentToSection:kDisplayedRouteDataFavorites];
        _favoriteStatus = kNextToArriveFavoriteSubtitleAdded;
        
        // Remove if in Recently Viewed
        if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataRecentlyViewed] )
        {
            [routeData removeObject:routeData.current fromSection:kDisplayedRouteDataRecentlyViewed];
        }
        
    }
    
    [self updateFavoritesStatus];
        
}

//NSComparisonResult (^sortNextToArriveSaveObjectByDate)(NTASaveObject*,NTASaveObject*) = ^(NTASaveObject *a, NTASaveObject *b)
//{
//    return [[b addedDate] compare: [a addedDate] ];
//};


-(void) loadDisclaimer
{

#if FUNCTION_NAMES_ON
    NSLog(@"IVC - loadDisclaimer");
#endif

    
    NSString *storyboardName = @"CommonWebViewStoryboard";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    CommonWebViewController *cwVC = (CommonWebViewController*)[storyboard instantiateViewControllerWithIdentifier:@"CommonWebViewStoryboard"];
    
//    [cwVC setAlertArr: _currentAlert ];
    [cwVC setBackImageName: _backButtonImage];
    [cwVC setTitle:@"Real Time Information"];
    
    NSString *p1 = @"<p class='indent'>In the event of a significant delay on a regularly scheduled train you may see the word 'SUSPEND' in the status column. This may mean the train is temporarily canceled while we work on a problem or it may mean the train will not continue operation. In that case, you may see a listing for another train with a different origination point and the same train number with a 'P' after it, i.e., 6353P. The 'P' means that SEPTA has sent another train to pick up customers to complete the original train's journey. If a train has been 'suspended' it will not appear as the second train of a connecting trip</p>";
    
    NSString *p2 = @"<p class='indent'>SEPTA operates 13 rail lines that travel to destinations across the region. Some of these trains operate on SEPTA controlled track and some on Amtrak territory. Our Regional Rail Control Center can 'see' all of the trains traveling on SEPTA territory in real time, so the status information posted on TrainView is also in real time. Train status for service originating from Amtrak territory - Newark, DE (WIL), Trenton , NJ, (TRE) and Thorndale (PAO) - is estimated times, since the Control Center cannot 'see' the actual movement of these trains. The Control Center receives updated reports about these trains and that information is published on TrainView.</p>";
    
    NSString *html = [NSString stringWithFormat:@"<html><head><title>Next To Arrive</title></head><body><div><ul> <li>%@</li> <li>%@</li> </ul> </div>", p2, p1];
    
    [cwVC setHTML: html];
    
    [self.navigationController pushViewController:cwVC animated:YES];
    
    
}



-(void) loadAdvisories
{
  
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - loadAdvisories");
#endif


    if  ( _currentAlert != nil )
    {
        NSString *storyboardName = @"SystemStatusStoryboard";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        SystemAlertsViewController *saVC = (SystemAlertsViewController*)[storyboard instantiateViewControllerWithIdentifier:@"SystemAlertsStoryboard"];
        
        [saVC setAlertArr: _currentAlert ];
        [saVC setBackImageName: _backButtonImage];
        
        [self.navigationController pushViewController:saVC animated:YES];
    }
    
    
}


-(void) getAdvisories
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - getAdvisories");
#endif

    
    [_alertsAPI clearAllRoutes];
    
//    NSMutableDictionary *shortToAlertNameLookUp = [[NSMutableDictionary alloc] init];
//    
////    [shortToAlertNameLookUp setObject:@"AlertName" forKey:@"ShortName"];
//    [shortToAlertNameLookUp setObject:@"che" forKey:@"CHE"];
//    [shortToAlertNameLookUp setObject:@"chw" forKey:@"CHW"];
//    [shortToAlertNameLookUp setObject:@"cyn" forKey:@"CYN"];
//
//    [shortToAlertNameLookUp setObject:@"fxc" forKey:@"FOX"];
//    [shortToAlertNameLookUp setObject:@"landdoy" forKey:@"LAN"];
//    [shortToAlertNameLookUp setObject:@"landdoy" forKey:@"DOY"];
//    [shortToAlertNameLookUp setObject:@"med" forKey:@"MED"];
//    
//    [shortToAlertNameLookUp setObject:@"nor" forKey:@"NOR"];
//    [shortToAlertNameLookUp setObject:@"pao" forKey:@"PAO"];
//    [shortToAlertNameLookUp setObject:@"trent" forKey:@"TRE"];
//
//    [shortToAlertNameLookUp setObject:@"warm" forKey:@"WAR"];
//    [shortToAlertNameLookUp setObject:@"wilm" forKey:@"WIL"];
//    [shortToAlertNameLookUp setObject:@"wtren" forKey:@"WTR"];
//    
//    [shortToAlertNameLookUp setObject:@"gc" forKey:@"GC"];
//
//    NSString *alertName = [shortToAlertNameLookUp objectForKey: self.routeData.route_short_name];
    
//    if ( alertName == nil  && [self.routeData.route_short_name isEqualToString:@"GC"] )
//    {
//        [_alertsAPI addRoute: [shortToAlertNameLookUp objectForKey:@"WAR"] ];
//        [_alertsAPI addRoute: [shortToAlertNameLookUp objectForKey:@"LAN"] ];
//        [_alertsAPI addRoute: [shortToAlertNameLookUp objectForKey:@"WTR"] ];
//    }
//    else
//        [_alertsAPI addRoute: alertName];

//    if ( alertName != nil )
//        [_alertsAPI addRoute: alertName];
//    else
//        [_alertsAPI addRoute: _routeData.route_short_name];
    
    [_alertsAPI addRoute: _routeData.route_short_name ofModeType:[_routeData.route_type intValue] ];
    [_alertsAPI fetchAlert];

    
}


-(void) loadFareVC
{
 
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - loadFareVC");
#endif

    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FareStoryboard" bundle:nil];
    FareViewController *fVC = (FareViewController*)[storyboard instantiateInitialViewController];
    [self.navigationController pushViewController: fVC animated: YES];
    
}


#pragma mark - GetAlertsAPIProtocol
-(void) alertFetched:(NSMutableArray *)alert
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - alertFetched");
#endif

    
    // Done -- TODO: Set badge (or remove if alerts went away)
    
    if ( [alert count] == 0 )
    {
        REMenuItem *alertsItem = [[_menu items] objectAtIndex:2];
        [alertsItem setSubtitle: ALERTS_EMPTY];
        _currentAlert = nil;
        
        return;
    }
    
    
    BOOL isAlert = NO;
    BOOL isDetour = NO;
    BOOL isAdvisory = NO;
    
    for (SystemAlertObject *saObject in alert)
    {
        
        if ( [saObject isAlert] )
            isAlert = YES;
        
        if ( [saObject isAdvisory] )
            isAdvisory = YES;
        
        if ( [saObject isDetour] )
            isDetour = YES;
        
    }
    
    _currentAlert = alert;
    
//    _currentAlert = (SystemAlertObject*)[alert objectAtIndex:0];
    
    UIBarButtonItem *rightButton = self.navigationItem.rightBarButtonItem;
    MenuAlertsImageView *mView = (MenuAlertsImageView*)rightButton.customView;
    
    
    if ( isAlert )
        [mView addAlert: kMenuAlertsImageAlerts];
    else
        [mView removeAlert: kMenuAlertsImageAlerts];

    if ( isAdvisory )
        [mView addAlert: kMenuAlertsImageAdvisories];
    else
        [mView removeAlert: kMenuAlertsImageAdvisories];
    
    if ( isDetour )
        [mView addAlert: kMenuAlertsImageDetours];
    else
        [mView removeAlert: kMenuAlertsImageDetours];
    
    
//    if ( [_currentAlert numOfAlerts] )
    if ( isAlert + isAdvisory + isDetour )
    {
        // Update REMenu item with Advisory
        REMenuItem *alertsItem = [[_menu items] objectAtIndex:2];
        // Detour, alert, advisory, (suspension?)
        [alertsItem setSubtitle: ALERTS_FOUND];
    }
    else
    {
        // Clear REMenu item
        REMenuItem *alertsItem = [[_menu items] objectAtIndex:2];
        [alertsItem setSubtitle: ALERTS_EMPTY];
    }

}


-(void) dropDownMenuPressed:(id) sender
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - dropDownMenuPressed");
#endif

    
    // TODO: Clear badges

    if (_menu.isOpen)
    {
        return [_menu close];
    }
    else
    {
        
//        [self.tableTrips setContentOffset:self.tableTrips.contentOffset animated:NO];
        
        DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
        
        
        // Is the route already Favorited?
        if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
        {
            _favoriteStatus = kNextToArriveFavoriteSubtitleAdded;
        }
        
        [self updateFavoritesStatus];
        
        CGRect rect = CGRectInset(CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height), 5, 0 );
        [_menu showFromRect:rect inView:self.view ];
//        [_menu showInView: self.view];

    }
    
    
}


@end
