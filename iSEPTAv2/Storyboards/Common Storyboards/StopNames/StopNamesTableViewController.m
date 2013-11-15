//
//  StopNamesTableViewController.m
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "StopNamesTableViewController.h"

@interface StopNamesTableViewController ()

@end

@implementation StopNamesTableViewController
{
    TableViewStore *_tableData;
    
    BOOL _startState;
    BOOL _doubleSectionMode;
    
    NSMutableDictionary *_replacement;
    
//    NSInteger _selectionType;
}

@synthesize stopData;
@synthesize selectionType;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}


-(void) viewWillAppear:(BOOL)animated
{
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];

    _replacement = [[NSMutableDictionary alloc] init];
//    [_replacement setObject:@"Main St (Norristown)" forKey:@"Main Street"];
//    [_replacement setObject:@"Norristown (Main St)" forKey:@"Main Street"];
    [_replacement setObject:@"Highland Avenue (WIL)" forKey:@"Highland Avenue"];
    [_replacement setObject:@"Highland (CHW)" forKey:@"Highland"];
    [_replacement setObject:@"Elm Street (NOR)" forKey:@"Norristown"];
    [_replacement setObject:@"Main Street (NOR)" forKey:@"Main Street"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // Register your Xibs!
    [self.tableView registerNib:[UINib nibWithNibName:@"StopNamesCLEACell" bundle:nil] forCellReuseIdentifier:@"StopNamesCLEACell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlainNamesCell" bundle:nil   ] forCellReuseIdentifier:@"PlainNamesCell"   ];

    
    // Initialize Data Object
    _tableData = [[TableViewStore alloc] init];
    
    
    // Add a DONE button
    [self.navigationItem setRightBarButtonItem: [ [UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)] ];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    
    if ( self.backImageName == nil )
        self.backImageName = @"NTA-white.png";
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:self.backImageName
                                                                                  withTarget:self
                                                                               andWithAction:@selector(backButtonPressed:)];
    
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    
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
    
    
    
    
    NSString *title;
//    switch ( [stopData.route_type intValue] )
//    {
//        case kGTFSRouteTypeRail:
//            title = @"Select Train Stop";
//            break;
//            
//        case kGTFSRouteTypeBus:
//            title = @"Select Bus Stop";
//            break;
//            
//        case kGTFSRouteTypeTrolley:
//            title = @"Select Trolley Stop";
//            break;
//            
//        default:
//            title = @"Select Stop";
//            break;
//    }

    if ( selectionType == kNextToArriveSelectionTypeStart || selectionType == kNextToArriveSelectionTypeStartAndEnd )
        title = @"Select Start Stop";
    else if ( selectionType == kNextToArriveSelectionTypeEnd )
        title = @"Select End Stop";
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: title];
    [self.navigationItem setTitleView:titleView];

    
    // There is a very specific set of conditions that must occur first before switching to doubleSectionMode.
    //    There is no direction because the user hasn't chosen a stop yet.  And the travelMode is Bus/Trolley.  For all
    //    other instances, one section is enough to display everything.
    GTFSRouteType routeType = [stopData.route_type intValue];
    if ( stopData.start_stop_name == nil && stopData.end_stop_name == nil && ( (routeType == kGTFSRouteTypeTrolley) || (routeType == kGTFSRouteTypeBus) ) )
        _doubleSectionMode = YES;
    else
        _doubleSectionMode = NO;
    
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"mainBackground.png"] ];
    [bgImageView setAlpha:0.20f];
    [self.tableView setBackgroundView: bgImageView];
    
//    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
    
    // Determine selection state
    if ( selectionType == kNextToArriveSelectionTypeStart || selectionType == kNextToArriveSelectionTypeStartAndEnd )
    {
        _startState = YES;
    }
    else if ( selectionType == kNextToArriveSelectionTypeEnd )
    {
        _startState = NO;
    }

    
    if ( [stopData.route_type intValue] == kGTFSRouteTypeBus )
        [self loadBusStopNames];
    else if ( [stopData.route_type intValue] == kGTFSRouteTypeTrolley && ![stopData.route_short_name isEqualToString:@"NHSL"] )
        [self loadBusStopNames];
    else
        [self loadRailStopNames];
    
    
//    if ( ([stopData.route_type intValue] == kGTFSRouteTypeBus) || ([stopData.route_type intValue] == kGTFSRouteTypeTrolley) )
//        [self loadBusStopNames];
//    else
//        [self loadRailStopNames];

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    _tableData = nil;
    
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
}


#pragma mark - Table view data source
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // All sections should be gray
    //    [cell setBackgroundColor: [UIColor colorWithRed:216.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1] ];  // 218, 217 are the missing numbers... Mwhahahaha.  You can't have them bac... oh, wait.
    
//    [cell setBackgroundColor: [UIColor colorWithWhite:1.0f alpha:.8] ];
    
    switch (indexPath.row)
    {
        case 0:
        case 1:
//            [cell setBackgroundColor: [UIColor colorWithWhite:0.6f alpha:1.0f] ];
        {
//            CGSize textSize = [cell.textLabel.text sizeWithFont: cell.textLabel.font];
//            NSLog(@"%d - textSize: %@", indexPath.row, NSStringFromCGSize(textSize));
//         
//            UIImageView *grayImageView = [[UIImageView alloc] init];
//            NSLog(@"accessory: %@", NSStringFromCGRect(cell.accessoryView.frame));
//            [grayImageView setFrame:CGRectMake(5, (cell.textLabel.frame.size.height - textSize.height)/2, cell.textLabel.frame.size.width - 10, textSize.height)];
//            [grayImageView setBackgroundColor:[UIColor colorWithWhite:0.6f alpha:1.0f]];
//            [cell addSubview: grayImageView];
//            [cell sendSubviewToBack: grayImageView];
            
//            [cell.textLabel setBackgroundColor: [UIColor redColor] ];
            
//            [cell.textLabel setTextAlignment: UITextAlignmentCenter];
////            [cell.textLabel setBackgroundColor: [UIColor colorWithWhite:0.1f alpha:0.2f] ];
//            [cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        }
            break;
            
        default:
            ;
            break;
    }
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_line.png"]];
    UITableViewCell *newCell = (UITableViewCell*)cell;
    
    [separator setFrame: CGRectOffset(separator.frame, 0, newCell.frame.size.height-separator.frame.size.height)];

    [newCell.contentView addSubview: separator];
    
}


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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *CellIdentifier = @"Cell";
    static NSString *cellCLEA = @"StopNamesCLEACell";  // CurrentLocation and EnterAddress
    static NSString *cellPlainNames = @"PlainNamesCell";
    
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    TripData *trip = [_tableData objectForIndexPath:indexPath];
    
    if ( [trip.start_stop_id intValue] <= kStopNamesSpecialCurrentLocation)
    {
        
        StopNamesCLEACell *snCell = (StopNamesCLEACell*)[tableView dequeueReusableCellWithIdentifier: cellCLEA];
        // Temporary fix: don't allow Enter Address to be selected
        if ( [trip.start_stop_id intValue] == kStopNamesSpecialEnterAddress)
        {
            [snCell setSelectionStyle: UITableViewCellSelectionStyleNone];
        }
        
//        [cell.textLabel setTextAlignment: UITextAlignmentCenter];
        [snCell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
        [snCell.lblTitle setText: trip.start_stop_name];
        
        return snCell;
    }
    else
    {
        PlainNamesCell *pnCell = (PlainNamesCell*)[tableView dequeueReusableCellWithIdentifier: cellPlainNames];

        [pnCell.textLabel setTextAlignment: NSTextAlignmentLeft];
        [pnCell setAccessoryType: UITableViewCellAccessoryNone];
//        [[pnCell textLabel] setText: trip.vanity_start_stop_name];
        
        [pnCell setWheelchairAccessiblity: [trip.wheelboard_boarding boolValue] ];
        [[pnCell lblStopName] setText: trip.vanity_start_stop_name];
        
        return pnCell;
    }
    
    
}


-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSString *header = [_tableData titleForSection: section];
    if ( [header isEqualToString:@"Data"] )
        return nil;
    else
        return header;
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    NSIndexPath *path = [_tableData getIndexPathForIndex:index];
//    NSInteger row = [_tableData getSectionWithIndex:index];
    
    //    // TODO: This won't work with Favorites and Recently Viewed
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return -1;  // Yes, Virginia.  Keep this as -1.
    
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [_tableData getSectionTitles];
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
    
    // For now, we're avoiding currect location for Bus and Trolleys
//    if ( [stopData.route_type intValue] == kGTFSRouteTypeBus)
//    {
//        [self.navigationItem.rightBarButtonItem setEnabled:YES];
//        return;
//    }
//    else if ( [stopData.route_type intValue] == kGTFSRouteTypeTrolley && ![stopData.route_short_name isEqualToString:@"NHSL"] )
//    {
//        [self.navigationItem.rightBarButtonItem setEnabled:YES];
//        return;
//    }
    
    
    if ( indexPath.row == 0 )
    {
        NSLog(@"Selected Current Location");
        
        [self.navigationItem.rightBarButtonItem setEnabled:NO];  // Disable button if Current Location was selected
        
        NSString * storyboardName = @"CurrentLocationStoryboard";
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        CurrentLocationTableViewController *clVC = (CurrentLocationTableViewController*)[storyboard instantiateInitialViewController];
        
        [clVC setBackImageName: _backImageName];
        
        if ( [stopData.route_type intValue] == kGTFSRouteTypeRail )
            [clVC setRouteType: [NSNumber numberWithInt:kCurrentLocationRouteTypeRailOnly] ];
        else
            [clVC setRouteType: [NSNumber numberWithInt:kCurrentLocationRouteTypeBusOnly] ];
        
        [clVC setRouteData: stopData];
        [clVC setDelegate:self];

        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

        [self.navigationController pushViewController:clVC animated:YES];
        
    }
    else if ( indexPath.row == 1 )
    {
        NSLog(@"Selected Enter Address");
        
        [self.navigationItem.rightBarButtonItem setEnabled:NO];  // Disable button if Enter Location was selected
        
        NSString * storyboardName = @"EnterAddressStoryboard";
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        EnterAddressViewController* mdsGVC = (EnterAddressViewController*)[storyboard instantiateInitialViewController];

        [mdsGVC setStopData: self.stopData];
        [mdsGVC setRouteType: self.routeType];
        
        [self.navigationController pushViewController:mdsGVC animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        //        EnterAddressTableViewController *eaVC = [[navController viewControllers] objectAtIndex:0];
        ////        [eaVC setRouteType: [NSNumber numberWithInt:kCurrentLocationRouteTypeRailOnly] ];
        //        [eaVC setDelegate:self];
        //
        //        [self presentViewController:navController animated:YES completion:nil];
        //        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        //        ForwardViewController *fvc = [[ForwardViewController alloc] initWithNibName:@"ForwardViewController" bundle:nil];
        //        [fvc setTitle:@"Forward"];
        
        //        [self presentModalViewController:fvc animated:YES];
        
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }

    
}



#pragma mark - Database Access
-(NSString*) filePath
{
    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
}



-(void) loadBusStopNames
{

    BOOL addedHeader = NO;
    NSDate *startTime = [NSDate date];
    NSLog(@"SNFRTC - Starting at %@", startTime);
    
    
    NSMutableDictionary *headerToDirection = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSMutableArray *headers = [[NSMutableArray alloc] initWithCapacity:2];
    
    
    [_tableData removeAllObjects];
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    /*
     *  Now that the database is open, need to query bus_stop_directions for the proper header name for each section
     *  This is only applicable for Bus and Trolley, as their direction is important to which stops they make
     */
    
    if ( ([stopData.route_type intValue] == kGTFSRouteTypeBus) || ([stopData.route_type intValue] == kGTFSRouteTypeTrolley) )
    {
        
        NSString *queryStr = [NSString stringWithFormat:@"SELECT dircode, Route, DirectionDescription FROM bus_stop_directions WHERE Route=\"%@\" ORDER BY dircode", stopData.route_short_name];
        FMResultSet *results = [database executeQuery: queryStr];
        if ( [database hadError] )  // Check for errors
        {
            
            int errorCode = [database lastErrorCode];
            NSString *errorMsg = [database lastErrorMessage];
            
            NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
            NSLog(@"SNFRTC - query str: %@", queryStr);
            
            return;  // If an error occurred, there's nothing else to do but exit
            
        } // if ( [database hadError] )
        
//        [_nameForSection removeAllObjects];
        while ( [results next] )
        {
            NSString *header  = [results stringForColumn:@"DirectionDescription"];
            NSString *dircode = [results stringForColumn:@"dircode"];

            if ( [dircode isEqualToString:@"NULL"] )
                continue;
            
//            [_nameForSection addObject:header];
//            [directionToHeaderArr addObject: header];
            
            [_tableData addSectionWithTitle: header];
            [headerToDirection setObject:header forKey: dircode ];
            [headers addObject:header];
            addedHeader = YES;
        }  // while ( [results next] )
        
        
        // If no headers were added, put in some default ones
        if ( !addedHeader )
        {
            // TODO: What if Route is a Loop and has one direction?
            [headerToDirection setObject:@"Dir0" forKey:@"0"];
            [headerToDirection setObject:@"Dir1" forKey:@"1"];
            
            [headers addObject:@"Dir0"];
            [headers addObject:@"Dir1"];
            
            [_tableData addSectionWithTitle:@"Dir0"];
            [_tableData addSectionWithTitle:@"Dir1"];
        }
        
    }  // if ( ([stopData.route_type intValue] == kGTFSRouteTypeBus ) || ( ... ) )
    
    

    
    
    GTFSRouteType routeType = [stopData.route_type intValue];
    NSString *queryStr;
    
    switch ( routeType )
    {
        case kGTFSRouteTypeBus:
        case kGTFSRouteTypeTrolley:
            
            if ( stopData.start_stop_name == nil && stopData.end_stop_name == nil )
            {
                queryStr = [NSString stringWithFormat:@"SELECT stop_name, stop_id, wheelchair_boarding FROM stopNameLookUpTable NATURAL JOIN stops_bus WHERE route_short_name=\"%@\" ORDER BY stop_name", stopData.route_short_name];
            }
            else
            {
                queryStr = [NSString stringWithFormat:@"SELECT stop_name, stop_id, wheelchair_boarding FROM stopNameLookUpTable NATURAL JOIN stops_bus WHERE route_short_name=\"%@\" AND direction_id=%d ORDER BY stop_name", stopData.route_short_name, stopData.direction_id];
            }
            
            break;
                        
        case kGTFSRouteTypeSubway:
            
            queryStr = @"SELECT stops_bus.stop_name, stop_times_DB.stop_id, stops_bus.wheelchair_boarding FROM trips_DB JOIN stop_times_DB ON trips_DB.trip_id=stop_times_DB.trip_id NATURAL JOIN stops_bus GROUP BY stop_times_DB.stop_id ORDER BY stops_bus.stop_name;";
            
            queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString: stopData.route_short_name];
            
            break;
        default:
            break;
    }
    
    
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {

        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];

        NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNFRTC - query str: %@", queryStr);

        return;  // If an error occurred, there's nothing else to do but exit

    } // if ( [database hadError] )


    while ( [results next])
    {

        NSString *stop_name = [results stringForColumn:@"stop_name"];
        NSNumber *stop_id   = [NSNumber numberWithInt: [results intForColumn:@"stop_id"] ];
        NSNumber *direction_id;
        
        if ( [stopData.route_type intValue] == kGTFSRouteTypeBus || [stopData.route_type intValue] == kGTFSRouteTypeTrolley )
            direction_id = [NSNumber numberWithInt:[results intForColumn:@"direction_id"] ];
        
        
        TripData *trip = [[TripData alloc] init];
        [trip setStart_stop_name: stop_name];
        [trip setStart_stop_id  : stop_id  ];
        [trip setDirection_id: direction_id];
        [trip setVanity_start_stop_name: stop_name];
        [trip setWheelboard_boarding: [NSNumber numberWithBool: [results intForColumn:@"wheelchair_boarding"] ] ];
        
        NSString *header = [headerToDirection objectForKey:[NSString stringWithFormat:@"%d", [direction_id intValue] ] ];
        if ( header != nil )
        {
            [_tableData addObject:trip forTitle:header];

        
            if ( _doubleSectionMode )
            {
    //            if ( [direction_id intValue] == 0 )
    //            {
    //                [_stopsSection0 addObject:trip];
    //            }
    //            else
    //            {
    //                [_stopsSection1 addObject:trip];
    //            }
            
            }
            else
            {
//            //            [_stopNames addTimes:trip];
//            [_stopsSection0 addObject:trip];
            }
        
        } // if ( header != nil )
        
    }  // while ( [results next] )

    
    [database close];

    
    NSMutableArray *dir0Arr = (NSMutableArray*)[_tableData objectForSectionWithTitle:[headerToDirection objectForKey:@"0"] ];
    NSMutableArray *dir1Arr = (NSMutableArray*)[_tableData objectForSectionWithTitle:[headerToDirection objectForKey:@"1"] ];
    
//    [myArray sortUsingComparator:^NSComparisonResult(TripData *a, TripData *b)
//     {
//         return [a.start_stop_name compare:b.start_stop_name options:NSNumericSearch];
//     }];

    
    // Add Current Location and Enter Address at the start of the arrary
    TripData *currentLocation = [[TripData alloc] init];
    [currentLocation setStart_stop_name: @"Current Location"];
    [currentLocation setStart_stop_id: [NSNumber numberWithInt: kStopNamesSpecialCurrentLocation] ];
    [currentLocation setDirection_id:  [NSNumber numberWithInt:0] ];
    
    TripData *enterAddress = [[TripData alloc] init];
    [enterAddress setStart_stop_name: @"Enter Address"];
    [enterAddress setStart_stop_id: [NSNumber numberWithInt: kStopNamesSpecialEnterAddress] ];
    [enterAddress setDirection_id:  [NSNumber numberWithInt:0] ];
    
    //    [_tableData addObject:currentLocation forTitle:@"Data"];
    //    [_tableData addObject:enterAddress];
    
    [dir0Arr insertObject:enterAddress atIndex:0];
    [dir0Arr insertObject:currentLocation atIndex:0];
    
    [dir1Arr insertObject:enterAddress atIndex:0];
    [dir1Arr insertObject:currentLocation atIndex:0];
    

    [_tableData generateIndexWithKey:@"start_stop_name" forSectionTitles:[NSArray arrayWithArray: headers] ];
//    [self.tableView reloadData];
    
//    if ( _doubleSectionMode )
//    {
//        NSDictionary *indices0 = [_stopsSection0 dictionaryOfIndicesandTitlesForKey:@"start_stop_name" forSection: [NSNumber numberWithInt:0] ];
//        NSDictionary *indices1 = [_stopsSection1 dictionaryOfIndicesandTitlesForKey:@"start_stop_name" forSection: [NSNumber numberWithInt:1] ];
//        
//        //        NSDictionaactivry *indices1 = [_stopsSection1 dictionaryOfIndicesandTitlesForKey:@"start_stop_name"];
//        
//        _sectionIndex = [indices0 objectForKey:@"index"];
//        [_sectionIndex addObject:[NSIndexPath indexPathForRow:0 inSection:1] ];  // Divider
//        [_sectionIndex addObjectsFromArray: [indices1 objectForKey:@"index"] ];
//        
//        _sectionTitle = [indices0 objectForKey:@"title"];
//        [_sectionTitle addObject:@"—"];
//        [_sectionTitle addObjectsFromArray: [indices1 objectForKey:@"title"] ];
//        
//    }
//    else
//    {
//        //        [_stopNames sort];
//        NSDictionary *indices0 = [_stopsSection0 dictionaryOfIndicesandTitlesForKey:@"start_stop_name" forSection: [NSNumber numberWithInt:0] ];
//        
//        _sectionIndex = [indices0 objectForKey:@"index"];
//        _sectionTitle = [indices0 objectForKey:@"title"];
//    }
//    
//    
//    //    [_stopNames generateIndex];
//    NSTimeInterval diff = [ [NSDate date] timeIntervalSinceDate: startTime];
//    NSLog(@"SNFRTC - %6.3f seconds have passed.", diff);
//    
    
}


-(void) loadRailStopNames
{
    
    //    [stopNames removeAllObjects];
    
//    [_stopNames clearData];
    
    [_tableData removeAllObjects];
    
    
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    NSString *queryStr;

    GTFSRouteType routeType = [stopData.route_type intValue];
    
    switch (routeType)
    {
        case kGTFSRouteTypeRail:
            queryStr = @"SELECT stop_name, stop_id, wheelchair_boarding FROM stops_rail ORDER BY stop_name";
            break;
        default:
            queryStr = @"SELECT stops_bus.stop_name, stop_times_DB.stop_id, stops_bus.wheelchair_boarding FROM trips_DB JOIN stop_times_DB ON trips_DB.trip_id=stop_times_DB.trip_id NATURAL JOIN stops_bus GROUP BY stop_times_DB.stop_id ORDER BY stops_bus.stop_name;";
            
            queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString: stopData.route_short_name];
            break;
    }

    
    
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"SNTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNTC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    }
    
    
    [_tableData addSectionWithTitle:@"Data"];
    
    while ( [results next] )
    {
        
        NSString *stop_name = [results stringForColumn:@"stop_name"];
        NSInteger stop_id  = [results intForColumn:@"stop_id"];
        
        if ( [stop_name isEqualToString:@"Main Street"] || [stop_name isEqualToString:@"Norristown"] )
        {
            NSLog(@"Break");
        }
        
        NSString *vanity_stop_name = [self fixMismatchedStopName:stop_name];
        
        //        StopNamesObject *snObject = [[StopNamesObject alloc] init];
        //        [snObject setStop_id: [NSNumber numberWithInt:stop_id] ];
        //        [snObject setStop_name: stop_name];
        //
        //        [stopNames addObject: snObject];
        
        TripData *trip = [[TripData alloc] init];
        [trip setStart_stop_name: stop_name];
        [trip setVanity_start_stop_name:vanity_stop_name];
        [trip setStart_stop_id:   [NSNumber numberWithInt:stop_id] ];
        [trip setWheelboard_boarding: [NSNumber numberWithBool: [results intForColumn:@"wheelchair_boarding"] ] ];
//        [_stopNames addTimes:trip];
        
        [_tableData addObject: trip];
        
        
    }
    

    NSMutableArray *myArray = (NSMutableArray*)[_tableData objectForSectionWithTitle:@"Data"];
    [myArray sortUsingComparator:^NSComparisonResult(TripData *a, TripData *b)
    {
        return [a.vanity_start_stop_name compare:b.vanity_start_stop_name options:NSNumericSearch];
    }];
    
    
    // Add Current Location and Enter Address at the start of the arrary
    TripData *currentLocation = [[TripData alloc] init];
    [currentLocation setStart_stop_name: @"Current Location"];
    [currentLocation setStart_stop_id: [NSNumber numberWithInt: kStopNamesSpecialCurrentLocation] ];
    [currentLocation setDirection_id:  [NSNumber numberWithInt:0] ];
    
    TripData *enterAddress = [[TripData alloc] init];
    [enterAddress setStart_stop_name: @"Enter Address"];
    [enterAddress setStart_stop_id: [NSNumber numberWithInt: kStopNamesSpecialEnterAddress] ];
    [enterAddress setDirection_id:  [NSNumber numberWithInt:0] ];
    
//    [_tableData addObject:currentLocation forTitle:@"Data"];
//    [_tableData addObject:enterAddress];

    [myArray insertObject:enterAddress atIndex:0];
    [myArray insertObject:currentLocation atIndex:0];
    
    
    [_tableData generateIndexWithKey:@"start_stop_name"];
    
}


-(NSString *) fixMismatchedStopName: (NSString*) stopName;
{
    
    // Unfortunately, at the time of writing this method, there are a few stop names in the GTFS file
    // that do not match up with the stop name of an internal SEPTA database.  As such, this method
    // looks for one of those stop names and replaces it with one that matches the internal name.
    
    // P.S. This is horrible code, if anyone asks, I'll deny ever writing in.
    //   Ran php jarowinkler | egrep -v 100% to find the gasps between the GTFS and internal naming.
    
    NSString *temp = [_replacement objectForKey:stopName];
    
    if ( temp != nil )
    {
        NSLog(@"NTAVC - fixMismatchedStopName: replacing %@ with %@", stopName, temp);
        return temp;
    }
    else
        return stopName;
    
}



#pragma mark - Buttons Pressed
-(void) backButtonPressed:(id) sender
{

    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void) doneButtonPressed:(id) sender
{
    [self selectionMade];
}


-(void) selectionMade
{
    
    if ( [self.delegate respondsToSelector:@selector(buttonPressed:withData:)] )
    {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if ( [indexPath isEqual: [NSIndexPath indexPathForRow:1 inSection:0] ] )
        {
            return;
        }
        
        StopNamesObject *sObj = [[StopNamesObject alloc] init];
        
        if ( indexPath != nil )
        {
            TripData *trip = [_tableData objectForIndexPath:indexPath];
            [sObj setStop_name: [trip start_stop_name] ];
            [sObj setStop_id  : [trip start_stop_id  ] ];
        }
        
        
//        NSLog(@"SNTVC - buttonType: %d", (kNextToArriveButtonTypeDone | kNextToArriveButtonTypeStartField) );
        
        if ( _startState )
            [self.delegate buttonPressed: (kNextToArriveButtonTypeDone | kNextToArriveButtonTypeStartField) withData:sObj];
        else
            [self.delegate buttonPressed: (kNextToArriveButtonTypeDone | kNextToArriveButtonTypeEndField)   withData:sObj];
        
    }
    
    
    // Don't close the StopNames VC if selectionType was set to Start and End and _startStart is TRUE
    if ( _startState && selectionType == kNextToArriveSelectionTypeStartAndEnd )
    {
        // Refresh VC.  Unselect current selection,
        
        if ( _doubleSectionMode )
        {
            // Because we're showing a doubleSelection, once a stop has been chosen, it's direction has indirectly been determined
            // With that direction now known, remove the opposite section
            
            //NSInteger section = [[self.tableView indexPathForSelectedRow] section];

            //NSString *header = [_tableData titleForSection: section];
            //[_tableData removeSectionWithTitle: header];
            
        }
        
        [self.tableView deselectRowAtIndexPath: [self.tableView indexPathForSelectedRow] animated:YES];
        
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
        [self.tableView scrollsToTop];
        
        LineHeaderView *header = (LineHeaderView*)[self.navigationItem titleView];
        [header setTitle:@"Select End Stop"];
        
        _startState = NO;
        
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

//#pragma mark - Getter/Setter Methods
//-(void) setSelectionType: (NSInteger) selectionType
//{
//    _selectionType = selectionType;
//}
//
//
//-(NSInteger) selectionType
//{
//    return _selectionType;
//}



#pragma mark - CurrentLocationProtocol
-(void) currentLocationSelectionMade:(BasicRouteObject *)routeObj
{
    NSLog(@"Received object: %@", routeObj);
    
    TripData *trip = [[TripData alloc] init];
    [trip setStart_stop_name: routeObj.stop_name];
    [trip setStart_stop_id  : [NSNumber numberWithInt: [routeObj.stop_id intValue] ] ];
    
    
    //NSArray *tempArr = [_tableData objectForSectionWithTitle:@"Data"];

    NSUInteger index = 0;
    for ( int LCV=0; LCV < [_tableData numOfSections]; LCV++ )
    {
        
        NSArray *dataArr = [_tableData objectForSection: LCV];
        if ( dataArr == nil || [dataArr count] == 0 )
        {
            continue;
        }
        
        

        if ( [[dataArr objectAtIndex:0] isKindOfClass:[TripData class] ] )
        {
        
            index = [dataArr indexOfObjectWithOptions:NSEnumerationConcurrent
                                                 passingTest:^(id obj, NSUInteger idx, BOOL *stop)
                            {
                                TripData *myTrip = (TripData *)obj;
//                                if ( [myTrip.start_stop_name isEqualToString:trip.start_stop_name])
                                if ( [myTrip.start_stop_id intValue] == [trip.start_stop_id intValue] )
                                {
                                    *stop = YES;
                                    return YES;
                                }
                                return NO;
                            }];
            
        }
        
        if ( index != NSNotFound )
        {
            break;
        }
        
    }
    
    
//    NSUInteger index = [tempArr indexOfObject:trip];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"start_stop_name = %@", routeObj.stop_name];
//    NSArray *results = [tempArr filteredArrayUsingPredicate:predicate];
    
//    [self.tableView scrollToNearestSelectedRowAtScrollPosition:index animated:YES];
//    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
//    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

    
    
    // Uncomment out this one!
    [self performSelector:@selector(highlightTheDamnRow:) withObject:[NSNumber numberWithInt:index] afterDelay:0.001f];  // Adding a delay works
    
//    [self highlightTheDamnRow: index];  // Not having a delay makes the highlight go away as the old VC is brought back
    
    NSLog(@"index: %d", index);
}


-(void) highlightTheDamnRow:(NSNumber*) index
{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[index intValue] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
//    [self selectionMade];
}



#pragma mark - Gesture Recognizers
-(void) gestureLongPress:(UILongPressGestureRecognizer*) gesture
{
    NSLog(@"Long press: %d", gesture.state);
    
    
    
    if ( gesture.state == UIGestureRecognizerStateBegan )
    {
        NSIndexPath *currentSelection = [self.tableView indexPathForSelectedRow];
        
        CGPoint touchPoint = [gesture locationInView:self.view];
        NSIndexPath *row = [self.tableView indexPathForRowAtPoint:touchPoint];
        

        // If the currentSelection differs from the longPress selection, deselect old and select new
        if ( row != currentSelection )
        {
            [self.tableView deselectRowAtIndexPath:currentSelection animated:NO];
            [self.tableView selectRowAtIndexPath:row animated:NO scrollPosition:UITableViewScrollPositionNone];
        }

        
        switch (row.row) {
            case 0:
            case 1:
                [self tableView:self.tableView didSelectRowAtIndexPath:row];
                break;
                
            default:
                [self doneButtonPressed:nil];
                break;
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
//    [self doneButtonPressed:nil];
    [self selectionMade];
}


@end
