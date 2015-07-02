//
//  RouteSelectionViewController.m
//  iSEPTA
//
//  Created by septa on 8/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "RouteSelectionViewController.h"

#import "BusDisplayStopsViewController.h"  // Delete me eventually
#import "ItineraryTripViewController.h"


#import "UITableViewStandardHeaderLabel.h"

//#import "TestDisplayedRouteData.h"

// Custom UITableViewCell
#import "UserPreferenceCell.h"
#import "BusRoutesDefaultCell.h"

#import "SVProgressHUD.h"

//#import "DisplayStopTimesViewController.h"

#import "FMDatabase.h"

//#define NSLog //


@interface RouteSelectionViewController ()

@end

@implementation RouteSelectionViewController
{
    //    PassedRouteData *_routeData;
    DisplayedRouteData *_routeData;
    
    FMDatabase *database;
    
    BOOL _didJustLoad;
    
    NSMutableArray *sectionIndex;
    NSMutableArray *sectionTitle;

    
    // --== For Alerts
//    NSMutableArray *_systemStatusArray;
    NSMutableDictionary *_ssDict;  // Key: GTFS route name, Value: SystemStatusObject
    NSString *_genericAlert;
    
    BOOL _stillWaitingOnAlertRequest;
    BOOL _stillWaitingOnGenericAlertRequest;
    
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_alertMainOp;
    NSBlockOperation *_alertDetailsOp;
    
    NSString *_alertMode;

    
}

@synthesize navbarSearchButton;
@synthesize travelMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - willAnimateRotationToInterfaceOrientation");
#endif
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    
    [titleView updateWidth: w];
//    NSLog(@"RSVC:wARtIO - titleView frame: %@, w: %5.2f", NSStringFromCGRect(titleView.frame), w);
    
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];

    // Refresh visible cells
//    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
    NSLog(@"RSVC - willAnimateRotationToInterfaceOrientation; reload");
    [self.tableView reloadData];
    
}



- (void)viewDidLoad
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - viewDidLoad");
#endif

#if DEBUG
  // Debug code goes here
#endif
    
    //    NSLog(@"BSVC -(void) viewDidLoad");
    [super viewDidLoad];
    
    //    NSLog(@"Travel Mode: %@", travelMode);
    
    [self loadRouteData];
    _didJustLoad = YES;
    
    
//    if ( [self.tableView respondsToSelector:@selector(setSectionIndexColor:)] )
//        [self.tableView setSectionIndexColor: [UIColor whiteColor]];
    
    _jsonQueue = [[NSOperationQueue alloc] init];
    
    
    // Register NIBs with Table View
    [self.tableView registerNib:[UINib nibWithNibName:@"UserPreferenceCell" bundle:nil] forCellReuseIdentifier:@"UserPreferenceCell"];
//    [self.tableView registerNib:[UINib nibWithNibName:@"BusRoutesDefaultCell" bundle:nil] forCellReuseIdentifier:@"BusRoutesDefaultCell"];
    
    // New Xibs, BusRoutesDefaultCell replacement
    [self.tableView registerNib:[UINib nibWithNibName:@"RouteSelectionCell" bundle:nil] forCellReuseIdentifier:@"RouteSelectionCell"];
    
    // Alerts - For displaying RRD generic and line-specific alerts
    [self.tableView registerNib:[UINib nibWithNibName:@"NextToArriveAlerts" bundle:nil] forCellReuseIdentifier:@"NextToArriveAlertsCell"];

    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.view setBackgroundColor: backgroundColor];
    
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ];
//    [backgroundImage setContentMode: UIViewContentModeScaleAspectFill];
//    backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
//    [self.view addSubview:backgroundImage];
//    [self.view sendSubviewToBack:backgroundImage];

    
//    _systemStatusArray = [[NSMutableArray alloc] init];
    _ssDict = [[NSMutableDictionary alloc] init];
    
    NSString *title;
    NSString *backButtonImage = @"";
    CGFloat fontSize = 45.0f/2.0f;
    if ( [travelMode isEqualToString:@"Rail"] )
    {
        title = @"Regional Rail Lines";
        backButtonImage = @"RRL_white.png";
    }
    else if ( [travelMode isEqualToString:@"Bus"] )
    {
        title = @"Bus";
        backButtonImage = @"Bus_white.png";
    }
    else if ( [travelMode isEqualToString:@"Trolley"] )
    {
        title = @"Trolley";
        backButtonImage = @"Trolley_white.png";
    }
    else if ( [travelMode isEqualToString:@"MFL"] )
    {
        title = @"Market-Frankford Line";
        backButtonImage = @"MFL_white.png";
        fontSize = 20.0f;
    }
    else if ( [travelMode isEqualToString:@"BSS"] || [travelMode isEqualToString:@"BSL"]  )
    {
        title = @"Broad Street Line";
        backButtonImage = @"BSL_white.png";
    }
    else if ( [travelMode isEqualToString:@"NHSL"] )
    {
        title = @"NHSL";
        backButtonImage = @"NHSL_white.png";
    }
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed: backButtonImage
                                                                                  withTarget:self
                                                                               andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: title withFontSize: fontSize];
    [self.navigationItem setTitleView:titleView];
    
    
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    [self configureTableView];

    [self.searchDisplayController.searchBar setHidden:YES];

    [self getUnfilteredBusRoutes];
    
    [self getMainAlerts];
    [self getGenericAlertDetails];
    
}

-(void) updateRouteData
{

    DisplayedRouteData *newData;
    if ( [[self travelMode] isEqualToString:@"Bus"] )
    {
        newData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingDBBus];
        _alertMode = @"Bus";
        //        [_routeData setDatabaseType:kDisplayedRouteDataUsingDBBus];
    }
    else if ( [[self travelMode] isEqualToString:@"Trolley"] )
    {
        newData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingTrolley];
        _alertMode = @"Trolley";
    }
    else if ( [[self travelMode] isEqualToString:@"Rail"] )
    {
        newData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingDBRail];
        _alertMode = @"Regional Rail";
        //        [_routeData setDatabaseType:kDisplayedRouteDataUsingDBRail];
    }
    else if ( [[self travelMode] isEqualToString:@"MFL"] )
    {
        newData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingMFL];
        _alertMode = @"Market/ Frankford";
        //        [_routeData setDatabaseType:kDisplayedRouteDataUsingDBBus];
        
    }
    else if ( [[self travelMode] isEqualToString:@"BSS"] || [travelMode isEqualToString:@"BSL"]  )
    {
        newData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingBSS];
        _alertMode = @"Broad Street Line";
    }
    else if ( [[self travelMode] isEqualToString:@"NHSL"])
    {
        newData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingNHSL];
        _alertMode = @"Norristown High Speed Line";
    }
    else
        return;  // travelMode needs to be a recognized type otherwise nothing is going to work
    
    for (NSArray *favorite in newData.favorites)
    {
        NSLog(@"%@",favorite);
    }
    
    [_routeData setFavorites     : newData.favorites];
    [_routeData setRecentlyViewed: newData.recentlyViewed];
    
}

-(void) loadRouteData
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - loadRouteData");
#endif

    
    if ( [[self travelMode] isEqualToString:@"Bus"] )
    {
        _routeData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingDBBus];
        _alertMode = @"Bus";
        //        [_routeData setDatabaseType:kDisplayedRouteDataUsingDBBus];
    }
    else if ( [[self travelMode] isEqualToString:@"Trolley"] )
    {
        _routeData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingTrolley];
        _alertMode = @"Trolley";
    }
    else if ( [[self travelMode] isEqualToString:@"Rail"] )
    {
        _routeData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingDBRail];
        _alertMode = @"Regional Rail";
        //        [_routeData setDatabaseType:kDisplayedRouteDataUsingDBRail];
    }
    else if ( [[self travelMode] isEqualToString:@"MFL"] )
    {
        _routeData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingMFL];
        _alertMode = @"Market/ Frankford";
        //        [_routeData setDatabaseType:kDisplayedRouteDataUsingDBBus];
        
    }
    else if ( [[self travelMode] isEqualToString:@"BSS"] || [travelMode isEqualToString:@"BSL"]  )
    {
        _routeData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingBSS];
        _alertMode = @"Broad Street Line";
    }
    else if ( [[self travelMode] isEqualToString:@"NHSL"])
    {
        _routeData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingNHSL];
        _alertMode = @"Norristown High Speed Line";
    }
    else
        return;  // travelMode needs to be a recognized type otherwise nothing is going to work
    
}


- (NSArray *)recursivePathsForResourcesOfType:(NSString *)type inDirectory:(NSString *)directoryPath
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - recursivePathsForResourcesOfType:%@ inDirectory:%@", type, directoryPath);
#endif
    
    
    NSMutableArray *filePaths = [[NSMutableArray alloc] init];
    
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    
    NSString *filePath;
    
    while ((filePath = [enumerator nextObject]) != nil){
        
        // If we have the right type of file, add it to the list
        // Make sure to prepend the directory path
        if([[filePath pathExtension] isEqualToString:type]){
            [filePaths addObject:[directoryPath stringByAppendingString:filePath]];
        }
    }
    
    return filePaths;
    
}

-(NSArray *)findFiles:(NSString *)extension
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - findFiles:%@", extension);
#endif

    
    NSMutableArray *matches = [[NSMutableArray alloc]init];
    NSFileManager *fManager = [NSFileManager defaultManager];
    NSString *item;
    NSArray *contents = [fManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] error:nil];
    
    // >>> this section here adds all files with the chosen extension to an array
    for (item in contents){
        if ([[item pathExtension] isEqualToString:extension]) {
            [matches addObject:item];
        }
    }
    return matches;
}


-(NSArray *)listFileAtPath:(NSString *)path
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - listFileAtPath: %@", path);
#endif

    
    //-----> LIST ALL FILES <-----//
    //    NSLog(@"LISTING ALL FILES FOUND");
    
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"BSRVC - File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    return directoryContent;
}


-(void) didMoveToParentViewController:(UIViewController *)parent
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - didMoveToParentViewController");
#endif

    
//    NSLog(@"BSRVC -(void) didMoveToParentViewController");
    
    //    if ( parent == nil )
    //    {
    //        [UIView animateWithDuration:0.3f animations:^
    //         {
    //             [sorterBar setFrame:CGRectMake(320, sorterBar.frame.origin.y, sorterBar.frame.size.width, sorterBar.frame.size.height)];
    //         }
    //                         completion:^(BOOL finished)
    //         {
    //
    //         }];
    //    } // if ( parent == nil )
    
}


-(void) viewWillAppear:(BOOL)animated
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - viewWillAppear: %d", animated);
#endif

    
    [super viewWillAppear:animated];
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
    
    
    // viewDidLoad
    
    
    // _didJustLoad was put in because these
    
    
    if ( !_didJustLoad )
    {
        
//        [self updateRouteData];
        [self loadRouteData];
        [self getUnfilteredBusRoutes];
        
//        [self getMainAlerts];
        [self getGenericAlertDetails];
        
    }

//    [self.tableView reloadData];  // This causes a crash
    
    _didJustLoad = NO;
    
}


-(void) viewDidAppear:(BOOL)animated
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - viewDidAppear: %d", animated);
#endif

    
    [super viewDidAppear:animated];
    
    [_routeData refreshSettings];  // Updates Settings:RecentlyDisplayLimit if it has changed
    
//    NSLog(@"RSVC - viewDidAppear: %d; reload", animated);
//    [self.tableView reloadData];   // Reload data in case of changes, commented out by gga on 4/15/15; on view startup, this causes the cells to be loaded twice; once for the inital read from the data source and then the second time when viewDidAppear loads
    
    _segueInAction = NO;
    
}


-(void) viewWillDisappear:(BOOL)animated
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - viewWillDisappear");
#endif

    [super viewWillDisappear:animated];
    
    [_jsonQueue cancelAllOperations];
    
    NSArray *cellArray = [self.tableView visibleCells];
    
    for (id cell in cellArray)
    {
        if ( [cell isKindOfClass:[RouteSelectionCell class] ] )
        {
//            [(TableCellAlertsView*)cell removeAllAlerts];
            [(TableCellAlertsView*)[cell alertView] removeAllAlerts];
        }
    }
    
    // Deselect selected row
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if ( selected != nil )
        [self.tableView deselectRowAtIndexPath:selected animated:YES];

    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - shouldAutorotateToInterfaceOrientation");
#endif
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - prepareForSegue (does nothing)");
#endif

    return;
    
}


#pragma mark - UITableView Footer
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:heightForFooterInSection: %ld", (long)section);
#endif

    return 4.0f;
}


-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:viewForFooterInSection: %ld", (long)section);
#endif

    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0f)];
    [footer setBackgroundColor: [UIColor clearColor] ];
    
    return footer;
    
}


#pragma mark - UITableView Header
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:heightForHeaderInSection: %ld", (long)section);
#endif

    
    if ( [_routeData numberOfSections] == 1 )  // If there are no Favorites or Recently Viewed, ensure no space for a header is added
        return 0.0f;
    else
        return 22.0f;
    
}



-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:viewForHeaderInSection: %ld", (long)section);
#endif

    
    if ( [_routeData numberOfSections] == 1 )  // If there are no Favorites or Recently Viewed, ensure no space for a header is added
    {
        //        self.tableView.tableHeaderView = nil;
        //        [self.tableView reloadData];
        return nil;
    }
    else
    {
        
        DisplayedRouteDataSections routeSec =  [_routeData sectionForIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];

        switch (routeSec)
        {
            case kDisplayedRouteDataFavorites:
            case kDisplayedRouteDataRecentlyViewed:
            {
                UILabel *headerLabel = [[UILabel alloc] init];
                
                [headerLabel setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f] ];
                [headerLabel setText: [_routeData sectionNameForSection: section] ];
                [headerLabel setTextColor: [UIColor whiteColor] ];
                
                [headerLabel setBackgroundColor: [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:74.0f/255.0f alpha:0.6f]];
                return headerLabel;
            }
                break;
        
            case kDisplayedRouteDataAlerts:
            {
                
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 22)];
                
                UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, self.view.frame.size.width-10, 22)];  // gga, 4/10/15: add -10 to better center Alerts
                [headerLabel setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f] ];
                [headerLabel setTextColor: [UIColor whiteColor] ];
                [headerLabel setBackgroundColor: [UIColor clearColor] ];
                
                [headerView addSubview: headerLabel];

                [headerLabel setText:@"Alerts"];
                [headerLabel setTextAlignment:NSTextAlignmentCenter];
                [headerView setBackgroundColor: [UIColor colorWithRed:181.0/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.8f]];
                
//                float x = 4.0;
//                float y = 4.0;
//                CGRect bound = CGRectMake(0, 0, self.view.frame.size.width - 5, 22);
//                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bound
//                                                               byRoundingCorners: UIRectCornerBottomRight | UIRectCornerTopRight
//                                                                     cornerRadii: CGSizeMake(x, y)];
//                CAShapeLayer *maskLayer = [CAShapeLayer layer];
//                maskLayer.frame = bound;
//                maskLayer.path= maskPath.CGPath;
//                
//                headerView.layer.mask = maskLayer;
                
                return headerView;
            }
                break;
                
            case kDisplayedRouteDataRoutes:
            case kDisplayedRouteDataOther:
            {
                UILabel *headerLabel = [[UILabel alloc] init];
                
                [headerLabel setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:17.0f] ];
                [headerLabel setText: [_routeData sectionNameForSection: section] ];
                [headerLabel setTextColor: [UIColor whiteColor] ];
                
                [headerLabel setBackgroundColor: [UIColor colorWithRed:13.0f/255.0f green:164.0f/255.0f blue:74.0f/255.0f alpha:0.6f]];
                SEPTARouteTypes routeType = kSEPTATypeBus;  // Default to bus
                
                if ( [travelMode isEqualToString:@"Rail"] )
                    routeType = kSEPTATypeRail;
                else if ( [travelMode isEqualToString:@"Trolley"] )
                    routeType = kSEPTATypeTrolley;
                else if ( [travelMode isEqualToString:@"MFL"] )
                    routeType = kSEPTATypeMFL;
                else if ( [travelMode isEqualToString:@"BSS"] || [travelMode isEqualToString:@"BSL"]  )
                    routeType = kSEPTATypeBSL;
                else if ( [travelMode isEqualToString:@"NHSL"] )
                    routeType = kSEPTATypeNHSL;
                
                [headerLabel setBackgroundColor: [UIColor colorForRouteType: routeType alpha:0.8f] ];
                return headerLabel;            
            }
                break;
            
            default:
                return nil;
                break;
        }
        
        
//        UITableViewStandardHeaderLabel *label = [[UITableViewStandardHeaderLabel alloc] init];
//        
//        UIColor *gradient1 = [UIColor colorWithRed:13.0f/255.0f green:74.0f/255.0f  blue:26.0f/255.0f alpha:1.0f];
//        UIColor *gradient2 = [UIColor colorWithRed:26.0f/255.0f green:120.0f/255.0f blue:37.0f/255.0f alpha:0.8f];
//        
//        NSArray *gradientArr = [NSArray arrayWithObjects:gradient2, gradient1, nil];
//        
//        [label setLeftInset:3.0f];
//        [label addArrayOfColors: gradientArr];
//        
//        [label setText: [_routeData sectionNameForSection:section] ];
//        [label setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:20.0f] ];
//        [label setTextColor: [UIColor whiteColor] ];
//        [label setOpaque:NO];
//        
//        [label setNumberOfLines:1];
//        [label setAdjustsFontSizeToFitWidth:YES];
//                
//        return label;
    }
    
    
}

#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:heightForRowAtIndexPath: %@", indexPath);
#endif

    
    if ( [_routeData sectionForIndexPath: indexPath] == kDisplayedRouteDataRoutes )
        return 38.0f;
    if ( [_routeData sectionForIndexPath: indexPath] == kDisplayedRouteDataAlerts )
    {
        AlertMessage *aMsg = (AlertMessage*)[_routeData objectWithIndexPath:indexPath];
        return CGRectFromString( aMsg.rect ).size.height+12;
    }
    else
        return 44.0f;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - numberOfSectionsInTableView");
#endif
    
    return [_routeData numberOfSections];
    //    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:numberOfRowsInSections: %ld", (long)section);
#endif
    
    
    //    NSLog(@"BSRVC - Number of Rows For Sections: %d -> %d", section, [_routeData numberOfRowsInSection:section]);
    return [_routeData numberOfRowsInSection:section];
    
    //    if ( queryType == kQueryNormalBus)
    //        return [unfilteredList count];
    //    else if ( queryType == kQuerySearchBus )
    //        return [filteredList count];
    //    else
    //        return 0;
}



-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:wilLDisplayCell:forRowAtIndexPath: %@", indexPath);
#endif

    
    DisplayedRouteDataSections section = [_routeData sectionForIndexPath: indexPath];
    
    switch (section)
    {
        case kDisplayedRouteDataRoutes:
        {
            
//            [cell setAlpha:1.0f];
            [cell setBackgroundColor: [UIColor clearColor]];
            RouteSelectionCell *rsCell = (RouteSelectionCell*)cell;
//            NSLog(@"rsCell frame: %@, img: %@", NSStringFromCGRect(rsCell.frame), NSStringFromCGRect(rsCell.imgCell.frame));
            
            // Modify the label width depending on the orientation
//            CGRect labelFrame = rsCell.lblTitle.frame;
//            labelFrame.size.width = self.view.frame.size.width - 36.0f - labelFrame.origin.x;
//            [rsCell.lblTitle setFrame: labelFrame];
//            
//            [rsCell.imgCell setFrame:CGRectMake(rsCell.imgCell.frame.origin.x, rsCell.imgCell.frame.origin.y, self.view.frame.size.width, rsCell.imgCell.frame.size.height)];
            
        }
            break;
            
        case kDisplayedRouteDataFavorites:
        case kDisplayedRouteDataRecentlyViewed:
        {
            [cell setBackgroundColor: [UIColor colorWithWhite:1.0f alpha:0.6f] ];
            
            UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_line.png"]];
            UITableViewCell *newCell = (UITableViewCell*)cell;

//            [separator setAutoresizesSubviews:YES];
//            [separator setAutoresizingMask: UIViewAutoresizingFlexibleWidth ];
//            
//            [separator setContentMode: UIViewContentModeScaleAspectFill];
            
//            [separator setFrame:CGRectMake(0, 0, self.view.frame.size.width, separator.frame.size.height)];
            
            [separator setFrame: CGRectOffset(separator.frame, 0, newCell.frame.size.height-separator.frame.size.height)];
            [newCell.contentView addSubview: separator];
        }
            break;
            
        case kDisplayedRouteDataOther:
            
            break;
            
        default:
            break;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:cellForRowAtIndexPath: %@", indexPath);
#endif

//    static NSString *defaultCellID        = @"BusRoutesDefaultCell";
    static NSString *userPreferenceCellID = @"UserPreferenceCell";
    static NSString *routeSelectionCellID = @"RouteSelectionCell";
    
    static NSString *alertCellID          = @"NextToArriveAlertsCell";
    
    
//    if ( tableView == self.searchDisplayController.searchResultsTableView )
//    {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defaultCellID];
//        if ( cell ==  nil )
//        {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellID];
//        }
//        
//        //        RouteData *row = [_routeData objectWithIndexPath:indexPath];
//        //        [[cell textLabel] setText: [row start_stop_name] ];
//        
//        NSDictionary *row = [filteredList objectAtIndex:indexPath.row];
//        [[cell textLabel] setText: [row objectForKey:@"stop_name"]];
//        return cell;
//        
//    }
//    else
    {
        
        // Configure the cell...
//        BusRoutesDefaultCell *defaultCell;// = [tableView dequeueReusableCellWithIdentifier:defaultCellID];
        UserPreferenceCell   *userPrefCell;
        
        RouteSelectionCell *routeSelectionCell;
        
        RouteData *row;
        switch ( (NSInteger)[_routeData sectionForIndexPath:indexPath] )
        {
            
            case kDisplayedRouteDataFavorites:
            case kDisplayedRouteDataRecentlyViewed:
                
                // Get a reusable cell identifier.  If it returns a nil, create it this time
                userPrefCell = [self.tableView dequeueReusableCellWithIdentifier: userPreferenceCellID];
                if ( ( userPrefCell == nil ) || ( ![userPrefCell isKindOfClass:[UserPreferenceCell class]] ) )
                {
                    userPrefCell = [self.tableView dequeueReusableCellWithIdentifier:userPreferenceCellID forIndexPath:indexPath];
                    
                    //userPrefCell = [[UserPreferenceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userPreferenceCellID];
                    //nib = [[NSBundle mainBundle] loadNibNamed:@"UserPreferenceCell" owner:self options:nil];
                    //userPrefCell = (UserPreferenceCell*)[nib objectAtIndex:0];
                }
                
                row = [_routeData objectWithIndexPath: indexPath];
                //                NSLog(@"row: %@", row);
                
                // Populate User Preferecne Cell with data from _routeData
                [[userPrefCell lblStartStopName]  setText: [row start_stop_name] ];
                [[userPrefCell lblEndStopName]    setText: [row end_stop_name  ] ];
                
                
                if ( [travelMode isEqualToString:@"Rail"] )
                {
                    if ( [row direction_id] == 0 )
                    {
                        [[userPrefCell lblFromTO] setText:@"TO"];
                    }
                    else if
                        ( [row direction_id] == 1 )
                    {
                        [[userPrefCell lblFromTO] setText:@"FROM"];
                    }
                }
                else
                {
                    [[userPrefCell lblFromTO] setText:@""];
                }
                
                
                [[userPrefCell lblRouteShortName] setText: [row route_short_name] ];
                                
                return userPrefCell;
                
                break;
                
            case kDisplayedRouteDataAlerts:
                // Insert code here!
            {
                NextToArriveAlerts *alertSelectionCell = (NextToArriveAlerts*)[self.tableView dequeueReusableCellWithIdentifier: alertCellID];
                
                AlertMessage *aMsg = (AlertMessage*)[_routeData objectWithIndexPath:indexPath];
                
                [[alertSelectionCell lblAlertText] setAttributedText: aMsg.attrText ];
                [alertSelectionCell setSelectionStyle: UITableViewCellSelectionStyleNone];
                
                CGRect rect = CGRectFromString(aMsg.rect);
                CGRect frame = [alertSelectionCell lblAlertText].frame;
                
                frame.origin.y = 0.0f + 6.0f;
                frame.size.height = (rect.size.height);
                frame.size.width = rect.size.width;
                
                [[alertSelectionCell lblAlertText] setFrame: frame];
                
                // This is nice to help visualize where the boundaries are.
                //        [myCell lblAlertText].layer.borderWidth = 1.0f;
                //        [myCell lblAlertText].layer.borderColor = [UIColor redColor].CGColor;
                
                
//                CAShapeLayer *maskLayer = [self formatCell: alertSelectionCell forIndexPath:indexPath];
//                ((UITableViewCell*)alertSelectionCell).layer.mask = maskLayer;
//                
//                ((UITableViewCell*)alertSelectionCell).layer.borderColor = [[UIColor colorWithRed:0.6 green:0.7 blue:0.2 alpha:1.0] CGColor];
                
                return alertSelectionCell;
            }
                
                break;
                
            case kDisplayedRouteDataRoutes:
            {
                
//                NSLog(@"%ld.%ld", indexPath.section, (long)indexPath.row);
                routeSelectionCell = [self.tableView dequeueReusableCellWithIdentifier:routeSelectionCellID];
                [routeSelectionCell setDelegate:self];
                
                RouteData *currentRoute = [_routeData objectWithIndexPath: indexPath];

                BOOL hasIndex = NO;
                if ( [self.travelMode isEqualToString:@"Bus"] )
                    hasIndex = YES;
                
                
                UIButton *alertBtn = routeSelectionCell.btnAlert;
                [alertBtn setHidden:YES];
                
//                for (UIView *subview in [alertBtn subviews])
//                {
//                    NSLog(@"%ld/%ld, %@", indexPath.section, indexPath.row, subview);
//                    if ( [subview isKindOfClass:[UIImageView class] ] )
//                        [subview removeFromSuperview];
//                }
                
                
//                if ( indexPath.row == 1 )
                if ( [(SystemStatusObject*)[_ssDict objectForKey: [currentRoute route_short_name] ] numOfAlerts] > 0 )
                {
                
                    NSInteger indexWidth = 0;
                    if ( hasIndex )
                        indexWidth = 20;
                    
                    // system_status_alert.png
                    // system_status_advisory.png
                    // system_status_detour.png
                    
                    // system_status_suspended.png

                    
                    // Spacing --> nw + (n-1)p + 2e
                    // Where n is the number of alert icons to display
                    // And p is the padding space in
                    NSInteger padding = -3;
                    NSInteger width   = 20;
                    NSInteger endPadding = 0;
                    NSInteger n = [[_ssDict objectForKey: [currentRoute route_short_name] ] numOfNonCriticalAlerts];
                    
                    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
                    
                    // Determine which Alerts are active
                    if ( [[_ssDict objectForKey: [currentRoute route_short_name] ] isSuspend] )  // Suspend trumps all
                    {
                        [imageArray addObject:@"system_status_alert.png"];
                        n = 1;
                    }
                    else
                    {
                        if ( [[_ssDict objectForKey: [currentRoute route_short_name] ] isAlert] )
                            [imageArray addObject:@"system_status_alert.png"];
                        
                        if ( [[_ssDict objectForKey: [currentRoute route_short_name] ] isDetour] )
                            [imageArray addObject:@"system_status_detour.png"];
                        
                        if ( [[_ssDict objectForKey: [currentRoute route_short_name] ] isAdvisory] )
                            [imageArray addObject:@"system_status_advisory.png"];
                    }

                    
                    // Calculate the widths to position the buttons and images
                    CGFloat buttonWidth = n * width + ( (n-1) * padding) + (2 * endPadding);
                    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width - indexWidth;
                    
                    
                    UIImageView *cell  = routeSelectionCell.imgCell;
                    CGRect btnFrame = CGRectMake(screenWidth - buttonWidth, cell.frame.origin.y+3, buttonWidth, 30.0f);
                    
//                    UIButton *alertBtn = [[UIButton alloc] initWithFrame:btnFrame];
                    UIButton *alertBtn = routeSelectionCell.btnAlert;
//                    [alertBtn setUserInteractionEnabled:YES];
                    [alertBtn setFrame: btnFrame];
                    [alertBtn setHidden:NO];

                    CGRect lblFrame = [routeSelectionCell.lblTitle frame];
                    lblFrame.size.width =  btnFrame.origin.x - lblFrame.origin.x;
                    [routeSelectionCell.lblTitle setFrame: lblFrame];
                
                    
                    for (NSInteger LCV = 0; LCV < n; LCV++)
                    {
                        
                        UIImageView *image = [[UIImageView alloc] initWithImage: [UIImage imageNamed: [imageArray objectAtIndex:LCV] ] ];
                        NSInteger x = endPadding + (LCV)*(padding+width);
                        CGRect bound = CGRectMake(x, 7.5f, 20.0f, 15.0f);
                        [image setFrame: bound];
                        
//                        [image.layer setBorderColor:[[UIColor whiteColor] CGColor]];
//                        [image.layer setBorderWidth:1.0f];
                        
                        [alertBtn addSubview: image];
                        
//                        if ( LCV == 0 )  // Moved before the for loop because logic
//                        {
//                            CGRect lblFrame = [routeSelectionCell.lblTitle frame];
//                            lblFrame.size.width =  btnFrame.origin.x - lblFrame.origin.x;
//                            [routeSelectionCell.lblTitle setFrame: lblFrame];
//                        }
                        
                    }
                    
//                    [routeSelectionCell addSubview:alertBtn];
                    
                }
                else
                {

                    if ( hasIndex )
                    {
//                        UILabel *lblTitle = routeSelectionCell.lblTitle;
//                        CGRect frame = [lblTitle frame];
//                        
//                        frame.size.width -= 20;
//                        
//                        [lblTitle setFrame: frame];
                        
                        // -20 to account for the index running down the side
                        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width - 20;
                        
                        CGRect lblTitleFrame = [routeSelectionCell.lblTitle frame];
                        lblTitleFrame.size.width =  screenWidth - lblTitleFrame.origin.x;
                        [routeSelectionCell.lblTitle setFrame: lblTitleFrame];

                    }
                    else
                    {
                        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

                        CGRect lblTitleFrame = [routeSelectionCell.lblTitle frame];
                        lblTitleFrame.size.width =  screenWidth - lblTitleFrame.origin.x;
                        [routeSelectionCell.lblTitle setFrame: lblTitleFrame];
                        
                    }
                    
                    
                    
                    
//                    UIButton *alertBtn = routeSelectionCell.btnAlert;
//                    [alertBtn setHidden:YES];
//                    
//                    for (UIView *subview in [alertBtn subviews])
//                    {
//                        NSLog(@"%@", subview);
//                    }
                    
                }
                
                row = [_routeData objectWithIndexPath: indexPath];
                
                [routeSelectionCell setRouteData: row];
//                [routeSelectionCell.lblTitle sizeToFit];
                
//                CGRect f = routeSelectionCell.lblTitle.frame;
//                f.size.width = 40.0f;
//                [routeSelectionCell.lblTitle setFrame:f];
                
                
                return routeSelectionCell;
            
                break;
            }
//            default:
//            {
//                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//                return cell;
//            }
//                break;
        }
        
    }
    
}


-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
 
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV,dEDC,fRAIP: %@", indexPath);
#endif
    
    switch ( (NSInteger)[_routeData sectionForIndexPath:indexPath] )
    {
        case kDisplayedRouteDataRoutes:
        {
//            RouteSelectionCell *routeSelectionCell = [self.tableView dequeueReusableCellWithIdentifier:@"RouteSelectionCell"];
//            TableCellAlertsView *alertView = (TableCellAlertsView*)[routeSelectionCell alertView];
//            [alertView removeAllAlerts];


            if ( [cell isKindOfClass:[RouteSelectionCell class] ] )
            {

                UIButton *alertBtn = [(RouteSelectionCell*)cell btnAlert];
                [alertBtn setHidden:YES];
                
                for (UIView *subview in [alertBtn subviews])
                {
//                    NSLog(@"%ld/%ld, %@", indexPath.section, indexPath.row, subview);
                    if ( [subview isKindOfClass:[UIImageView class] ] )
                        [subview removeFromSuperview];
                }
                
            }
            
            
            break;
        }
        default:
            break;
    }
    
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:commitEditingStyle:forRowAtIndexPath: %@", indexPath);
#endif

    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {

        NSInteger numberOfRows = [_routeData numberOfRowsInSection:indexPath.section];
        
        [tableView beginUpdates];
        [_routeData removeObjectWithIndexPath: indexPath];
        //        [_routeData.recentlyViewed removeObjectAtIndex: indexPath.row];

        if ( numberOfRows != 1 )
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        else
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
        
        [_routeData updateSectionCountForSection:kDisplayedRouteDataRecentlyViewed];
//        NSLog(@"RSVC - tV:commitEditingStyle:forRowAtIndexPath: %@; reload", indexPath);
        [tableView reloadData];
    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:canEditRowAtIndexPath: %@", indexPath);
#endif

    
    // Return NO if you do not want the specified item to be editable.
    //    NSInteger section = indexPath.section;
    
    NSInteger section = [_routeData sectionForIndexPath: indexPath];
    
    if ( section == kDisplayedRouteDataRoutes )
        return NO;
    else
        return YES;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - sectionIndexTitlesForTableView");
#endif

    
    if ( [self.travelMode isEqualToString:@"Bus"] )
        return sectionTitle;
    else
        return nil;
    
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:sectionForSectionIndexTitle:%@ atIndex:%ld", title, (long)index);
#endif

    
    if ( [self.travelMode isEqualToString:@"Bus"] )
    {
        
        //    NSInteger row = [stops getSectionForSection:segmentedIndex withIndex:index];
        
        //    NSInteger row = [stopData getSectionForSection:segmentedIndex withIndex:index];
        NSInteger row = [[sectionIndex objectAtIndex:index] integerValue];
        
        // Calculate number of sections
        NSInteger section = [_routeData numberOfSections] - 1;
        
        //    NSLog(@"sec/row: %d/%d, title: %@", section, row, [sectionTitle objectAtIndex:index]);
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    return -1;  // Yes, Virginia.  Keep this as -1 becaues we don't have multiple sections, which is what this method what designed for}
    
}

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


#pragma mark - Fun With Notifications
-(void) notificationTest
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - notificationTest");
#endif
    
    //    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    
    // Get the date/time 30 seconds into the future
    //    NSTimeInterval seconds30 = 15;
    //    NSDate *futureDate = [NSDate dateWithTimeIntervalSinceNow: seconds30];
    //
    //    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    //    if ( localNotification == nil )
    //        return;
    //
    //    localNotification.fireDate = futureDate;
    //    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //
    //    localNotification.repeatInterval = NSMinuteCalendarUnit;
    //
    //    localNotification.alertBody = @"Your 30 seconds are up!";
    //    localNotification.alertAction = @"Alert";
    //
    //    localNotification.soundName = UILocalNotificationDefaultSoundName;
    ////    localNotification.applicationIconBadgeNumber = 1;
    //
    //    [[UIApplication sharedApplication] scheduleLocalNotification: localNotification];
    
    // AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    // #import <AudioToolbox/AudioServices.h>
    
    
}

// Respond to local notification firing


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - tV:didSelectRowAtIndexPath: %@", indexPath);
#endif

    
    if ( ! [[_routeData objectWithIndexPath:indexPath] isKindOfClass:[RouteData class] ] )
    {
        return;
    }
    
    NSLog(@"BSRVC - s/r: %ld/%ld", (long)indexPath.section, (long)indexPath.row);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ItineraryStoryboard" bundle:nil];
    ItineraryViewController *iVC = (ItineraryViewController*)[storyboard instantiateInitialViewController];

    
    // Passing Data to the ItineraryTripViewController
    //   At minimum, it needs to know the routeID
    //   If a Recently Viewed or Favorited Itinerary was selected, pass a completed ItineraryObject
    //      * startStop, startID, endStop, endID, routeID, routeShortName, routeLongName and directionID
    
    NSInteger row = [[[self tableView] indexPathForSelectedRow] row];
    NSInteger section = [[[self tableView] indexPathForSelectedRow] section];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
    
    //        RouteData *route = [_routeData objectWithIndexPath: path];
    [iVC setRouteData: [_routeData objectWithIndexPath: path] ];
    
    
    // Initially selecting MFL/BSS sets travelMode to MFL/BSS respectively.  This translates into a routeType of 1.
    // However, there's a NightOwl Service which is a Bus with routeType of 3.  The routeType will always be passed
    // correctly, but travelMode needs to be adjusted if that's the case.
    // TODO:  Stop using travelMode and use route_type instead.
    //        if ( [[[_routeData objectWithIndexPath:path] route_type] intValue] == 3 )
    //            self.travelMode = @"Bus";
    
    [iVC setTravelMode: self.travelMode];
    
    
//    NSString *routeName;
//    RouteData *currentRoute = [_routeData objectWithIndexPath: path];
//    if ( [self.travelMode isEqualToString:@"Rail"] )
//    {
//        routeName = [NSString stringWithFormat:@"Route %@",[currentRoute route_id] ];
//    }
//    else if ( [self.travelMode isEqualToString:@"Bus"] )
//    {
//        routeName = [NSString stringWithFormat:@"Route %@", [currentRoute route_short_name] ];
//    }
//    else
//    {
//        routeName = self.travelMode;
//    }
    
    
    
    [self.navigationController pushViewController:iVC animated:YES];
    
    return;
    
}


- (IBAction)navbarSearchButtonClicked:(id)sender
{
    NSLog(@"BSRVC -(IBAction) navbarSearchButtonClicked");
    //    UIView *sup = self.view.superview;
    //    NSLog(@"BSRVC | superview frame: %@, bounds: %@", NSStringFromCGRect(sup.frame), NSStringFromCGRect(sup.bounds) );
    //    NSLog(@"BSRVC | tableview frame: %@, bounds: %@,\tcSize: %@, cOffset: %@, cInset: %@, sInset: %@", NSStringFromCGRect(self.tableView.frame), NSStringFromCGRect(self.tableView.bounds), NSStringFromCGSize(self.tableView.contentSize), NSStringFromCGPoint(self.tableView.contentOffset),NSStringFromUIEdgeInsets(self.tableView.contentInset), NSStringFromUIEdgeInsets(self.tableView.scrollIndicatorInsets) );
    
    
    
    //    CGFloat searchBarHeight = self.searchDisplayController.searchBar.frame.size.height;
    [self hideShowSearchBar];
    
    
    
}

-(void) hideShowSearchBar
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - hideShowSearchBar");
#endif
    
    NSLog(@"BSRVC -(void) hideShowSearchBar");
    float shiftBy = 0;
    
    if ( self.searchDisplayController.searchBar.hidden == YES )  // If it's hidden, make it visible
    {
        shiftBy = 29;
        [self.searchDisplayController.searchBar setHidden:NO];
        
        [UIView animateWithDuration:0.3f animations:^
         {
             [[self tableView] setContentOffset:CGPointMake(0, -shiftBy)];
             [[self tableView] setContentInset:UIEdgeInsetsMake(shiftBy, 0, 0, 0)];
             
         } completion:^(BOOL finished)
         {
             
         }];
        
    }
    else  // Search Bar is not hidden, so hide it.
    {
        shiftBy = 15;
        [UIView animateWithDuration:0.3f animations:^
         {
             [[self tableView] setContentOffset:CGPointMake(0, shiftBy)];
             [[self tableView] setContentInset:UIEdgeInsetsMake(-shiftBy, 0, 0, 0)];
         }
                         completion:^(BOOL finished)
         {
             [self.searchDisplayController.searchBar setHidden:YES];
             //[self.searchDisplayController.searchBar setFrame:CGRectMake(0, -44, self.searchDisplayController.searchBar.frame.size.width, self.searchDisplayController.searchBar.frame.size.height)];
         }];
        
    }
    
}

#pragma mark -- Private Methods
-(void) configureTableView
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - configureTableView");
#endif

    
    _segueInAction = NO;
    busFilterStr = nil;
    queryType = kQueryNotYet;
    
    
    if ( [travelMode isEqualToString:@"Bus"] )
        [self setTitle:@"Bus Routes"];
    else if ( [travelMode isEqualToString:@"Trolley"] )
        [self setTitle:@"Trolley Lines"];
    else if ( [travelMode isEqualToString:@"Rail"] )
        [self setTitle:@"Regional Rail Lines"];
    else if ( [travelMode isEqualToString:@"MFL"] )
        [self setTitle:@"Market Frankford Line"];
    else if ( [travelMode isEqualToString:@"BSS"] || [travelMode isEqualToString:@"BSL"]  )
        [self setTitle:@"Broad Street Line"];
    else if ( [travelMode isEqualToString:@"NHSL"] )
        [self setTitle:@"NHSL"];
    
    
    // Here's why this is a bad idea, or an idea that should be carefully considered.  Adding a GestureRecognizer here will retain that Gesture in the NavBar
    // into another view.  So when we push into BusDisplayStopViewControl and tap the top, it'll try calling an instance that might not exist.
    //    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTop:)];
    //    tapped.cancelsTouchesInView = NO;  // This line allows the back button to work, as opposed to the tap gesture being called for every touch on the navigation bar
    //    [self.navigationController.navigationBar addGestureRecognizer: tapped];
    
    
    UISearchDisplayController *sdc = self.searchDisplayController;  // To make the following lines neater
    [[sdc searchBar] setHidden:YES];
    [[sdc searchBar] setFrame:CGRectMake(0, -44, sdc.searchBar.frame.size.width, sdc.searchBar.frame.size.height)];
    
    // Load custom xib file that contains all the
    //    NSArray *newNib = [[NSBundle mainBundle] loadNibNamed:@"BusRouteSorter" owner:self options:nil];
    //    sorterBar = [newNib objectAtIndex:0];
    //
    //    float navH   = self.navigationController.navigationBar.frame.size.height;
    //    float navY   = self.navigationController.navigationBar.frame.origin.y;  // Status bar height is 20 points thus the nav bar starts at (0, 20)
    //
    //    [sorterBar setDelegate:self];
    //    [sorterBar setFrame:CGRectMake(sorterBar.frame.size.width, navH+navY, sorterBar.frame.size.width, sorterBar.frame.size.height)];
    //    [self.parentViewController.view addSubview:sorterBar];
    ////    [self.tableView addSubview:sorterBar];
    //
    //    [UIView animateWithDuration:0.3f animations:^
    //     {
    //         [sorterBar setFrame:CGRectMake(0, navH+navY, sorterBar.frame.size.width, sorterBar.frame.size.height)];
    //     }
    //     completion:^(BOOL finished)
    //     {
    //
    //     }];
    
}

-(void) getUnfilteredBusRoutes
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - getUnfilteredBusRoutes");
#endif

    
    // holds routes
    // Array of Dictionaries to hold routes and route ids
    //    unfilteredList = [[NSMutableArray alloc] init];
    [_routeData removeAllObjectsWithSection:kDisplayedRouteDataRoutes];
    
    
    database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    if (![database open])
    {
        [database close];
        return;
    }
    
    
    NSString *queryStr;
    if ( [[self travelMode] isEqualToString:@"Bus"] )
    {
        if ( busFilterStr == nil )
            queryStr = @"SELECT route_short_name, route_id, route_type, route_long_name FROM routesDB WHERE route_type=3 AND route_short_name NOT IN (\"MFO\",\"BSO\") ORDER BY route_short_name ASC";
        else
            queryStr = [NSString stringWithFormat:@"SELECT route_short_name, route_id, route_type, route_long_name FROM routesDB WHERE %@ AND route_type=3 ORDER BY route_short_name ASC", busFilterStr];
    }
    else if ( [[self travelMode] isEqualToString:@"Rail"] )
    {
        if ( busFilterStr == nil )
            queryStr = @"SELECT route_short_name, route_id, route_type, route_long_name FROM routesDB WHERE route_type=2 ORDER BY route_short_name ASC";
        else
            queryStr = [NSString stringWithFormat:@"SELECT route_short_name, route_id, route_type, route_long_name FROM routesDB WHERE %@ AND route_type=2 ORDER BY route_short_name ASC", busFilterStr];
    }
    else if ( [[self travelMode] isEqualToString:@"Trolley"] )
    {
        if ( busFilterStr == nil )
            queryStr = @"SELECT route_short_name, route_id, route_type, route_long_name FROM routesDB WHERE route_type=0 AND route_short_name != \"NHSL\" ORDER BY route_short_name ASC";
        else
            queryStr = [NSString stringWithFormat:@"SELECT route_short_name, route_id, route_type, route_long_name FROM routesDB WHERE %@ AND route_type=0 ORDER BY route_short_name ASC", busFilterStr];
    }
    else if ( [[self travelMode] isEqualToString:@"MFL"] )
    {
        queryStr = @"SELECT route_short_name, route_id, route_type, route_long_name FROM routesDB WHERE route_short_name LIKE \"MF_\" ORDER BY route_short_name";
    }
    else if ( [[self travelMode] isEqualToString:@"BSS"] || [travelMode isEqualToString:@"BSL"]  )
    {
        queryStr = @"SELECT route_short_name, route_id, route_type, route_long_name FROM routesDB WHERE route_short_name LIKE \"BS_\" ORDER BY route_short_name";
    }
    else if ( [[self travelMode] isEqualToString:@"NHSL"] )
    {
        queryStr = @"SELECT route_short_name, route_id, route_type, route_long_name FROM routesDB WHERE route_short_name=\"NHSL\" ORDER BY route_short_name";
    }
    else
        return;  // No other travel modes are supported at this time
    
    if ( [[self travelMode] isEqualToString:@"Rail"] )
    {
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
    }
    else
    {
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
    }
    
//    NSLog(@"BSRVC - getUnfilteredBusRoutes, queryStr: %@", queryStr);
    
    //    NSDate *startTime = [NSDate date];
    //    NSDate *endTime;
    //    NSLog(@"Starting at %@", startTime);
    
    queryType = kQueryNormalBus;  // ???
    FMResultSet *results = [database executeQuery: queryStr];
    
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"BSRVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"BSRVC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    }
    
    
    
    while ( [results next] )
    {
        
        //        endTime = [NSDate date];
        //        NSTimeInterval diff = [endTime timeIntervalSinceDate: startTime];
        //        NSLog(@"BSRVC - %6.3f seconds have passed.", diff);
        
        NSString *route_short_name = [results stringForColumn:@"route_short_name"];
        NSString *route_long_name  = [results stringForColumn:@"route_long_name"];
        NSString *route_id         = [results stringForColumn:@"route_id"];
        NSInteger route_type       = [results intForColumn   :@"route_type"];
        
        RouteData *newData = [[RouteData alloc] init];
        
        [newData setRoute_id: route_id];
        [newData setRoute_long_name: route_long_name];
        
        if ( [self.travelMode isEqualToString:@"Rail"] )
            [newData setRoute_short_name: route_id];
        else
            [newData setRoute_short_name: route_short_name];
        
        [newData setRoute_type: [NSNumber numberWithLong: route_type] ];
        
        [_routeData addObject: newData toSection:kDisplayedRouteDataRoutes];
        
    }
    
    [database close];
    
    
    if ( [self.travelMode isEqualToString:@"BSS"] || [travelMode isEqualToString:@"BSL"]  )  // OMG, reverseSort for just BSS and BSL.  *face palm*
    {
        [_routeData reverseSortWithSection:kDisplayedRouteDataRoutes];
    }
    else
    {
        [_routeData sortWithSection:kDisplayedRouteDataRoutes];
    }
    
    
    [self createIndexAndTitle];
    
    
}


-(void) createIndexAndTitle
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - sort");
#endif

    
    sectionIndex = [[NSMutableArray alloc] init];
    sectionTitle = [[NSMutableArray alloc] init];
    
    NSString *lastChar = @"";
    NSString *newChar;
    NSInteger index = 0;
    NSInteger len = 1;
    
    for ( RouteData *route in _routeData.routes )
    {
        
        len = 1;
        //        NSLog(@"BSRVC - Route: %@", [route route_short_name] );
        while ( ( [[route.route_short_name substringToIndex:len] intValue] ) && ( len < [route.route_short_name length] ) )
        {
            
            int newNum = [[route.route_short_name substringToIndex:len] intValue];
            
            if ( newNum == [[route.route_short_name substringToIndex:len+1] intValue] )
            {
                break;
            }
            len++;
            
        }  // while ( [[route.start_stop_name substringToIndex:len] intValue] )
        
        newChar = [route.route_short_name substringToIndex:len];
        
        
        if ( ![newChar isEqualToString:lastChar] )
        {
            [sectionTitle addObject: newChar];
            [sectionIndex addObject: [NSNumber numberWithInt:(int)index] ];
            
            lastChar = newChar;
        }  // if ( ![newChar isEqualToString:lastChar] )
        else
        {
//            NSLog(@"Break here");
        }
        index++;
        
    }  // for ( RouteData *route in _routeData.routes )
    
    
    
}  // -(void) sort


-(void) getFilteredBusRoutes
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - getFilteredBusRoutes");
#endif

    
    filteredList = [[NSMutableArray alloc] init];
    
    NSLog(@"BSRVC -(void) getFilteredRoutesWithString");
    
    // Begin SQL3 db process
    if( sqlite3_open( [[GTFSCommon filePath] UTF8String], &dbh) == SQLITE_OK )
    {
        
        NSString *queryStr;
        if ( busFilterStr == nil)
            queryStr = [NSString stringWithFormat:@"SELECT unique_stops.route_short_name, unique_stops.route_id, unique_stops.route_type, fts3_unique_stops.stop_name FROM fts3_unique_stops JOIN unique_stops ON fts3_unique_stops.uid=unique_stops.uid WHERE fts3_unique_stops.stop_name MATCH 'stop_name:*%@*'", searchStr];
        else
            queryStr = [NSString stringWithFormat:@"SELECT unique_stops.route_short_name, unique_stops.route_id, unique_stops.route_type, fts3_unique_stops.stop_name FROM fts3_unique_stops JOIN unique_stops ON fts3_unique_stops.uid=unique_stops.uid WHERE %@ AND fts3_unique_stops.stop_name MATCH 'stop_name:*%@*'", busFilterStr, searchStr];
        NSLog(@"BSRVC -(void) getFilteredRoutesWithString: %@", queryStr);
        
        
        queryType = kQuerySearchBus;
        sqlite3_stmt * statement;
        
        if(sqlite3_prepare_v2(dbh, [queryStr UTF8String], -1, &statement, nil)==SQLITE_OK)
        {
            
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                
                char *routes    = (char *) sqlite3_column_text(statement, 0);
                char *route_id  = (char *) sqlite3_column_text(statement, 1);
                char *stop_name = (char *) sqlite3_column_text(statement, 2);
                int  route_type = (int)    sqlite3_column_int (statement, 3);
                
                NSString *routeStr   = [[NSString alloc] initWithUTF8String: routes];
                NSString *routeIDStr = [[NSString alloc] initWithUTF8String: route_id];
                NSString *stopNameID = [[NSString alloc] initWithUTF8String: stop_name];
                NSNumber *routeType  = [[NSNumber alloc] initWithInt       : route_type];
                
                [filteredList addObject:
                 [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:routeStr, routeIDStr, stopNameID, routeType, nil]
                                             forKeys: [NSArray arrayWithObjects:
                                                       @"route_short_name",
                                                       @"route_id",
                                                       @"stop_name",
                                                       @"route_type",
                                                       nil] ] ];
                
                
                
            } // while (sqlite3_step(statement)==SQLITE_ROW)
            
            sqlite3_finalize(statement);
            
        }
        else
        {
            int errorCode = sqlite3_step( statement );
            char *errMsg = (char *)sqlite3_errmsg(dbh);
            NSString *errStr = [[NSString alloc] initWithUTF8String:errMsg];
            NSLog(@"BSRVC - query failure, code: %d, %@", errorCode, errStr);
            NSLog(@"BSRVC - query str: %@", queryStr);
            queryType = kQueryFailure;
        }
        
        [filteredList sortUsingComparator:^NSComparisonResult(id a, id b)
         {
             
             //            int first = [[a objectAtIndex:0] intValue];  // Returns nil if value is not an integer
             //            int second = [[b objectAtIndex:0] intValue]; // Returns nil if value is not an integer
             
             return [[a route_short_name] compare:[b route_short_name] options:NSNumericSearch];
             
             
             //            int first  = [[a objectForKey:@"route_short_name"] intValue];
             //            int second = [[b objectForKey:@"route_short_name"] intValue];
             //
             //            if ( !first && !second )
             //                return first > second;
             //            else if (first == 0)
             //                return 1;
             //            else if (second == 0)
             //                return -1;
             //            else
             //                return first > second;
             
         }];
        
        
    } // if( sqlite3_open( [[GTFSCommon filePath] UTF8String], &db) == SQLITE_OK )
    
    sqlite3_close(dbh);
    
    //    NSLog(@"filtered results: %d", [filteredList count]);
    //
    //    int count = 1;
    //    for (NSDictionary *object in filteredList)
    //    {
    //
    //        NSLog(@"%d) %@", count, [object objectForKey:@"stop_name"]);
    //
    //        if ( count++ > 5 )
    //            break;
    //
    //    }
    
    
}

// Database path Declaration
//-(NSString *) filePath
//{
//    
//#if FUNCTION_NAMES_ON
//    NSLog(@"RSVC - filePath");
//#endif
//
//    //    NSString *databaseName;
//    
//    //    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] )
//    //        databaseName = @"SEPTAbus";
//    //    else if ( [self.travelMode isEqualToString:@"Rail"] )
//    //        databaseName = @"SEPTArail";
//    //    else
//    //        return nil;
//    
//    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
//    
//}


#pragma mark - UISearchDisplayController Delegate Methods

#pragma mark - UISearchDisplayDelegate Protocol
-(void) searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"BSRVC - didHideSearchResultsTableView");
}

-(void) searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"BSRVC - didLoadSearchResultsTableView");
    //    NSLog(@"BSVC | tableview frame: %@, bounds: %@,\tcSize: %@, cOffset: %@, cInset: %@, sInset: %@", NSStringFromCGRect(tableView.frame), NSStringFromCGRect(tableView.bounds), NSStringFromCGSize(tableView.contentSize), NSStringFromCGPoint(tableView.contentOffset),NSStringFromUIEdgeInsets(tableView.contentInset), NSStringFromUIEdgeInsets(tableView.scrollIndicatorInsets) );
    
    //    [tableView setBounds:CGRectMake(tableView.bounds.origin.x, 15, tableView.bounds.size.width, tableView.bounds.size.height)];
    //    [tableView setContentOffset:CGPointMake(0, 15)];
    //    [tableView setContentInset:UIEdgeInsetsMake(-15, 0, 0, 0)];
    
    //    [self.tableView setContentInset:UIEdgeInsetsMake(-100, 0, 0, 0)];
    //    [self.tableView setBackgroundColor:[UIColor blueColor]];
}

-(void) searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"BSRVC - didShowSearchResultsTableView");
    //    [tableView setContentInset:UIEdgeInsetsMake(58, 0, 0, 0)];
    
    [tableView setContentOffset:CGPointMake(0, -29) animated:YES];
    
    
    //    NSLog(@"BSRVC | tableview frame: %@, bounds: %@,\tcSize: %@, cOffset: %@, cInset: %@, sInset: %@", NSStringFromCGRect(tableView.frame), NSStringFromCGRect(tableView.bounds), NSStringFromCGSize(tableView.contentSize), NSStringFromCGPoint(tableView.contentOffset),NSStringFromUIEdgeInsets(tableView.contentInset), NSStringFromUIEdgeInsets(tableView.scrollIndicatorInsets) );
    
}

-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"BSRVC - shouldReloadTableForSearchString");
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex ]]];
    
    //    UITableView *tableView = controller.searchResultsTableView;
    //    NSLog(@"BSRVC | tableview frame: %@, bounds: %@,\tcSize: %@, cOffset: %@, cInset: %@, sInset: %@", NSStringFromCGRect(tableView.frame), NSStringFromCGRect(tableView.bounds), NSStringFromCGSize(tableView.contentSize), NSStringFromCGPoint(tableView.contentOffset),NSStringFromUIEdgeInsets(tableView.contentInset), NSStringFromUIEdgeInsets(tableView.scrollIndicatorInsets) );
    
    [self.searchDisplayController.searchResultsTableView reloadData];
    [self.searchDisplayController.searchResultsTableView setContentOffset:CGPointMake(0, -29) animated:NO];
    //    self.tableView.scrollEnabled;
    return NO;
}

-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSLog(@"BSRVC - shouldReloadTableForSearchScope");
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

-(void) searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"BSRVC - willHideSearchResultsTableView");
}

-(void) searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"BSRVC - willShowSearchResultsTableView");
    //    [tableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
    //    [tableView setBackgroundColor:[UIColor redColor]];
}

-(void) searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"BSRVC - willUnloadSearchResultsTableView");
}

-(void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"BSRVC - searchDisplayControllerDidBeginSearch");
}

-(void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"BSRVC - searchDisplayControllerDidEndSearch");
}

-(void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    NSLog(@"BSRVC - searchDisplayControllerWillBeginSearch");
}

-(void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"BSRVC - searchDisplayControllerWillEndSearch");
}



#pragma mark - UISearchBarDelegate Protocol
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    NSLog(@"BSRVC - textDidChange");
    //    if ( [searchText length] > 2)
    //    {
    //    }
    
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"BSRVC - searchButtonClicked");
    
    // Readjust the table view yet again, at the searchDisplayController overwrite all our prior settings
    //    UITableView *tableView = self.searchDisplayController.searchResultsTableView;
    //    [tableView setFrame:CGRectMake(tableView.frame.origin.x, 29+44, tableView.frame.size.width, 367)];
    //    [self.searchDisplayController.searchResultsTableView setBounds:CGRectMake(tableView.bounds.origin.x, -29, tableView.bounds.size.width, tableView.bounds.size.height)];
    //    [self.searchDisplayController.searchResultsTableView setContentOffset:CGPointMake(0, -29)];
    //    [self.searchDisplayController.searchResultsTableView setContentInset:UIEdgeInsetsMake(29, 0, 0, 0)];  // This line disables the scrolling of the table
    //    [tableView setScrollEnabled:YES];
    //    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor blueColor]];
    
}


-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"BSRVC - cancelButtonClicked");
    [self hideShowSearchBar];
    [self getUnfilteredBusRoutes];  // Load the original list back into the routesArray array
    
    [self.tableView setBounds:CGRectMake(self.tableView.bounds.origin.x, 15, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
    [self.tableView setContentOffset:CGPointMake(0, 15)];
    
    //    NSLog(@"BSRVC | tableview frame: %@, bounds: %@,\tcSize: %@, cOffset: %@, cInset: %@, sInset: %@", NSStringFromCGRect(self.tableView.frame), NSStringFromCGRect(self.tableView.bounds), NSStringFromCGSize(self.tableView.contentSize), NSStringFromCGPoint(self.tableView.contentOffset),NSStringFromUIEdgeInsets(self.tableView.contentInset), NSStringFromUIEdgeInsets(self.tableView.scrollIndicatorInsets) );
    
}


#pragma mark - Content Filtering
-(void) filterContentForSearchText:(NSString*) searchText scope: (NSString*) scope
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - filterContentForSearchText: %@ scope: %@", searchText, scope);
#endif
    
    if ( searchStr != searchText )
        searchStr = [searchText copy];
    
    [self getFilteredBusRoutes];
    
}

#pragma mark - UISegementControl, Bus Route Sorter
- (IBAction)segmentChanged:(id)sender
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - segmentChanged");
#endif

    
    NSInteger index = [(UISegmentedControl*)sender selectedSegmentIndex];
    NSLog(@"RSVC - filter has changed to: %ld", (long)index);
    
    
    //    BOOL showOnlyRoutes = YES;
    
    switch (index) {
        case 1:
            busFilterStr = @" (routes.route_short_name+0 BETWEEN 1 and 30) ";  // +0 forces a conversion from string to integer
            break;
        case 2:
            busFilterStr = @" (routes.route_short_name+0 BETWEEN 31 and 60) ";
            break;
        case 3:
            busFilterStr = @" (routes.route_short_name+0 BETWEEN 61 and 90) ";
            break;
        case 4:
            busFilterStr = @" (routes.route_short_name+0 BETWEEN 91 and 310) ";
            break;
        case 5:
            busFilterStr = @" (routes.route_short_name BETWEEN 'A' and 'Z') ";
            break;
        default:
            busFilterStr = nil;
            //            showOnlyRoutes = NO;  // No, show everything.
            break;
    }
    
    
    if ( queryType == kQueryNormalBus )
    {
        [self getUnfilteredBusRoutes];
        NSLog(@"RSVC - segmentChanged; reload");
        [self.tableView reloadData];
    }
    else if ( queryType == kQuerySearchBus )
    {
        [self getFilteredBusRoutes];
        [self.searchDisplayController.searchBar setText: self.searchDisplayController.searchBar.text];  // Forces the searchDisplayController to refresh the data
        NSLog(@"BSRVC - filterHasChanged:  filteredBusRoutes size: %lu", (unsigned long)[filteredList count]);
    }
    
}

#pragma mark - BusRouteSorter Protocol
-(void) filterHasChanged:(int)index
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - filterHasChanged: %d", index);
#endif

    
//    NSLog(@"BSRVC - filter has changed to: %d", index);
    //    busRouteFilter = index;
    
    //    return;
    
    switch (index) {
        case 1:
            busFilterStr = @" (routes.route_short_name+0 BETWEEN 1 and 30) ";
            break;
        case 2:
            busFilterStr = @" (routes.route_short_name+0 BETWEEN 31 and 60) ";
            break;
        case 3:
            busFilterStr = @" (routes.route_short_name+0 BETWEEN 61 and 90) ";
            break;
        case 4:
            busFilterStr = @" (routes.route_short_name+0 BETWEEN 91 and 310) ";
            break;
        case 5:
            busFilterStr = @" (routes.route_short_name BETWEEN 'A' and 'Z') ";
            break;
        default:
            busFilterStr = nil;
            break;
    }
    
    if ( queryType == kQueryNormalBus )
    {
        [self getUnfilteredBusRoutes];
        NSLog(@"RSVC - filterHasChanged: %d; reload", index);
        [self.tableView reloadData];
    }
    else if ( queryType == kQuerySearchBus )
    {
        [self getFilteredBusRoutes];
        [self.searchDisplayController.searchBar setText: self.searchDisplayController.searchBar.text];  // Forces the searchDisplayController to refresh the data
        NSLog(@"RSVC - filterHasChanged:  filteredBusRoutes size: %lu", (unsigned long)[filteredList count]);
    }
    
    //    NSLog(@"reloading data");
    //    _useFilteredDataSource = YES;  // This line needs to preceed any loading of data
    
}


#pragma mark - Tap Gesture Recognizer
-(void) scrollToTop:(UITapGestureRecognizer*) recognizer
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - scrollToTop:");
#endif

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


#pragma mark - Buttons Pressed
-(void) backButtonPressed:(id) sender
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - backButtonPressed");
#endif

    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Alert Button Pressed
-(void) dropDownMenuPressed:(id) sender
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - dropDownMenuPressed");
#endif
    
    NSLog(@"RSVC - Alert Button Pressed!");
}


#pragma mark - Fetching Alerts
-(void) getGenericAlertDetails
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - getGenericAlertDetails");
#endif
    
    // Check for Internet connection
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
        return;  // Don't bother continuing if no internet connection is available
    
    
    if ( _stillWaitingOnGenericAlertRequest )  // Avoid asking the server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnGenericAlertRequest = YES;
    
    

    NSString *stringURL = @"http://www3.septa.org/api/Alerts/get_alert_data.php?req1=generic";
//    NSString *stringURL = @"http://www3.septa.org/beta/agga/Alerts/gga.php";
    
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"RSVC - getGenericAlertDetails -- api url: %@", webStringURL);
    
    _alertMainOp = [[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOp = _alertMainOp;
    [weakOp addExecutionBlock:^{
        
        NSData *alertData = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self processGenericAlertData:alertData];
            }];
        }
        else
        {
            NSLog(@"NTAVC - getGenericAlertDetails: _jsonOp cancelled");
        }
        
    }];
    
    [_jsonQueue addOperation: _alertMainOp];
    
}


-(void) getMainAlerts
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - getMainAlerts");
#endif
    
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
    
    
    NSString* stringURL = @"http://www3.septa.org/api/Alerts/";
    
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"RSVC - getMainAlerts -- api url: %@", webStringURL);
    
    _alertMainOp = [[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOp = _alertMainOp;
    [weakOp addExecutionBlock:^{
        
        NSData *alertData = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self processMainAlerts:alertData];
            }];
        }
        else
        {
            NSLog(@"NTAVC - getAlertsForLines: _jsonOp cancelled");
        }
        
    }];
    
    [_jsonQueue addOperation: _alertMainOp];
    
    
}


-(void) processMainAlerts:(NSData*) returnedData
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - processMainAlerts");
#endif
    
    _stillWaitingOnAlertRequest = NO;
    
    
    if ( returnedData == nil )  // If we didn't even receive data, try again in another JSON_REFRESH_RATE seconds
    {
        //        NSLog(@"NTAVC - processAlertData - kicking off another Alert request - 1");
        //        [self kickOffAnotherJSONRequest];
        return;
    }
    
    
    NSMutableArray *myData;
    myData = [[NSMutableArray alloc] init];
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    
    if ( json == nil || error != nil )  // Something bad happened, so just return
    {
        //        NSLog(@"NTAVC - processJSON - kicking off another Alert request - 2");
        //        [self kickOffAnotherJSONRequest];  // And before we return, let's try again in JSON_REFRESH_RATE seconds
        return;
    }
    
    
    
    
    
    //    NSMutableDictionary *jsonTest = [[NSMutableDictionary alloc] init];
    
//    if ( /* DISABLES CODE */ (0) )  // Set to 1 when testing, 0 when um... the opposite.
//    {
//        NSMutableArray *jsonTest = [[NSMutableArray alloc] init];
//        
//        NSMutableDictionary *route = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"generic",@"route_id",@"Generic",@"route_name",@"RRD: Warminster Train #4331 is canceled from Warmisnter to Glenside. Service will begin at Glenside to depart the scheduled time of 9:08AM",@"current_message", nil];
//        
//        [jsonTest addObject: route];
//        json = jsonTest;
//        
//    }
    
    
    NSDictionary *alertRouteNameLookup = @{
                                           @"Market/ Frankford Line" : @"MFL",
                                           @"Market Frankford Owl"   : @"MFO",
                                           @"Broad Street Line"      : @"BSL",
                                           @"Broad Street Line Owl"  : @"BSO",
                                           @"Norristown High Speed Line" : @"NHSL",
                                           @"LUCY"                   : @"LUCY",
                                           @"Airport"                : @"AIR",
                                           @"Chestnut Hill East"     : @"CHE",
                                           @"Chestnut Hill West"     : @"CHW",
                                           @"Cynwyd"                 : @"CYN",
                                           @"Fox Chase"              : @"FOX",
                                           @"Glenside Combined"      : @"GC",
                                           @"Lansdale/Doylestown"    : @"LAN",
                                           @"Manayunk/Norristown"    : @"NOR",
                                           @"Media/Elywn"            : @"MED",
                                           @"Paoli/Thorndale"        : @"PAO",
                                           @"Trenton"                : @"TRE",
                                           @"Warminster"             : @"WAR",
                                           @"Wilmington/Newark"      : @"WIL",
                                           @"West Trenton"           : @"WTR",
                                           };
    
    
    for (NSDictionary *data in json)
    {
        
        if ( [_alertMainOp isCancelled] )
            return;
        
        SystemStatusObject *ssObj = [[SystemStatusObject alloc] init];
        
        if ( [[data objectForKey:@"mode"] isEqualToString:_alertMode] )
        {
            
            [ssObj setRoute_id  : [data objectForKey:@"route_id"] ];
            
            if ( [alertRouteNameLookup objectForKey: [data objectForKey:@"route_name"] ] == nil )
            {
                 [ssObj setRoute_name: [data objectForKey:@"route_name"] ];
            }
            else if ( [[data objectForKey:@"route_name"] isEqualToString:@"LUCY"] )
            {
                
                // The Alerts contains one LUCY, whereas the GTFS splits them by Gold and Green.
                // In order to easily handle this, first create an entry for LUCYGO and populate it
                // inside the else if, then setup LUCYGR to be updated outside of the if statement.

                SystemStatusObject *tempObj = [[SystemStatusObject alloc] init];
                [tempObj setRoute_id  : [data objectForKey:@"route_id"] ];

                [tempObj setRoute_name:@"LUCYGO"];
                [tempObj setMode      : [data objectForKey:@"mode"] ];
                [tempObj setIsadvisory: [data objectForKey:@"isadvisory"] ];
                
                [tempObj setIsalert   : [data objectForKey:@"isalert"] ];
                [tempObj setIsdetour  : [data objectForKey:@"isdetour"] ];
                
                [tempObj setIssuspend :[data objectForKey:@"issuppend"] ];
                
                [_ssDict setObject: tempObj forKey: [tempObj route_name] ];
                
                [ssObj setRoute_name:@"LUCYGR"];
            }
            else
            {
                [ssObj setRoute_name: [alertRouteNameLookup objectForKey: [data objectForKey:@"route_name"] ] ];
            }
            
            [ssObj setMode      : [data objectForKey:@"mode"] ];
            [ssObj setIsadvisory: [data objectForKey:@"isadvisory"] ];
            
            [ssObj setIsalert   : [data objectForKey:@"isalert"] ];
            [ssObj setIsdetour  : [data objectForKey:@"isdetour"] ];
            
            [ssObj setIssuspend :[data objectForKey:@"issuppend"] ];
            
            [_ssDict setObject: ssObj forKey: [ssObj route_name] ];
            
        }
        
    }
    
    [self.tableView reloadData];
    
}


-(void) processGenericAlertData:(NSData*) returnedData
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - processGenericAlertData");
#endif
    
    _stillWaitingOnGenericAlertRequest = NO;
    
    
    if ( returnedData == nil )  // If we didn't even receive data, try again in another JSON_REFRESH_RATE seconds
    {
//        NSLog(@"NTAVC - processAlertData - kicking off another Alert request - 1");
//        [self kickOffAnotherJSONRequest];
        return;
    }
    
    
    NSMutableArray *myData;
    myData = [[NSMutableArray alloc] init];
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    
    if ( json == nil || error != nil )  // Something bad happened, so just return
    {
//        NSLog(@"NTAVC - processJSON - kicking off another Alert request - 2");
//        [self kickOffAnotherJSONRequest];  // And before we return, let's try again in JSON_REFRESH_RATE seconds
        return;
    }
    
    
    //    NSMutableDictionary *jsonTest = [[NSMutableDictionary alloc] init];
    
    if ( /* DISABLES CODE */ (0) )  // Set to 1 when testing, 0 when um... the opposite.
    {
        NSMutableArray *jsonTest = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *route = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"generic",@"route_id",@"Generic",@"route_name",@"RRD: Warminster Train #4331 is canceled from Warmisnter to Glenside. Service will begin at Glenside to depart the scheduled time of 9:08AM",@"current_message", nil];

//        NSMutableDictionary *route = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"generic",@"route_id",@"Generic",@"route_name",@"Warminster Train #4331 is canceled from Warminster to Glenside. Service will begin at Glenside to depart the scheduled time of 9:08AM",@"current_message", nil];

        
        [jsonTest addObject: route];
        json = jsonTest;
        
    }
    

    for (NSDictionary *data in json)
    {
        
        if ( [_alertMainOp isCancelled] )
            return;
        
        SystemAlertObject *saObj = [[SystemAlertObject alloc] init];
        [saObj setCurrent_message: [data objectForKey:@"current_message" ] ];
        
        // Does you even contain data, bro?
        if ( [saObj.current_message length] < 2 )  // In case current_message ever gets a space or two
            continue;
        
        [saObj setRoute_name: [data objectForKey:@"route_name"] ];
        [saObj setRoute_id  : [data objectForKey:@"route_id"  ] ];

        
        AlertMessage *alertMsg = [[AlertMessage alloc] init];
        [alertMsg setText: saObj.current_message];
        [alertMsg updateAttrText];
        
        if ( [_alertMode isEqualToString:@"Regional Rail"] )
        {
         
            if ( [ saObj.current_message rangeOfString:@"RRD"].location != NSNotFound )  // If the message contains RRD, it's a generic RR alert
            [_routeData addObject:alertMsg toSection:kDisplayedRouteDataAlerts];
            
        }  // if ( [_alertMode isEqualToString:@"Regional Rail"] )
        else
        {
            if ( [ saObj.current_message rangeOfString:@"RRD"].location == NSNotFound )  // If the message does not contain RRD, it's a generic Bus/Trolley/MFL/BSL/NHSL alert
                [_routeData addObject:alertMsg toSection:kDisplayedRouteDataAlerts];
        }
        
    }
    
    [self.tableView reloadData];
    
    //    [self.tableView beginUpdates];
    
//    if ( [_systemStatusArray count] == 0 )  // If the data is empty, remove the Alerts section
//    {
//        [_tableData removeSectionWithTitle:@"Alerts"];
//    }
//    else if ( [_tableData indexForSectionTitle:@"Alerts"] == NSNotFound )  // If Alerts is not found in _tableData, add it.
//    {
//        [_tableData addSectionWithTitle:@"Alerts"];
//        [_tableData setTag:kNextToArriveSectionAlerts forTitle:@"Alerts"];
//        [_tableData addArray:myData forTitle:@"Alerts"];
//        [_tableData sortByTags];
//        
//        //        [_tableData moveSection:[_tableData indexForSectionTitle:@"Data"] afterSection:[_tableData indexForSectionTitle:@"Alerts"] ];
//    }
//    else  // Otherwise, just update the Alerts section with the new data
//    {
//        [_tableData clearSectionWithTitle:@"Alerts"];
//        [_tableData replaceArrayWith: myData forTitle:@"Alerts"];
//    }
    
    
    [self.tableView reloadData];
    
    
    //    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[_tableData indexForSectionTitle:@"Alerts"] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //    [self.tableView endUpdates];
    
    //    NSLog(@"JSON: %@", json);
    
}


#pragma mark - RouteSelectionCell Protocol
-(void) alertTapped
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - alertTapped");
#endif
    
    NSLog(@"Alert Tapped");
    
}


-(CAShapeLayer*) formatCell:(UITableViewCell*) cell forIndexPath:(NSIndexPath*) indexPath
{

#if FUNCTION_NAMES_ON
    NSLog(@"RSVC - formatCell: forIndexPath: %@", indexPath);
#endif
    
    UIRectCorner corner = 0;
    
    // First Cell
//    corner |= UIRectCornerTopRight;
    
    // Last Cell
//    corner |= UIRectCornerBottomRight;
    
    AlertMessage *aMsg = (AlertMessage*)[_routeData objectWithIndexPath:indexPath];
    CGFloat msgHeight = CGRectFromString( aMsg.rect ).size.height+12;
    
    float x = 4.0;
    float y = 4.0;
    CGRect bound = cell.bounds;
    bound.size.height = msgHeight;
    bound.size.width = self.view.frame.size.width - 5;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: bound
                                                   byRoundingCorners: corner
                                                         cornerRadii: CGSizeMake(x, y)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bound;
    maskLayer.path= maskPath.CGPath;
    
    return maskLayer;
    
}


@end
