//
//  FindLocationsViewController.m
//  iSEPTA
//
//  Created by septa on 11/6/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "FindLocationsViewController.h"
#import "ShowTimesModel.h"

#import "SVProgressHUD.h"

@interface FindLocationsViewController ()

@end

@implementation FindLocationsViewController
{
    ShowTimesModel *_showTimes;
    NSIndexPath *_highlightedIndexPath;
    
    NSInteger stopIDToIgnore;

}

@synthesize routeData;
@synthesize buttonType;

//@synthesize routeName;
//@synthesize stopID;
//@synthesize dirCode;
//@synthesize stopName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _showTimes = [[ShowTimesModel alloc] init];
    
    
    [self.btnDone setEnabled:NO];
    _highlightedIndexPath = nil;
    
    
    if ( self.buttonType == kLeftButtonIsStart )
        [self setTitle:@"Select Start Stop"];
    else if ( (self.buttonType = kLeftButtonIsEnd) )
        [self setTitle:@"Select End Stop"];
    
    
    [self.btnCancel setEnabled:NO];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    dispatch_queue_t loadingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(loadingQueue, ^{
        
//        NSLog(@"FLVC -(void) viewDidLoad -- Loading SVProgressHUD");
        [self getStopTimes];

        NSLog(@"FLVC - inside dispatch_async, reloadData");

//        [self performSelector:@selector(reloadTableData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
//        [self performSelectorOnMainThread:@selector(reloadTableData) withObject:nil waitUntilDone:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
            [self.btnCancel setEnabled:YES];
        });
        
        
//        dispatch_retain(loadingQueue);
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
//            
//            
//        });
//        
//        dispatch_release(loadingQueue);
        
    });
    
    
//    [self getStopTimes];
    
}

-(void) reloadTableData
{
    NSLog(@"FLVC - reload table data");
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
    [self.btnCancel setEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    NSLog(@"FLVC -(void) viewDidUnload");
    
    [self setTableView:nil];
    [self setBtnCancel:nil];
    [self setBtnDone:nil];
    
    [self setDoubleTapGestureRecognizer:nil];
    [self setLongPressGestureRecognizer:nil];
    
    [super viewDidUnload];
}

#pragma mark - UIBarButtons
- (IBAction)doneButtonPressed:(id)sender
{
    NSLog(@"FLVC -(IBAction) doneButtonPressed");
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if ( path == nil )
    {  // Check if _highlightedIndexPath has a value
        path = _highlightedIndexPath;
    }
    
    TripData *trip = [_showTimes objectForIndexPath:path];
    
    NSInteger selectedStopID   = [[trip start_stop_id] intValue];
    NSString *selectedStopName = [trip start_stop_name];
    
    if ( [self.delegate respondsToSelector:@selector(doneButtonPressed:WithStopName:andStopID:)] )
        [[self delegate] doneButtonPressed:self WithStopName:selectedStopName andStopID:selectedStopID];

}


- (IBAction)cancelButtonPressed:(id)sender
{
    NSLog(@"FLVC -(IBAction) cancelButtonPressed");
    if ( [self.delegate respondsToSelector:@selector(cancelButtonPressed:)] )
        [[self delegate] cancelButtonPressed:self];
    
}

#pragma mark - UITableViewDataSource
// Required Methods
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  // Required method
{
    
    //    static NSString *CellIdentifier = @"ShowTimesCellIdentifier";
    static NSString *CellIdentifier = @"FindLocationsCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    TripData *trip = [_showTimes objectForIndexPath:indexPath];
    
    [[cell textLabel] setText: [ [_showTimes objectForIndexPath:indexPath] start_stop_name] ];
//    [[cell textLabel] setText: [trip start_stop_name] ];
    [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
    
    return cell;
}

//-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    TripData *trip = [_showTimes objectForIndexPath:indexPath];
//    
//    if ( [[trip start_stop_id] integerValue] == stopIDToIgnore )
//    {
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        [cell setBackgroundColor:[UIColor grayColor] ];
//
//    }
//}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  // Required method
{
    //    return [stops numberOfRowsForSection:section];
    return [_showTimes numberOfRows];
}


// Optional Methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_showTimes numberOfSections];
}



- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{    
//    NSInteger segmentedIndex = [self.btnToFrom selectedSegmentIndex];
//    
    NSInteger row = [_showTimes getSectionWithIndex:index];
//    NSInteger section = [stopData numberOfSections] - 1;
//    
//    if ( section < 0 )
//        section = 0;
//    
//    // TODO: This won't work with Favorites and Recently Viewed
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return -1;  // Yes, Virginia.  Keep this as -1.
    
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//    NSInteger segmentIndex = [self.btnToFrom selectedSegmentIndex];
//    //    return [stops getSectionTitleForSection:index];
//    return [stopData getSectionTitleForSection: segmentIndex];
    return [_showTimes getSectionTitle];
//    return nil;
}



    // - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
// - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
// - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
// - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
// - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
// - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
    // - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    // - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
// - (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
// - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

#pragma mark - UITableViewDelegate
// Optional Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.btnDone setEnabled:YES];
//    NSMutableDictionary *dict = [_showTimes objectForIndexPath:indexPath];
//    NSLog(@"FLVC -(void) didSelect %@ - stop_id: %d", [dict objectForKey:@"stop_name"], [[dict objectForKey:@"stop_id"] intValue] );
    TripData *trip = [_showTimes objectForIndexPath: indexPath];
    NSLog(@"FLVC -(void) didSelect %@ - stop_id: %d", [trip start_stop_name], [[trip start_stop_id] intValue] );

}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"FLVC -(NSIndexPath*) willSelect");
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"FLVC -(void) didHighlightRowAtIndexPath");
    _highlightedIndexPath = indexPath;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    if ( [indexPath row] == [(NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject] row] )
//    {
//        NSLog(@"FLVC -willDisplayCell -- dismissing SVProgressHUD");
//        [SVProgressHUD dismiss];
//    }
//    
//}

// - (CGFloat)tableView:(UITableView *)  tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
// - (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
// - (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
// - (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath

// - (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
// - (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
// - (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
// - (NSString *)tableView:(UITableView *)   tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath

// - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
// - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
// - (void)tableView:(UITableView *)    tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
// - (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath

    // - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
// - (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
// - (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
    // - (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath

    //- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    //- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
//- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section

//- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section
//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath




#pragma mark - SQLite (and related) Functions
-(NSString *) filePath
{

    NSString *databaseName;
    
    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] )
        databaseName = @"SEPTAbus";
    else if ( [self.travelMode isEqualToString:@"Rail"] )
        databaseName = @"SEPTArail";
    else
        return nil;
    
    return [[NSBundle mainBundle] pathForResource:databaseName ofType:@"sqlite"];
    
//    NSString *databaseName;
//    
//    if ( [[routeData current] database_type] == kDisplayedRouteDataUsingDBBus )
//        databaseName = @"SEPTAbus";
//    else if ( [[routeData current] database_type] == kDisplayedRouteDataUsingDBRail )
//        databaseName = @"SEPTArail";
//    else
//        return nil;
//    
//    return [[NSBundle mainBundle] pathForResource:databaseName ofType:@"sqlite"];
    
}


-(void) getStopTimes
{
    
    // holds routes
    _showTimes = [[ShowTimesModel alloc] init];
    
    //    NSLog(@"BRTVC -(void) getBusRoutes");
    
    // Begin SQL3 db process
    if(sqlite3_open( [[self filePath] UTF8String], &db) == SQLITE_OK)
    {
        
//        NSLog(@"FLVC - filePath: %@", [self filePath]);
        sqlite3_stmt * statement;
        NSString *queryStr;
        
        
        //        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        //        NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
        //        int weekday = [comps weekday];
        //
        //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //        [dateFormatter setDateFormat:@"EEEE"];
        //        NSLog(@"%@", [dateFormatter stringFromDate:[NSDate date]]);
        
        if ( [[self travelMode] isEqualToString:@"Bus"] || [[self travelMode] isEqualToString:@"MFL"] || [[self travelMode] isEqualToString:@"BSS"] || [[self travelMode] isEqualToString:@"NHSL"] )
        {
        
//            NSString *fields  = [NSString stringWithFormat:@" route_%@.stop_id ", routeData.current.route_short_name];
//            NSString *sect    = [NSString stringWithFormat:@" (SELECT trip_id, stop_sequence FROM route_%@ WHERE stop_id=%d) as sect ", routeData.current.route_short_name, routeData.current.start_stop_id];
            
//            NSString *where   = [NSString stringWithFormat:@" WHERE (route_%@.trip_id=sect.trip_id AND route_%@.direction_id = %d) ", routeData.current.route_short_name, routeData.current.route_short_name, routeData.current.direction_id ];
//
//            
//            NSString *orderBy = [NSString stringWithFormat:@" ORDER BY route_%@.trip_id, route_%@.stop_sequence ", routeData.current.route_short_name, routeData.current.route_short_name];
//
//            NSString *innerSelect = [NSString stringWithFormat:@" (SELECT DISTINCT %@ FROM route_%@, %@ %@ %@) as iselect", fields, routeData.current.route_short_name, sect, where, orderBy];
            
            //        NSString *fields = @"stops.stop_id, trip_id, arrival_time, departure_time, direction_id, stop_sequence, stop_name";
            //        NSString *join   = [NSString stringWithFormat:@"JOIN stops ON route_%@.stop_id=stops.stop_id", routeName];
            //        NSString *where  = [NSString stringWithFormat:@"WHERE trip_id=%d AND stop_sequence > %@", tripID, stopSequence];
                    
            //        queryStr = [NSString stringWithFormat:@"SELECT %@ FROM route_%@ %@ %@ ORDER BY arrival_time", fields, routeName, join, where];
//            queryStr = [NSString stringWithFormat:@"SELECT stops.stop_name, stops.stop_id FROM stops, %@ where stops.stop_id=iselect.stop_id", innerSelect];
            
            // The old query was taking way too long to run whereas the rail one was running lickity split.  Updating queryStr to make it a little simplier.
            queryStr = [NSString stringWithFormat:@"SELECT stops.stop_name, stops.stop_id FROM route_ROUTE JOIN stops ON route_ROUTE.stop_id=stops.stop_id WHERE direction_id=%d GROUP BY route_ROUTE.stop_id ORDER BY stops.stop_name", routeData.current.direction_id];
            queryStr = [queryStr stringByReplacingOccurrencesOfString:@"ROUTE" withString:routeData.current.route_short_name];
            
            
        }
        else if ( [[self travelMode] isEqualToString:@"Rail"] )
        {
            
            NSString *fields = @"stops.stop_name, stops.stop_id, stop_sequence";
            NSString *joins  = [NSString stringWithFormat:@"JOIN stops ON stop_times.stop_id=stops.stop_id JOIN route_%@ ON route_%@.stop_times_uid=stop_times.uid", routeData.current.route_short_name, routeData.current.route_short_name];
            NSString *innerSQL = [NSString stringWithFormat:@"(SELECT trip_id FROM stop_times WHERE stop_id=%d)", routeData.current.start_stop_id];
            
            NSString *where = [NSString stringWithFormat:@"trip_id IN %@ AND direction_id=%d", innerSQL, routeData.current.direction_id];
            NSString *groupBy = @"stop_times.stop_id";
            NSString *orderBy = @"stop_name";
            
            queryStr = [NSString stringWithFormat:@"SELECT %@ FROM stop_times %@ WHERE %@ GROUP BY %@ ORDER BY %@", fields, joins, where, groupBy, orderBy];
            
//            queryStr = [NSString stringWithFormat:@"\
                            SELECT stops.stop_name, stops.stop_id, stop_sequence FROM stop_times\
                            JOIN stops ON stop_times.stop_id=stops.stop_id\
                            JOIN route_%@ ON route_%@.stop_times_uid=stop_times.uid\
                            WHERE trip_id IN\
                                (SELECT trip_id FROM stop_times WHERE stop_id=%d)\
                            GROUP BY stop_times.stop_id\
                            ORDER BY stop_name\
                        ",  routeData.current.route_short_name,
//                            routeData.current.route_short_name,
//                            routeData.current.start_stop_id];
            
        }
        else
        {
            return;  // travelMode has been set (or not set as the case may be) to something that is not supported
        }
        
        
        NSLog(@"FLVC - %@", queryStr);
        
        
        // stop_id        INT
        // trip_id        INT
        // arrival_time   TIMESTAMP
        // departure_time TIMESTAMP
        // stop_sequence  TEXT
        // direction_id   INT
        
        if ( sqlite3_prepare_v2(db, [queryStr UTF8String], -1, &statement, nil) == SQLITE_OK )
        {
            
//            NSString *stopNameToIgnore;
//            NSInteger stopIDToIgnore;
            
            if ( buttonType == kLeftButtonIsStart )
                stopIDToIgnore = routeData.current.start_stop_id;
            else if ( buttonType == kLeftButtonIsEnd )
                stopIDToIgnore = routeData.current.end_stop_id;
            else
                stopIDToIgnore = -1;
            
            
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                
                char *stop_name    = (char *) sqlite3_column_text(statement, 0);
                int stop_id        = (int) sqlite3_column_int(statement, 1);
                
                NSString *thisStopName = [[NSString alloc] initWithUTF8String: stop_name];

                NSArray *stopName = [NSArray arrayWithObjects: routeData.current.start_stop_name, routeData.current.end_stop_name, nil];
                if ( ![stopName containsObject: thisStopName] )
                {
                    TripData *trip = [[TripData alloc] init];
                    [trip setStart_stop_name: thisStopName];
                    [trip setStart_stop_id  : [NSNumber numberWithInt: stop_id] ];
                    
                    [_showTimes addTimes: trip];
                }
                
            } // while (sqlite3_step(statement)==SQLITE_ROW)
            
            sqlite3_finalize(statement);
            
        }
        else
        {
            int errorCode = sqlite3_step( statement );
            char *errMsg = (char *)sqlite3_errmsg(db);
            NSString *errStr = [[NSString alloc] initWithUTF8String:errMsg];
            NSLog(@"FLVC - query failure, code: %d, %@", errorCode, errStr);
            NSLog(@"FLVC - query str: %@", queryStr);
        } // if ( sqlite3_prepare_v2(db, [queryStr UTF8String], -1, &statement, nil) == SQLITE_OK )
        
    } // if(sqlite3_open([[self filepath] UTF8String], &db) == SQLITE_OK)
    
    //    [stops sort];
    //    [self configureSegmentedControl];
    
    NSLog(@"FLVC - Number of rows: %d", [_showTimes numberOfRows]);
    [_showTimes sort];
    sqlite3_close(db);  // Should probably open and close the database once, not multiple times.
    
    
    
//    if ( [_showTimes numberOfRows] == 2 )  // 2 is considered empty now
//    {
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//        [dict setObject:@"No scheduled stops" forKey:@"arrival_time"];
//        [dict setObject:[NSNumber numberWithInt:0] forKey:@"stop_id"];
//        [dict setObject:[NSNumber numberWithInt:0] forKey:@"trip_id"];
//        [dict setObject:[NSNumber numberWithInt:0] forKey:@"direction_id"];
//        [dict setObject:@"-1" forKey:@"stop_sequence"];
//        
//        [_showTimes addTimes: dict];
//    }
    
}

#pragma mark - Gesture Recognziers
- (IBAction)longPressDetected:(id)sender
{
    NSLog(@"FLVC - longPressDetected");
    //    [self.btnDone.target performSelector:self.btnDone.action ];  // Gives a warning

    
    UILongPressGestureRecognizer *gesture = (UILongPressGestureRecognizer*)sender;
    if ( [gesture state] == UIGestureRecognizerStateBegan )
    {
        [self.btnDone.target performSelector: @selector(doneButtonPressed:)];
    }
    
}



- (IBAction)doubleTapDetected:(id)sender
{
    NSLog(@"FLVC - doubleTapDetected");
//    [self.btnDone.target performSelector:self.btnDone.action ];  // Gives a warning
    [self.btnDone.target performSelector: @selector(doneButtonPressed:)];
}




@end
