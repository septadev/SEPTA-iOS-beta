//
//  StopNamesForRouteTableController.m
//  iSEPTA
//
//  Created by apessos on 3/5/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "StopNamesForRouteTableController.h"
#import "StopNamesObject.h"


// --==  External Libraries  ==--
#import "FMDatabase.h"
#import "SVProgressHUD.h"
// --==  External Libraries  ==--


#import "ShowTimesModel.h"
#import "TripData.h"
#import "ItineraryObject.h"

@interface StopNamesForRouteTableController ()

@end

@implementation StopNamesForRouteTableController
{
    
    NSIndexPath *_selectedIndexPath;
//    NSMutableArray *_stopNamesArr;
//    NSMutableArray *_masterNamesArr;
    
    NSOperationQueue *_sqlQueue;
    NSBlockOperation *_sqlOp;
    
    NSTimer *timer;
    ShowTimesModel *_stopNames;
    
    BOOL _doubleSectionMode;
    NSMutableArray *_nameForSection;
    
    NSMutableArray *_stopsSection0;
    NSMutableArray *_stopsSection1;
    
    NSMutableArray *_sectionIndex;
    NSMutableArray *_sectionTitle;
    
}


@synthesize direction;  // Used to determine how many sections to display (one or two)
@synthesize travelMode;
@synthesize itinerary;


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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.btnDone setEnabled:NO];

    
    _nameForSection = [[NSMutableArray alloc] init];
//    [_nameForSection addObject:@"Section 0"];
//    [_nameForSection addObject:@"Section 1"];
    
    _stopsSection0 = [[NSMutableArray alloc] init];
    _stopsSection1 = [[NSMutableArray alloc] init];
    
    // There is a very specific set of conditions that must occur first before switching to doubleSectionMode.
    //    There is no direction because the user hasn't chosen a stop yet.  And the travelMode is Bus/Trolley.  For all
    //    other instances, one section is enough to display everything.
    if ( ( self.direction == nil ) && ( [self.travelMode isEqualToString: @"Bus"] || [self.travelMode isEqualToString:@"Trolley"] ) )
        _doubleSectionMode = YES;
    else
        _doubleSectionMode = NO;
    
    
    _sqlQueue  = [[NSOperationQueue alloc] init];
    _sqlOp     = [[NSBlockOperation alloc] init];
    
    _stopNames = [[ShowTimesModel alloc] initWithPlaceholders:0];


    [SVProgressHUD showWithStatus:@"Loading..."];
    
    __weak NSBlockOperation *weakOp = _sqlOp;
    [weakOp addExecutionBlock:^{
        
        [self loadStopNames];
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                _stopNamesArr = [_masterNamesArr copy];
                [self.tableView reloadData];
                [SVProgressHUD dismiss];     // Dismisses any active loading HUD
                
            }];
        }
        else
        {
            NSLog(@"SNFRTC - running SQL Query: _sqlOp cancelled");
        }
        
    }];
    
    [_sqlQueue addOperation: _sqlOp];
    
}


-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(void) fiveSecondTimer
{
//    NSLog(@"TIMER!!!");
//    [SVProgressHUD dismiss];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource/Delegate

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if ( section >= [_nameForSection count] )
        return nil;
    
    if ( _doubleSectionMode )
    {
        return (NSString*)[_nameForSection objectAtIndex:section];
    }
    else
    {
        return nil;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{

//    NSInteger row = [[_sectionIndex objectAtIndex:index] intValue];
    
    NSIndexPath *path = [_sectionIndex objectAtIndex:index];
    NSInteger row = [path row];
    NSInteger section = [path section];
    
    
    // TODO: This won't work with Favorites and Recently Viewed
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return -1;  // Yes, Virginia.  Keep this as -1.
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
//    return [_stopNames getSectionTitle];
    return _sectionTitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    if ( _doubleSectionMode )
        return 2;
    else
        return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // Return [_stopNamesArr count];
    
    if ( _doubleSectionMode )
    {
        if ( section == 1 )
            return [_stopsSection1 count];
    }

    return [_stopsSection0 count];
    
//    return [_stopNames numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellId = @"StopNameCell";
    
//    NSString *name = [[_stopNamesArr objectAtIndex: indexPath.row] stop_name];
//    NSLog(@"cellID: %@, stopName: %@", cellId, name);
    UITableViewCell *cell = [thisTableView dequeueReusableCellWithIdentifier:cellId];
    
    // Configure the cell...

//    TripData *trip = [_stopNames objectForIndexPath:indexPath];
    
    NSMutableArray *array;
    if ( indexPath.section == 0 )
        array = _stopsSection0;
    else
        array = _stopsSection1;
    
    TripData *trip = [array objectAtIndex:indexPath.row];
    [[cell textLabel] setText: [trip start_stop_name] ];
    
    
    
    return cell;
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
    [self.btnDone setEnabled:YES];
    _selectedIndexPath = indexPath;
}

// This method is available in iOS 6.0 and later.  Highlight is the precursor to selection
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
}

- (void)viewDidUnload
{

    [self setBtnCancel:nil];
    [self setBtnDone:nil];

//    [self setGestureDoubleTap:nil];
//    [self setGestureLongPress:nil];

    [super viewDidUnload];
    
}


#pragma mark -
#pragma mark IBActions
- (IBAction)cancelButtonPressed:(id)sender
{
    NSLog(@"SNFRTC -(IBAction) cancelButtonPressed");
    if ( [self.delegate respondsToSelector:@selector(cancelButtonPressed:)] )
        [[self delegate] cancelButtonPressed:self];
}


- (IBAction)doneButtonPressed:(id)sender
{
    
    [SVProgressHUD showWithStatus:@"Loading..."];

    NSIndexPath *path = _selectedIndexPath;
//    StopNamesObject *stopNames = [_stopNamesArr objectAtIndex:path.row];
    
    TripData *trip;
    if ( path.section == 0 )
    {
        trip = [_stopsSection0 objectAtIndex: path.row];
    }
    else if ( path.section == 1 )
    {
        trip = [_stopsSection1 objectAtIndex: path.row];
    }
    
//    TripData *trip = [_stopNames objectForIndexPath:path];
    
    NSString *selectedStopName = [trip start_stop_name];
    NSInteger selectedStopID  = [[trip start_stop_id] intValue];
    NSNumber *selectedDirID   = [trip direction_id];
    
   NSLog(@"SNFRTC -(IBAction) doneButtonPressed.  Name: %@, Stop ID: %d, direction ID: %d", selectedStopName, selectedStopID, [selectedDirID intValue] );
    
    [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:NO];
    
    if ( [self.delegate respondsToSelector:@selector(doneButtonPressed:WithStopName:andStopID:withDirectionID:)] )
        [[self delegate] doneButtonPressed:self WithStopName:selectedStopName andStopID:selectedStopID withDirectionID:selectedDirID];
    
//    [self.navigationController popViewControllerAnimated:YES];
    
}

//- (IBAction)gestureDoubleTapTriggered:(id)sender
//{
//    
//    [self.btnDone.target performSelector: @selector(doneButtonPressed:)];
//
////    UITapGestureRecognizer *gesture = (UITapGestureRecognizer*)sender;
////    if ( [gesture state] == UIGestureRecognizerStateBegan )
////    {
////        [self.btnDone.target performSelector: @selector(doneButtonPressed:)];
////    }
//    
//}
//
//- (IBAction)gestureLongPressTriggered:(id)sender
//{
//    UILongPressGestureRecognizer *gesture = (UILongPressGestureRecognizer*)sender;
//    if ( [gesture state] == UIGestureRecognizerStateBegan )
//    {
//        [self.btnDone.target performSelector: @selector(doneButtonPressed:)];
//    }
//}


#pragma -
#pragma Database
-(void) loadStopNames
{
 
    NSDate *startTime = [NSDate date];
    NSLog(@"SNFRTC - Starting at %@", startTime);
 
    [_stopNames clearData];
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    /*
     *  Now that the database is open, need to query bus_stop_directions for the proper header name for each section
     *  This is only applicable when travelMode is Bus.
     */
    
    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Trolley"] )
    {
        
        NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM bus_stop_directions WHERE Route=\"%@\" ORDER BY dircode", self.itinerary.routeShortName];
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
            [_nameForSection addObject:header];
        }
        
    }
    
    
    
    FMResultSet *results = [database executeQuery: self.queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNFRTC - query str: %@", self.queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    } // if ( [database hadError] )
    
    
//    TripData *currentLocation = [[TripData alloc] init];
//    [currentLocation setStart_stop_name: @"Current Location"];
//    [currentLocation setStart_stop_id: [NSNumber numberWithInt:-100] ];
//    [currentLocation setDirection_id:  [NSNumber numberWithInt:0] ];
//    
//    TripData *enterAddress = [[TripData alloc] init];
//    [enterAddress setStart_stop_name: @"Enter Address"];
//    [enterAddress setStart_stop_id: [NSNumber numberWithInt:-101] ];
//    [enterAddress setDirection_id:  [NSNumber numberWithInt:0] ];
//
//    [_stopsSection0 addObject: currentLocation];
//    [_stopsSection0 addObject: enterAddress];
    
    
    while ( [results next])
    {
//        StopNamesObject *sObject = [[StopNamesObject alloc] init];
        
        NSString *stop_name = [results stringForColumn:@"stop_name"];
        NSNumber *stop_id   = [NSNumber numberWithInt: [results intForColumn:@"stop_id"] ];
        NSNumber *direction_id;
        
        if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"Trolley"] )
            direction_id = [NSNumber numberWithInt:[results intForColumn:@"direction_id"] ];
        
        
        TripData *trip = [[TripData alloc] init];
        [trip setStart_stop_name: stop_name];
        [trip setStart_stop_id  : stop_id  ];
        [trip setDirection_id: direction_id];

        
        if ( _doubleSectionMode )
        {
            
            if ( [direction_id intValue] == 0 )
            {
                [_stopsSection0 addObject:trip];
            }
            else
            {
                [_stopsSection1 addObject:trip];
            }
            
        }
        else
        {
//            [_stopNames addTimes:trip];
            [_stopsSection0 addObject:trip];
        }
        
        
    }  // while ( [results next] )
    
    
    [database close];
    
    if ( _doubleSectionMode )
    {
        NSDictionary *indices0 = [_stopsSection0 dictionaryOfIndicesandTitlesForKey:@"start_stop_name" forSection: [NSNumber numberWithInt:0] ];
        NSDictionary *indices1 = [_stopsSection1 dictionaryOfIndicesandTitlesForKey:@"start_stop_name" forSection: [NSNumber numberWithInt:1] ];
        
//        NSDictionary *indices1 = [_stopsSection1 dictionaryOfIndicesandTitlesForKey:@"start_stop_name"];
        
        _sectionIndex = [indices0 objectForKey:@"index"];
        [_sectionIndex addObject:[NSIndexPath indexPathForRow:0 inSection:1] ];  // Divider
        [_sectionIndex addObjectsFromArray: [indices1 objectForKey:@"index"] ];
        
        _sectionTitle = [indices0 objectForKey:@"title"];
        [_sectionTitle addObject:@"—"];
        [_sectionTitle addObjectsFromArray: [indices1 objectForKey:@"title"] ];
        
    }
    else
    {
//        [_stopNames sort];
        NSDictionary *indices0 = [_stopsSection0 dictionaryOfIndicesandTitlesForKey:@"start_stop_name" forSection: [NSNumber numberWithInt:0] ];
        
        _sectionIndex = [indices0 objectForKey:@"index"];
        _sectionTitle = [indices0 objectForKey:@"title"];
    }
    
    
//    [_stopNames generateIndex];
    NSTimeInterval diff = [ [NSDate date] timeIntervalSinceDate: startTime];
    NSLog(@"SNFRTC - %6.3f seconds have passed.", diff);
    
}

-(NSString*) filePath
{
    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];    
}


@end
