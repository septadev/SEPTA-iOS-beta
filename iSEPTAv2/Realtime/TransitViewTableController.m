//
//  TransitViewTableController.m
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "TransitViewTableController.h"
//#import "TrainViewViewController.h"
#import "NewTrainViewViewController.h"

#import "FMDatabase.h"
#import "RouteInfo.h"

#import "VehicleDetailsCell.h"

@interface TransitViewTableController ()

@end

@implementation TransitViewTableController
{
    NSMutableArray *_tableData;  // Array of RouteInfos
    
    NSMutableArray *_busSectionTitle;
    NSMutableArray *_busSectionIndex;
}


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
    
    _tableData = [[NSMutableArray alloc] init];
    [self getBusRouteInfo];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"TVTC - didReceiveMemoryWarning");

    // Dispose of any resources that can be recreated.
    _tableData = nil;
    _busSectionIndex = nil;
    _busSectionTitle = nil;
    
}

#pragma mark - UITableViewDataSource
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _busSectionTitle;
}

- (NSInteger)tableView:(UITableView *)thisTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[_busSectionIndex objectAtIndex:index] intValue] inSection:0];
    [thisTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

    return -1;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"TransitCellIdentifier";
    VehicleDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    RouteInfo *route = [_tableData objectAtIndex:indexPath.row];

    [[cell lblRouteName] setText: route.route_short_name];
    [cell setRouteType: [route.route_type intValue] ];
    
    [cell setRouteInfo: route];
    
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

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}


//-(NSString*) filePath
//{
//    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
//}


-(void) getBusRouteInfo
{

    [_tableData removeAllObjects];
    
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    
    // --==  Load Service Hours  ==--
    int currentServiceID;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date] ];
    int weekday = (int)[comps weekday];  // Sunday is 1, Mon (2), Tue (3), Wed (4), Thur (5), Fri (6) and Sat (7)
    
    currentServiceID = pow(2,(7-weekday));
    
    
    // TODO: Make this holiday aware
    NSString *qStr = [NSString stringWithFormat:@"SELECT route_id, route_short_name, route_type, direction_id, Direction, min, max FROM routes_bus NATURAL JOIN serviceHours WHERE (service_id & %d) AND route_short_name NOT IN (\"MFL\", \"NHSL\", \"BSS\")", currentServiceID];
    NSLog(@"TVTC - queryStr: %@", qStr);
    FMResultSet *r = [database executeQuery: qStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"TVTC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"TVTC - query str: %@", qStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    }
    
    
    /* 
     *  The following results will be returned from the above query:
     *     11219|124|3|0|Westbound|04:33|23:27
     *     11219|124|3|1|Eastbound|05:40|24:50
     *  Two results per route_id, one for each direction.  But the UITableView uses one cell that 
     *  contains both pieces of information.  Because I can't get them into the same line with a 
     *  simple select, we'll need another method.
     *
     *  quickLook will be a fast lookup dictionary for the individual RouteInfo objects stored in
     *  _tableData.  _tableData is what is used to populate the table.  We check if the key is
     *  in quickLookup.  If it isn't, we created and keep a link with quickLookup.
     */
    
    NSMutableDictionary *quickLookup = [[NSMutableDictionary alloc] init];
    BOOL foundInQuick = NO;
    
    while ( [r next] )
    {
        
        int route_id = [r intForColumn:@"route_id"];
        NSString *route_short_name = [r stringForColumn:@"route_short_name"];
//        NSString *route_long_name = [r stringForColumn:@"route_long_name"];
        int route_type = [r intForColumn:@"route_type"];
        
        int direction_id = [r intForColumn:@"direction_id"];
        
        NSString *direction = [r stringForColumn:@"Direction"];
        NSString *minTime   = [r stringForColumn:@"min"];
        NSString *maxTime   = [r stringForColumn:@"max"];
        
        
//        NSLog(@"TVTC - Route #%@", route_short_name);
        
        RouteInfo *routeInfo;
        if ( [quickLookup objectForKey: route_short_name] == nil )
        {
            routeInfo = [[RouteInfo alloc] init];
            [quickLookup setObject:routeInfo forKey:route_short_name];
        }
        else
        {
            routeInfo = [quickLookup objectForKey: route_short_name];
            foundInQuick = YES;
        }
        
        
        [routeInfo setRoute_id:[NSNumber numberWithInt:route_id] ];
        [routeInfo setRoute_short_name: route_short_name];
        [routeInfo setRoute_type:[NSNumber numberWithInt:route_type] ];
        
        [routeInfo setCardinalDirection:direction withID:direction_id forHoursMin:minTime andMax:maxTime];
        
        if ( !foundInQuick )  // If it was found, we don't need to add the object into _tableData as it's already there
            [_tableData addObject:routeInfo];  // This object was just created, add it to _tableData
        foundInQuick = NO;
        
    }  // while ( [results next] )
    
    quickLookup = nil;  // We don't need this anymore
    
    
    [_tableData sortUsingComparator:^(id a, id b)
     {
         return [[a route_short_name] compare: [b route_short_name] options:NSNumericSearch];
     }];
    
    
    [self generateIndex];
    [self.tableView reloadData];
    
}


//NSComparisonResult (^sortBusNames)(id,id) = ^(id a, id b)
//{
//    //  This sort here is good, and Imma gonna let you finish, but I just wanted to say that it won't properly handle numbers
//    //    return [[a start_stop_name] compare: [b start_stop_name]];
//    
//    // NSComparisonResult...  -1 is Ascending, 0 is Ordered same and 1 is Descending
//    
//    // a and b are PushObjects
//    
//    int aInt = [[a route_short_name] intValue];  // Returns 0 if the a does not begin with a valid number
//    int bInt = [[b route_short_name] intValue];  // Returns 0 if the b does not being with a valid numbe
//    
//    //    NSLog(@"a: %@, b: %@", a, b);
//    
//    if ( aInt && bInt )             // As long as both aInt and bInt aren't 0, they're integers and we want to do a simple numeric comparsion
//        return (NSComparisonResult)(aInt > bInt);         // Straight up, dead simple numeric comparsion here
//    else if ( aInt && !bInt )       // If aInt is an integer and b isn't make sure that a comes first;  steadyfast rule: Integers Before Strings
//        return (NSComparisonResult)-1;                  // This means, a in relationship to b should be above b, or they need to be layed out in ascending order (-1)
//    else if ( bInt && !aInt )       // But if bInt is the integer and a isn't, make sure that b comes first
//        return (NSComparisonResult)1;                   // This means, a in relationship to b should be below b, or they need to be layed out in descending order (1)
//    else
//        return [[a route_short_name] compare: [b route_short_name] ];  // If we got to this point, both a and b are strings and we just want a simple string comparison
//    
//    
//};

-(void) generateIndex
{
    
    _busSectionIndex  = [[NSMutableArray alloc] init];
    _busSectionTitle  = [[NSMutableArray alloc] init];
    
    NSString *lastChar = @"";
    NSString *newChar;
    NSInteger index = 0;
    NSInteger len = 1;
    
    for (RouteInfo *route in _tableData)
    {
        
        NSString *short_name = [route route_short_name];
        
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
            [_busSectionIndex addObject: [NSNumber numberWithInt:(int)index] ];
            
            //            NSLog(@"PNVC - title: %@, index: %d", newChar, index);
            
            lastChar = newChar;
        }
        index++;
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ( [[segue identifier] isEqualToString:@"BusViewSegue"] )
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RouteInfo *route = [_tableData objectAtIndex: indexPath.row];
        
        NewTrainViewViewController *tvvc = [segue destinationViewController];
//        [tvvc setViewType: [NSString stringWithFormat:@"Bus:%@", route.route_short_name] ];
        [tvvc setTravelMode: @"Bus"];
    
//        NSLog( @"%@", [self stringForRouteType:[ [route route_type] integerValue] ] );
        
        [tvvc setTitle: [NSString stringWithFormat:@"%@ %@",[self stringForRouteType:[ [route route_type] integerValue] ], route.route_short_name] ];
        
//        if ( [route.route_short_name isEqualToString:@"LUCYGO"] || [route.route_short_name isEqualToString:@"LUCYGR"] )
//        {
//            [route setRoute_short_name:@"LUCY"];
//        }
        
        [tvvc setRouteName: route.route_short_name];
        [tvvc setRouteType: route.route_type];
    }
    
}


-(NSString*) stringForRouteType: (NSInteger) routeType
{
    
    switch (routeType) {
        case 0:
            return @"Trolley";
            break;
        case 1:
            return @"Subway";
            break;
        case 2:
            return @"Rail";
            break;
        case 3:
            return @"Bus";
            break;
        case 4:
            return @"Ferry";
            break;
        case 5:
            return @"Cable Car";
            break;
        case 6:
            return @"Gondola";
            break;
        case 7:
            return @"Funicular";
            break;
        default:
            return nil;
            break;
    }
    
}


- (void)viewDidUnload
{
    
    [self setLblRouteName:nil];
    [self setLblTitleServiceHours:nil];
    [self setLblServiceHours:nil];
    
    [super viewDidUnload];
    
}

@end
