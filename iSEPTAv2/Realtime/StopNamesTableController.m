//
//  StopNamesTableController.m
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "StopNamesTableController.h"
#import "FMDatabase.h"

#import "ShowTimesModel.h"
#import "TripData.h"

@interface StopNamesTableController ()

@end

@implementation StopNamesTableController
{
//    NSMutableArray *stopNames;
    ShowTimesModel *_stopNames;
}

@synthesize delegate;

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
    
//    stopNames = [[NSMutableArray alloc] init];
    _stopNames = [[ShowTimesModel alloc] initWithPlaceholders:0];
    
    [self getRailStopNames];
    
}


//-(void)viewDidAppear:(BOOL)animated
//{
//    NSLog(@"SNTC - viewDidAppear");
//}
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    NSLog(@"SNTC - viewWillAppear");
//}
//
//-(void)viewDidDisappear:(BOOL)animated
//{
//    NSLog(@"SNTC - viewDidDisappear");
//}
//
//-(void)viewWillDisappear:(BOOL)animated
//{
//    NSLog(@"SNTC - viewWillDisappear");
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"SNTC - didReceiveMemoryWarning");

    // Dispose of any resources that can be recreated.
    _stopNames = nil;
    
}


-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


-(NSString*) filePath
{
//    NSString *databaseName;
    
    // Only supporting rails for now
    
    //    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] )
    //        databaseName = @"SEPTAbus";
    //    else if ( [self.travelMode isEqualToString:@"Rail"] )
//    databaseName = @"SEPTA";
    //    else
    //        return nil;
    
    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
}


-(void) getRailStopNames
{
    
//    [stopNames removeAllObjects];
    
    [_stopNames clearData];
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    NSString *queryStr = @"SELECT * FROM stops_rail ORDER BY stop_name";
    
    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"SNTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"SNTC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    }
    
    // Add Current Location and Enter Address at the start of the arrary
    TripData *currentLocation = [[TripData alloc] init];
    [currentLocation setStart_stop_name: @"Current Location"];
    [currentLocation setStart_stop_id: [NSNumber numberWithInt:-100] ];
    [currentLocation setDirection_id:  [NSNumber numberWithInt:0] ];
    
    TripData *enterAddress = [[TripData alloc] init];
    [enterAddress setStart_stop_name: @"Enter Address"];
    [enterAddress setStart_stop_id: [NSNumber numberWithInt:-101] ];
    [enterAddress setDirection_id:  [NSNumber numberWithInt:0] ];
    [_stopNames addTimes: currentLocation];
    [_stopNames addTimes: enterAddress];
    
    while ( [results next] )
    {
        
        NSString *stop_name = [results stringForColumn:@"stop_name"];
        NSInteger stop_id  = [results intForColumn:@"stop_id"];

//        StopNamesObject *snObject = [[StopNamesObject alloc] init];
//        [snObject setStop_id: [NSNumber numberWithInt:stop_id] ];
//        [snObject setStop_name: stop_name];
//        
//        [stopNames addObject: snObject];
        
        TripData *trip = [[TripData alloc] init];
        [trip setStart_stop_name: stop_name];
        [trip setStart_stop_id:   [NSNumber numberWithInt:stop_id] ];
        [_stopNames addTimes:trip];
        
    }
    
//    [_stopNames sort];  // Sort normally handles sorting the address and generating the index, but in this case, the SQL statement handled the sorting part.
    [_stopNames generateIndex];
    
}

#pragma mark - UITableViewDelegate
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger row = [_stopNames getSectionWithIndex:index];

    //    // TODO: This won't work with Favorites and Recently Viewed
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return -1;  // Yes, Virginia.  Keep this as -1.
    
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [_stopNames getSectionTitle];
}



// Optional Methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return [stopNames count];
    return [_stopNames numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITableViewCell * cell = [thisTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
//    [[cell textLabel] setText: [(StopNamesObject*)[stopNames objectAtIndex:indexPath.row] stop_name] ];
    
    TripData *trip = [_stopNames objectForIndexPath:indexPath];
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

    if ( indexPath.row == 0 )
    {
        NSLog(@"Selected Current Location");
        NSString * storyboardName = @"CurrentLocationStoryboard";
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        CurrentLocationTableViewController *clVC = (CurrentLocationTableViewController*)[storyboard instantiateInitialViewController];
        
        [clVC setRouteType: [NSNumber numberWithInt:kCurrentLocationRouteTypeRailOnly] ];
        [clVC setDelegate:self];
        
        [self.navigationController pushViewController:clVC animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if ( indexPath.row == 1 )
    {
        NSLog(@"Selected Enter Address");
//        NSString * storyboardName = @"EnterAddressStoryboard";
//        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
//        UINavigationController* navController = (UINavigationController*)[storyboard instantiateInitialViewController];
//        
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
    
/*
 
 NSString * storyboardName = @"CurrentLocationStoryboard";
 UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
 UINavigationController* navController = (UINavigationController*)[storyboard instantiateInitialViewController];
 
 CurrentLocationTableViewController *clVC = [[navController viewControllers] objectAtIndex:0];
 [clVC setRouteType: [NSNumber numberWithInt:kCurrentLocationRouteTypeRailOnly] ];
 [clVC setDelegate:self];
 
 [self presentViewController:navController animated:YES completion:nil];
 [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
 
 */

}

#pragma mark - UIBarButtons
- (IBAction)doneButtonPressed:(id)sender
{
    NSLog(@"SNTC -(IBAction) doneButtonPressed");
    
    
    TripData *trip;
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if ( path == nil )
    {  // Check if _highlightedIndexPath has a value
//        path = _highlightedIndexPath;
        trip = nil;
    }
    else
    {
        trip = [_stopNames objectForIndexPath: path];
    }
    
    NSString *selectedStopName = [trip start_stop_name];
    NSInteger selectedStopID   = [[trip start_stop_id] intValue];
    
    if ( [self.delegate respondsToSelector:@selector(doneButtonPressed:WithStopName:andStopID:)] )
        [[self delegate] doneButtonPressed:self WithStopName:selectedStopName andStopID:selectedStopID];
    
}


- (IBAction)cancelButtonPressed:(id)sender
{
    NSLog(@"SNTC -(IBAction) cancelButtonPressed");
    if ( [self.delegate respondsToSelector:@selector(cancelButtonPressed:)] )
        [[self delegate] cancelButtonPressed:self];
    
}


#pragma mark - CurrentLocationProtocol
-(void) currentLocationSelectionMade:(BasicRouteObject *)routeObj
{
    NSLog(@"Received object: %@", routeObj);
}



@end
