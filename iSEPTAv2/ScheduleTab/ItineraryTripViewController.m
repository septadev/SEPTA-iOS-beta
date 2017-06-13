//
//  ItineraryTripViewController.m
//  iSEPTA
//
//  Created by septa on 3/5/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "ItineraryTripViewController.h"

#import "MapViewController.h"
#import "TripDetailsTableController.h"

//#import "ItineraryCell.h"
#import "TripCell.h"
#import "ActiveTrainCell.h"
#import "NTASaveObjectCell.h"

// --==  Data Models  ==--
#import "ItineraryObject.h"
#import "TripObject.h"
#import "ActiveTrainObject.h"
// --==  Data Models  ==--

// --==  External Libraries  ==--
#import "SVProgressHUD.h"
#import "FMDatabase.h"
// --==  External Libraries  ==--

// --==  Categories  ==--
#import "NSString+Hashes.h"
// --==  Categories  ==--

#import "DisplayedRouteData.h"


#import "StopNamesForRouteTableController.h"

#define DEFAULT_MESSAGE @"Click to enter destination"
#define CELL_REFRESH_RATE 60.0f/6.0f   // 6 times a minute, 10 seconds refresh rate
#define JSON_REFRESH_RATE 60.0f/4.0f   // 4 times a minute, 15 seconds refresh rate

@interface ItineraryTripViewController ()

@end

@implementation ItineraryTripViewController
{
    
    /*
     This VC will contain three sections: itinerary, active trains, trips.
     itinerary - holds start/end stops (name and id), direction_id, route_id and contains the various buttons this VC will respond to
     active trains - an array of tripObjects.  Loaded from TrainView, inserts data into the VC 5-10 seconds after VC has finished loading
     trips - holds the start/end time, train #, route_id, direction_id, service_id, start/end sequence
     */
    
    ItineraryObject *itinerary;
    NSMutableArray *activeTrainsArr;  // Array of TripObjects
    NSMutableArray *masterTripsArr;   // Master list of all TripObjects based on ItineraryObject
    NSMutableArray *currentTripsArr;  // Filtered from master list based on direction_id and service_id
    BOOL _startENDButtonPressed;
 
    NSInteger _currentDisplayDirection;
    NSInteger _currentSegmentIndex;
    
    // --==  Runs SQL queries in a background thread  ==--
    NSOperationQueue *_sqlQueue;
    NSBlockOperation *_sqlOp;
    
    // --==  Runs JSON queries in a background thread  ==--
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_jsonOp;
    NSMutableDictionary *_masterTrainLookUpDict;
    NSMutableArray *_masterJSONTrainArr;
//    NSMutableArray *_currentJSONTrainArr;
    
    NSTimer *cellRefreshTimer;  // Refreshes time for each cell
//    NSTimer *cellRemoverTimer;  // Used during testing, probably doesn't need to be used any longer
    NSTimer *jsonRefreshTimer;  // Refreshes JSON data
    
    BOOL _findLocationsSegue;
    BOOL _use24HourTime;
    BOOL _stillWaitingOnWebRequest;
    
    BOOL _viewIsClosing;
    
//    NSString *_currentServiceID;
    NSInteger _currentServiceID;
    NSMutableArray *toFromDirection;
    NSString *_headerDirection;

    // Used to store the header titles for the current bus direction
    NSMutableArray *_nameForSection;

    
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
    
    
    // Registering xib
    [self.tableTrips registerNib:[UINib nibWithNibName:@"ActiveTrainCell" bundle:nil] forCellReuseIdentifier:@"ActiveTrainCell"];
    [self.tableTrips registerNib:[UINib nibWithNibName:@"ItineraryCell"   bundle:nil] forCellReuseIdentifier:@"ItineraryCell"];
    [self.tableTrips registerNib:[UINib nibWithNibName:@"TripCell"        bundle:nil] forCellReuseIdentifier:@"TripCell"];
    
    
    // Dismiss any active SVProgressHUD.  Previous VC could have started one.
    _startENDButtonPressed = 0;
    
    _currentSegmentIndex = [self.segmentService selectedSegmentIndex];
    _currentDisplayDirection    = 0;  // Default current direction to 0
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
        [itinerary setStartStopName: DEFAULT_MESSAGE];
        [itinerary setEndStopName  : DEFAULT_MESSAGE];
        
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
        
        
        // If either Start or End stop_id is invalid, the SQL query will return nothing and nothing will be changed.
        [self reverseStopLookUpForStart:YES];
        [self reverseStopLookUpForStart:NO];
        
        
//        if ( [self.travelMode isEqualToString:@"Bus"] )
//        {
//            
//            [itinerary reverse];
//            
//            // Populate the itinerary in the opposite direction
//            [itinerary setStartStopName: DEFAULT_MESSAGE];
//            [itinerary setEndStopName  : DEFAULT_MESSAGE];
//            
//            [itinerary setStartStopID :[NSNumber numberWithInt:0] ];
//            [itinerary setEndStopID   :[NSNumber numberWithInt:0] ];
//            
//            [itinerary reset];
//            
//        }
        
        
//        NSString *key = [NSString stringWithFormat:@"%@%@%@", itinerary.routeID, itinerary.startStopName, itinerary.endStopName];
//        NSLog(@"MD5 hash for %@ = %@", key, [key md5]);
//        NSLog(@"SHA1 hash for %@ = %@", key, [key sha1]);
    }


    _nameForSection = [[NSMutableArray alloc] init];  // Needs to be initialized before [self loadHeaderNames]
    [self loadHeaderNamesWith: itinerary];  // Itinerary Object needs to be defined before this;  Or I can do that and explicitly state what it needs
    // Except, butthead, you forgot to pass _nameForSection into it as well.
    
    
//    for (int LCV = 0; LCV < 100; LCV++ )
//    {
//        TripObject *trip = [[TripObject alloc] init];
//        
//        [trip setTrainNo:[NSNumber numberWithInt:444] ];
//        [trip setStartTime: @"15:00"];
//        
//        [trip setEndTime: @"16:00"];
//        
//        [currentTripsArr addObject: trip];
//    }
    
    // --==  TEMPORARY, JUST FOR TESTING  ==--
    
    // --==  Set Title of the ViewController  ==--
    [self setTitle:@"Schedule"];
    
    DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
//    NSLog(@"RouteData: %@", routeData.current);
    
    // Check if flipped stop names are a favorite location
    if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
        [self setFavoriteHighlight:YES];
    else
        [self setFavoriteHighlight:NO];
    
    
    [self updateServiceID];
    [self loadTripsInTheBackground];

//    ActiveTrainObject *test = [[ActiveTrainObject alloc] init];
//    [test setTrainDelay:[NSNumber numberWithInt:2] ];
//    [test setTrainNo: [NSNumber numberWithInt:420] ];
//    
//    [test setNextStop:@"Nowhere"];
//    [test setDestination:@"East of Timbuktu"];
//    
//    [activeTrainsArr addObject:test];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    
    NSLog(@"ITVC - viewWillAppear");
    cellRefreshTimer =[NSTimer scheduledTimerWithTimeInterval:CELL_REFRESH_RATE
                                                  target:self
                                                selector:@selector(refreshCellsTime)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self updateTimeSettings];
    [self loadJSONDataIntheBackground];
    
    _findLocationsSegue = NO;
    _viewIsClosing = NO;
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    
    _viewIsClosing = YES;
    
    NSLog(@"ITVC - viewWilLDisappear");
    if ( cellRefreshTimer != nil )  // Might not be necessary but for now, better safe than CRASH!
    {
        
        if ( [cellRefreshTimer isValid]  )
        {
            [cellRefreshTimer invalidate];
            cellRefreshTimer = nil;
            NSLog(@"ITVC - Killing updateTimer");
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


-(void) loadHeaderNamesWith: (ItineraryObject*) itin
{
    
    if ( !([self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Trolley"] ) )
        return;
    
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM bus_stop_directions WHERE Route=%@ ORDER BY dircode", itinerary.routeShortName];
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
    }
    
}


-(DisplayedRouteData*) convertItineraryObjectToDisplayedRouteData
{
    
    NSInteger dbType;
    
    if ( [self.travelMode isEqualToString:@"Bus"] )
    {
        dbType = kDisplayedRouteDataUsingDBBus;
    }
    else if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        dbType = kDisplayedRouteDataUsingDBRail;
    }
    else if ( [self.travelMode isEqualToString:@"Trolley"] )
    {
        dbType = kDisplayedRouteDataUsingTrolley;
    }
    else if ( [self.travelMode isEqualToString:@"MFL"] )
    {
        dbType = kDisplayedRouteDataUsingMFL;
    }
    else if ( [self.travelMode isEqualToString:@"BSS"] )
    {
        dbType = kDisplayedRouteDataUsingBSS;
    }
    else if ( [self.travelMode isEqualToString:@"NHSL"] )
    {
        dbType = kDisplayedRouteDataUsingNHSL;
    }
    else
        return nil;
    
    DisplayedRouteData *routeData = [[DisplayedRouteData alloc] initWithDatabaseType:dbType];
    
    [routeData.current setRoute_id: itinerary.routeID];
    [routeData.current setRoute_short_name: itinerary.routeShortName];
    [routeData.current setRoute_type: [NSNumber numberWithInt:999] ];
    
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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    currentTripsArr = nil;
    masterTripsArr  = nil;
    itinerary = nil;
    
//    _sqlQueue = nil;
    
}

- (void)viewDidUnload
{
    
//    [self setBtnFavorite:nil];
    
    [self setTableSequence:nil];
    [self setTableTrips:nil];
    
    [self setMapView:nil];
    
    [self setScrollView:nil];
    
    [self setPageControl:nil];
    [self setSegmentService:nil];
    
    [self setViewTrips:nil];
    [self setViewSequence:nil];
    
    [self setLeftSwipe:nil];
    [self setRigthSwipe:nil];
    [self setDoubleTap:nil];
    [self setSegmentService:nil];
    
    [self setSegmentMapFavorite:nil];
    [super viewDidUnload];
    
}


#pragma mark - Refresh Time in Cells
-(void) refreshCellsTime
{
    
//    NSLog(@"ITVC - refreshCellsTime");
    
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
            if ( ( [ [tripCell lblTimeBeforeArrival] text] == nil ) && ([self.segmentService selectedSegmentIndex] == 0) )  // Only remove empty TimeBeforeArrival cells when "Now" has been selected
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
    // Get 24HourTime setting
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:24HourTime"];
    if ( object == nil )
    {
        _use24HourTime = YES;  // Defaults to YES.  boolForKey defaults to NO.
    }
    else
    {
        _use24HourTime = [object boolValue];
    }
    
}


#pragma mark -
#pragma mark Load Data
-(void) loadTripsInTheBackground
{
    
    NSLog(@"ITVC - loadTripsInTheBackground");
    [_jsonQueue cancelAllOperations];  // Since _jsonQueue depends on loadTrips, if we're about to reload loadTrips, all JSON operations needs to be cancelled
    [jsonRefreshTimer invalidate];
    
    _sqlOp = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation *weakOp = _sqlOp;
    [weakOp addExecutionBlock:^{
        
        [self loadTrips];
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self filterCurrentTrains];  // Updates currentTrainsArr and reloaded self.tableTrips
                [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];  // Forced update of To/From Header
                
                [SVProgressHUD dismiss];     // Dismisses any active loading HUD
                
                [self createMasterJSONLookUpTable];
                
                if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Rail"] )  // MFL, BSS and NHSL do not have realtime data
                    [self loadJSONDataIntheBackground];  // This should only be called once loadTrips has been loaded
                
            }];
        }
        else
        {
            NSLog(@"ITVC - running SQL Query: _sqlOp cancelled");
        }
        
    }];
    
    
    [_sqlQueue addOperation: _sqlOp];

}


-(void) createMasterJSONLookUpTable
{

    NSLog(@"ITVC - createMasterJSONLookUpTable");  // This table only needs to be run when masterTripsArr gets populated or repopulated
    for (TripObject *trip in masterTripsArr )
    {
        NSString *tripKey = [NSString stringWithFormat:@"%d", [trip.trainNo intValue] ];
        
        if ( [_masterTrainLookUpDict objectForKey:tripKey] == nil )
        {
            NSMutableArray *newArr = [[NSMutableArray alloc] initWithObjects:[NSValue valueWithNonretainedObject:trip], nil];
            [_masterTrainLookUpDict setObject:newArr forKey:tripKey];
        }
        else
        {
            
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
                NSMutableArray *oldArr = [_masterTrainLookUpDict objectForKey:tripKey];
                [oldArr addObject:[NSValue valueWithNonretainedObject:trip] ];
            }  // if ( !isFound )
            
        }  // else if ( [_masterTrainLookUpDict objectForKey:tripKey] == nil )
        
    } // for (TripObject *trip in masterTripsArr)
    
}


-(void) loadTrips
{
    
    BOOL _forceLoad = 0;
    BOOL _firstTime = 1;
    
    if ( !_forceLoad )
    {
        // As long as _forceLoad is not true, check if startStopName and endStopName are nil.  If they're nil, don't load
        if ( [itinerary.startStopID intValue] == 0 || [itinerary.endStopID intValue] == 0 || itinerary.routeID == nil )
        {
            return;  // If either is nil, there's nothing to do.
        }
        
    }
    
    NSDate *startTime = [NSDate date];
    NSLog(@"ITVC - Starting at %@", startTime);

    [masterTripsArr removeAllObjects];
    [_masterTrainLookUpDict removeAllObjects];  // This will trigger _masterTrainLookUpDict to repopulate itself during the next JSON request
    
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_timesDB.trip_id trip_id FROM stop_timesDB JOIN tripsDB ON tripsDB.trip_id=stop_timesDB.trip_id WHERE tripsDB.trip_id IN (SELECT trip_id FROM tripsDB WHERE route_id=\"%@\" ) AND stop_id=%d ORDER BY arrival_time", itinerary.routeID, [itinerary.startStopID intValue] ];

    if ( [self.travelMode isEqualToString:@"Rail"] )
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
    else if ( [self.travelMode isEqualToString:@"MFL"] )
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_MFL"];
    else
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
    
    NSLog(@"ITVC - queryStr: %@", queryStr);
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"ITVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"ITVC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    
    // Process the first query
    NSMutableDictionary *tripDict = [[NSMutableDictionary alloc] init];
    
    
    //
    //  The first pull from [results next] takes the longest amount of time.  If the user cancelled the operation
    //
//    BOOL successfulResults = [results next];
//    if ( [_sqlOp isCancelled] )
//        return;
    
    while ( [results next] )
    {
    
        if ( [_sqlOp isCancelled] )  // If the operation has been cancelled, no need to continue reading from the database
            return;
        
//        NSString *routeID = [results stringForColumn:@"route_id"];
//        NSNumber *blockID = [NSNumber numberWithInt: [results intForColumn:@"block_id"] ];
//        NSNumber *stopSequence = [NSNumber numberWithInt: [results intForColumn:@"stop_sequence"] ];
//        
//        NSString *arrivalTime = [results stringForColumn:@"arrival_time"];
//        NSNumber *directionID = [NSNumber numberWithInt: [results intForColumn:@"direction_id"] ];
//        NSString *serviceID = [results stringForColumn:@"service_id"];
//        NSString *tripID    = [results stringForColumn:@"trip_id"];

        
//        NSString *routeID      = [results stringForColumnIndex:0];
//        NSNumber *blockID      = [NSNumber numberWithInt: [results intForColumnIndex:1] ];
//        NSNumber *stopSequence = [NSNumber numberWithInt: [results intForColumnIndex:2] ];
//
//        NSString *arrivalTime  = [results stringForColumnIndex:3];
//        NSNumber *directionID  = [NSNumber numberWithInt: [results intForColumnIndex:4] ];
//        NSString *serviceID    = [results stringForColumnIndex:5];
        NSString *tripID       = [results stringForColumnIndex:6];
        
        if ( [tripDict objectForKey:tripID] == nil )
        {
            TripObject *trip = [[TripObject alloc] init];
            
            [trip setRouteName: [results stringForColumnIndex:0] ];
//            [trip setRouteStart: [results stringForColumn:0] ];
            
            [trip setTrainNo: [NSNumber numberWithInt: [results intForColumnIndex:1] ] ];
            
            [trip setStartSeq: [NSNumber numberWithInt: [results intForColumnIndex:2] ] ];
            [trip setStartTime:[NSNumber numberWithInt: [results intForColumnIndex:3] ] ];
//            [trip setStartTime: [results stringForColumnIndex:3] ];
            
            [trip setServiceID: [NSNumber numberWithInt:[results intForColumnIndex:5] ] ];
            [trip setTripID: tripID];
            
            [tripDict setObject:trip forKey:tripID];
        }
        
//        [trip setEndSeq  : endSeq];
//        [trip setEndTime  : endTime];
        
    }  // while ( [results next] )
    
    NSTimeInterval diff = [ [NSDate date] timeIntervalSinceDate: startTime];
    NSLog(@"ITVC - %6.3f seconds have passed.", diff);
    NSLog(@"ITVC - Loaded and stored");
    
    
//    queryStr = @"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_times_rail.trip_id trip_id FROM stop_times_rail JOIN trips_rail ON trips_rail.trip_id=stop_times_rail.trip_id WHERE trips_rail.trip_id IN (SELECT trip_id FROM trips_rail WHERE route_id=\"WAR\" ) AND stop_id=90413 ORDER BY arrival_time";

    queryStr = [NSString stringWithFormat:@"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_timesDB.trip_id trip_id FROM stop_timesDB JOIN tripsDB ON tripsDB.trip_id=stop_timesDB.trip_id WHERE tripsDB.trip_id IN (SELECT trip_id FROM tripsDB WHERE route_id=\"%@\" AND direction_id=%d ) AND stop_id=%d ORDER BY arrival_time", itinerary.routeID, _currentDisplayDirection, [itinerary.endStopID intValue] ];

    if ( [self.travelMode isEqualToString:@"Rail"] )
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
    else if ( [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] )
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:[NSString stringWithFormat:@"_%@", self.travelMode] ];
    else
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
    
    
    NSLog(@"ITVC - queryStr: %@", queryStr);
    results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"ITVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"ITVC - query str: %@", queryStr);
        
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
                [trip setEndTime:[NSNumber numberWithInt: [results intForColumnIndex:3] ] ];
//                [trip setEndTime: [results stringForColumnIndex:3] ];
                

                
                // The first time we find a complete trip with the start and end sequence in the right
                // order, we need to determine if this is To/From some point.  What that point is differs
                // for different travel types.
                
                if ( _firstTime )
                {
                    
                    if ( [self.travelMode isEqualToString:@"Rail"] )  // Determine Rail To/From points
                    {

                        
                        if ( [trip.routeName isEqualToString:_routeData.route_id] )
                        {
                            if ( [trip.directionID intValue] == 0 )
                                _headerDirection = @"To";
                            else
                                _headerDirection = @"From";
                        }
                        else
                        {
                            if ( [trip.directionID intValue] == 0 )
                                _headerDirection = @"From";
                            else
                                _headerDirection = @"To";
                        }
                        
                        
                        
//                        if ( [trip.routeName isEqualToString: endRoute] )  // Catches: PAO->PAO, LAN->LAN, etc.
//                        {
//                            
//                            if ( ![endRoute isEqualToString: _routeData.route_id] ) // Catches: PAO->PAO for a LAN trip or LAN->LAN for a PAO trip
//                            {
//                                NSLog(@"ITVC - FROM %@", _routeData.route_id);
////                                _headerDirection = [NSString stringWithFormat:@"From %@", _routeData.route_id];
//                                _headerDirection = @"From";
//                            }
//                            else  // Catches: PAO->PAO for a PAO trip, or LAN->LAN for a LAN trip
//                            {
//                                if ( [trip.directionID intValue] == 0 )  // In this case, direction 0 is FROM
//                                {
//                                    NSLog(@"ITVC - FROM %@", _routeData.route_id);
////                                    _headerDirection = [NSString stringWithFormat:@"From %@", _routeData.route_id];
//                                    _headerDirection = @"From";
//                                }
//                                else  // And direction 1 is TO
//                                {
//                                    NSLog(@"ITVC - TO %@", _routeData.route_id);
////                                    _headerDirection = [NSString stringWithFormat:@"To %@", _routeData.route_id];
//                                    _headerDirection = @"To";
//                                }
//                            }
//                            
//                        }
//                        else  // Catches: PAO->LAN, or LAN->PAO
//                        {
//                            NSLog(@"ITVC - FROM %@", trip.routeName);
////                            _headerDirection = [NSString stringWithFormat:@"From %@", trip.routeName];
//                            _headerDirection = @"From";
//                        }
                        
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

                [trip setStartSeq: [NSNumber numberWithInt: [results intForColumnIndex:2] ] ];
                [trip setStartTime:[NSNumber numberWithInt: [results intForColumnIndex:3] ] ];
//                [trip setStartTime: [results stringForColumnIndex:3] ];

                
                // Please explain the logic behind this, so when I change this, I know if I'm $@!%ing something up!
                
                // The problem here, is the user selected 19th Street as the start then 22nd Street as the end stop.
                // Unfortunately, the default direction 0, goes in the opposite direction 22nd->19th street.  
                
                if ( [self.travelMode isEqualToString:@"Trolley"] || [self.travelMode isEqualToString:@"Bus"] )
                {
                    if ( !flippedOnce )
                    {
                        NSLog(@"ITVC - flipped trips!");
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
    
    diff = [ [NSDate date] timeIntervalSinceDate: startTime];
    NSLog(@"ITVC - %6.3f seconds have passed.", diff);
    
}


//-(void) loadTrips2
//{
//
//    // Only load if forced or both start and end names have been entered
//    
////    if ( ![SVProgressHUD isVisible] )
////    {
////        [SVProgressHUD setStatus:@"Loading..."];
////    }
//    
//    BOOL _forceLoad = 0;
//    
//    if ( !_forceLoad )
//    {
//        // As long as _forceLoad is not true, check if startStopName and endStopName are nil.  If they're nil, don't load
//        if ( itinerary.startStopName == nil || itinerary.endStopName ==  nil )
//        {
//            return;  // If either is nil, there's nothing to do.
//        }
//        
//    }
//    
//    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
//
//    if ( ![database open] )
//    {
//        [database close];
//        return;
//    }
//    
//    NSString *outerSQL = @"tableA.route_id, tableA.block_id, tableA.stop_sequence, tableB.stop_sequence, tableA.arrival_time, tableB.arrival_time, tableA.service_id, tableA.direction_id, tableB.direction_id";
//    NSString *startSQL = [NSString stringWithFormat:@"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_timesDB.trip_id FROM stop_timesDB JOIN tripsDB ON tripsDB.trip_id=stop_timesDB.trip_id WHERE tripsDB.trip_id IN (SELECT trip_id FROM tripsDB WHERE route_id=\"%@\" ) AND stop_id=%d", itinerary.routeID, [itinerary.startStopID intValue] ];
//    NSString *endSQL   = [NSString stringWithFormat:@"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_timesDB.trip_id FROM stop_timesDB JOIN tripsDB ON tripsDB.trip_id=stop_timesDB.trip_id WHERE tripsDB.trip_id IN (SELECT trip_id FROM tripsDB WHERE route_id=\"%@\" ) AND stop_id=%d", itinerary.routeID, [itinerary.endStopID intValue] ];
//    
//    NSString *onCondition = @"tableA.trip_id=tableB.trip_id";
//    NSString *groupBy = @"tableA.trip_id";
//    NSString *orderBy = @"tableA.arrival_time";
//    
//    NSString *queryStr = [NSString stringWithFormat:@"SELECT %@ FROM ( %@ ) as tableA INNER JOIN ( %@ ) as tableB ON %@ GROUP BY %@ ORDER BY %@", outerSQL, startSQL, endSQL, onCondition, groupBy, orderBy];
//    
//    if ( [self.travelMode isEqualToString:@"Rail"] )
//        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
//    else
//        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
//    
//    
//    queryStr = @"SELECT route_id, block_id, stop_sequence, arrival_time, direction_id, service_id, stop_times_rail.trip_id FROM stop_times_rail JOIN trips_rail ON trips_rail.trip_id=stop_times_rail.trip_id WHERE trips_rail.trip_id IN (SELECT trip_id FROM trips_rail WHERE route_id=\"WAR\" ) AND stop_id=90004";
//    
//    
//    
////    NSLog(@"ITVC - queryStr: %@", queryStr);
//    
////    NSDate *startTime = [NSDate date];
////    NSLog(@"ITVC - Starting at %@", startTime);
//    
//    FMResultSet *results = [database executeQuery: queryStr];
//    if ( [database hadError] )  // Check for errors
//    {
//        
//        int errorCode = [database lastErrorCode];
//        NSString *errorMsg = [database lastErrorMessage];
//        
//        NSLog(@"BDSVC - query failure, code: %d, %@", errorCode, errorMsg);
//        NSLog(@"BDSVC - query str: %@", queryStr);
//        
//        return;  // If an error occurred, there's nothing else to do but exit
//        
//    } // if ( [database hadError] )
//    
//    
//    [masterTripsArr removeAllObjects];
//    int dirGood = 0;
//    int dirBad = 0;
////    NSMutableArray *collection = [[NSMutableArray alloc] init];
////    NSNumber *goodDirection;
//    
////    BOOL foundResult = [results next];
////    NSTimeInterval diff = [ [NSDate date] timeIntervalSinceDate: startTime];
////    NSLog(@"%6.3f seconds have passed.", diff);
//    
//    while ( [results next] && 0 )
//    {
//
////        NSTimeInterval diff = [ [NSDate date] timeIntervalSinceDate: startTime];
////        NSLog(@"%6.3f seconds have passed.", diff);
//        
//        NSNumber *block_id = [NSNumber numberWithInt: [results intForColumn:@"tableA.block_id"] ];
//        NSNumber *startSeq = [NSNumber numberWithInt: [results intForColumn:@"tableA.stop_sequence"] ];
//        NSNumber *endSeq   = [NSNumber numberWithInt: [results intForColumn:@"tableB.stop_sequence"] ];
//        
//        NSString *startTime;  // startTime is written when the direction is determined down below
//        NSString *endTime;    // Same goes for endTime
//        
////        NSString *service_id = [results stringForColumn:@"tableA.service_id"];
//        NSNumber *service_id = [NSNumber numberWithInt: [results intForColumn:@"tableA.service_id"] ];
//        NSNumber *startDir = [NSNumber numberWithInt: [results intForColumn:@"tableA.direction_id"] ];
//        
//        if ( [startSeq intValue] < [endSeq intValue] )
//        {
//            dirGood++;
////            [collection addObject:startDir];
//            _currentDisplayDirection = [startDir integerValue];
//            
//            startTime = [results stringForColumn:@"tableA.arrival_time"];
//            endTime   = [results stringForColumn:@"tableB.arrival_time"];
//        }
//        else
//        {
//            dirBad++;
//            
//            // Here, the endSeq is greater than startSeq, meaning the arrival_times are in reverse order.
//            // Give startTime the arrival_time from tableB while endTime uses tableA.
//            startTime = [results stringForColumn:@"tableB.arrival_time"];
//            endTime   = [results stringForColumn:@"tableA.arrival_time"];
//        }
//        
//        NSString *route_id = [results stringForColumn:@"tableA.route_id"];
//        
//        TripObject *trip = [[TripObject alloc] init];
//        
//        [trip setStartSeq: startSeq];
//        [trip setEndSeq  : endSeq];
//        
//        [trip setStartTime: startTime];
//        [trip setEndTime  : endTime];
//        
//        [trip setDirectionID: startDir];
//        [trip setServiceID: service_id];
//        [trip setTrainNo:block_id];
//        
//        [trip setRouteName: route_id];
//        
////        NSLog(@"ITVC - trip: %@", trip);
//        
//        [masterTripsArr addObject: trip];
//        
//    }  // while ( [results next])
//    
//    // Once all the results have been read in, close the database connection
//    [database close];
//    
//    [SVProgressHUD dismiss];
//    
////    NSLog(@"Collection: %@", collection);
//    
////    for (NSNumber *num in collection)
////    {
////    
////    }
//
//    
//}


//-(NSString*) filePath
//{
//    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
//}


-(void) filterActiveTrains
{
    
//    NSPredicate *predicateFilter = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"(serviceID LIKE '%@') AND (directionID == %d)", _currentServiceID, _currentDisplayDirection] ];
    
    if ( [_masterJSONTrainArr count] == 0 )  // If it has no active vehiciles, nothing below will have any effect
        return;
    
    NSPredicate *predicateFilter = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"( (serviceID & %d) > 0 ) AND (directionID == %d)", _currentServiceID, _currentDisplayDirection] ];

    NSLog(@"ITVC - filter active trains: %@", predicateFilter);
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
    
    // Update itinerary to the new direction id
//    [itinerary setDirectionID: [NSNumber numberWithInt:_currentDisplayDirection] ];

    // Grab the latest selected segment
    NSInteger segmentIndex = [self.segmentService selectedSegmentIndex];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *now = @"00:00";  // Always show times greater than 00:00 unless a new time has been added.
    
    if ( segmentIndex == 0 )
    {
        [dateFormatter setDateFormat:@"HH:mm"];
        now = [dateFormatter stringFromDate: [NSDate date] ];
    }

    
//    NSPredicate *predicateFilter = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"(serviceID LIKE '%@') AND (directionID == %d) AND (startTime > '%@')", _currentServiceID, _currentDisplayDirection, now] ];
    NSPredicate *predicateFilter = [NSPredicate predicateWithFormat: [NSString stringWithFormat:@"( (serviceID & %d) > 0 )  AND (directionID == %d) AND (startTime > '%@')", _currentServiceID, _currentDisplayDirection, now] ];
    
//    NSLog(@"ITVC - filter: %@", predicateFilter);
//    NSLog(@"ITVC - %@", masterTripsArr);

//    [masterTripsArr removeLastObject];  // Why the hell am I doing this again?
    currentTripsArr = [[masterTripsArr filteredArrayUsingPredicate:predicateFilter] mutableCopy];
    

//    _trainStr = @"";
//    for (TripObject *trip in currentTripsArr)
//    {
//        [_trainStr stringByAppendingFormat:@";%d", [[trip trainNo] intValue] ];
//    }
    
    // Before we can determine the current direction of the train, we need to look at a sample of a Trip object in currentTripsArr
//    TripObject *trip = [currentTripsArr objectAtIndex:0];
//    if ( trip.startSeq < trip.endSeq )
//    {
//        _currentDisplayDirection = [trip.directionID intValue];
//    }
//    else
//    {
//        // Since startSeq is larger then endSeq, the currently displayed direction needs to be the opposite of the current direction
//        if ( [trip.directionID intValue] == 0 )
//            _currentDisplayDirection = 1;
//        else
//            _currentDisplayDirection = 0;
//
//    }
    
    // An example of the above...
    //   When the app first loads, _currentDisplayDirection is defaulted to 0 (outbound travel).  Now, suppose inbound was selected,
    //   we're not going to know until we filter the results
    
    
    // Now filter that data...
    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
    // User Preferences
    if ( itinerary.routeID != nil && itinerary.startStopName != nil && itinerary.endStopName != nil )
    {
        
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
        
    }
    
    [itinerary setDirectionID: [NSNumber numberWithInt:_currentDisplayDirection] ];
    
//    DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
//    NSLog(@"RouteData: %@", routeData.current);
    
}

#pragma mark -
#pragma mark Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue identifier] isEqualToString:@"StopTimesSegue"] || [[segue identifier] isEqualToString:@"StopTimesSegue"] )
    {
        
        NSLog(@"ITVC - Seguing to %@", [segue identifier] );
        
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
        NSLog(@"ITVC - queryStr: %@", queryStr);
        
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
    
    NSString *queryStr;

    
    queryStr = [NSString stringWithFormat:@"SELECT stopsDB.stop_name, stopsDB.stop_id FROM tripsDB JOIN stop_timesDB ON tripsDB.trip_id=stop_timesDB.trip_id JOIN stopsDB ON stop_timesDB.stop_id=stopsDB.stop_id WHERE route_id=\"%@\" GROUP BY stopsDB.stop_id ORDER BY stopsDB.stop_name;", self.routeData.route_id];
    
    if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_rail"];
    }
    else if ( [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] )
    {
//        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_MFL"];
        queryStr = @"SELECT stops_bus.stop_name, stop_times_DB.stop_id FROM trips_DB JOIN stop_times_DB ON trips_DB.trip_id=stop_times_DB.trip_id NATURAL JOIN stops_bus GROUP BY stop_times_DB.stop_id ORDER BY stops_bus.stop_name;";
        
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString: self.travelMode];
    }
    else // If it's not rail, it's from the bus GTFS data
    {
//        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"DB" withString:@"_bus"];
        
        // If both start and end stop names are set to the default message, do not filter by direction
        if ( [itinerary.startStopName isEqualToString:DEFAULT_MESSAGE] && [itinerary.endStopName isEqualToString: DEFAULT_MESSAGE] )
        {
            queryStr = [NSString stringWithFormat:@"SELECT * FROM stopNameLookUpTable NATURAL JOIN stops_bus WHERE route_id=%@ ORDER BY stop_name", self.routeData.route_id];
        }
        else
        {
            // Since either one or two of the stop names have been filled in, the direction is now known
            queryStr = [NSString stringWithFormat:@"SELECT * FROM stopNameLookUpTable NATURAL JOIN stops_bus WHERE route_id=%@ AND direction_id=%d ORDER BY stop_name", self.routeData.route_id, _currentDisplayDirection];  // Was self.routeData.direction_id instead of _currentDisplayDirection
        }

    }

    
    return queryStr;
}

#pragma mark -
#pragma mark UITableViewDataSource


// Allow editing of only the Itinerary Cell
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [itinerary clearStops];  // Clear out the stop information for itinerary
    
    [itinerary setStartStopName: DEFAULT_MESSAGE];  // Put the default messages back
    [itinerary setEndStopName  : DEFAULT_MESSAGE];
    
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
    
    
    [self.tableTrips reloadData];
    
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Return NO if you do not want the specified item to be editable.
    //    NSInteger section = indexPath.section;
    
    if ( indexPath.section == 0 )
        return YES;
    else
        return NO;
}



-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"ITVC - accessoryButtonTappedForSection/Row: %d/%d", indexPath.section, indexPath.row);
}


- (void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( ( indexPath.section == 1 ) || ( indexPath.section == 2 ) )
    {
        NSLog(@"ITVC - section 1, row %d selected", indexPath.row);
        [self performSegueWithIdentifier:@"TripDetailsSegue" sender:self];
    }
    
//    if ( indexPath.section == 2 )
//    {
//        TripObject *trip = [currentTripsArr objectAtIndex:indexPath.row];
////        NSLog(@"ITVC - selected %d.%d : %@", indexPath.section, indexPath.row, trip);
//    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *itineraryStr = @"ItineraryCell";
    static NSString *tripStr      = @"TripCell";
//    static NSString *activeStr    = @"ActiveTrainCell2";
    
    id cell;
    
    
    if ( ( indexPath.section == 0 ) )
    {
    
//        NSLog(@"ITVC - Building ItineraryCell: section.row (%d.%d)", indexPath.section, indexPath.row);
        cell = (ItineraryCell*)[self.tableTrips dequeueReusableCellWithIdentifier: itineraryStr];
//        cell = (ItineraryCell*)[tableView dequeueReusableCellWithIdentifier: itineraryStr ];
        
        if ( cell == nil )
        {
            NSLog(@"ITVC - IF YOU SEE THIS THEN SOMETHING IS BROKEN");
            abort();
        }
        
        [cell setDelegate:self];
        
        [[cell btnStartStopName] setTitle: [NSString stringWithFormat:@"%@", itinerary.startStopName ] forState:UIControlStateNormal];
        [[cell btnStartStopName] setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

        [[[cell btnStartStopName] titleLabel] setAdjustsFontSizeToFitWidth:YES];
        
        [[cell btnEndStopName  ] setTitle: [NSString stringWithFormat:@"%@", itinerary.endStopName ] forState:UIControlStateNormal];
        [[cell btnEndStopName  ] setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [[[cell btnEndStopName ] titleLabel] setAdjustsFontSizeToFitWidth:YES];
        
    }
    else if ( indexPath.section == 1 )
    {

        cell = (ActiveTrainCell*)[self.tableTrips dequeueReusableCellWithIdentifier:@"ActiveTrainCell"];
//        NTASaveObjectCell *cell = [self.tableTrips dequeueReusableCellWithIdentifier:activeStr];
        if ( cell == nil )
        {
            
            cell = [self.tableTrips dequeueReusableCellWithIdentifier:@"ActiveTrainCell" forIndexPath:indexPath];
            
//            @try
//            {
//                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ActiveTrainCell" owner:self options:nil];
//                cell = (ActiveTrainCell*)[nib objectAtIndex:0];
//                
////                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NTASaveObjectCell" owner:self options:nil];
////                cell = (NTASaveObjectCell*)[nib objectAtIndex:0];
//            }
//            @catch (NSException* exception) {
//                NSLog(@"Uncaught exception %@", exception);
//                NSLog(@"Stack trace: %@", [exception callStackSymbols]);
//            }


        }
        
        ActiveTrainObject *atObject = [activeTrainsArr objectAtIndex: indexPath.row];
        [[cell lblTrainNo]    setText: [NSString stringWithFormat:@"%d", [atObject.trainNo intValue] ] ];
        
        int delay = [atObject.trainDelay intValue];
//        NSLog(@"ITVC - ActiveTrain delay: %d", delay);
        if ( delay == 0 )
        {
            [[cell lblTrainDelay] setTextColor:[UIColor colorWithRed:69.0f/255.0f green:94.0f/255.0f blue:143.0f/255.0f alpha:1.0f] ];
            [[cell lblTrainDelay] setText: @"On time" ];
        }
        else
        {
            [[cell lblTrainDelay] setTextColor:[UIColor orangeColor] ];
            [[cell lblTrainDelay] setText: [NSString stringWithFormat:@"%d mins", delay] ];
        }

        [[cell lblNextStop] setText: atObject.nextStop];
        [[cell lblDestination] setText: atObject.destination];

        return cell;
        
//        NSLog(@"Break!");
        
//
//        if ( cell == nil )
//        {
//            NSLog(@"ITVC - Error!  Error!");
//            abort();
//        }
        
//        ActiveTrainObject *atObject = [activeTrainsArr objectAtIndex: indexPath.row];
//        [[cell lblTrainNo] setText: [NSString stringWithFormat:@"%d", [atObject.trainNo intValue]] ];
//        [[cell lblStartTime] setText: atObject.startTime];
//        [[cell lblEndTime] setText: @""];
//        

    }
    else
    {
        
//        NSLog(@"ITVC - Building TripCell:  section.row (%d.%d)", indexPath.section, indexPath.row);
         cell = (TripCell*)[self.tableTrips dequeueReusableCellWithIdentifier: tripStr];
//        cell = (TripCell*)[tableView dequeueReusableCellWithIdentifier: tripStr ];
        
        if ( cell == nil )
        {
            NSLog(@"ITVC - IF YOU SEE THIS THEN SOMETHING IS BROKEN");
            abort();
        }
        
        TripObject *thisTrip = [currentTripsArr objectAtIndex:indexPath.row];

        [[cell lblTrainNo] setText: [NSString stringWithFormat:@"%d", [thisTrip.trainNo intValue] ] ];
//        [[cell lblStartTime] setText: thisTrip.startTime];
//        [[cell lblEndTime  ] setText: thisTrip.endTime];
        
        [cell setUse24HourTime: _use24HourTime];
        [cell setDisplayCountdown:YES];
        
        [cell addArrivalTimeStr: [NSString stringWithFormat:@"%d", [thisTrip.startTime intValue] ] ];
        [cell addDepartureTimeStr: [NSString stringWithFormat:@"%d", [thisTrip.endTime intValue] ] ];
        
//        [cell addArrivalTimeStr: thisTrip.startTime];
//        [cell addDepartureTimeStr: thisTrip.endTime];

        [cell updateCell];
        
    }
    
    
    return cell;
    
}


//-(void) removeCellAtIndexPath: (NSTimer*) theTimer
-(void) removeTopMostCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    NSLog(@"ITVC - removing cell at %d/%d", indexPath.section, indexPath.row);
    [currentTripsArr removeObjectAtIndex: [indexPath row] ];
    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex: [indexPath section] ] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [cellRemoverTimer invalidate];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:  // First section only has one row
            return 1;
            break;
        case 1:  // Second section is for active trains
            return [activeTrainsArr count];
            break;
        case 2:  // Third section is for all trips based on the selected criteria
            return [currentTripsArr count];
            break;
        default:
            return 0;
            break;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if ( tableView == self.tableTrips )
    {
        return 3;  // This stays hardcoded.  It should never change unless a major redesign is happening
    }
    else if ( tableView == self.tableSequence )
    {
        return 0;
    }
    else
        return 0;
    
}

//-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return nil;
//}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    
    
    switch (section) {
        case 0:
//            return nil;  // At this time, the first section does not need a header.  What would it say?

        {
            
        
            
            NSString *toFrom = @"From";
            if ( _currentDisplayDirection == 0 )
            {
                toFrom = @"To";
            }
            
//            // This is an annoyance.  Stupid change happens to the Rails portion of the GTFS changing the short name to the long name
//            // For Buses, the route_id is just a 5 digit number that changes every GTFS update.  Whereas the short name is the actual
//            // bus number.  For Rail, the id is the three digit abbreviation of that route (the same as the short name) but now it's
//            // the full route name, e.g. Lansdale/Doylestown Line.  Joy.  >.>   <.<
            
            if ( [self.travelMode isEqualToString:@"Rail"] )
                return [NSString stringWithFormat:@"%@ %@", _headerDirection, itinerary.routeID];
//                return _headerDirection;
            else
            {
                
                if ( _currentDisplayDirection >= [_nameForSection count] )
                    return [NSString stringWithFormat:@"%@ %@", toFrom, itinerary.routeShortName];
                else
                    return [_nameForSection objectAtIndex:_currentDisplayDirection];
            }
        }
            
            break;
        case 1:
            if ( [activeTrainsArr count] == 0 )
            {
                return nil;
            }
            else
            {
                return @"Active Trains";
            }
            break;
        case 2:
            if ( [currentTripsArr count] == 0 )
            {
                return nil;
            }
            else
            {
                NSInteger segmentIndex = [self.segmentService selectedSegmentIndex];
                switch (segmentIndex) {
                    case 0:
                        return @"Remaining Trips For Today";
                        break;
                    case 1:
                        return @"Trips For Mon thru Fri";
                        break;
                    case 2:
                        return @"Trips For Saturday";
                        break;
                    case 3:
                        return @"Trips For Sunday";
                        break;
                    default:
                        return @"Trips";
                        break;
                }
            
            }
            break;
            
        default:
            return nil;
            break;
    }

}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//
//    switch (section) {
//        case 0:
//        case 2:
//            return [NSString stringWithFormat:@"Bottom %d", section];
//            break;
//        default:
//            return nil;
//            break;
//    }
//
//}

#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section)
    {
        case 0:
            return 72.0f;
            break;
        default:
            return 44.0f;
            break;
    }
    
}


#pragma mark -
#pragma mark ItineraryCellProtocol

-(void) switchDirectionButtonTapped
{
    NSLog(@"ITVC - switch to/from direction");
//    if ( [itinerary.directionID  intValue] == 0 )
//        [itinerary setDirectionID:[NSNumber numberWithInt:1] ];
//    else
//        [itinerary setDirectionID:[NSNumber numberWithInt:0] ];
//    
//    [self.tableTrips reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


-(void) flipStopNamesButtonTapped
{
    
    NSLog(@"ITVC - flip start and end stop names");
    
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
    

    NSLog(@"ITVC - Flipped (Itinerary): %@", itinerary);
    
    
    DisplayedRouteData *routeData = [self convertItineraryObjectToDisplayedRouteData];
    // Check if flipped stop names are a favorite location
//    NSLog(@"RouteData: %@", routeData.current);
    if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
        [self setFavoriteHighlight:YES];
    else
        [self setFavoriteHighlight:NO];
    
    
    
    if ( itinerary.startStopName == NULL )
    {
        NSLog(@"We have a fucking problem!");
    }

    
}


-(void) getStopNamesButtonTapped:(NSInteger) startEND  // start = 1, END = 0
{

    // Stop JSON reloading and cancel any pending/ongoing Operations
    [_jsonQueue cancelAllOperations];
    [jsonRefreshTimer invalidate];
    
    
    if ( startEND )
    {
        NSLog(@"ITVC - load start stop names");
        _startENDButtonPressed = 1;
        [self performSegueWithIdentifier:@"StopTimesSegue" sender:self];
    }
    else
    {
        NSLog(@"ITVC - load end stop names");
        _startENDButtonPressed = 0;
        [self performSegueWithIdentifier:@"StopTimesSegue" sender:self];
    }
    


    
}


#pragma mark - StopNamesForRoute Protocol

-(void) doneButtonPressed:(StopNamesForRouteTableController *)view WithStopName:(NSString *)selectedStopName andStopID:(NSInteger)selectedStopID withDirectionID:(NSNumber*)directionID
{
    
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
    
    [self doneButtonPressed:view WithStopName:selectedStopName andStopID:selectedStopID withDirectionID:NULL];
    
}

-(void) cancelButtonPressed:(StopNamesForRouteTableController *)view
{

    if ( [[self modalViewController] isBeingDismissed] )
        return;
    else
        [view dismissModalViewControllerAnimated:YES];
    
    _startENDButtonPressed = 0;
    
}


// --==
// --==  Find the Reverse Stop for the Start (yesNo == YES) or End (yesNo == NO)
// --==
-(void) reverseStopLookUpForStart:(BOOL) yesNO;
{
    
    if ( !([self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Trolley"]) )
        return;
    
    
    // Perform a bus stop reverse lookup to find the closest stop_id in the opposite direction
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
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
    NSString *queryStr = [NSString stringWithFormat:@"SELECT reverseStopSearch.stop_id,reverse_stop_id,distance,stop_name FROM reverseStopSearch JOIN stops_bus ON reverseStopSearch.reverse_stop_id=stops_bus.stop_id WHERE reverseStopSearch.stop_id=%d AND route_id=%@", numID, itinerary.routeID];
    
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
    
    switch ([self.segmentMapFavorite selectedSegmentIndex])
    {
        case 0:
            NSLog(@"ITVC - Map Button Pressed");
            [self performSegueWithIdentifier:@"MapViewSegue" sender:self];
            break;
        case 1:
            NSLog(@"ITVC - Favorite Button Pressed");
            [self favoriteButtonSelected];
            break;
        default:
            break;
    }
    
}

-(void) favoriteButtonSelected
{
    NSLog(@"Favorites Button Pressed");
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
    
    if ( _currentSegmentIndex != [self.segmentService selectedSegmentIndex] )
    {
        _currentSegmentIndex = [self.segmentService selectedSegmentIndex];
        
        [self updateServiceID];
        [self filterCurrentTrains];
        [self filterActiveTrains];
    }
    
}

-(void) updateServiceID
{

    switch ( _currentSegmentIndex )
    {
        case 0: // Now

        {
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
            int weekday = [comps weekday];  // Sunday is 1, Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
            
            
            _currentServiceID = pow(2,(7-weekday));
            NSLog(@"weekday: %d, currentServiceID: %d", weekday, _currentServiceID);
            
        }
            break;
            
        case 1: // Week
            
            _currentServiceID = 62;  // 011 1110
            break;
            
        case 2: // Sat
            
            _currentServiceID = 1;   // 000 0001 (SuMoTu WeThFrSa)
            break;
            
        case 3: // Sun
            
            _currentServiceID = 64;  // 100 0000 (Sunday,Monday,Tuesday  Wednesday,Thursday,Friday,Saturday)
            break;
            
        default:
            break;
    }
    
    return;
    
}



#pragma mark - Favorite Button
- (IBAction)btnFavoritesPressed:(id)sender
{
    
    NSLog(@"Favorites Button Pressed");
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
    
//    if ( [self.segmentMapFavorite set ])
    
//    if ( yesNO )
//        [self.btnFavorite setTintColor:[UIColor yellowColor] ];
//    else
//        [self.btnFavorite setTintColor:[UIColor clearColor] ];
    
    if ( yesNO )
        [self.segmentMapFavorite setTintColor:[UIColor yellowColor] ];
    else
        [self.segmentMapFavorite setTintColor:[UIColor clearColor] ];
    
}


#pragma mark - Realtime Data
-(void) loadJSONDataIntheBackground
{
    
    NSLog(@"ITVC - loadJSONDataInTheBackground");
    
    if ( [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] || [self.travelMode isEqualToString:@"Bus"] )  // Bus is only temporary; I'll add that in later.
    {
        NSLog(@"ITVC - loadJSONDataInTheBackground - Current Route Does Not Support RealTime Data");
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
                [self filterActiveTrains];
                
                // TODO:  Build in a fail safe, if a minute passes without a refresh, REload JSON data (in the background, if you would please).
                if ( !_viewIsClosing )
                {
                    jsonRefreshTimer =[NSTimer scheduledTimerWithTimeInterval:JSON_REFRESH_RATE
                                                                       target:self
                                                                     selector:@selector(loadJSONDataIntheBackground)
                                                                     userInfo:nil
                                                                      repeats:NO];  // Ensures always JSON_REFRESH_RATE seconds after each successful operation.  Keeps everything in sync.
                }  // if ( !_viewIsClosing )
                
            }];
        }
        else
        {
            NSLog(@"ITVC - running SQL Query: _sqlOp cancelled");
        }
        
    }];
    
    [_jsonQueue addOperation: _jsonOp];
    
}

-(void) loadLatestJSONData
{
    
    NSLog(@"ITVC - loadLatestJSONData");
    
    
    // Builds _masterTrainLookUpDict for easy search of trains
//    for (TripObject *trip in masterTripsArr)
//    {
//            
//        if ( [_jsonOp isCancelled] )
//            return;
    
//        NSString *tripKey = [NSString stringWithFormat:@"%d_%@", [trip.trainNo intValue], trip.serviceID];
//        NSLog(@"_masterTrainLookUpDict: %@", tripKey);
//        [_masterTrainLookUpDict setObject:[NSValue valueWithNonretainedObject:trip] forKey:tripKey];

        
//        NSLog(@"_masterTrainLookUpDict: %@", trip.tripID);
//        [_masterTrainLookUpDict setObject:[NSValue valueWithNonretainedObject:trip] forKey:trip.tripID];
        
        
        // The _masterTrainLookUpDict is based on trainNo, because that's what the JSON realtime data returns
        // In order to create a hash based on trainNo, we must acknowledge that trainNo isn't solely unique.
        // A train number can be used during the Week, Sat and Sun.  What changes is the service_id.

        
        
        // To remove object [ [_masterJSONTrainDoct objectForKey:@"key"] nonretainedObjectValue]
        
//    }  // for (TripObject *trip in masterTripsArr)
    
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
//    if ( [self.travelMode isEqualToString:@"Bus"] )  // Add MFL to this?  Need to investigate this further
//    {
//        
//        NSString* stringURL = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/TransitView/%@",routeData.current.route_short_name];
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
        NSString* stringURL = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/TrainView/"];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"ITVC - loadLatestRailJSONData -- api url: %@", webStringURL);
        
        NSData *realtimeData = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
        [self processJSONData:realtimeData];
    }
    
    
    
}

-(void) processJSONData:(NSData*) returnedData
{

    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    if ( [_jsonOp isCancelled] )  // As the JSON pull can take upwards of a few seconds, before we even process the data, check if the JSON operation has been cancelled
        return;
    
    if ( returnedData == nil )  // If returnedData is nil, don't even continue.
    {
        NSLog(@"ITVC - processJSONData, returnedData is nil.  Returning");
        return;
    }
    
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
                [atObject setStartTime: [NSString stringWithFormat:@"%d", [trip.startTime intValue] ] ];
//                [atObject setStartTime: trip.startTime];     // ordered by this
                [atObject setServiceID: trip.serviceID ];     // sorted by this
                [atObject setDirectionID:trip.directionID];  // and sorted by this
                [atObject setTripID: trip.tripID];
                
                [_masterJSONTrainArr addObject: atObject];
//                NSLog(@"ITVC - processJSONData, added trip: %@", atObject);
            }
            
        }
        
        
        
    }  // for (NSDictionary *railData in json)
    
}



-(void) loadToFromDirections
{
    
    return;
    
    // Only proceed if travelMode has been set to Bus or Trolley
    if ( ![self.travelMode isEqualToString:@"Bus"] || ![self.travelMode isEqualToString:@"Trolley"] )
    {
        return;
    }
    
    
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
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
        
        NSLog(@"ITVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"ITVC - query str: %@", queryStr);
        
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
    
    NSLog(@"ITVC - addAnnotationsUsingJSONRailData");
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

@end
