//
//  NextToArriveTableViewController.m
//  iSEPTA
//
//  Created by septa on 7/19/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NextToArriveTableViewController.h"




@interface NextToArriveTableViewController ()

@end

@implementation NextToArriveTableViewController
{

//    NTAProgressObject *_ntaProgress;
    
    // Favorites, Recently Viewed, Data, etc. are stored here for easy access
    TableViewStore *_tableData;
    
    // Contains detailed information about the start/end destinations selected in the topmost cell
    ItineraryObject *_itinerary;
    
    
    StopNamesTableViewControllerSelectionType _lastSelectedType;
    NextToArriveFavoriteSubtitleState _favoriteStatus;
    
    
    // Drop down window controller
    REMenu *_menu;

    
    // Handles Reading and Writing of Favorites and Recently Viewed
    NTASaveController *saveData;
    
    
    // Used for retrieving the latest JSON data on the Trains
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_jsonOp;
    NSBlockOperation *_alertOp;
    
    NSTimer *menuRefreshTimer;
    NSTimer *updateTimer;
    
    BOOL _stillWaitingOnWebRequest;
    BOOL _stillWaitingOnAlertRequest;
    
    BOOL _launchUpdateTimer;
    BOOL _killAllTimers;
    
    // --==  This dictionary is the quick lookup hash for replacing one the correct, GTFS approved, station name with one that SEPTA's internal DBs will recognize.  *Insert face palm here*
    NSMutableDictionary *replacement;
    
    NSMutableDictionary *alertLineDict;  // Converts NTA returned line with parameter used in Alerts API
    NSArray *_ntaUniqueLines;
    
    NextToArriveLeftButtonPressed _itineraryCompletion;
    
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
    
    [ALAlertBanner forceHideAllAlertBannersInView:self.view];
    
}

-(void) viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    
    // self.view.frame will display the actual width and height based on the orientation here.
    // viewDidLoad will only show the portriat width and height, regardless of orientation.
        
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];

    
    // If start and end are nil, just pull the generic.  Otherwise, leave it up to the refreshJSONData method to get the latest
    if ( ( [[_itinerary startStopName] isEqualToString: DEFAULT_START_MESSAGE] ) || ( [[_itinerary endStopName] isEqualToString: DEFAULT_END_MESSAGE] ) )
        [self getAlertsForLines: @[ @"Generic" ] ];  // Get the latest Alerts
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // Initialize our objects
    _tableData = [[TableViewStore alloc] init];
    _itinerary = [[ItineraryObject alloc] init];
    
    [_itinerary setStartStopID:[NSNumber numberWithInt:0] ];
    [_itinerary setStartStopName: DEFAULT_START_MESSAGE];
    
    [_itinerary setEndStopID:[NSNumber numberWithInt:0] ];
    [_itinerary setEndStopName: DEFAULT_END_MESSAGE];
    
    
    [_tableData addObject:_itinerary forTitle:@"Itinerary" withTag:kNextToArriveSectionStartEndCells];
    
    
    // Registering xib
    [self.tableView registerNib:[UINib nibWithNibName:@"NextToArriveTripHistoryCell"    bundle:nil] forCellReuseIdentifier:@"NextToArriveTripHistoryCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NextToArriveItineraryCell"      bundle:nil] forCellReuseIdentifier:@"NextToArriveItineraryCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NextToArriveSingleTripCell"     bundle:nil] forCellReuseIdentifier:@"NextToArriveSingleTripCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NextToArriveConnectionTripCell" bundle:nil] forCellReuseIdentifier:@"NextToArriveConnectionTripCell"];

    // Alerts - For displaying RRD generic and line-specific alerts
    [self.tableView registerNib:[UINib nibWithNibName:@"NextToArriveAlerts" bundle:nil] forCellReuseIdentifier:@"NextToArriveAlertsCell"];
    
    
    // --==  Create the NSOperationQueue to allow for cancelling
    _jsonQueue  = [[NSOperationQueue alloc] init];
    
    
    // Load Favorites and Recent from the Save Controller
    saveData = [[NTASaveController alloc] init];
    
    
    // --==  Favorites  ==--
//    for (id object in [saveData favorites] )
//    {
//        [_tableData addObject: object forTitle:@"Favorites"];
//    }
//    
//    if ( [saveData favorites] != nil )
//        [saveData setFavorites: [_tableData objectForSectionWithTitle:@"Favorites"] ];
    
    _favoriteStatus = kNextToArriveFavoriteSubtitleStatusUnknown;
    
    
    // --==  Recent  ==--
//    for (id object in [saveData recent] )
//    {
//        [_tableData addObject: object forTitle:@"Recent"];
//    }
//    
//    if ( [saveData recent] != nil )
//        [saveData setRecent: [_tableData objectForSectionWithTitle:@"Recent"] ];

    [_tableData replaceArrayWith: [saveData favorites] forTitle:@"Favorites"];
    [_tableData replaceArrayWith: [saveData recent]    forTitle:@"Recent"   ];
    
    // For aesethic purposes, display four blank cells when the view initially loads
    [_tableData addObject: [[NextToArrivaJSONObject alloc] init] forTitle:@"Data"];
    [_tableData addObject: [[NextToArrivaJSONObject alloc] init] forTitle:@"Data"];
    [_tableData addObject: [[NextToArrivaJSONObject alloc] init] forTitle:@"Data"];
    [_tableData addObject: [[NextToArrivaJSONObject alloc] init] forTitle:@"Data"];
    
    [_tableData setTag:kNextToArriveSectionFavorites forTitle: @"Favorites"];
    [_tableData setTag:kNextToArriveSectionRecent    forTitle: @"Recent"   ];
    [_tableData setTag:kNextToArriveSectionAlerts    forTitle: @"Alerts"   ];
    [_tableData setTag:kNextToArriveSectionData      forTitle: @"Data"     ];
    
    _launchUpdateTimer = NO;
    _killAllTimers     = NO;

    
//    UIImage *backImg = [UIImage imageNamed:@"NTA-white.png"];
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"NTA-white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
//    float w    = self.view.frame.size.width;
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0,500, 32) withTitle:@"Next To Arrive"];
    [self.navigationItem setTitleView:titleView];

    
        
    // Now create an imageView with the background image you want to use
//    UIImageView *bgImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"mainBackground.png"] ];
//    [self.tableView setBackgroundView: bgImageView];

    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.tableView setBackgroundColor: backgroundColor];

    
    
    // Used in [self fixMismatchedStopName].  Key: GTFS-compliant station name, value: NTA recognized equivalent station name.
    // To any developer reading this, I'm sorry for this blight but there needs to be some glue logic to connect a GTFS stop name
    // to the names stored in the legacy database that the API uses.
    // TODO:  Change the *#@!ing NTA API to recognize these translations!
    replacement = [[NSMutableDictionary alloc] init];
    [self populateGTFSLookUp];
    
    
    //  Add Upper Right button
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] init];
//    [rightButton setImage: [UIImage imageNamed:@"second-menu.png"] ];
//    [rightButton setStyle: UIBarButtonItemStylePlain];
    
//    CustomFlatBarButton *rightButton = [[CustomFlatBarButton alloc] initWithImageNamed:@"second-menu.png" withTarget:self andWithAction:@selector(dropDownMenuPressed:)];
//    [self.navigationItem setRightBarButtonItem: rightButton];

    MenuAlertsImageView *mView = [[MenuAlertsImageView alloc] initWithFrame: CGRectMake(0, 0, 50, 37.5)];
    
    [mView setBaseImage: [UIImage imageNamed:@"second-menu.png"] ];
    [mView addTarget:self action:@selector(dropDownMenuPressed:) forControlEvents:UIControlEventTouchDown];
    
//    [mView addAlert: kMenuAlertsImageAlerts];
//    [mView addAlert: kMenuAlertsImageDetours];
//    [mView addAlert: kMenuAlertsImageAdvisories];

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView: mView];
    [self.navigationItem setRightBarButtonItem: rightButton];

//    [mView startLoop];
    
    
//    NSTimer *onceAndDone = [NSTimer scheduledTimerWithTimeInterval:2.0f
//                                                     target:self
//                                                   selector:@selector(removeAlert)
//                                                   userInfo:nil
//                                                    repeats:NO];

    
 
    REMenuItem *refreshItem = [[REMenuItem alloc] initWithTitle:@"Refresh"
                                                       subtitle:@"select trip before refreshing"
                                                          image:[UIImage imageNamed:@"Refresh.png"]
                                               highlightedImage:nil
                                                         action:^(REMenuItem *item) {
                                                             [self refreshJSONData];
                                                         }];
    
    
    REMenuItem *favoritesItem = [[REMenuItem alloc] initWithTitle:@"Favorite"
                                                         subtitle:FAVORITE_SUBTITLE_NONE
                                                            image:[UIImage imageNamed:@"Favorite.png"]
                                                 highlightedImage:nil
                                                           action:^(REMenuItem *item) {
                                                               [self selectedFavorites];
                                                           }];
    
//    REMenuItem *filterItem = [[REMenuItem alloc] initWithTitle:@"Filter"
//                                                      subtitle:@"select filter options"
//                                                         image:[UIImage imageNamed:@"Filter.png"]
//                                              highlightedImage:nil
//                                                        action:^(REMenuItem *item) {
////                                                            [self showTSMessage];
//                                                        }];
//    
//    REMenuItem *advisoryItem = [[REMenuItem alloc] initWithTitle:@"Advisory"
//                                                        subtitle:@"Service Advisories"
//                                                           image:[UIImage imageNamed:@"Advisory.png"]
//                                                highlightedImage:nil
//                                                          action:^(REMenuItem *item) {
//                                                              
//                                                          }];

    REMenuItem *fareItem = [[REMenuItem alloc] initWithTitle:@"Fare"
                                                        subtitle:@"Fare Information"
                                                           image:[UIImage imageNamed:@"Fare.png"]
                                                highlightedImage:nil
                                                          action:^(REMenuItem *item) {
                                                              [self loadFareVC];
                                                          }];
    
    REMenuItem *disclaimerItem = [[REMenuItem alloc] initWithTitle:@"Real Time"
                                                          subtitle: @"Regional Rail Service"
                                                             image:[UIImage imageNamed:@"tipsBack.png"]
                                                  highlightedImage:nil
                                                            action:^(REMenuItem *item) {
                                                                [self loadDisclaimer];
                                                            }];

    
//    _menu = [[REMenu alloc] initWithItems:@[refreshItem, favoritesItem, filterItem, advisoryItem, fareItem] ];
    _menu = [[REMenu alloc] initWithItems:@[refreshItem, favoritesItem, fareItem, disclaimerItem] ];
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
    
    
//    _menu.textAlignment = UITextAlignmentLeft;
 
    
//    [[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    alertLineDict = [[NSMutableDictionary alloc] init];
    
    [alertLineDict setObject:@"rr_route_che"  forKey:@"Chestnut Hill East"];
    [alertLineDict setObject:@"rr_route_apt"  forKey:@"Airport"];
    [alertLineDict setObject:@"rr_route_wilm" forKey:@"Wilmington/Newark"];
    [alertLineDict setObject:@"rr_route_fxc"  forKey:@"Fox Chase"];
    
    [alertLineDict setObject:@"rr_route_nor"   forKey:@"Manayunk/Norristown"];
    [alertLineDict setObject:@"rr_route_wtren" forKey:@"West Trenton"];
    [alertLineDict setObject:@"rr_route_med"   forKey:@"Media/Elwyn"];
    [alertLineDict setObject:@"rr_route_pao"   forKey:@"Paoli/Thorndale"];
    
    [alertLineDict setObject:@"rr_route_chw"     forKey:@"Chestnut Hill West"];
    [alertLineDict setObject:@"rr_route_trent"   forKey:@"Trenton"];
    [alertLineDict setObject:@"rr_route_cyn" forKey:@"Cynwyd"];
    
    [alertLineDict setObject:[NSArray arrayWithObjects:@"rr_route_gc",@"rr_route_landdoy", nil] forKey:@"Lansdale/Doylestown"];
    [alertLineDict setObject:[NSArray arrayWithObjects:@"rr_route_gc",@"rr_route_warm"   , nil] forKey:@"Warminster"];

    [alertLineDict setObject:@"generic" forKey:@"Generic"];
    
}


//-(void) removeAlert
//{
//    MenuAlertsImageView *mView;
//    UIBarButtonItem *rightButton = self.navigationItem.rightBarButtonItem;
//    
//    mView = (MenuAlertsImageView*)[rightButton customView];
////    [mView removeAlert: kMenuAlertsImageAlerts];
////    [mView removeAlert: kMenuAlertsImageDetours];
//    
//}


- (void)viewDidUnload
{
//    [self setGestureDoubleTap:nil];
    [self setGestureLongPress:nil];
    [super viewDidUnload];
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _killAllTimers = NO;
    // Let's not immediately kick off another JSON request this when user comes back into this view
    //    if ( _launchUpdateTimer )
    //        [self kickOffAnotherJSONRequest];
    
}


-(void) viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
    
    NSLog(@"NTA -(void) viewDidDisappear");
    _killAllTimers = YES;
    
    if ( [SVProgressHUD isVisible] )
        [SVProgressHUD dismiss];
    
    
    [_jsonQueue cancelAllOperations];
    

    // Save Favorite/Recent data if it's been modified
    [saveData save];
    

    _launchUpdateTimer = NO;
    [self invalidateTimer];
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
 
    NSLog(@"NtATVC - didReceiveMemoryWarning");
}



-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  
//    CGFloat width = [UIScreen mainScreen].bounds.size.width - 10;  // Take the same space off as the formatCell method

//    NSLog(@"NtATVC - willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)%ld duration:(NSTimeInterval)%6.4f withWidth: %6.4f",toInterfaceOrientation,duration,width);
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
    
    
    if ( [_tableData indexForSectionTitle:@"Alerts"] != NSNotFound )
    {
        // Alerts has data
        NSMutableArray *alertArr = [_tableData objectForSectionWithTitle:@"Alerts"];
        for (AlertMessage *aMsg in alertArr)
        {
            [aMsg updateAttrText];
        }
    }
    
    
    [self.tableView reloadData];
    
}


//-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    
//}


#pragma mark - Update Itinerary
-(void) updateItinerary
{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    NextToArriveItineraryCell *myCell = (NextToArriveItineraryCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [[myCell btnStartDestination] setTitle:_itinerary.startStopName forState:UIControlStateNormal];
    [[myCell btnEndDestination  ] setTitle:_itinerary.endStopName   forState:UIControlStateNormal];
    
}


#pragma mark - UITableView data source
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewDidScroll");
//}
//
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewWillBeginDragging");
//}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [_tableData numOfSections];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [_tableData numOfRowsForSection:section];
    
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [cell setBackgroundColor: [UIColor colorWithWhite:1.0f alpha:0.8f] ];
    
    return;
    
//    [cell setBackgroundColor: [UIColor colorWithWhite:1.0f alpha:.8] ];
//    
//    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_line.png"]];
////    [separator setAutoresizesSubviews:YES];
////    [separator setAutoresizingMask: (UIViewAutoresizingFlexibleWidth) ];
////    [separator setContentMode: UIViewContentModeScaleAspectFit];
//    
//    UITableViewCell *newCell = (UITableViewCell*)cell;
//    
//    [separator setFrame: CGRectOffset(separator.frame, 0, newCell.frame.size.height-separator.frame.size.height)];
//    [newCell.contentView addSubview: separator];
    
}



- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *itineraryCell      = @"NextToArriveItineraryCell";

    
    id myCell;
    
    switch (indexPath.section)
    {
        case 0:
            
//            NextToArriveItineraryCell *cell = [thisTableView dequeueReusableCellWithIdentifier:itineraryCell forIndexPath:indexPath];
//        {
            myCell = (NextToArriveItineraryCell*)[thisTableView dequeueReusableCellWithIdentifier: itineraryCell];
            [myCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [myCell setDelegate:self];
            
            [[myCell btnStartDestination] setTitle:_itinerary.startStopName forState:UIControlStateNormal];
//            [[myCell btnStartDestination] setBackgroundColor:[UIColor lightGrayColor]];
            
            [[myCell btnEndDestination  ] setTitle:_itinerary.endStopName   forState:UIControlStateNormal];
//            [[myCell btnEndDestination] setBackgroundColor:[UIColor lightGrayColor]];
//            [myCell setEnd_stop_name  : _itinerary.endStopName  ];
            
//            float x = 4.0;
//            float y = 4.0;
            
//            NextToArriveItineraryCell *nCell = (NextToArriveItineraryCell*)myCell;
//            CGRect bound = nCell.bounds;
//            bound.size.width = self.view.frame.size.width - 5;
//            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bound
//                                                           byRoundingCorners: UIRectCornerTopRight | UIRectCornerBottomRight
//                                                                 cornerRadii: CGSizeMake(x, y)];
//            CAShapeLayer *maskLayer = [CAShapeLayer layer];
//            maskLayer.frame = bound;
//            maskLayer.path= maskPath.CGPath;
//            
//            nCell.layer.mask = maskLayer;
            
            return myCell;
//        }
            
            break;
        default:
            
            return [self cellForSection: indexPath];
            
            break;
    }
    
    
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [thisTableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    switch (indexPath.section)
//    {
//        case 0:
//            return 62.0f;
//            break;
//            
//        default:
//    
            return [self heightForSection: indexPath];
//            break;
//    }
    
}



-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    if ( section == 0 )
        return 0.0f;
    else
        return 22.0f;

}


-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 22)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, self.view.frame.size.width-10, 22)];  // gga, 4/10/15: add -10 to better center Alerts
    [headerLabel setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f] ];
    [headerLabel setTextColor: [UIColor whiteColor] ];
    [headerLabel setBackgroundColor: [UIColor clearColor] ];
    
    [headerView addSubview: headerLabel];
    
    
    // TODO: Prettify this so it doesn't make me want to bash my head against the desk.  Repeatedly.  -- DONE  You can thank me later!
    if ( [[_tableData titleForSection:section] isEqualToString:@"Favorites"] )
    {
        [headerLabel setText:@"Favorites"];
        [headerView setBackgroundColor: [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:74.0f/255.0f alpha:0.6f]];
    }
    else if ( [[_tableData titleForSection:section] isEqualToString:@"Recent"] )
    {
        [headerLabel setText:@"Recent"];
        [headerView setBackgroundColor: [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:74.0f/255.0f alpha:0.6f]];
    }
    else if ( [[_tableData titleForSection:section] isEqualToString:@"Alerts"] )
    {
        
        [headerLabel setText:@"Alerts"];
        [headerLabel setTextAlignment:NSTextAlignmentCenter];
        [headerView setBackgroundColor: [UIColor colorWithRed:181.0/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.8f]];
    }
    else if ( [[_tableData titleForSection:section] isEqualToString:@"Data"] )
    {
        [headerLabel setText:@"Next to Arrive Trains"];
        [headerView setBackgroundColor: [UIColor colorWithRed:240.0f/255.0f green:78.0f/255.0f blue:67.0f/255.0f alpha:0.6f]];
    }
    else
        return nil;
    
    
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


-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0f;
}


-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0f)];
    [footer setBackgroundColor: [UIColor clearColor] ];
    
    return footer;
    
}



#pragma - UITableView Helper Methods
-(id) cellForSection: (NSIndexPath*) indexPath
{

//    NSLog(@"indexPath: %ld/%ld, # of rows in section 2: %ld", (long)indexPath.section, (long)indexPath.row, (long)[_tableData numOfRowsForSection:2]);
    
    static NSString *singleTripCell     = @"NextToArriveSingleTripCell";
    static NSString *connectionTripCell = @"NextToArriveConnectionTripCell";
    static NSString *tripHistoryCell    = @"NextToArriveTripHistoryCell";
    static NSString *tripAlertCell      = @"NextToArriveAlertsCell";
    
    id myCell;
    if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Favorites"] || [[_tableData titleForSection:indexPath.section] isEqualToString:@"Recent"] )
    {
        myCell = (NextToArriveTripHistoryCell*)[self.tableView dequeueReusableCellWithIdentifier: tripHistoryCell];

        NTASaveObject *saveObject = [_tableData objectForIndexPath:indexPath];
        
        [[myCell lblStartName] setText: [saveObject startStopName] ];
        [[myCell lblEndName]   setText: [saveObject endStopName]   ];
        
        CAShapeLayer *maskLayer = [self formatCell: myCell forIndexPath:indexPath];
        ((UITableViewCell*)myCell).layer.mask = maskLayer;
        
//        return myCell;
    }
    else if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Alerts"] )
    {
        NSLog(@"Alerts section!");
        myCell = (NextToArriveAlerts*)[self.tableView dequeueReusableCellWithIdentifier: tripAlertCell];
        
//        SystemAlertObject *saObj = [_tableData objectForIndexPath:indexPath];
        AlertMessage *aMsg = [_tableData objectForIndexPath:indexPath];
        
//        [myCell updateAlertTitle:@"RRD" andText: saObj.current_message];
//        [myCell updateAlertText:saObj.current_message];
        [[myCell lblAlertText] setAttributedText: aMsg.attrText ];

        [myCell setSelectionStyle: UITableViewCellSelectionStyleNone];
        
//        [[myCell lblAlertText] setNumberOfLines:0];
        
        CGRect rect = CGRectFromString(aMsg.rect);

        CGRect frame = [myCell lblAlertText].frame;
        
//        frame.origin.y = (rect.size.height/10.0f/2.0);
        frame.origin.y = 0.0f + 6.0f;
        frame.size.height = (rect.size.height);
        frame.size.width = rect.size.width;
        
//        rect.origin.y = (rect.size.height/10.0f/2.0);  // Pad it with a tenth of its own height
        [[myCell lblAlertText] setFrame: frame];
  
        
//        [[myCell lblAlertText] setBounds: CGRectFromString( aMsg.rect ) ];

//        [[myCell lblAlertText] sizeToFit];

        // This is nice to help visualize where the boundaries are.
//        [myCell lblAlertText].layer.borderWidth = 1.0f;
//        [myCell lblAlertText].layer.borderColor = [UIColor redColor].CGColor;
        
        
        CAShapeLayer *maskLayer = [self formatCell: myCell forIndexPath:indexPath];
        ((UITableViewCell*)myCell).layer.mask = maskLayer;
        
        ((UITableViewCell*)myCell).layer.borderColor = [[UIColor colorWithRed:0.6 green:0.7 blue:0.2 alpha:1.0] CGColor];
        
    }
    else
    {
        CAShapeLayer *maskLayer;
        NextToArrivaJSONObject *ntaObject = [_tableData objectForIndexPath: indexPath];
        
        
        if ( [ntaObject Connection] == nil )  // If connection is nil then it's a single trip
        {
            myCell = (NextToArriveSingleTripCell*)[self.tableView dequeueReusableCellWithIdentifier: singleTripCell];
            [myCell updateCellUsingJsonData: ntaObject];
            
//            myCell height is the generic 44 pixels.  A workaround is needed here.
            maskLayer = [self formatCell: (NextToArriveSingleTripCell*)myCell forIndexPath:indexPath];
            
        }
        else  // Otherwise a connection is required
        {
            myCell = (NextToArriveConnectionTripCell*)[self.tableView dequeueReusableCellWithIdentifier: connectionTripCell];
            [myCell updateCellUsingJsonData: ntaObject];
            
            maskLayer = [self formatCell: (NextToArriveConnectionTripCell*)myCell forIndexPath:indexPath];
        }
        
        

        ((UITableViewCell*)myCell).layer.mask = maskLayer;
        
    }
    
//    NSLog(@"%@",myCell);
    return myCell;
    
}


-(CAShapeLayer*) formatCell:(UITableViewCell*) cell forIndexPath:(NSIndexPath*) indexPath
{

    UIRectCorner corner = 0;
    
    if ( indexPath.row == 0 )
    {
        corner |= UIRectCornerTopRight;
    }
    
    if ( indexPath.row == [_tableData numOfRowsForSection: indexPath.section] - 1 )
    {
        corner |= UIRectCornerBottomRight;
    }
    
    float x = 4.0;
    float y = 4.0;
    CGRect bound = cell.bounds;
    bound.size.height = [self heightForSection: indexPath];
    bound.size.width = self.view.frame.size.width - 5;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bound
                                                   byRoundingCorners: corner
                                                         cornerRadii: CGSizeMake(x, y)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bound;
    maskLayer.path= maskPath.CGPath;
    
    return maskLayer;
    
}


-(CGFloat) heightForSection: (NSIndexPath*) indexPath
{
    
    // TODO: Find a better way to do this, this happens very often
    if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Favorites"] )
    {
        return 38.0f;
    }
    else if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Recent"] )
    {
        return 38.0f;
    }
    else if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Alerts"] )
    {
//        return 38.0f;
        AlertMessage *aMsg = (AlertMessage*)[_tableData objectForIndexPath:indexPath];
        return CGRectFromString( aMsg.rect ).size.height+12;
    }
    else if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Data"] )
    {
        
        NextToArrivaJSONObject *ntaObject = [_tableData objectForIndexPath: indexPath];
        
        if ( [ntaObject Connection] == nil )
            return 47.0f;
        else
            return 102.0f;
        
    }
    else  // Then it's Itinerary
        return 62.0f;
    
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


#pragma mark - UITableView Delete Rows
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( editingStyle == UITableViewCellEditingStyleDelete )
    {
        
        if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Itinerary"] )
        {
            NSLog(@"Clear the Itinerary Cells");
            [self clearItineraryCells];
            _favoriteStatus = kNextToArriveFavoriteSubtitleStatusUnknown;
        }
        else if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Favorites"] )
        {
            NSLog(@"Forget Favorites");
            [self removeObjectAtIndexPath:indexPath];
        }
        else if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Recent"] )
        {
            NSLog(@"Remove Recent");
            [self removeObjectAtIndexPath:indexPath];
        }
        
    }
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Itinerary"] )
    {
        //        NSLog(@"Clear the Itinerary Cells");
        return YES;
    }
    else if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Favorites"] )
    {
        //        NSLog(@"Forget Favorites");
        return YES;
    }
    else if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Recent"] )
    {
        //        NSLog(@"Remove Recent");
        return YES;
    }
    
    return NO;
    
}


#pragma mark - UITableView Delete Helper Methods
-(void) clearItineraryCells
{
    [self invalidateTimer];
    
    // clear the _itineraryCompletion flag
    _itineraryCompletion = kNextToArriveNoButtonPressed;
    
    [_itinerary clearStops];
    [_itinerary setStartStopName: DEFAULT_START_MESSAGE];
    [_itinerary setEndStopName  : DEFAULT_END_MESSAGE];
    
    [self updateRefreshStatusWith: kNextToArriveRefreshStatusNoStops];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];  // Itinerary is always at section 0
    
}


-(void) removeObjectAtIndexPath: (NSIndexPath *) indexPath
{
    
    [self.tableView beginUpdates];
    
    
    if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Favorites"] )
    {
        [saveData makeSectionDirty: kNTASectionFavorites];
//        [[saveData favorites] removeObjectAtIndex: indexPath.row];
    }
    else if ( [[_tableData titleForSection:indexPath.section] isEqualToString:@"Recent"] )
    {
        [saveData makeSectionDirty: kNTASectionRecentlyViewed];
//        [[saveData recent] removeObjectAtIndex: indexPath.row];
    }
    
    
    // Delete row only if there is more than one row in the table, others delete the entire section
    if ( [_tableData numOfRowsForSection: indexPath.section ] > 1 )
    {
        // Since there are at least 2 objects in Favorites, we can delete a row
        [_tableData removeObjectWithIndexPath: indexPath];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // There is only 1 object remaining in Favorites, delete the section
//        [_tableData removeObjectWithIndexPath:indexPath];
        [_tableData removeSection: indexPath.section];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex: indexPath.section ] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    
    [self.tableView endUpdates];
    
//    [self.tableView reloadData];
    
}



#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *title = [_tableData titleForSection:indexPath.section];

    NTASaveSection selection = kNTASectionNone;

    if ( [title isEqualToString:@"Alerts"] )
    {
        return;
    }

    
    
    if ( [title isEqualToString:@"Favorites"] )
    {
        selection = kNTASectionFavorites;
    }
    else if ( [title isEqualToString:@"Recent"] )
    {
        selection = kNTASectionRecentlyViewed;
    }
    
    
    
    
    if ( selection != kNTASectionNone )
    {
        
        NTASaveObject *sObject = [_tableData objectForIndexPath:indexPath];
        
        [_itinerary setStartStopName: [sObject startStopName] ];
        [_itinerary setEndStopName  : [sObject endStopName]   ];
        [_itinerary setStartStopID  : [sObject startStopID]   ];
        [_itinerary setEndStopID    : [sObject endStopID]     ];
        
        // A selection was made, whether it be in Favorites or Recent; update date
        [sObject setAddedDate:[NSDate date] ];
        
        [saveData makeSectionDirty: selection];
        
        // Sort Favorites/Recent with the new date
        [[_tableData objectForSectionWithTitle:title] sortUsingComparator: sortNextToArriveSaveObjectByDate];
        
        // Update the table view for just the Favorites/Recent section
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[_tableData indexForSectionTitle:title] ] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // Indicate that both the Start and End buttons have been pressed
        _itineraryCompletion = kNextToArriveStartButtonPressed | kNextToArriveEndButtonPressed;
        
        // Then update the itinerary cell
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        
//        [self highlightRetrieveButton];
        [self updateRefreshStatusWith:kNextToArriveRefreshStatusReady];

        
    }

    [self refreshJSONData];


}


-(void) highlightRetrieveButton
{
    //    if ( self.btnRetrieveData.tintColor == [UIColor redColor] )
    //        [self.btnRetrieveData setTintColor:[UIColor blackColor] ];
    //    else
    
    //    REMenuItem *refreshItem = [[_menu items] objectAtIndex:0];
    //    [refreshItem setSubtitle:@"click to refresh data"];
    
    [self updateRefreshStatusWith:kNextToArriveRefreshStatusReady];
    
//    [self.btnRetrieveData setTintColor:[UIColor redColor] ];
    
}


#pragma mark - Buttons Pressed
-(void) backButtonPressed:(id) sender
{

    NSLog(@"Custom Back Button -- %@", sender);
//    [self dismissModalViewControllerAnimated:YES];  // Does not work
//    [self removeFromParentViewController];   // Does nothing!
//    [self.view removeFromSuperview];  // Removed from Superview but doesn't go back to previous VC
    
    
//    [self.navigationController removeFromParentViewController];  // Does not work, does not do anything

    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - REMenu
-(void) dropDownMenuPressed:(id) sender
{
    
    if (_menu.isOpen)
    {
        [menuRefreshTimer invalidate];
        return [_menu close];
    }
    else
    {

//        [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
        
        if ( ![menuRefreshTimer isValid] && [updateTimer isValid] )
            menuRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(menuRefreshUpdate:) userInfo:nil repeats:YES];
        
        if ( updateTimer != nil )
        {
            [self updateRefreshStatusWith:kNextToArriveRefreshStatusInUnknown];
        }
        
        
        [self updateFavoritesStatus];
        
//        CGRect rect = CGRectInset(self.view.frame, 5, 0);
//        CGRect rect = CGRectInset(CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height), 5, 0 );
//        [_menu showFromRect:rect inView:self.tableView ];
//        [_menu showInView: self.tableView];
        
        
        CGRect rect = CGRectInset(CGRectMake(0, self.tableView.contentOffset.y, self.view.frame.size.width, self.view.frame.size.height), 5, 0);
        [_menu showFromRect: rect inView: self.tableView];
        
    }
        
    
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"begin dragging");
    if (_menu.isOpen)
    {
        return [_menu close];
    }
    
    [ALAlertBanner forceHideAllAlertBannersInView:self.view];
    
}

//-(void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//
//    NSLog(@"scrolling");
//    if (_menu.isOpen)
//    {
//        return [_menu close];
//    }
//
//    
//}


-(void) updateFavoritesStatus
{
    
    // Compare the list of Favorites to that of _itinerary

    NSArray *tempArr = [_tableData objectForSectionWithTitle:@"Favorites"];
    if (tempArr == nil)
    {
        
        if ( [_itinerary.startStopName isEqualToString:DEFAULT_START_MESSAGE] && [_itinerary.endStopName isEqualToString:DEFAULT_END_MESSAGE] )
            _favoriteStatus = kNextToArriveFavoriteSubtitleStatusUnknown;  // If either are not set, set status to unknown
        else
            _favoriteStatus = kNextToArriveFavoriteSubtitleNotAdded;  // If both have data, set not added for now.  We'll be checked for Added below.
        
    }
    
    
    NTASaveObject *sObject = [[NTASaveObject alloc] init];
    [sObject setStartStopName: _itinerary.startStopName];
    [sObject setEndStopName  : _itinerary.endStopName];
    [sObject setEndStopID    : _itinerary.endStopID];
    [sObject setStartStopID  : _itinerary.startStopID];
    
    if ( [self doesObject: sObject existInSection:@"Favorites"] != -1 )
    {
        _favoriteStatus = kNextToArriveFavoriteSubtitleAdded;
    }
    else if ( [self doesObject: sObject existInSection:@"Recent"] != -1 )
    {
        _favoriteStatus = kNextToArriveFavoriteSubtitleNotAdded;
    }
   

    
//    for (NTASaveObject *sObject in [_tableData objectForSectionWithTitle:@"Favorites"] )
//    {
//        
//        if ( [_itinerary.startStopName isEqualToString: [sObject startStopName] ] && [_itinerary.endStopName isEqualToString: [sObject endStopName] ] )
//        {
//            _favoriteStatus = kNextToArriveFavoriteSubtitleAdded;
//            break;  // Once a match is found, no reason to continue searching
//        }
//        
//    }
    

    // --==  Update Favorites subtitle
    REMenuItem *refreshItem = [[_menu items] objectAtIndex:1];
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


-(void) menuRefreshUpdate: (NSTimer*) timer
{
    
    
    if ( [updateTimer isValid] )
    {
        NSTimeInterval seconds = [[updateTimer fireDate] timeIntervalSinceDate:[NSDate date] ];
        
        if ( seconds < 1.0f )
        {
            [self updateRefreshStatusWith:kNextToArriveRefreshStatusNow];
        }
        else
        {
            REMenuItem *refreshItem = [[_menu items] objectAtIndex:0];
            [refreshItem setSubtitle:[NSString stringWithFormat:@"refreshing in %d seconds", (int)round([[updateTimer fireDate] timeIntervalSinceDate:[NSDate date]]) ] ];
        }
        
    }  // if ( [updateTimer isValid] )
    
}


-(void)updateRefreshStatusWith:(NextToArriveRefreshStatusMessage) message
{
    
    REMenuItem *refreshItem = [[_menu items] objectAtIndex:0];
    
    switch (message)
    {
        case kNextToArriveRefreshStatusNoStops:
            [refreshItem setSubtitle:REFRESH_NO_STOPS];
            break;
            
        case kNextToArriveRefreshStatusInUnknown:
            [refreshItem setSubtitle:REFRESH_IN_UNKNOWN];
            break;
            
        case kNextToArriveRefreshStatusInXSecs:
            [refreshItem setSubtitle:REFRESH_IN_X_SECS];
            break;
            
        case kNextToArriveRefreshStatusNow:
            [refreshItem setSubtitle:REFRESH_NOW];
            break;
            
        case kNextToArriveRefreshStatusReady:
            [refreshItem setSubtitle:REFRESH_READY];
            break;
            
        default:
            break;
    }
    
}


#pragma mark - NextToArriveItineraryCellProtocol
-(void) itineraryButtonPressed:(NSInteger) buttonType
{
    
    StopNamesTableViewControllerSelectionType selType;
    switch (buttonType)
    {
            
        case kNextToArriveButtonTypeStart:
//            NSLog(@"NtATVC - start label pressed");
            
            // If the start label was pressed but the end is empty, then let's get the user to complete both of them.
//            if ( [_itinerary.endStopID intValue] <= 0 )
            if ( [_itinerary.startStopName isEqualToString: DEFAULT_START_MESSAGE] )
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
            _lastSelectedType = kNextToArriveSelectionNone;
            
            [_itinerary flipStops];
            
            [self updateItinerary];
            
            // If the start/end have been reversed, immediately get the JSON data, but invalidate the current timer first
            [self invalidateTimer];
            [self refreshJSONData];
            
            
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            return;
            break;
            
        default:
            // The code should never reach this point
            return;
            break;
    }
    
    [self invalidateTimer];
    
    _lastSelectedType = selType;
    
    NSString *storyboardName = @"StopNamesStoryboard";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    StopNamesTableViewController *sntvc = (StopNamesTableViewController*)[storyboard instantiateInitialViewController];
    
    [sntvc enableFilter:NO];
    
    // Determine which route type
    RouteData *rData = [[RouteData alloc] init];
    [rData setRoute_type:[NSNumber numberWithInt:kGTFSRouteTypeRail] ];
    
    
    // Pass information to the stopNames VC
    [sntvc setStopData: rData];          // Contains: start/end stop names and id, along with routeType -- the data
    [sntvc setSelectionType: selType];   // Determines its behavior, whether to show only the start, end or both start/end stops information
    [sntvc setDelegate:self];
    
    NSLog(@"NtATVC - itineraryButtonPressed, selectionType: %ld", (long)selType);
    
    [self.navigationController pushViewController:sntvc animated:YES];
    
}



#pragma mark - StopNameTableViewControllerProtocol
-(void) buttonPressed:(StopNamesTableViewControllerButtonPressed) buttonType withData:(StopNamesObject*) stopData
{
    
    // What happened in StopNames VC?  Was the Done button pressed, or was one of the cells selected by either a double tap or long press?
    // Or was the cancel button pressed?
    
//    NSLog(@"stopData: %@", stopData);
    
    switch (buttonType & kNextToArriveButtonMask)
    {
        case kNextToArriveButtonTypeDone:
        case kNextToArriveButtonTypeDoubleTap:
        case kNextToArriveButtonTypeLongPress:
            
            if ( buttonType & kNextToArriveButtonTypeStartField )
            {
                [_itinerary setStartStopID  : stopData.stop_id  ];
                [_itinerary setStartStopName: stopData.stop_name];
                
                _itineraryCompletion |= kNextToArriveStartButtonPressed;
            }
            else if ( buttonType & kNextToArriveButtonTypeEndField )
            {
                [_itinerary setEndStopID  : stopData.stop_id  ];
                [_itinerary setEndStopName: stopData.stop_name];
                
                _itineraryCompletion |= kNextToArriveEndButtonPressed;
            }

            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
        case kNextToArriveButtonTypeCancel:
            break;
            
            
        default:
            break;
    }
 
    [self refreshJSONData];
    
}



//#pragma mark - Load Storyboards
//-(void) loadStopNamesVC
//{
//    
//
//    
//}


-(void) populateGTFSLookUp
{
    [replacement setObject:@"Norristown TC"         forKey:@"Norristown T.C."];
    [replacement setObject:@"Temple U"              forKey:@"Temple University"];
    [replacement setObject:@"Elm St"                forKey:@"Norristown Elm Street"];
    [replacement setObject:@"Neshaminy Falls"       forKey:@"Neshaminy"];
    
    [replacement setObject:@"Mt Airy"               forKey:@"Mount Airy"];
    [replacement setObject:@"Morton"                forKey:@"Morton-Rutledge"];
    [replacement setObject:@"Main St"               forKey:@"Main Street"];
    [replacement setObject:@"Levittown"             forKey:@"Levittown-Tullytown"];
    
    [replacement setObject:@"Jenkintown-Wyncote"    forKey:@"Jenkintown Wyncote"];
    [replacement setObject:@"Highland Ave"          forKey:@"Highland Avenue"];
    [replacement setObject:@"Highland"              forKey:@"Highland Station"];
    [replacement setObject:@"Ft Washington"         forKey:@"Fort Washington"];
    
    [replacement setObject:@"Fernwood"              forKey:@"Fernwood-Yeadon"];
    [replacement setObject:@"Fern Rock TC"          forKey:@"Fern Rock T C"];
    [replacement setObject:@"Elwyn Station"         forKey:@"Elwyn"];
    [replacement setObject:@"Eastwick Station"      forKey:@"Eastwick"];
    
    [replacement setObject:@"Churchmans Crossing"   forKey:@"Churchman's Crossing"];
    [replacement setObject:@"Chester TC"            forKey:@"Chester"];
    [replacement setObject:@"Airport Terminal E-F"  forKey:@"Airport Terminal E F"];
    [replacement setObject:@"Airport Terminal C-D"  forKey:@"Airport Terminal C D"];
    
    [replacement setObject:@"North Philadelphia"    forKey:@"North Philadelphia Amtrak"];
    [replacement setObject:@"Prospect Park"         forKey:@"Prospect Park - Moore"];
    [replacement setObject:@"Wayne Station"         forKey:@"Wayne"];
    [replacement setObject:@"Wayne Jct"             forKey:@"Wayne Junction"];
    
    [replacement setObject:@"49th St"               forKey:@"49th Street"];
    [replacement setObject:@"North Broad St"        forKey:@"North Broad"];
    
    [replacement setObject:@"Market East"           forKey:@"Jefferson Station"];
}


#pragma mark - REMenu Selection
-(void) refreshJSONData
{
    
    if ( !( (_itineraryCompletion & kNextToArriveEndButtonPressed ) && ( _itineraryCompletion & kNextToArriveStartButtonPressed ) ) )
    {
        // Either the Start or End itinerary fields were not set
        return;
    }
    
    [ALAlertBanner hideAllAlertBanners];

    
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    NTASaveObject *sObject = [[NTASaveObject alloc] init];
    [sObject setStartStopName: _itinerary.startStopName];
    [sObject setEndStopName  : _itinerary.endStopName  ];
    
    if ( _itinerary.startStopID == nil  || [_itinerary.startStopID intValue] == 0 )  // ['30th Street Station' intValue] = 30
    {
        [self loadStopIDstartEND:1];
    }
    
    if ( _itinerary.endStopID == nil || [_itinerary.endStopID intValue] == 0 )
    {
        [self loadStopIDstartEND:0];
    }
    
    [sObject setStartStopID: _itinerary.startStopID];
    [sObject setEndStopID  : _itinerary.endStopID];
    [sObject setAddedDate:[NSDate date] ];
    
    
    // --==  WARNING!!  ==--
    
    // All the stop ids from Thorndale to Overbrook, Newark to Darby and Trenton to North Philadelphia
    NSString *darkTerritoryStopIDs = @"90501,90502,90503,90504,90505,90506,90507,90508,90509,90510,90511,90512,90513,90514,90515,90516,90517,90518,90519,90520,90521,90522,90201,90202,90203,90204,90205,90206,90207,90209,90210,90211,90212,90213,90214,90215,90216,90217,90701,90702,90703,90704,90706,90707,90708,90709,90710,90711";

    NSArray *darkTerritoryStopIDArray = [darkTerritoryStopIDs componentsSeparatedByString:@","];

    
    NSString *startID;
    NSString *endID;
    
    @try
    {
        startID = [_itinerary.startStopID stringValue];
        endID   = [_itinerary.endStopID stringValue];
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
    {
        
        // Removed on 02/02/15 due to strange crashing issues that cannot be recreated in a test environment
        
//        NSLog(@"***  DARK TERRITORY!!!  DARK TERRITORY!!  ***");
//        NSLog(@"rect: %@", NSStringFromCGRect(self.tableView.frame));
//
//        __weak typeof(self) weakSelf = self;
//        ALAlertBanner *aBanner = [ALAlertBanner alertBannerForView:self.view
//                                                   style:ALAlertBannerStyleFailure
//                                                position:ALAlertBannerPositionBottom
//                                                   title:@"Non-SEPTA Territory"
//                                                subtitle:@"One or more selected stops are in Non-SEPTA territory.  Tap for more details."
//                                             tappedBlock:^(ALAlertBanner *alertBanner)
//                        {
//
//                            [alertBanner hide];
//                            [weakSelf loadDisclaimer];
//                            
//                        }];
//        
//        NSTimeInterval showTime = 4.0f;
//        [aBanner setSecondsToShow: showTime];
//        
//        [aBanner show];
//        
//        NSLog(@"Banner show!");
        
    }
    


    
    NSInteger row;
    NSString *title;
    if ( (row = [self doesObject:sObject existInSection:@"Favorites"]) != -1 )
    {
        // If the current start/end names already exists in Favorites, nothing to do but update the timestamp
        NTASaveObject *sObject = [_tableData objectForIndexPath: [NSIndexPath indexPathForRow:row inSection:[_tableData indexForSectionTitle:@"Favorites"] ] ];
        [sObject setAddedDate: [NSDate date] ];
        title = @"Favorites";
    }
    else if ( (row = [self doesObject:sObject existInSection:@"Recent"]) != -1 )
    {
        // If the current start/end names already exists in Favorites, nothing to do but update the timestamp
        NTASaveObject *sObject = [_tableData objectForIndexPath: [NSIndexPath indexPathForRow:row inSection:[_tableData indexForSectionTitle:@"Recent"] ] ];
        [sObject setAddedDate: [NSDate date] ];
        title = @"Recent";
    }
    else
    {
    // Since the object doesn't exist in the Favorites or Recent section, add it to Recent
        [self addObject: sObject toSection: kNTASectionRecentlyViewed];
    }
    
//    if ( ![[_tableData returnAllSections] containsObject:@"Recent"] )  // Is there even a Recent section

    if ( title != nil )
        [[_tableData objectForSectionWithTitle:title] sortUsingComparator: sortNextToArriveSaveObjectByDate];

    
    [self.tableView reloadData];
    
    [self invalidateTimer]; // Invalidate any timer that is already active.  If no timer is active, nothing happens
    [self getLatestJSONData];

    
}


//-(NSString*) filePath
//{
//#if FUNCTION_NAMES_ON
//    NSLog(@"NtATVC filePath");
//#endif
//    
//    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
//}


// There are cases where the Saved Object might not have certain information, such as the stop_id for each stop_name.  This function
// updates _itinerary.startStopID and endStopID fields as needed.
-(void) loadStopIDstartEND:(NSInteger) startEND
{
    
    // startEND ->  start (1, true) END (0, false)
    
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    NSString *stopName;
    if ( startEND )
        stopName = [self fixMismatchedStopName: _itinerary.startStopName];
    else
        stopName = [self fixMismatchedStopName: _itinerary.endStopName];
    
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT stop_id FROM stops_rail WHERE stop_name = '%@'", stopName];
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNFRTC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    [results next];
    
    if ( startEND )
        [_itinerary setStartStopID: [NSNumber numberWithInt: [results intForColumnIndex:0] ] ];
    else
        [_itinerary setEndStopID  : [NSNumber numberWithInt: [results intForColumnIndex:0] ] ];
    
}


-(void) addObject: (NTASaveObject*) sObject toSection: (NTASaveSection) section
{
    
    NSMutableArray *genericArr;
    NSString *title;
    int tag;
    
    if ( section == kNTASectionFavorites )
    {
        tag = kNextToArriveSectionFavorites;
        title = @"Favorites";
        genericArr = [saveData favorites];
    }
    else if ( section == kNTASectionRecentlyViewed )
    {
        tag = kNextToArriveSectionRecent;
        title = @"Recent";
        genericArr = [saveData recent];
    }
    else
        return;
    
    
    if ( [_tableData indexForSectionTitle: title] == NSNotFound )
    {
        [_tableData addSectionWithTitle: title];
        [_tableData setTag:tag forTitle: title];
        [_tableData sortByTags];
    }
    
    [sObject setAddedDate: [NSDate date] ];
    
    [saveData addObject: sObject intoSection:section];
    [_tableData replaceArrayWith: genericArr forTitle:title];
    
}


-(NSInteger) doesObject:(NTASaveObject*) sObject existInSection:(NSString*) title
{
    
    if ( title == nil )
        return -1;
    
    if ( [_tableData objectForSectionWithTitle:title] == nil )
        return -1;
    
    
    int count = 0;
    for (NTASaveObject *sObject in [_tableData objectForSectionWithTitle:title] )
    {
        if ( [[sObject startStopName] isEqualToString:_itinerary.startStopName] && [[sObject endStopName] isEqualToString: _itinerary.endStopName] )
            return count;
        count++;
    }
    
    return -1;
    
}

//-(void) removeObject:(NTASaveObject*) sObject ifItExistsInSection:(NSString*) title
-(void) removeObject:(NTASaveObject*) sObject ifItExistsInSection:(NTASaveSection) section
{
    
    NSString *title;
    
    if ( section == kNTASectionFavorites )
        title = @"Favorites";
    else if ( section == kNTASectionRecentlyViewed )
        title = @"Recent";
    
    
    if ( title == nil )
        return;
    
    if ( [_tableData objectForSectionWithTitle:title] == nil )
        return;
        

    
    // Remove object from saveData recent/favorites
    NSInteger row;
    NSIndexPath *indexPath;
    if ( ( row = [self doesObject:sObject existInSection:title] ) != -1 )
    {
        indexPath = [NSIndexPath indexPathForRow:row inSection: [_tableData indexForSectionTitle: title] ];
        [self removeObjectAtIndexPath: indexPath];
    }
    return;
    
    
//    int count = 0;  // Reading NSArray in sequential order
//    NSIndexPath *indexPath;
//    
//    for (NTASaveObject *sObject in [_tableData objectForSectionWithTitle:title] )
//    {
//        if ( [[sObject startStopName] isEqualToString:_itinerary.startStopName] && [[sObject endStopName] isEqualToString: _itinerary.endStopName] )
//        {
//            indexPath = [NSIndexPath indexPathForRow:count inSection: [_tableData indexForSectionTitle: title] ];
//            
//            break;
//        }
//        count++;
//    }
//    
//    if ( indexPath != nil )
//    {
//        
//        
////        [self removeObjectAtIndexPath:indexPath];
//    }
    
}


-(void) selectedFavorites
{
    
    // _favoriteStatus is unknown
    if ( _favoriteStatus == kNextToArriveFavoriteSubtitleStatusUnknown )
        return;
    

    NTASaveObject *sObject = [[NTASaveObject alloc] init];
    [sObject setStartStopName: _itinerary.startStopName];
    [sObject setEndStopName  : _itinerary.endStopName  ];
    [sObject setStartStopID  : _itinerary.startStopID  ];
    [sObject setEndStopID    : _itinerary.endStopID    ];
    [sObject setAddedDate: [NSDate date] ];
    
    // The currente itinerary has been added to Favorites.  Click on it again will remove it
    if ( _favoriteStatus == kNextToArriveFavoriteSubtitleAdded )
    {
        [self removeObject: sObject ifItExistsInSection: kNTASectionFavorites];
        [self addObject   : sObject toSection: kNTASectionRecentlyViewed];

        [self.tableView reloadData];
        return;
    }


//    NSInteger locatedAt;
//    locatedAt = [saveData addObject: sObject intoSection: kNTASectionFavorites];
//    NSLog(@"NTAVC - saveData, locatedAt: %d", locatedAt);  // if locatedAt == NSNotFound, it wasn't found in the Favorites

//    NSLog(@"%@", _tableData);
    
    BOOL newSection = NO;
    if ( [_tableData objectForSectionWithTitle:@"Favorites"] == nil )
    {
        newSection = YES;
//        [_tableData addSectionWithTitle:@"Favorites"];
//        [_tableData setTag:kNextToArriveSectionFavorites forTitle:@"Favorites"];
//        [_tableData sortByTags];
//        [self.tableView reloadData];
    }
        
    
    // Check if trip exists in Recent and, if so, remove it.
    [self removeObject: sObject ifItExistsInSection: kNTASectionRecentlyViewed];
    [self addObject   : sObject toSection:kNTASectionFavorites];
    
//    [saveData addObject: sObject intoSection: kNTASectionFavorites];
//    [_tableData replaceArrayWith: [saveData favorites] forTitle: @"Favorites"];
    
//    [_tableData addObject:sObject forTitle:@"Favorites" withTag: kNextToArriveSectionFavorites];
    
    [ [_tableData objectForSectionWithTitle:@"Favorites" ] sortUsingComparator:sortNextToArriveSaveObjectByDate];
    
//    [self.tableView reloadData];
//    return;
    
    
    
    
    
    if ( newSection )
    {
        // Favorites always appears after Itineray but before Recent
        [_tableData moveSection:[_tableData indexForSectionTitle:@"Favorites"] afterSection:[_tableData indexForSectionTitle:@"Itinerary"] ];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:[_tableData indexForSectionTitle:@"Favorites"] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[_tableData indexForSectionTitle:@"Favorites"] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
//    [self.tableView reloadData];
    
    
    NSLog(@"Done");
}


NSComparisonResult (^sortNextToArriveSaveObjectByDate)(NTASaveObject*,NTASaveObject*) = ^(NTASaveObject *a, NTASaveObject *b)
{
    return [[b addedDate] compare: [a addedDate] ];
};


-(void) invalidateTimer
{
    
    if ( updateTimer != nil )
    {
        if ( [updateTimer isValid]  )
        {
            REMenuItem *refreshItem = [[_menu items] objectAtIndex:0];
            [refreshItem setSubtitle:@"click to refresh"];
            
            [updateTimer invalidate];
            updateTimer = nil;
        }
    }
    else
    {
//        NSLog(@"NTAVC - Trying to send messages to updateTimer which no longer exists.");
    }
    
}


-(void) getAlertsForLines: (NSArray*) lines
{
 
    
    // Check for Internet connection
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
        return;  // Don't bother continuing if no internet connection is available
    
    
    if ( _stillWaitingOnAlertRequest )  // Avoid asking the server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnAlertRequest = YES;


//    [alertLineDict setObject:@"rr_route_cyn" forKey:@"Cynwyd"];
//    [alertLineDict setObject:[NSArray arrayWithObjects:@"rr_route_gc",@"rr_route_landdoy", nil] forKey:@"Lansdale/Doylestown"];
    
    if ( [lines count] == 0 )
        return;  // Nothing to process
    
//    NSMutableArray *lineArr = [[NSMutableArray alloc ] init];
    NSMutableDictionary *lineDict = [[NSMutableDictionary alloc] init];
    
    for (id line in lines)
    {

        id result = [alertLineDict objectForKey:line];  // The results of alertLineDict can either be a string or an NSArray, nothing else
        
        if ( [result isKindOfClass:[NSArray class] ] )
        {
            for (NSString *l in result )
            {
                [lineDict setObject:@"1" forKey:l];
            }
        }
        else
        {
            [lineDict setObject:@"1" forKey:[alertLineDict objectForKey:line]];
        }
        
    }
    
    NSString *lineStr = [[lineDict allKeys] componentsJoinedByString:@","];
    
    
    NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/beta/Alerts/get_alert_data.php?route_id=%@", lineStr];
    
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"NTAVC - getAlertsForLines -- api url: %@", webStringURL);

    _alertOp = [[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOp = _alertOp;
    [weakOp addExecutionBlock:^{
        
        NSData *alertData = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self processAlertData:alertData];
            }];
        }
        else
        {
            NSLog(@"NTAVC - getAlertsForLines: _jsonOp cancelled");
        }
        
    }];
    
    [_jsonQueue addOperation: _alertOp];
    
    
}



-(void) getLatestJSONData
{
    
    NSLog(@"NTAVC - getLatestJSONData");
    
//    NSLog(@"DSTVC - getLatestBusJSONData");
    
    // Check for Internet connection
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
        return;  // Don't bother continuing if no internet connection is available
    
    
    // If start and end points haven't been entered, do nothing
    //    if ( ( _startObject.stop_name == nil ) || ( _endObject.stop_name == nil ) )
    //    _startStopName = [[[_tData data] objectAtIndex:0] objectAtIndex:0];
    //    _endStopName   = [[[_tData data] objectAtIndex:0] objectAtIndex:1];
    
    
    NSString *startStopName = [self fixMismatchedStopName: [_itinerary startStopName] ];
    NSString *endStopName   = [self fixMismatchedStopName: [_itinerary endStopName] ];
    
    
    if ( ( startStopName == nil ) || ( endStopName == nil ) )
        return;
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
    NSString *_newStartStop = [self fixMismatchedStopName: startStopName];
    NSString *_newEndStop   = [self fixMismatchedStopName: endStopName];
    
    NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/NextToArrive/%@/%@/50", _newStartStop, _newEndStop];
    
    
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"NTAVC - getLatestRailJSONData -- api url: %@", webStringURL);
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    _jsonOp = [[NSBlockOperation alloc] init];
    
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
    
    
    //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
    //
    //            NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
    //            [self performSelectorOnMainThread:@selector(processJSONData:) withObject: realTimeTrainInfo waitUntilDone:YES];
    //            
    //        });
    
}


-(NSString *) fixMismatchedStopName: (NSString*) stopName;
{
    
    // Unfortunately, at the time of writing this method, there are a few stop names in the GTFS file
    // that do not match up with the stop name of an internal SEPTA database.  As such, this method
    // looks for one of those stop names and replaces it with one that matches the internal name.
    
    // P.S. This is horrible code, if anyone asks, I'll deny ever writing in.
    //   Ran php jarowinkler | egrep -v 100% to find the gasps between the GTFS and internal naming.
    
    NSString *temp = [replacement objectForKey:stopName];
    
    if ( temp != nil )
    {
//        NSLog(@"NTAVC - fixMismatchedStopName: replacing %@ with %@", stopName, temp);
        return temp;
    }
    else
        return stopName;
    
}



-(void) kickOffAnotherJSONRequest
{
    
    if ( _killAllTimers )
    {
        [self invalidateTimer];
        return;
    }
    
    NSLog(@"NTAVC - kickOffAnotherJSONRequest");
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:JSON_REFRESH_RATE
                                                  target:self
                                                selector:@selector(getLatestJSONData)
                                                userInfo:nil
                                                 repeats:NO];
}


-(void) processAlertData:(NSData*) returnedData
{

    _stillWaitingOnAlertRequest = NO;
    
    
    if ( returnedData == nil )  // If we didn't even receive data, try again in another JSON_REFRESH_RATE seconds
    {
        NSLog(@"NTAVC - processAlertData - kicking off another Alert request - 1");
        [self kickOffAnotherJSONRequest];
        return;
    }
 
    
    NSMutableArray *myData;
    myData = [[NSMutableArray alloc] init];
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    
    if ( json == nil || error != nil )  // Something bad happened, so just return
    {
        NSLog(@"NTAVC - processJSON - kicking off another Alert request - 2");
        [self kickOffAnotherJSONRequest];  // And before we return, let's try again in JSON_REFRESH_RATE seconds
        return;
    }
    
    
//    NSMutableDictionary *jsonTest = [[NSMutableDictionary alloc] init];
    
    if ( /* DISABLES CODE */ (0) )  // Set to 1 when testing, 0 when um... the opposite.
    {
        NSMutableArray *jsonTest = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *route = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"rr_route_warm",@"route_id",@"Warminster",@"route_name",@"Warminster Train #426 will now fly directly from Glenside to Jefferson Station.  Please be aware of the change in trip.  Frequent flyer miles can be redeemed at the SEPTA store at 1234 Market Street.",@"current_message", nil];
        
        [jsonTest addObject: route];
        
        route = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"generic",@"route_id",@"Generic",@"route_name",@"RRD: Warminster Train #4331 is canceled from Warmisnter to Glenside. Service will begin at Glenside to depart the scheduled time of 9:08AM",@"current_message", nil];
        
        [jsonTest addObject: route];

        route = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"rr_route_gc",@"route_id",@"Glenside Combined",@"route_name",@"Glenside will be combined with Anti-Glenside and used to power the entire Eastern coast.  Please be advised that any anomalies should be avoided and promptly reported to the Department of Time and Space (DTS).",@"current_message", nil];

        [jsonTest addObject: route];
        
        json = jsonTest;
        
    }
    
    for (NSDictionary *data in json)
    {
        
        if ( [_alertOp isCancelled] )
            return;

        SystemAlertObject *saObj = [[SystemAlertObject alloc] init];
        
        NSString *cMessage = [(NSString*)[data objectForKey:@"current_message"] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        
        [saObj setRoute_id: [data objectForKey:@"route_id"] ];
        [saObj setRoute_name: [data objectForKey:@"route_name"] ];
        [saObj setCurrent_message: cMessage];
//        [saObj setCurrent_message: [data objectForKey:@"current_message"] ];

//        if ( [saObj.route_name isEqualToString:@"Generic"] )  // Generic requires a specific check
//            [saObj setCurrent_message:@"RRD: Warminster Train #4331 is canceled from Warmisnter to Glenside. Service will begin at Glenside to depart the scheduled time of 9:08AM"];  // Test
        
        
        if ( [saObj.current_message length] > 1 )  // Is there any data in the current_message?
        {
            
            if ( [saObj.route_name isEqualToString:@"Generic"] )  // Generic requires a specific check
            {
                
                // If Current_message contains RRD, add it to myData, otherwise ignore it.
                if ( [saObj.current_message rangeOfString:@"RRD"].location != NSNotFound )
                {
//                    [myData addObject: [self formatCurrentMessage: saObj.current_message] ];
                    AlertMessage *alertMsg = [[AlertMessage alloc] init];
                    [alertMsg setText: saObj.current_message];
                    [alertMsg updateAttrText];
                    
                    [myData addObject: alertMsg];
                }
            }
            else
            {
//                [myData addObject: [self formatCurrentMessage: [NSString stringWithFormat:@"%@: %@",saObj.route_name, saObj.current_message] ] ];
                AlertMessage *alertMsg = [[AlertMessage alloc] init];
                [alertMsg setText: [NSString stringWithFormat:@"%@: %@",saObj.route_name, saObj.current_message] ];
                [alertMsg updateAttrText];
                
                [myData addObject: alertMsg];
            }

            
        }
        else
        {
            
        }
        
        
        
    }
    
//    [self.tableView beginUpdates];
    
    if ( [myData count] == 0 )  // If the data is empty, remove the Alerts section
    {
        [_tableData removeSectionWithTitle:@"Alerts"];
    }
    else if ( [_tableData indexForSectionTitle:@"Alerts"] == NSNotFound )  // If Alerts is not found in _tableData, add it.
    {
        [_tableData addSectionWithTitle:@"Alerts"];
        [_tableData setTag:kNextToArriveSectionAlerts forTitle:@"Alerts"];
        [_tableData addArray:myData forTitle:@"Alerts"];
        [_tableData sortByTags];

//        [_tableData moveSection:[_tableData indexForSectionTitle:@"Data"] afterSection:[_tableData indexForSectionTitle:@"Alerts"] ];
    }
    else  // Otherwise, just update the Alerts section with the new data
    {
        [_tableData clearSectionWithTitle:@"Alerts"];
        [_tableData replaceArrayWith: myData forTitle:@"Alerts"];
    }
    
    
    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[_tableData indexForSectionTitle:@"Alerts"] ] withRowAnimation:UITableViewRowAnimationAutomatic];

//    [self.tableView endUpdates];
    
//    NSLog(@"JSON: %@", json);
    
}


-(AlertMessage*) formatCurrentMessage: (NSString*) message
{
    
    NSRange endRange = [message rangeOfString:@":"];
    
    NSString *title = @"";
    NSString *text  = @"";
    
    if (endRange.length != NSNotFound )
    {
        title = [message substringToIndex:endRange.location+1];
        text = [message substringFromIndex:endRange.location+2];
    }
    
    
    UIFont *boldFont    = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14.0];
    UIFont *defaultFont = [UIFont fontWithName:@"Trebuchet MS"      size:14.0];

    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
//    [paraStyle setLineSpacing:24.0f];
//    [paraStyle setLineHeightMultiple:0.85f];
    
//    NSDictionary *titleDict = [NSDictionary dictionaryWithObject: boldFont forKey:NSFontAttributeName];
    NSDictionary *titleDict = [NSDictionary dictionaryWithObjectsAndKeys:boldFont, NSFontAttributeName, paraStyle, NSParagraphStyleAttributeName, nil];
    
    NSMutableAttributedString *titleAttrString = [[NSMutableAttributedString alloc] initWithString:title attributes: titleDict];

    
    NSDictionary *textDict = [NSDictionary dictionaryWithObject:defaultFont forKey:NSFontAttributeName];
    NSMutableAttributedString *textAttrString = [[NSMutableAttributedString alloc]initWithString: text attributes:textDict];
    [textAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:(NSMakeRange(0, 15))];
    
    
    [titleAttrString appendAttributedString:textAttrString];
//    [titleAttrString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, [message length])];
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 10;  // Take the same space off as the formatCell method
    CGRect rect = [titleAttrString boundingRectWithSize:CGSizeMake(width,9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  context:nil];
    
    //    CGSize sizeNew = [titleAttrString size];
    //    NSLog(@"width: %6.4f",[UIScreen mainScreen].bounds.size.width);
    
//    CGFloat height = rect.size.height;
    
//    return [NSDictionary dictionaryWithObjectsAndKeys:@"text",titleAttrString,@"height",[NSNumber numberWithFloat:height], nil];
    
    AlertMessage *aMsg = [[AlertMessage alloc] init];
    
//    [aMsg setHeight: [NSNumber numberWithFloat:height] ];
    [aMsg setRect: NSStringFromCGRect(rect)];
    NSLog(@"Rect: %@ with Message: %@",aMsg.rect, message);
    [aMsg setAttrText: titleAttrString];
    
    return aMsg;
    
}


-(void) processJSONData:(NSData*) returnedData
{
    
    [SVProgressHUD dismiss];
    _stillWaitingOnWebRequest = NO;
    
    
    if ( returnedData == nil )  // If we didn't even receive data, try again in another JSON_REFRESH_RATE seconds
    {
        NSLog(@"NTAVC - processJSON - kicking off another JSON request - 1");
        [self kickOffAnotherJSONRequest];
        return;
    }
    
    //    NSMutableArray *tableData;  // Array of NextToArrivaJSONObjects
    //    tableData = [[NSMutableArray alloc] init];
    
//    [ntaDataSection removeAllObjects];
    

    NSMutableDictionary *dataLines = [[NSMutableDictionary alloc] init];
    [dataLines setObject:@"1" forKey:@"Generic"];  // Always add Generic upon JSON refresh
    
    
    NSMutableArray *myData;
    myData = [[NSMutableArray alloc] init];
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];

    
    if ( json == nil || error != nil )  // Something bad happened, so just return
    {
        NSLog(@"NTAVC - processJSON - kicking off another JSON request - 2");
        [self kickOffAnotherJSONRequest];  // And before we return, let's try again in JSON_REFRESH_RATE seconds
        return;
    }
    
    
    for (NSDictionary *data in json)
    {
        
        if ( [_jsonOp isCancelled] )
            return;
        
        NextToArrivaJSONObject *ntaObject = [[NextToArrivaJSONObject alloc] init];
        
        [ntaObject setConnection: [data objectForKey:@"Connection"] ];
        [ntaObject setIsdirect: [data objectForKey:@"isdirect"] ];
        
        
        NSString *time = [data objectForKey:@"orig_arrival_time"];
        [ntaObject setOrig_arrival_time: [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] ];
        [ntaObject setOrig_delay: [data objectForKey:@"orig_delay"] ];
        
        
        time = [data objectForKey:@"orig_departure_time"];
        [ntaObject setOrig_departure_time: [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] ];
        
        [ntaObject setOrig_line: [data objectForKey:@"orig_line"] ];
        [ntaObject setOrig_train: [data objectForKey:@"orig_train"] ];
        
        [dataLines setObject:@"1" forKey:ntaObject.orig_line];
        
        time = [data objectForKey:@"term_arrival_time"];
        [ntaObject setTerm_arrival_time: [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] ];
        
        [ntaObject setTerm_delay: [data objectForKey:@"term_delay"] ];
        
        time = [data objectForKey:@"term_depart_time"];
        [ntaObject setTerm_depart_time: [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] ];
        
        [ntaObject setTerm_line: [data objectForKey:@"term_line"] ];
        [ntaObject setTerm_train: [data objectForKey:@"term_train"] ];
        
            [myData addObject:ntaObject];
//        [_tableData addObject: ntaObject];  // Because we cleared the @"Data" above, the _tableData internal indexPath is pointing to the @"Data" section
        
    }
    
    _ntaUniqueLines = [dataLines allKeys];  // Take all the keys and put them into the _ntaUniqueLines array
    
    if ( [_tableData indexForSectionTitle:@"Data"] == NSNotFound )
    {
        [_tableData addSectionWithTitle:@"Data"];
        [_tableData setTag:kNextToArriveSectionData forTitle:@"Data"];
    }
    
    [_tableData clearSectionWithTitle:@"Data"];
    
    [_tableData replaceArrayWith: myData forTitle:@"Data"];
    _launchUpdateTimer = YES;
    
    // Only start the timer for the next JSON request after
    NSLog(@"NTAVC - processJSON - kicking off another JSON request - 3");
    [self kickOffAnotherJSONRequest];
    
    [self getAlertsForLines:_ntaUniqueLines];
    
    //    [self sortDataWithIndex: _previousIndex];
    [self.tableView reloadData];
    
}




#pragma mark - Gestures
- (IBAction)longPressRecognized:(UILongPressGestureRecognizer*)sender
{
    // Since a long press is triggered before a tap, a LP on a favorite or recent will not actually load any data into the start/end fields
    // Do that now

//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    UILongPressGestureRecognizer *gesture = (UILongPressGestureRecognizer*) sender;
    
    if ( gesture.state == UIGestureRecognizerStateBegan )
    {
//        NSLog(@"NtATVC - Began");
        CGPoint touchPoint = [sender locationInView: self.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];

//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        if ( [cell isKindOfClass: [NextToArriveTripHistoryCell class] ] )
//        {
//            _ntaProgress = [[NTAProgressObject alloc] init];
//            [_ntaProgress startWithCell:(NextToArriveTripHistoryCell*)cell];
//            [_ntaProgress setMax:60];
//        }
        
        [self tableView:self.tableView didSelectRowAtIndexPath: indexPath];
        [self refreshJSONData];
        
//        NSLog(@"NtATVC - loading data in indexPath: %@", row);
    }
    else if ( gesture.state == UIGestureRecognizerStateRecognized )
    {
//        NSLog(@"NtATVC - Recognized");
//        NSLog(@"count: %d", [_ntaProgress count]);
//        [_ntaProgress clear];
//        _ntaProgress = nil;
        
    }
//    else if ( gesture.state == UIGestureRecognizerStateEnded )
//    {
//        NSLog(@"NtATVC - Ended");
//    }
    else if ( gesture.state == UIGestureRecognizerStateChanged )
    {
//        NSLog(@"NtATVC - Changed");
        
//        CGPoint touchPoint = [sender locationInView: self.view];
//        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
//        
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        if ( [cell isKindOfClass: [NextToArriveTripHistoryCell class] ] )
//        {
//            if ( _ntaProgress.cell == cell )
//                [_ntaProgress clear];
//        }
        
    }
//    else if ( gesture.state == UIGestureRecognizerStateFailed )
//    {
//        NSLog(@"NtATVC - Failed");
//    }
//    else if ( gesture.state == UIGestureRecognizerStatePossible )
//    {
//        NSLog(@"NtATVC - Possible");
//    }


}


//- (IBAction)doubleTapRecognized:(id)sender1
//{
//    //    [self refreshJSONData];
//    
//    NSLog(@"Double Tab");
//    
//}


-(void) loadDisclaimer
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"IVC - loadDisclaimer");
#endif
    
    
    NSString *storyboardName = @"CommonWebViewStoryboard";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    CommonWebViewController *cwVC = (CommonWebViewController*)[storyboard instantiateViewControllerWithIdentifier:@"CommonWebViewStoryboard"];
    
    //    [cwVC setAlertArr: _currentAlert ];
    [cwVC setBackImageName: @"NTA-white.png"];
    [cwVC setTitle:@"Real Time"];
    
    NSString *p1 = @"<p class='indent'>In the event of a significant delay on a regularly scheduled train you may see the word 'SUSPEND' in the status column. This may mean the train is temporarily canceled while we work on a problem or it may mean the train will not continue operation. In that case, you may see a listing for another train with a different origination point and the same train number with a 'P' after it, i.e., 6353P. The 'P' means that SEPTA has sent another train to pick up customers to complete the original train's journey. If a train has been 'suspended' it will not appear as the second train of a connecting trip</p>";
    
    NSString *p2 = @"<p class='indent'>SEPTA operates 13 rail lines that travel to destinations across the region. Some of these trains operate on SEPTA controlled track and some on Amtrak territory. Our Regional Rail Control Center can 'see' all of the trains traveling on SEPTA territory in real time, so the status information posted on TrainView is also in real time. Train status for service originating from Amtrak territory - Newark, DE (WIL), Trenton , NJ, (TRE) and Thorndale (PAO) - is estimated times, since the Control Center cannot 'see' the actual movement of these trains. When the Control Center receives updated reports about these trains that information is published on TrainView.</p>";
    
    NSString *html = [NSString stringWithFormat:@"<html><head><title>Next To Arrive</title></head><body><div><ul> <li>%@</li> <li>%@</li> </ul> </div>", p2, p1];
    
    [cwVC setHTML: html];
    
    [self.navigationController pushViewController:cwVC animated:YES];
    
    
}


#pragma mark - Fare ViewController
-(void) loadFareVC
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FareStoryboard" bundle:nil];
    FareViewController *fVC = (FareViewController*)[storyboard instantiateInitialViewController];
    [self.navigationController pushViewController: fVC animated: YES];
    
}

@end
