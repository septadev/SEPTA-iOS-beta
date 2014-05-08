

//  BusDisplayStopsViewController.m
//  iSEPTA
//
//  Created by septa on 11/2/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "BusDisplayStopsViewController.h"
#import "DisplayRouteModel.h"
#import "UITableViewStandardHeaderLabel.h"

//#import "ShowTimesViewController.h"
#import "StopNameData.h"

#import "DisplayStopTimesViewController.h"
#import "ScrollingTestViewController.h"

#import "FMDatabase.h"

//#define NSLog //

@interface BusDisplayStopsViewController ()

@end

@implementation BusDisplayStopsViewController
{
    DisplayRouteModel *stops;
    StopNameData *stopData;
    
//    NSMutableArray *_sectionIndex;
}


//@synthesize routeID;
//@synthesize routeName;
@synthesize routeData;


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
    NSLog(@"BDSVC -(void) viewDidLoad");
    [super viewDidLoad];
    
    [self setTitle: [NSString stringWithFormat:@"Route %@", routeData.current.route_short_name] ];
    
    [self initializeData];
    
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.btnToFrom setSelectedSegmentIndex:0];
    
//    [self.btnToFrom setBackgroundColor: [UIColor blackColor] ];
//    [self.btnToFrom setGestureRecognizers:[NSArray arrayWithObject: [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(segmentTapped:)] ] ];
//    [self.btnToFrom addTarget:self action:@selector(segmentTouched:) forControlEvents:UIControlEventTouchDown];
//   [self.btnToFrom addTarget:self action:@selector(segmentTouched:) forControlEvents:UIControlEventValueChanged];
    
//    [self.tableView setContentInset: UIEdgeInsetsMake(-44, 0, 0, 0)];
    [self.tableView setContentOffset:CGPointMake(0, self.searchBar.frame.size.height)];
    
	// Do any additional setup after loading the view.
}


-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"BDSVC -(void) viewWillAppear");
    
    [routeData.current setEnd_stop_id:0];
    [routeData.current setEnd_stop_name:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setBtnToFrom:nil];
    [self setTableView:nil];
    [self setSearchBar:nil];
    
    [self setView:nil];
    [super viewDidUnload];
}


-(void) initializeData
{
    if ( stopData == nil )
        stopData = [[StopNameData alloc] initWithDisplayedRouteData: routeData andDatabaseType:kDisplayedRouteDataUsingDBBus];
    
    [stopData setInboundOrOutbound: kStopNameOutboundSection];
    
    [self getBusRoutes];
}

-(void) configureSegmentedControl
{
    
    int numOfSegments = [self.btnToFrom numberOfSegments];
    int numOfDirection = [stopData numberOfDirections];
    
    
    if ( numOfSegments > numOfDirection )
    {
        // More segments than directions, remove segments
        // E.g. btnToFrom has 2 segments at index 0 and 1, but only contains 1 direction
        // toRemove starts at 1 but never reaches 2.  index 1 is the one we want removed
        // For 3 segments, 0,1 and 2 but only 1 direction is works at the same.  Start at 1 go to 2.
        for (int toRemove = numOfDirection; toRemove < numOfSegments; toRemove++)
        {
            [self.btnToFrom removeSegmentAtIndex:toRemove animated:NO];
        }
        
    }
    else if ( numOfSegments < numOfDirection )
    {
        // More directions than segments, add segments
        for (int toAdd = numOfSegments; toAdd < numOfSegments; toAdd++)
        {
            [self.btnToFrom insertSegmentWithTitle:[stopData directionForID:toAdd] atIndex:toAdd animated:NO];
        }
        
    }
    

    // As Goldlocks would say, it's just right!
    for (int index = 0; index < numOfDirection; index++)
    {
        [self.btnToFrom setTitle:[stopData directionForID:index] forSegmentAtIndex:index];
    }
    
        
//    }
//
//    for (int LCV = 0; LCV <= 1; LCV++)
//    {
//        
//        if ( LCV < numOfDirection )
//        {
//            [self.btnToFrom setTitle: [stopData directionForID:LCV] forSegmentAtIndex:LCV];
//        }
//        else
//        {
//            
//        }
//        
//    }
    
    [self resizeSegmentsToFitTitles];
}

-(void) resizeSegmentsToFitTitles
{
    
//    CGFloat totalWidths = 0;
//    NSUInteger nSegments = self.btnToFrom.subviews.count;
//    
//    UIView *aSegment = [self.btnToFrom.subviews objectAtIndex:0];
//    UIFont *theFont = nil;
    
    CGFloat smallestSize = 9999.0f;
    
    // Loop through all subviews, looking for UILabel
    for (UIView* segView in self.btnToFrom.subviews)
    {
        
        for (UILabel* aLabel in segView.subviews)
        {
            if ( [aLabel isKindOfClass:[UILabel class]])
            {
                NSLog(@"BDSVC - Width: %6.2f of text: %@", aLabel.frame.size.width, aLabel.text);
                NSString *text = aLabel.text;
                CGFloat pointSize = 0.0f;
                [text sizeWithFont:[UIFont boldSystemFontOfSize:15] minFontSize:5.0f actualFontSize:&pointSize forWidth:150 lineBreakMode:NSLineBreakByWordWrapping];
                [aLabel setFrame:CGRectMake(aLabel.frame.origin.x, aLabel.frame.origin.y, [[UIScreen mainScreen] bounds].size.width/2 - 10, aLabel.frame.size.height)];
//                [aLabel setNumberOfLines:1];
//                [aLabel setAdjustsFontSizeToFitWidth:YES];
                
                if ( pointSize < smallestSize )
                    smallestSize = pointSize;
//                UIFont *actualFont = [UIFont boldSystemFontOfSize:pointSize];
//                [aLabel setFont: actualFont];
//                [aLabel sizeToFit];
                NSLog(@"BDSVC - Width: %6.2f of text: %@", aLabel.frame.size.width, aLabel.text);
            }
        }
        
    }

    UIFont *font = [UIFont boldSystemFontOfSize: smallestSize];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:UITextAttributeFont];
    [self.btnToFrom setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    
    
//    for (UILabel* aLabel in aSegment.subviews)
//    {
//        if ( [aLabel isKindOfClass:[UILabel class]])
//        {
//            NSLog(@"Width: %6.2f of text: %@", aLabel.frame.size.width, aLabel.text);
//            [aLabel setFrame:CGRectMake(aLabel.frame.origin.x, aLabel.frame.origin.y, [[UIScreen mainScreen] bounds].size.width/2 - 10, aLabel.frame.size.height)];
//            [aLabel setNumberOfLines:1];
//            [aLabel setAdjustsFontSizeToFitWidth:YES];
//            theFont = aLabel.font;
//            break;
//        }  // if isKindOf UILabel
//    } // for UILabel loop
//    
//    for (NSUInteger i=0; i < nSegments; i++)
//    {
//        CGFloat textWidth = [[self.btnToFrom titleForSegmentAtIndex:i] sizeWithFont:theFont].width;
//        totalWidths += textWidth;
//        
//    }

//    CGFloat spaceWidth = self.btnToFrom.bounds.size.width - totalWidths;
//    
//    for (NSUInteger i=0; i < nSegments; i++)
//    {
//        CGFloat textWidth = [[self.btnToFrom titleForSegmentAtIndex:i] sizeWithFont: theFont].width;
//        CGFloat segWidth  = roundf(textWidth + (spaceWidth/nSegments));
//        [self.btnToFrom setWidth:segWidth forSegmentAtIndex:i];
//    }
    
}

-(void) getBusRoutes
{
    
    [stopData clear];  // Clears data in inbound and outbound arrays
    
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    NSString *queryStr;
    
    // Get all stop names for the selected route.  (AIR, CHE, CHW, ... )
    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] )
    {
        queryStr = @"SELECT DISTINCT route_ROUTE.direction_id, stops.stop_name, stops.stop_id FROM route_ROUTE JOIN stops ON route_ROUTE.stop_id=stops.stop_id ORDER BY stops.stop_name";
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"ROUTE" withString: routeData.current.route_short_name];
    }
    else if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        
        /* Rail needs to display the data in a different manner.
          For example: the Warminster line can continue on to AIR, PAO, CHW, ELW or WIL.
         Instead of having a to/to segmented control at the top, we'll skip over that
         and use a table index along the right side.  We'll create a section for each route
        
         */
        
        queryStr = @"SELECT stop_name, direction_id, stops.stop_id FROM route_ROUTE JOIN stop_times ON route_ROUTE.stop_times_uid=stop_times.uid JOIN stops ON stop_times.stop_id=stops.stop_id GROUP BY stops.stop_id, direction_id ORDER BY stop_name;";
        
        queryStr = [queryStr stringByReplacingOccurrencesOfString:@"ROUTE" withString: routeData.current.route_short_name];
        
    }
    else  // No travel mode set
    {
//        queryStr = @"";
        return;
    }
    
    // Debug:  print out the SQL statement to verify in SQLite
    NSLog(@"BDSVC - queryStr: %@", queryStr);
    

    FMResultSet *results = [database executeQuery: queryStr];
    if ( [database hadError] )  // Check for errors
    {
        
        int errorCode = [database lastErrorCode];
        NSString *errorMsg = [database lastErrorMessage];
        
        NSLog(@"BDSVC - query failure, code: %d, %@", errorCode, errorMsg);
        NSLog(@"BDSVC - query str: %@", queryStr);
        
        return;  // If an error occurred, there's nothing else to do but exit
        
    }
    
    
    while ( [results next] )  // Loop through all the results from the query
    {

        NSInteger direction_id = [results intForColumn:@"direction_id"];
        NSInteger stop_id      = [results intForColumn:@"stop_id"];
        
        NSString  *stop_name   = [results stringForColumn:@"stop_name"];

        
        RouteData *newData = [[RouteData alloc] init];
        [newData setStart_stop_name: stop_name];
        [newData setStart_stop_id: stop_id];
        [newData setRoute_id: routeData.current.route_id];
        [newData setRoute_short_name: routeData.current.route_short_name];
        [newData setDirection_id: direction_id];
            
        if ( direction_id == 0 )  // 0 is outbound, according to GTFS guidelines
        {
            [[stopData outbound] addObject: newData];
        }
        else if ( direction_id == 1 ) // 1 is inbound, according to GTFS guidelines
        {
            [[stopData inbound] addObject: newData];
        }
        
    } // while ( [results next] )
        

    
    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] )
    {
        
        queryStr = [NSString stringWithFormat:@"SELECT dircode, DirectionDescription FROM bus_stop_directions WHERE Route=\"%@\" ORDER BY dircode ASC", routeData.current.route_short_name];
        
        results = [database executeQuery: queryStr];
        if ( [database hadError] )  // Check for errors
        {
            
//            [[stopData directions] addObject:@"To "];
//            [[stopData directions] addObject:@"From "];
            
            int errorCode = [database lastErrorCode];
            NSString *errorMsg = [database lastErrorMessage];
            
            NSLog(@"BDSVC - query failure, code: %d, %@", errorCode, errorMsg);
            NSLog(@"BDSVC - query str: %@", queryStr);
            
            //return;  // If an error occurred, there's nothing else to do but exit
            
        }
        
        
        NSLog(@"BDSVC - queryStr: %@", queryStr);
        
        int numOfResults = 0;
        while ( [results next] )  // No error, loop through the results!
        {
            numOfResults++;
            NSString *direction_name = [results stringForColumn:@"DirectionDescription"];
            [[stopData directions] addObject: [NSString stringWithFormat:@"To %@", direction_name] ];
        }
    
        // TODO: Temporary fix for route 15B and its ilk
        if ( numOfResults == 0 )
        {
            [[stopData directions] addObject:@"To "];
            [[stopData directions] addObject:@"From "];
        }
        
        
    }  // if ( [self.travelMode isEqualToString:@"Bus"] )
    else if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        
//        queryStr = @"";
        [[stopData directions] addObject:[NSString stringWithFormat:@"To %@", routeData.current.route_short_name] ];
        [[stopData directions] addObject:[NSString stringWithFormat:@"From %@", routeData.current.route_short_name] ];
        
    }
    else
    {
        [[stopData directions] addObject:@"To Point A"];
        [[stopData directions] addObject:@"To Point B"];
    }

//    [stops setOutboundName: [stops directionForID:0] ];  // 0 is outbound travel, according to the GTF guidelines
//    [stops setInboundName : [stops directionForID:1] ];  // 1 is inbound travel, according to the GTFS guidelines
    
    [stopData sort];  // outbound name and inbound name are set inside sort.  Imagine that!
    
    [self configureSegmentedControl];

}


//-(NSString *) filePath
//{
//
//    NSString *databaseName;
//    
//    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] )
//        databaseName = @"SEPTAbus";
//    else if ( [self.travelMode isEqualToString:@"Rail"] )
//        databaseName = @"SEPTArail";
//    else
//        return nil;
//    
//    return [[NSBundle mainBundle] pathForResource:databaseName ofType:@"sqlite"];
//    
////    NSString *databaseName;
////    
////    if ( [[routeData current] database_type] == kDisplayedRouteDataUsingDBBus )
////        databaseName = @"SEPTAbus";
////    else if ( [[routeData current] database_type] == kDisplayedRouteDataUsingDBRail )
////        databaseName = @"SEPTArail";
////    else
////        return nil;
////    
////    return [[NSBundle mainBundle] pathForResource:databaseName ofType:@"sqlite"];
//    
//}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"BDSVC - didSelectRow/Section: %d/%d", indexPath.row, indexPath.section);
    [self performSegueWithIdentifier:@"DisplayStopTimesSegueIdentifier" sender:self];
//    [self performSegueWithIdentifier:@"TestSegueIdentifier" sender:self];
}


#pragma mark - UITableViewDataSource
// Required Methods
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  // Required method
{
    
//    NSLog(@"indexPath, row/section: %d/%d", indexPath.row, indexPath.section);
    
    static NSString *CellIdentifier = @"DisplayRouteViewIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell ==  nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
//    NSInteger segmentedIndex = [self.btnToFrom selectedSegmentIndex];
//    RouteData *myData = (RouteData*)[stops objectForIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:segmentedIndex] ];
//    RouteData *myData = [stopData objectWithIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:segmentedIndex]];
    RouteData *myData = [stopData objectWithIndexPath: indexPath];
    [[cell textLabel] setText: myData.start_stop_name];
    [[cell textLabel] setAdjustsFontSizeToFitWidth:YES];
    
    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  // Required method
{
//    NSLog(@"BDSVC - Number of Rows For Section: %d -> %d", section, [stops numberOfRowsForSection:section]);

//    NSInteger segmentedIndex = [self.btnToFrom selectedSegmentIndex];
//    NSLog(@"BDSVC - Number of Rows For Section: %d -> %d", section, [stopData numberOfRowsInSection:segmentedIndex]);
//    return [stops numberOfRowsForSection:segmentedIndex];
//    return [(DisplayedRouteData*)stopData numberOfRowsInSection:segmentedIndex];
    return [stopData numberOfRowsInSection];
    
}


// Optional Methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
//    NSLog(@"BDSVC - Number of Sections: %d", [stops numberOfSections] );
//    return [stops numberOfSections];
    
    NSLog(@"BDSVC - Number of Sections: %d", [stopData numberOfSections] );
    return [stopData numberOfSections];
    
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{

    if ( [self.travelMode isEqualToString:@"Rail"] || [self.travelMode isEqualToString:@"Trolley"] )
        return 0;
    
    NSInteger segmentedIndex = [self.btnToFrom selectedSegmentIndex];
//    NSInteger row = [stops getSectionForSection:segmentedIndex withIndex:index];
    
    NSInteger row = [stopData getSectionForSection:segmentedIndex withIndex:index];
    NSInteger section = [stopData numberOfSections] - 1;
    
    if ( section < 0 )
        section = 0;
    
    // TODO: This won't work with Favorites and Recently Viewed
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return -1;  // Yes, Virginia.  Keep this as -1 becaues we don't have multiple sections, which is what this method what designed for
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    
    if ( [self.travelMode isEqualToString:@"Rail"] || [self.travelMode isEqualToString:@"Trolley"] )
        return nil;
    
    NSInteger segmentIndex = [self.btnToFrom selectedSegmentIndex];
    return [stopData getSectionTitleForSection: segmentIndex];
    
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
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    NSLog(@"BDSVC - viewForHeaderInSection: %d", section);
////    UITableViewStandardHeaderLabel *label = [[UITableViewStandardHeaderLabel alloc] init];
//    UITableViewStandardHeaderLabel *label = [[UITableViewStandardHeaderLabel alloc] initWithFrame:CGRectMake(0, 0, 290, 0)];
////    [label setFrame: CGRectMake(label.frame.origin.x, label.frame.origin.y, 290, label.frame.size.height)];
//    
////    [label setText: [stops directionForID:section ] ];
////    NSInteger segmentedIndex = [self.btnToFrom selectedSegmentIndex];
////    [label setText: [stops nameForSection:segmentedIndex] ];  // nameForSections handles Favorites, Recently Views, Inbound and Outbound headers
//    [label setText: [stopData nameForSection: section] ];
//    [label setFont: [UIFont boldSystemFontOfSize:20] ];
//    [label setTextColor: [UIColor whiteColor] ];
//    [label setOpaque:NO];
//    
//    [label setNumberOfLines:1];
//    [label setAdjustsFontSizeToFitWidth:YES];
//    
//    return label;
//    
//}


// - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
// - (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
// - (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
// - (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath

// - (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
// - (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
// - (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
// - (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath

// - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
// - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
// - (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
// - (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath

// - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
// - (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
// - (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
// - (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath


#pragma mark - Segment Control
- (IBAction)segmentChanged:(id)sender
{
//    NSLog(@"BDSVC - Segmented control was changed: %d", [self.btnToFrom selectedSegmentIndex] );
    NSLog(@"BDSVC - Segmented control was changed: %d", [(TapableSegmentControl*)sender selectedSegmentIndex] );
        
    NSInteger index = [(TapableSegmentControl*)sender selectedSegmentIndex];
    if ( index == 0 )  // Outbound
        [stopData setInboundOrOutbound:NO];
    else
        [stopData setInboundOrOutbound:YES];
    
    [self segmentSelectedForIndex: index];
//    [self.tableView reloadSectionIndexTitles];
    [self.tableView reloadData];
    
    if ( [stopData numberOfRowsInSection:index] > 0 )
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}


//- (IBAction)segmentTouched:(id)sender
//{
//    
//    NSLog(@"BDSVC -(IBAction) segmentTouched:(id)sender");
//    NSInteger index = [(TapableSegmentControl*)sender selectedSegmentIndex];
//    [self segmentSelectedForIndex: index];
//
//}


//-(void) segmentTapped:(UITapGestureRecognizer *) recognizer
//{
//    
//    return;
//    
//    CGPoint location = [recognizer locationInView:self.view];
//    NSLog(@"Segment was tapped at (%6.2f, %6.2f)", location.x, location.y);
//    
//    
//    [self segmentSelectedForIndex: [self.btnToFrom selectedSegmentIndex] ];
//}


-(void) segmentSelectedForIndex:(NSInteger) index
{
    
//    NSInteger numOfSections = [stops numberOfSections];
    NSInteger numOfSections = [stopData numberOfSections];
//    NSInteger startSection = 0;
//    NSInteger endSection   = 0;  // Was 1
    
    switch (numOfSections) {
        case 2:
            // No change
            break;
        case 3:
        case 4:
//            startSection = numOfSections-2;
//            endSection   = numOfSections-2;  // Was -1
        default:
            break;
    }
    
    
//    if (index == 0)
//    {
        // Jump to the top of the first section
    
//        [self.tableView selectRowAtIndexPath:   [NSIndexPath indexPathForRow:0 inSection:startSection] animated:YES scrollPosition:UITableViewScrollPositionTop];
//        [self.tableView deselectRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:startSection] animated:NO];
    
    
//    }
//    else if ( index == 1 )
//    {
//        if ( [stops numberOfDirections] == 1 )
//        {
//            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[stops numberOfOutboundRows]-1 inSection:startSection] animated:YES scrollPosition:UITableViewScrollPositionBottom];
//            [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:[stops numberOfOutboundRows]-1 inSection:startSection] animated:YES];
//        }
//        else
//        {
//            [self.tableView selectRowAtIndexPath:   [NSIndexPath indexPathForRow:0 inSection:endSection] animated:YES scrollPosition:UITableViewScrollPositionTop];
//            [self.tableView deselectRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:endSection] animated:NO];
//        }
//    }
//    else if ( index == UISegmentedControlNoSegment)
//    {
//        NSLog(@"No option for : %d", index);  // Deselected segment
//    }
    
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"BDSVC - searchBar searchText: %@", searchText);
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"BDSVC - searchBar cancel button clicked");
    [[self searchBar] resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"BDSVC - searchBar search button clicked");
    [[self searchBar] resignFirstResponder];
}



// Optional Methods
    // - (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
// - (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
    // - (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
// - (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar

    // - (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
// - (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
// - (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
// - (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar

// - (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
// - (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
// - (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    //        RouteData *myData = [stops objectForIndexPath:path];
    RouteData *myData = [stopData objectWithIndexPath:path];
    
    //        StopNameData *newData = (StopNameData*)routeData;
    
    [routeData.current setDirection_id   : myData.direction_id   ];
    [routeData.current setStart_stop_id  : myData.start_stop_id  ];
    [routeData.current setStart_stop_name: myData.start_stop_name];
    
    //        NSMutableDictionary *dict = [stops objectForIndexPath:path];
    //        [routeData.current setDirection_id: path.section];
    //        [routeData.current setStart_stop_id: [[dict objectForKey:@"stop_id"] intValue] ];
    //        [routeData.current setStart_stop_name: [dict objectForKey:@"stop_name"] ];
    
    
    if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        NSString *title;
        if ( routeData.current.direction_id == 0 )
            title = [NSString stringWithFormat:@"To %@", routeData.current.route_short_name];
        //            [[[self navigationItem] backBarButtonItem] setTitle:[NSString stringWithFormat:@"To %@", routeData.current.route_short_name] ];
        else if ( routeData.current.direction_id == 1 )
            title = [NSString stringWithFormat:@"From %@", routeData.current.route_short_name];
        //            [[[self navigationItem] backBarButtonItem] setTitle:[NSString stringWithFormat:@"From %@", routeData.current.route_short_name] ];
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:nil action:nil];
        
    }
    

    if ( [[segue identifier] isEqualToString:@"ShowTimesSegueIdentifier"] )
    {
        NSLog(@"BDSVC - YOU SHOULD NEVER SEE THIS LINE!");
//        ShowTimesViewController *showVC = [segue destinationViewController];
//        [showVC setRouteData: routeData];
    }
    else if ( [[segue identifier] isEqualToString:@"DisplayStopTimesSegueIdentifier"] )
    {
        DisplayStopTimesViewController *stopVC = [segue destinationViewController];
        [stopVC setTravelMode: self.travelMode];
        [stopVC setRouteData: routeData];
    }
    
    
}


@end
