//
//  TripDetailsTableController.m
//  iSEPTA
//
//  Created by apessos on 3/23/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TripDetailsTableController.h"

// --==  Custom Cells  ==--
#import "StopSequenceCell.h"


// --==  External Libraries  ==--
#import "FMDatabase.h"


// --==  Objects  ==--
//#import "TripObject.h"
#import "StopSequenceObject.h"
#import "StopSequenceCellData.h"


// --==  Frameworks  ==--
#import <CoreLocation/CoreLocation.h>


@interface TripDetailsTableController ()

@end

@implementation TripDetailsTableController
{
    NSMutableArray *alarmArr;
    NSMutableArray *stopsArr;
    
    NSMutableArray *_sectionIndex;
    NSMutableArray *_sectionTitle;
    
    StopSequenceCellData *seqData;
    
    NSIndexPath *_selectedCell;
    CLLocationManager *_ccManager;
    CLRegion *_clRegion;
    
}

@synthesize tripID = _tripID;
@synthesize trip = _trip;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _selectedCell = nil;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    alarmArr = [[NSMutableArray alloc] init];
    stopsArr = [[NSMutableArray alloc] init];
    
    [stopsArr addObject:@"Test1"];
    [stopsArr addObject:@"Test2"];

    
    if ( [self.travelMode isEqualToString:@"Rail"])
    {
        [self.navigationItem setTitle:@"Stations"];
    }
    else
    {
        [self.navigationItem setTitle:@"Stops"];
    }
    
    
    // Initialize CCLocationManager
    _ccManager = [[CLLocationManager alloc] init];
    
    [_ccManager setDesiredAccuracy: kCLLocationAccuracyThreeKilometers];
    [_ccManager setDelegate:self];
    
    
    
    _sectionIndex  = [[NSMutableArray alloc] init];
    _sectionTitle  = [[NSMutableArray alloc] init];
    
    seqData = [[StopSequenceCellData alloc] init];
    
    [self loadStopSequence];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)thisTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    NSInteger row = [[_sectionIndex objectAtIndex:index] intValue];
    
    // TODO: This won't work with Favorites and Recently Viewed
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    return -1;  // Tells the tableview that you'll handle jumping to the appropriate row.  (If we had more than one section, maybe we'd return something different)
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)thisTableView
{
    return _sectionTitle;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    switch (section)
    {
        case 0:
            return [alarmArr count];
            break;
        case 1:
            return [stopsArr count];
            break;
        default:
            return 0;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"TripDetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    switch (indexPath.section)
    {
        case 0:
//        [[cell textLabel] setText: [alarmArr objectAtIndex:indexPath.row] ];
            return [self returnCellForAlarms:indexPath];
            break;
        case 1:
//        [[cell textLabel] setText: [stopsArr objectAtIndex:indexPath.row] ];
            return [self returnCellForStopSequence:indexPath];
            break;
        default:
            break;
    }

    return cell;
    
}


-(id) returnCellForAlarms:(NSIndexPath*) indexPath
{
    
    return nil;
}

-(id) returnCellForStopSequence:(NSIndexPath*) indexPath
{
    /*
     
     Show all routes in this sequence.  All previous routes are grayed out (black 50% alpha)
     Current and future routes are shown without alpha.
     All routes past end stop are grayed out.
     
     User can touch a cell to switch start or end points
     
     */
    
    //    static NSInteger startHighlighting = 0;
    static NSString *sequenceCellIdentifier = @"SequenceCellIdentifier";
    StopSequenceCell *cell;
    
    //    NSLog(@"TABLESEQ!");
    cell = (StopSequenceCell*)[self.tableView dequeueReusableCellWithIdentifier: sequenceCellIdentifier];
    
    if ( cell == nil )
    {
        //        cell = [[StopSequenceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sequenceCellIdentifier];
//        NSLog(@"TDTC - creating StopSeqeuenceCell");
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StopSequenceCell" owner:self options:nil];
        cell = (StopSequenceCell*)[nib objectAtIndex:0];
    }

    StopSequenceObject *ssObject = [stopsArr objectAtIndex:indexPath.row];
    
    //[[cell lblStopName] setText: ssObject.stopName];
    //[[cell lblStopTime] setText: ssObject.arrivalTime];
    [cell loadObject: ssObject];
    [cell clearAlarm];  // When reusing a cell, if we don't do this the button might be visible as the user scrolls.
    
    // seqData is used to identify the start and end of the trip
    [cell setSequenceData:seqData forCurrentSequence:ssObject.stopSequence];
    
    // Tell cell what the first stop sequence, last stop sequence and current stop sequence
    
    
//    TripData *trip = [_stopSequence objectForIndexPath:indexPath];
//    
//    [[cell lblStopName] setText: [trip start_stop_name   ] ];
//    [[cell lblStopTime] setText: [trip start_arrival_time] ];
//    [cell setDelegate: self];
//    
//    int currentSequence = [[trip start_stop_sequence] intValue];
//    
//    if ( [_stopSequence numberOfRows] == indexPath.row+1 )
//    {
//        if ( currentSequence != _endSequence )
//        {
//            // C
//            UIImage *temp = [UIImage imageNamed:@"stopSequenceTopBubble.png"];
//            [[cell imgSequence] setImage: [UIImage imageWithCGImage: temp.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
//        }
//        else
//        {
//            // D
//            UIImage *tempSeq = [UIImage imageNamed:@"stopSequenceTopHighBubble.png"];
//            UIImage *tempPro = [UIImage imageNamed:@"stopSequenceTopGreenBubble.png"];
//            [[cell imgSequence] setImage: [UIImage imageWithCGImage: tempSeq.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
//            [[cell imgProgress] setImage: [UIImage imageWithCGImage: tempPro.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
//        }
//        
//    }
//    else if ( indexPath.row == 0 )
//    {
//        
//        // A or B depending on highlighted
//        if ( currentSequence != _startSequence )
//        {
//            // A
//            [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceTopBubble.png"] ];
//        }
//        else
//        {
//            // B
//            [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceTopHighBubble.png"] ];
//            [[cell imgProgress] setImage: [UIImage imageNamed:@"stopSequenceTopGreenBubble.png"] ];
//        }
//        
//    }
//    else if ( currentSequence < _startSequence )
//    {
//        // E as long as currentSequence before _startSequence
//        [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceMidBubble.png"] ];
//    }
//    else if ( currentSequence == _startSequence )
//    {
//        // G
//        [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceMidHighDownBubble.png"] ];
//        [[cell imgProgress] setImage: [UIImage imageNamed:@"stopSequenceMidGreenDownBubble.png"] ];
//    }
//    else if ( currentSequence < _endSequence )
//    {
//        // H
//        [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceMidHighBubble.png"] ];
//        [[cell imgProgress] setImage: [UIImage imageNamed:@"stopSequenceMidGreenBubble.png"] ];
//    }
//    else if ( currentSequence == _endSequence )
//    {
//        // F
//        UIImage *tempSeq = [UIImage imageNamed:@"stopSequenceMidHighDownBubble.png"];
//        UIImage *tempPro = [UIImage imageNamed:@"stopSequenceMidGreenDownBubble.png"];
//        [[cell imgSequence] setImage: [UIImage imageWithCGImage: tempSeq.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
//        [[cell imgProgress] setImage: [UIImage imageWithCGImage: tempPro.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
//    }
//    else
//    {
//        // E
//        [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceMidBubble.png"] ];
//    }
    
    
    //    [cell setProgress:0.5];
    
    //    if ( [startSequence isEqualToString: [trip start_stop_sequence] ] )
    //    {
    //        startHighlighting = 1;
    //    }
    
    
    
    //    if ( indexPath.row == 0 )
    //    {
    //        if ( [[trip start_stop_name]  isEqualToString:@"No scheduled stops"] )
    //            [cell changeImageTo: kStopSequenceUndefined];
    //        else
    //            [cell changeImageTo: kStopSequenceTopBubble];
    //    }
    //    else if ( indexPath.row == [_stopSequence numberOfRows] -1 )
    //    {
    //        [cell changeImageTo: kStopSequenceBtmBubble];
    //    }
    //    else
    //    {
    //        [cell changeImageTo: kStopSequenceMidBubble];
    //    }
    //
    //
    //    if ( [endSequence isEqualToString: [trip start_stop_sequence] ] )
    //    {
    //        startHighlighting = 0;
    //    }
    
    
    return cell;
    
}


// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}


// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
////        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}

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
    
//    [tableView setEditing:YES animated:YES];
    
    
    // Return cell that was selected
    
    if ( _selectedCell != nil && _selectedCell != [self.tableView indexPathForSelectedRow] )
    {
        id cell = [self.tableView cellForRowAtIndexPath:_selectedCell];
        if ( [cell isKindOfClass:[StopSequenceCell class] ] )
        {
            [(StopSequenceCell*)cell clearAlarm];
            [self stopMonitoringRegion];
        }
    }
    
    
    _selectedCell = [self.tableView indexPathForSelectedRow];
    id cell = [self.tableView cellForRowAtIndexPath:_selectedCell];
    
    if ( [cell isKindOfClass:[StopSequenceCell class] ] )
    {
        [(StopSequenceCell*)cell setAlarm];
        NSLog(@"%@", cell);
        [self startMonitoringRegionFor: [cell getLoc] ];
    }
    
    
    [self.tableView deselectRowAtIndexPath:_selectedCell animated:YES];
    
    
}


-(void) startMonitoringRegionFor:(CLLocationCoordinate2D) loc
{
    
//    loc.latitude = 39.95192f;
//    loc.longitude = -75.16022f;
//    
//    _clRegion = [[CLRegion alloc] initCircularRegionWithCenter:loc radius:10.0f identifier:@"Train"];  // Radius is measured in meters
//    [_ccManager startMonitoringForRegion:_clRegion desiredAccuracy: kCLLocationAccuracyBest];
//    [_ccManager startMonitoringSignificantLocationChanges];
}

-(void) stopMonitoringRegion
{
//    [_ccManager stopMonitoringForRegion:_clRegion];
//    [_ccManager stopMonitoringSignificantLocationChanges];
}


-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    UIAlertView *alr = [[UIAlertView alloc] initWithTitle:@"Did Enter Region" message:@"You entered selected region" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alr show];
}

-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    UIAlertView *alr = [[UIAlertView alloc] initWithTitle:@"Did Exit Region" message:@"You exited selected region" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alr show];
}


#pragma mark - Database Access
-(void) loadStopSequence
{

    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
 
    
    NSString *queryStr = [NSString stringWithFormat:@"SELECT stop_sequence, arrival_time, stop_name, stops_rail.stop_id, stop_lon, stop_lat FROM stop_times_rail JOIN stops_rail ON stop_times_rail.stop_id=stops_rail.stop_id  WHERE trip_id=\"%@\" ORDER BY stop_sequence", _tripID];
    NSLog(@"ITVC - queryStr: %@", queryStr);
    
    if ( ![[self travelMode] isEqualToString:@"Rail"] )
    {
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"_rail" withString:@"_bus"];
    }
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"ITVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"ITVC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
    [stopsArr removeAllObjects];
    
    [seqData setStartOfTrip: _trip.startSeq];
    [seqData setEndOfTrip  : _trip.endSeq];
    
    while ( [results next] )
    {
        int stopSequence      = [results intForColumnIndex:0];     // stop_sequence
        NSString *arrivalTime = [results stringForColumnIndex:1];  // arrival_time
        
        NSString *stopName    = [results stringForColumnIndex:2];  // stop_name
        int stopID            = [results intForColumnIndex:3];     // stops_rail.stop_id

        NSString *stopLon     = [results stringForColumnIndex:4];  // stop_lon
        NSString *stopLat     = [results stringForColumnIndex:5];  // stop_lat
        
        StopSequenceObject *ssObject = [[StopSequenceObject alloc] init];
        
        [ssObject setStopSequence: [NSNumber numberWithInt:stopSequence] ];
        [ssObject setArrivalTime : arrivalTime];
        
        [ssObject setStopName    : stopName];
        [ssObject setStopID      : [NSNumber numberWithInt:stopID] ];
        
        [ssObject setStopLon     : stopLon];
        [ssObject setStopLat     : stopLat];
        
        [stopsArr addObject: ssObject];
                
    }
    
    [seqData setFirstSequence: [[stopsArr objectAtIndex:0] stopSequence] ];
    [seqData setLastSequence : [[stopsArr lastObject] stopSequence] ];
    
//    [stopsArr sortByKey:@"stopSequence"];
    NSDictionary *dict = [stopsArr dictionaryOfIndicesandTitlesForKey:@"stopName"];
    
    _sectionIndex = [dict objectForKey:@"index"];
    _sectionTitle = [dict objectForKey:@"title"];
    
    
}


//-(NSString*) filePath
//{
//    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
//}


- (void)viewDidUnload
{
    [self setBtnEdit:nil];
    [super viewDidUnload];
}

#pragma mark - Button Edit
- (IBAction)btnEditPressed:(id)sender
{
    
    NSLog(@"TDTC - Edit Button Pressed");
//    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
//    [downloadButton setFrame:CGRectMake(0, 0, 100, 35)];
    NSIndexPath *indexPath;
    indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView cellForRowAtIndexPath:indexPath].accessoryView = downloadButton;
    
    [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}



@end

