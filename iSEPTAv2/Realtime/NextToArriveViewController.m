//
//  NextToArriveViewController.m
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "NextToArriveViewController.h"

//#import "UITableViewStandardHeaderLabel.h"

// Custom Cells
#import "NTAConnectionCell.h"
#import "NTASingleCell.h"
#import "NTASaveObjectCell.h"




// Custom Data Objects
#import "ShowTimesModel.h"
#import "TripData.h"

#import "StopNamesObject.h"
#import "NextToArrivaJSONObject.h"
#import "ItineraryObject.h"
#import "TableDataController.h"
#import "NTASaveController.h"
#import "NTASaveObject.h"


// POD Libraries
#import "FMDatabase.h"
#import "SVProgressHUD.h"
#import "REMenu.h"
#import "TSMessage.h"
#import "DMRNotificationView.h"


#define JSON_REFRESH_RATE 20.0f
#define DEFAULT_MESSAGE @"Click to enter destination"


#define REFRESH_NO_STOPS @"select trips before refreshing"
#define REFRESH_READY    @"click to refresh data"
#define REFRESH_IN_UNKNOWN @"refreshing in..."
#define REFRESH_IN_X_SECS  @"refreshing in X seconds"
#define REFRESH_NOW        @"refreshing now"


@interface NextToArriveViewController ()

@end


@implementation NextToArriveViewController
{

//    NSString *_startStopName;
//    NSString *_endStopName;

    // --==  This dictionary is the quick lookup hash for replacing one the correct, GTFS approved, station name with one that SEPTA's internal DBs will recognize.  *Insert face palm here*
    NSMutableDictionary *replacement;
    
//    UITapGestureRecognizer *editEndTap;
//    UITapGestureRecognizer *editStartTap;
    
    NSTimer *menuRefreshTimer;
    NSTimer *updateTimer;
    BOOL _stillWaitingOnWebRequest;
    BOOL _launchUpdateTimer;
    BOOL _killAllTimers;
    
    
    NextToArriveLeftButtonPressed _whichLeftButton;
    
//    TableDataController *_tData;
    NTASaveController *saveData;
    
    char _buttonPressed;
    
    NSOperationQueue *_jsonQueue;
    NSBlockOperation *_jsonOp;
    
    NSMutableArray *_tableData;

    
    //
    //  --==  VC is broken into 4 sections:
    //  --==    Section 0 - IternaryCell
    //  --==    Section 1 - Favorites
    //  --==    Section 2 - RecentlyViewed
    //  --==    Section 3 - NTASingleCell/NTAConnectionCell
    //
    
    ItineraryObject *itinerarySection;
    NSMutableArray  *favoritesSection;
    NSMutableArray  *recentlyViewedSection;
    NSMutableArray  *ntaDataSection;
    
    
    // REMenu
    REMenu *_menu;
    
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
    
    // --==  Initialize two of the four section handlers here
    itinerarySection = [[ItineraryObject alloc] init];
    ntaDataSection   = [[NSMutableArray  alloc] init];
    
    [itinerarySection setStartStopName: DEFAULT_MESSAGE];
    [itinerarySection setEndStopName  : DEFAULT_MESSAGE];
    
//    _tData = [[TableDataController alloc] init];
    
    
    // --==  Create the NSOperationQueue to allow for cancelling
    _jsonQueue  = [[NSOperationQueue alloc] init];

    
    _launchUpdateTimer = NO;
    _killAllTimers     = NO;
    
    
//    editEndTap   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editLocation:)];  // This gesture is added to the end cell when it is created in cellForIndexPath...
//    [editEndTap setDelegate:self];
//    //
//    editStartTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editLocation:)];  // This gesture is added to the start cell when it is created in cellForIndexPath...
//    [editStartTap setDelegate:self];
    
    
    [self.segmentRouteType setSelectedSegmentIndex:1];  // Set it permenantly to Rails while Segement remains hidden
    
    
//    _startStopName = DEFAULT_MESSAGE;   // Quick access to the startStopName stored in _tData[0,0]
//    _endStopName   = DEFAULT_MESSAGE;   // Quick access to the endStopName stored in _tData[0,0]
    
    _buttonPressed = kNextToArriveNoButtonPressed;
    
    // Set the default start/end cell message
//    NSMutableArray *selection = [NSMutableArray arrayWithObjects:_startStopName, _endStopName, nil];
//    [_tData addName:@"StartEndCells" toSection: kNextToArriveSectionStartEndCells];
//    [_tData addObject: selection toSection: kNextToArriveSectionStartEndCells];
    
    
    // Load Favorites and Recent from the Save Controller
    saveData = [[NTASaveController alloc] init];
    favoritesSection      = [saveData favorites];
    recentlyViewedSection = [saveData recent];
    
    
    // Populate _tData with the saved data, even if it's just an empyt array
//    [_tData addName:@"Favorites" toSection: kNextToArriveSectionFavorites];
//    [_tData addObject: [saveData favorites] toSection: kNextToArriveSectionFavorites];
//    
//    [_tData addName:@"Recent" toSection: kNextToArriveSectionRecent];
//    [_tData addObject: [saveData recent] toSection: kNextToArriveSectionRecent];

    
    _whichLeftButton = kNextToArriveNoButtonPressed;
//    _tableData = [[NSMutableArray alloc] init];
    
    
    // Used in [self fixMismatchedStopName].  Key: GTFS-compliant station name, value: NTA recognized equivalent station name.
    // To any developer reading this, I'm sorry for this blight but there needs to be some glue logic to connect a GTFS stop name
    // to the names stored in the legacy database that the API uses.
    // TODO:  Change the *#@!ing NTA API to recognize these translations!
    replacement = [[NSMutableDictionary alloc] init];

    [replacement setObject:@"Norristown TC"         forKey:@"Norristown T.C."];
    [replacement setObject:@"Temple U"              forKey:@"Temple University"];
    [replacement setObject:@"Elm St"                forKey:@"Norristown"];
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
    [replacement setObject:@"Elwyn Station"         forKey:@"Elywn"];
    [replacement setObject:@"Eastwick Station"      forKey:@"Eastwick"];
    
    [replacement setObject:@"Churchmans Crossing"   forKey:@"Churchman's Crossing"];
    [replacement setObject:@"Chester TC"            forKey:@"Chester"];
    [replacement setObject:@"Airport Terminal E-F"  forKey:@"Airport Terminal E F"];
    [replacement setObject:@"Airport Terminal C-D"  forKey:@"Airport Terminal C D"];
    
    [replacement setObject:@"North Philadelphia"    forKey:@"North Philadelphia Amtrak"];
    [replacement setObject:@"Prospect Park"         forKey:@"Prospect Park - Moore"];
    [replacement setObject:@"Wayne Station"         forKey:@"Wayne"];
    [replacement setObject:@"Wayne Jct"             forKey:@"Wayne Junction"];

    
//    __typeof (&*self) __weak weakSelf = self;
    
    REMenuItem *refreshItem = [[REMenuItem alloc] initWithTitle:@"Refresh"
                                                   subtitle:@"select trip before refreshing"
                                                      image:[UIImage imageNamed:@"limitIcon"]
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self refreshJSONData];
                                                     }];

    REMenuItem *favoritesItem = [[REMenuItem alloc] initWithTitle:@"Favorite"
                                                   subtitle:@"add route to favorites"
                                                      image:[UIImage imageNamed:@"limitIcon"]
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self selectedFavorites];
                                                     }];

    REMenuItem *filterItem = [[REMenuItem alloc] initWithTitle:@"Filter"
                                                   subtitle:@"select filter options"
                                                      image:[UIImage imageNamed:@"limitIcon"]
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         [self showTSMessage];
                                                     }];

    REMenuItem *settingsItem = [[REMenuItem alloc] initWithTitle:@"Settings"
                                                   subtitle:@"change settings"
                                                      image:[UIImage imageNamed:@"limitIcon"]
                                           highlightedImage:nil
                                                     action:^(REMenuItem *item) {
                                                         
                                                     }];

    
    
    _menu = [[REMenu alloc] initWithItems:@[refreshItem, favoritesItem, filterItem, settingsItem] ];
    _menu.cornerRadius = 4;
    _menu.shadowRadius = 4;
    _menu.shadowColor = [UIColor blackColor];
    _menu.shadowOffset = CGSizeMake(0, 1);
    _menu.shadowOpacity = 1;
    _menu.imageOffset = CGSizeMake(5, -1);
    _menu.waitUntilAnimationIsComplete = NO;

    
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
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
    
    NSLog(@"NtAVC - (void) viewDidDisappear");
    _killAllTimers = YES;
    
    if ( [SVProgressHUD isVisible] )
        [SVProgressHUD dismiss];
    
//    NSLog(@"NTA -1");
    [_jsonQueue cancelAllOperations];

//    NSLog(@"NTA -2");
    [saveData save];
    
//    NSLog(@"NTA -3");
    _launchUpdateTimer = NO;
    [self invalidateTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"NtAVC - didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.
    
//    editEndTap   = nil;
//    editStartTap = nil;
    
//    _tableData   = nil;
//    _tData       = nil;
    
    _jsonQueue  = nil;
    _jsonOp     = nil;
    
    saveData     = nil;
    
}

- (void)viewDidUnload
{

    NSLog(@"NtAVC -(void) viewDidUnload");
    
    [self setSegmentRouteType:nil];
    [self setTableView       :nil];
    [self setBtnRetrieveData :nil];
    
    [self setGestureLongPress:nil];
    [self setGestureDoubleTap:nil];
    [super viewDidUnload];
    
}

// iOS5
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

// iOS6
/*
 -(NSUInteger)supportedInterfaceOrientations
 {
   return UIIntegerfaceOrientationMaskAll;
 }
 
 -(BOOL)shouldAutorotate
 {
   return YES;
 }
 
 */


-(void) invalidateTimer
{
    
//    NSLog(@"NTA -(void) invalidateTimer, updateTimer: %p", updateTimer);
    
    if ( updateTimer != nil )
    {
//        NSLog(@"NTA -(void) invalidateTimer, about to check if updateTimer isValid");
        if ( [updateTimer isValid]  )
        {
//            NSLog(@"NTAVC -(void) invalidateTimer, about to invalidate updateTimer");
            
            REMenuItem *refreshItem = [[_menu items] objectAtIndex:0];
            [refreshItem setSubtitle:@"click to refresh"];
            
            [updateTimer invalidate];
            updateTimer = nil;
        }
    }
    else
    {
        NSLog(@"NtAVC -  Trying to send messages to updateTimer which no longer exists.");
    }
    
}

#pragma mark - UITableViewDataSource
#pragma mark - UITableViewDelegate

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        
        if ( indexPath.section == kNextToArriveSectionStartEndCells)
        {
            
            // Stop the timer
            [self invalidateTimer];
            
            // No buttons are pressed
            _buttonPressed = kNextToArriveNoButtonPressed;
            
            [itinerarySection clearStops];
            [itinerarySection setStartStopName:DEFAULT_MESSAGE];
            [itinerarySection setEndStopName  :DEFAULT_MESSAGE];
            
            [self updateRefreshStatusWith:kNextToArriveRefreshStatusNoStops];
            
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            return;
        }
        
        
        [tableView beginUpdates];
        
        switch (indexPath.section)
        {
            case kNextToArriveSectionFavorites:  // Favorites
                [favoritesSection removeObjectAtIndex: indexPath.row];
                
                break;
            case kNextToArriveSectionRecent:
                [recentlyViewedSection removeObjectAtIndex:indexPath.row];
                
                break;
//            case 3:
//                [ntaDataSection removeObjectAtIndex: indexPath.row];
//                break;
            default:
                // Don't remove a thing!
                break;
        }
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
        [tableView reloadData];
        
        
        // kNextToArriveSectionFavorites is not the same as kNTASectionFavorites, nor should they be
        // kNexToArriveSectionXXX is specific to this class, and more can be added or removed
        // Whereas kNTASectionFavorites means something very specific to NTASaveController.
        // There is no guarantee these two values will be the same, or will stay the same in the future
        // Say, if some enterprising programmer decides to switch things around.  Hello Still Working App!
        // These if statements provide the proper translation between the values used here and the
        // the values used in NTASaveController
//        if ( indexPath.section == kNextToArriveSectionFavorites )
//        {
//            [saveData removeObject:sObject fromSection:kNTASectionFavorites];
//        }
//        else if ( indexPath.section == kNextToArriveSectionRecent)
//        {
//            [saveData removeObject:sObject fromSection:kNTASectionRecentlyViewed];
//        }

        
        if ( indexPath.section == kNextToArriveSectionFavorites )
        {
            [saveData makeSectionDirty:kNTASectionRecentlyViewed];
        }
        else if ( indexPath.section == kNextToArriveSectionRecent )
        {
            [saveData makeSectionDirty:kNTASectionRecentlyViewed];
        }

        
    }

//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        
//        NSInteger numberOfRows = [_routeData numberOfRowsInSection:indexPath.section];
//        
//        [tableView beginUpdates];
//        [_routeData removeObjectWithIndexPath: indexPath];
//        //        [_routeData.recentlyViewed removeObjectAtIndex: indexPath.row];
//        
//        if ( numberOfRows != 1 )
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        else
//            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
//        
//        [tableView endUpdates];
//        [_routeData updateSectionCountForSection:kDisplayedRouteDataRecentlyViewed];
//        [tableView reloadData];
//    }
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ( indexPath.section == kNextToArriveSectionStartEndCells )
    {
        return YES;
    }
    if ( indexPath.section == kNextToArriveSectionFavorites )
    {
        return YES;
    }
    else if ( indexPath.section == kNextToArriveSectionRecent )
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    
    // Return NO if you do not want the specified item to be editable.
    //    NSInteger section = indexPath.section;
    
//    NSInteger section = [_routeData sectionForIndexPath: indexPath];
//    if ( section == kDisplayedRouteDataRoutes )
//        return NO;
//    else
//        return YES;
    
}



- (void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id sectionArray = nil;
    
    if ( indexPath.section == kNextToArriveSectionRecent)
    {
        sectionArray = recentlyViewedSection;
    }
    else if ( indexPath.section == kNextToArriveSectionFavorites )
    {
        sectionArray = favoritesSection;
    }
//    else if ( indexPath.section == kNextToArriveSectionData )
//    {
//    }
    
    
    if ( sectionArray != nil )
    {
        
        NTASaveObject *sObject = [sectionArray objectAtIndex:indexPath.row];

        [itinerarySection setStartStopName: [sObject startStopName] ];
        [itinerarySection setEndStopName  : [sObject endStopName  ] ];
        
        [sObject setAddedDate:[NSDate date] ];

        if ( indexPath.section == kNextToArriveSectionRecent)
            [saveData makeSectionDirty:kNTASectionRecentlyViewed];
        else if ( indexPath.section == kNextToArriveSectionFavorites)
            [saveData makeSectionDirty:kNTASectionFavorites];

        [sectionArray sortUsingComparator: sortNTASaveObjectByDate];

        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kNextToArriveSectionStartEndCells] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        _buttonPressed = 0x03;
        
        if ( indexPath.row != 0 )
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self highlightRetrieveButton];
        
    }
        
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    switch (section)
    {
        case kNextToArriveSectionFavorites:
            
            if ( [favoritesSection count] > 0 )
            {
                return @"Favorites";
            }
            
            break;
        case kNextToArriveSectionRecent:
            
            if ( [recentlyViewedSection count] > 0 )
            {
                return @"Recent";
            }
            
            break;
            
        case kNextToArriveSectionData:
            return @"Next To Arrive Trains";
            break;
        default:
            return nil;
            break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    switch (indexPath.section) {
        case kNextToArriveSectionStartEndCells:
            return 72.0f;
            break;
        case kNextToArriveSectionRecent:

            if ( [recentlyViewedSection count] == 0 )
                return 0.0f;
            else
                return 44.0f;
            
            break;
        case kNextToArriveSectionFavorites:
            
            if ( [favoritesSection count] == 0 )
                return 0.0f;
            else
                return 44.0f;
            
            break;
        case kNextToArriveSectionData:
            
            if ( [[ntaDataSection objectAtIndex:indexPath.row] Connection] == nil )
            {
                return 44.0f;
            }
            else
            {
                return 118.0f;
            }
            
            break;
        default:
            return 44.0f;
            break;
    }
    
    
//    NSString *headerName = [_tData nameForSection:indexPath.section];
    
    
//    if ( [headerName isEqualToString:@"StartEndCells"] )
//    {
//        return 44.0f;
//    }
//    else if ( [headerName isEqualToString:@"Favorites"] )
//    {
//        return 44.0f;
//    }
//    else if ( [headerName isEqualToString:@"Recent"] )
//    {
//        return 44.0f;
//    }
//    else
//    {
//        
////        NextToArrivaJSONObject *ntaObject = [_tableData objectAtIndex:indexPath.row-2];
//        NextToArrivaJSONObject *ntaObject = [_tData returnObjectAtIndexPath:indexPath];
//        
//        if ( [ntaObject Connection] == nil )
//        {
//            return 44.0f;
//        }
//        else
//        {
//            return 118.0f;
//        }
//        
//    }
    
    
//    if ( [_tableData count]+2 <= indexPath.row )
//        return 44.0f;
//    
//    if ( (indexPath.row == 0) || (indexPath.row == 1) )
//        return 44.0f;
//    
//    NextToArrivaJSONObject *ntaObject = [_tableData objectAtIndex:indexPath.row-2];
//    if ( [ntaObject Connection] == nil )
//    {
//        return 44.0f;
//    }
//    else
//    {
//        return 118.0f;
//    }
    
}


//-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    
//    if ( ( section == 0 ) || ( [_tData numberOfRowsInSection:section] == 0 ) )
//        return 0.0f;
//    else
//        return 22.0f;
//    
//}


//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
////    if ( [_showTimes numberOfSections] == 1 )  // Why do this?
////    {
////        //        self.tableView.tableHeaderView = nil;
////        //        [self.tableView reloadData];
////        return nil;
////    }
////    else
////    {
//    
//    if ( section > 0 )  // First section consists of the start and end cells
//    {
//    
//        UITableViewStandardHeaderLabel *label = [[UITableViewStandardHeaderLabel alloc] init];
//        
//        [label setText: [_tData nameForSection:section] ];
//        [label setFont: [UIFont boldSystemFontOfSize:20] ];
//        [label setTextColor: [UIColor whiteColor] ];
//        [label setOpaque:NO];
//        
//        [label setNumberOfLines:1];
//        [label setAdjustsFontSizeToFitWidth:YES];
//        
//        return label;
//    }
//    else
//        return nil;
//    
//}



-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
//    NSLog(@"NTAVC - # of sections: %d", [_tData numberOfSections] );
//    return [_tData numberOfSections];
//    return 1;  // Table only has one section, segmented control switches between data sources
    
    return 4;  // As described somewhere up above, there are 4 sections: Itinerary, Favorites, Recent and Data.  No more, no less!
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [_tableData count] + 2;  // Plus 2 for the Start and End cell
//    NSLog(@"NTAVC -  # of rows :%d in section: %d", [_tData numberOfRowsInSection:section], section);
//    return [_tData numberOfRowsInSection:section];
    
    // No just because there are 4 sections does not main each section needs to be displayed
    
    switch (section) {
        case kNextToArriveSectionStartEndCells:
            return 1;  // There always needs to be this ItineraryCell to accept user input
            break;
        case kNextToArriveSectionFavorites:
            return [favoritesSection count];
            break;
        case kNextToArriveSectionRecent:
            return [recentlyViewedSection count];
            break;
        case kNextToArriveSectionData:
            return [ntaDataSection count];
            break;
        default:
            return 0;
            break;
    }
    
    
}


- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *startCellIdentifier      = @"ItineraryCell";
    static NSString *displayCellIdentifier    = @"NTAResultIdentifer";
    static NSString *saveObjectCellIdentifier = @"SaveObjectCell";
    
    
    if ( indexPath.section == kNextToArriveSectionStartEndCells )
    {
        
        ItineraryCell *cell = (ItineraryCell*)[self.tableView dequeueReusableCellWithIdentifier:startCellIdentifier];
        
        if ( ( cell ==  nil ) || ( ![cell isKindOfClass:[ItineraryCell class] ] ) )
        {
            cell = [[ItineraryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:startCellIdentifier];
        }
        
        
        if ( itinerarySection.startStopName != nil )
        {
            [[cell btnStartStopName] setTitle:itinerarySection.startStopName forState:UIControlStateNormal];
            [[cell btnStartStopName] setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        }
        
        if ( itinerarySection.endStopName != nil )
        {
            [[cell btnEndStopName] setTitle:itinerarySection.endStopName   forState:UIControlStateNormal];
            [[cell btnEndStopName] setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        }
        
        [cell setDelegate:self];
        
        return cell;
        
    } // if ( indexPath.section == kNextToArriveSectionStartEndCells )
    else if ( indexPath.section == kNextToArriveSectionFavorites )
    {
        
        NTASaveObjectCell *cell = [self.tableView dequeueReusableCellWithIdentifier:saveObjectCellIdentifier];
        if ( cell == nil )
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NTASaveObjectCell" owner:self options:nil];
            cell = (NTASaveObjectCell*)[nib objectAtIndex:0];
        }
        
        NTASaveObject *favorite = [favoritesSection objectAtIndex:indexPath.row];
        
        [[cell lblStartName] setText: [favorite startStopName] ];
        [[cell lblEndName]   setText: [favorite endStopName  ] ];
        
        return cell;
        
    } // else if ( indexPath.section == kNextToArriveSectionFavorites )
    else if ( indexPath.section == kNextToArriveSectionRecent )
    {
        
        NTASaveObjectCell *cell = [self.tableView dequeueReusableCellWithIdentifier:saveObjectCellIdentifier];
        if ( cell == nil )
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NTASaveObjectCell" owner:self options:nil];
            cell = (NTASaveObjectCell*)[nib objectAtIndex:0];
        }
        
        NTASaveObject *recent = [recentlyViewedSection objectAtIndex:indexPath.row];
        
        [[cell lblStartName] setText: [recent startStopName] ];
        [[cell lblEndName]   setText: [recent endStopName  ] ];
        
        return cell;
        
    } // else if ( indexPath.section == kNextToArriveSectionRecent )
    else if ( indexPath.section == kNextToArriveSectionData )
    {
        
        id cell = [self.tableView dequeueReusableCellWithIdentifier:displayCellIdentifier];
        
        NextToArrivaJSONObject *ntaObject = [ntaDataSection objectAtIndex: indexPath.row];
        
        if ( [ntaObject Connection] == nil )
        {
            if ( cell == nil )
            {
                // Use NTASingleCell
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NTASingleCell" owner:self options:nil];
                cell = (NTASingleCell*)[nib objectAtIndex:0];
            }
        }
        else
        {
            if ( cell == nil )
            {
                // Use NTAConnectionCell
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NTAConnectionCell" owner:self options:nil];
                cell = (NTAConnectionCell*)[nib objectAtIndex:0];
            }
        }
        
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_line.png"]];
        UITableViewCell *newCell = (UITableViewCell*)cell;
        [newCell.contentView addSubview: separator];
        
//        [[(UITableViewCell*) cell].contentView addSubview: separator];
        

//        [cell.contentView addSubview: separator];
        

        
        
        
        [cell addObjectToCell: ntaObject];
        return cell;
        
    }  // else if ( indexPath.section == kNextToArriveSectionData )
        

    
    

    
    id cell = [self.tableView dequeueReusableCellWithIdentifier:displayCellIdentifier];
    return cell;
    
//
//        NextToArrivaJSONObject *ntaObject = [[_tData returnObjectFromSection: indexPath.section] objectAtIndex: indexPath.row];
//    
//        if ( [ntaObject Connection] == nil )
//        {
//            if ( cell == nil )
//            {
//                // Use NTASingleCell
//                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NTASingleCell" owner:self options:nil];
//                cell = (NTASingleCell*)[nib objectAtIndex:0];
//            }
//        }
//        else
//        {
//            if ( cell == nil )
//            {
//                // Use NTAConnectionCell
//                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NTAConnectionCell" owner:self options:nil];
//                cell = (NTAConnectionCell*)[nib objectAtIndex:0];
//            }
//        }
//        
//        [cell addObjectToCell: ntaObject];
//        
////        NTAResultsCell *cell = [thisTableView dequeueReusableCellWithIdentifier:displayCellIdentifier];
////        if ( cell == nil )
////            cell = [[NTAResultsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:displayCellIdentifier];
//        
//        
////        NextToArrivaJSONObject *ntaObject = [_tableData objectAtIndex: indexPath.row-2];  // Because added +2 for the start and end cell
////        [cell addObjectToCell: ntaObject];
//        
////        NSLog(@"ntaObject: %@", ntaObject);
////        [[cell textLabel] setText:[NSString stringWithFormat:@"%@ - %@->%@, %@", ntaObject.orig_train, ntaObject.orig_departure_time, ntaObject.orig_arrival_time, ntaObject.orig_delay] ];
//        
//        NSLog(@"row: %d - ntaObject: %@", indexPath.row, ntaObject);
//        
//        return cell;
    
//    }
    
    
}

- (IBAction)segmentRouteTypeChanged:(id)sender
{
    NSLog(@"NtAVC -  index changed");
    int index = [self.segmentRouteType selectedSegmentIndex];
    
    if ( index == 0 )
    {
        // Bus selected
        // There are 13352 stops for the buses, let's skip this for now
//        [_showTimes clearData];
        [self.tableView reloadData];
    }
    else if ( index == 1 )
    {
        // Rails selected
        // There are only 152 stops for rails
//        [self getRailStopNames];
//        [self.tableView reloadData];
    }
    
}

-(void) getRailStopNames
{
    
//    [_showTimes clearData];
//    
//    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
//    
//    if ( ![database open] )
//    {
//        [database close];
//        return;
//    }
//    
//    
//    NSString *queryStr = @"SELECT * FROM stops";
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
//    }
//    
//    while ( [results next] )
//    {
//    
//        NSString *stop_name = [results stringForColumn:@"stop_name"];
//        NSInteger stop_id  = [results intForColumn:@"stop_id"];
//        
//        TripData *trip = [[TripData alloc] init];
//        [trip setStart_stop_name: stop_name];
//        [trip setStart_stop_id: [NSNumber numberWithInt:stop_id] ];
//        
//        [_showTimes addTimes:trip];
//        
//    }
//    
//    [_showTimes sort];
    
}

-(NSString*) filePath
{
    NSString *databaseName;

    // Only supporting rails for now
    
//    if ( [self.travelMode isEqualToString:@"Bus"] || [self.travelMode isEqualToString:@"MFL"] || [self.travelMode isEqualToString:@"BSS"] || [self.travelMode isEqualToString:@"NHSL"] )
//        databaseName = @"SEPTAbus";
//    else if ( [self.travelMode isEqualToString:@"Rail"] )
        databaseName = @"SEPTArail";
//    else
//        return nil;
    
    return [[NSBundle mainBundle] pathForResource:databaseName ofType:@"sqlite"];
}


#pragma mark -
#pragma mark ItineraryCellProtocol

-(void) flipStopNamesButtonTapped
{
    
    NSLog(@"NtAVC -  flipStopNamesButtonPressed");

    [itinerarySection flipStops];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:kNextToArriveSectionStartEndCells] withRowAnimation:UITableViewRowAnimationAutomatic];    
    
}


-(void) getStopNamesButtonTapped:(NSInteger)startEND
{
    
    NSLog(@"NtAVC -  getStopNamesButtonPressed");
    if ( startEND == 1 )
        _whichLeftButton = kNextToArriveStartButtonPressed;
    else
        _whichLeftButton = kNextToArriveEndButtonPressed;
    
    [self performSegueWithIdentifier:@"StopNamesSegue" sender:self];
    
}

//-(void) editLocation:(UITapGestureRecognizer*) recognizer
//{
//    NSLog(@"NTAVC - editLocation");
//    
//    if ( recognizer == editStartTap )
//    {
//        NSLog(@"NTAVC - Edit new start point");
//        StopTimesCell *thisCell = (StopTimesCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
////        [thisCell.btnGetStopNames sendActionsForControlEvents:UIControlEventTouchUpInside];  // In Storyboard, the button press triggers the transition to FindLocationVC.  This simulates a button press to the same affect
//    }
//    else if ( recognizer == editEndTap )
//    {
//        NSLog(@"NTAVC - Edit new end point");
//        StopTimesCell *thisCell = (StopTimesCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
////        [thisCell.btnGetStopNames sendActionsForControlEvents:UIControlEventTouchUpInside];  // In Storyboard, the button press triggers the transition to FindLocationVC.  This simulates a button press to the same affect
//    }
//    
//}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue identifier] isEqualToString: @"StopNamesSegue"] )
    {
        UINavigationController *navController = [segue destinationViewController];
        StopNamesTableController *sntc = (StopNamesTableController*)[navController topViewController];
        
//        StopNamesTableController *sntc = [segue destinationViewController];
        [sntc setDelegate:self];
    }
    
}

-(void) doneButtonPressed:(StopNamesTableController*) view WithStopName:(NSString*) selectedStopName andStopID:(NSInteger) selectedStopID
{
    
    NSLog(@"NtAVC - (void) doneButtonPressed, stopID: %d, stopName: %@", selectedStopID, selectedStopName);
    if ( [[self modalViewController] isBeingDismissed] )
        return;
    else
        [view dismissModalViewControllerAnimated:YES];
    

    if ( _whichLeftButton == kNextToArriveStartButtonPressed )
    {
        [itinerarySection setStartStopName:selectedStopName];
        _buttonPressed |= kNextToArriveStartButtonPressed;
    }
    else if ( _whichLeftButton == kNextToArriveEndButtonPressed )
    {
        [itinerarySection setEndStopName:selectedStopName];
        _buttonPressed |= kNextToArriveEndButtonPressed;
    }
    
    
    if ( (_buttonPressed & 0x03) == 3 )
    {
        // Both buttons have been pressed
        [self highlightRetrieveButton];
    }

    
    // Update table
    NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0] ];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
}

//-(void) fixMismatchedStopName: (NSString**) stopName
-(NSString *) fixMismatchedStopName: (NSString*) stopName;
{
    
    // Unfortunately, at the time of writing this method, there are a few stop names in the GTFS file
    // that do not match up with the stop name of an internal SEPTA database.  As such, this method
    // looks for one of those stop names and replaces it with one that matches the internal name.
    
    // P.S. This is horrible code, if anyone asks, I'll deny ever writing in.  Ran php jarowinkler | egrep -v 100% to find the gasps between the GTFS and internal naming.
    

    
//    NSString *temp = [replacement objectForKey: *stopName];
    NSString *temp = [replacement objectForKey:stopName];
    
    if ( temp != nil )
    {
        NSLog(@"NtAVC - fixMismatchedStopName: replacing %@ with %@", stopName, temp);
        return temp;
    }
    else
        return stopName;
    
//    if ( [stopName isEqualToString:@"Norristown T.C."])
//    {
//        stopName = @"Norristown TC";
//    }
//    else if ( ( [stopName isEqualToString:@"Temple University"] ) )
//    {
//        stopName = @"Temple U";
//    }
//    else if ( ( [stopName isEqualToString:@""] ) )
//    {
//        
//    }
    
}


-(void) highlightRetrieveButton
{
//    if ( self.btnRetrieveData.tintColor == [UIColor redColor] )
//        [self.btnRetrieveData setTintColor:[UIColor blackColor] ];
//    else
    
//    REMenuItem *refreshItem = [[_menu items] objectAtIndex:0];
//    [refreshItem setSubtitle:@"click to refresh data"];
    
    [self updateRefreshStatusWith:kNextToArriveRefreshStatusReady];
    
    [self.btnRetrieveData setTintColor:[UIColor redColor] ];
    
}

-(void) cancelButtonPressed:(StopNamesTableController*) view
{
    NSLog(@"NtAVC -(void) cancelButtonPressed");
    [view dismissModalViewControllerAnimated:YES];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}


- (IBAction)btnRetrieveDataPressed:(id)sender
{
    
    return;
    
}

NSComparisonResult (^sortNTASaveObjectByDate)(NTASaveObject*,NTASaveObject*) = ^(NTASaveObject *a, NTASaveObject *b)
{
    return [[b addedDate] compare: [a addedDate] ];
};


-(void) kickOffAnotherJSONRequest
{
 
    if ( _killAllTimers )
    {
        [self invalidateTimer];
        return;
    }
    
    NSLog(@"NtAVC - kickOffAnotherJSONRequest");
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:JSON_REFRESH_RATE
                                                  target:self
                                                selector:@selector(getLatestJSONData)
                                                userInfo:nil
                                                 repeats:NO];
}



-(void) getLatestJSONData
{
    
    NSLog(@"NtAVC - getLatestBusJSONData");
    
    // If start and end points haven't been entered, do nothing
//    if ( ( _startObject.stop_name == nil ) || ( _endObject.stop_name == nil ) )
//    _startStopName = [[[_tData data] objectAtIndex:0] objectAtIndex:0];
//    _endStopName   = [[[_tData data] objectAtIndex:0] objectAtIndex:1];
    
    
    NSString *startStopName = [itinerarySection startStopName];
    NSString *endStopName   = [itinerarySection endStopName];
    
    
    if ( ( startStopName == nil ) || ( endStopName == nil ) )
        return;
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;

    
    int index = [self.segmentRouteType selectedSegmentIndex];  // As of 12/20/12, always set to 1
    if ( index == 0 )  // Add MFL to this?  Need to investigate this further
    {
        
//        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@",@"1"];
//        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"DSTVC - getLatestBusJSONData -- api url: %@", webStringURL);
//        
//        //    [SVProgressHUD showWithStatus:@"Retrieving data..."];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
//            
//            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
//            [self performSelectorOnMainThread:@selector(processJSONData:) withObject: realtimeBusInfo waitUntilDone:YES];
//            
//        });
        
    }
    else if ( index == 1 )
    {
        
        NSString *_newStartStop = [self fixMismatchedStopName: startStopName];
        NSString *_newEndStop   = [self fixMismatchedStopName: endStopName];
        
//        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/NextToArrive/%@/%@/10", _startStopName, _endStopName];

        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/NextToArrive/%@/%@/50", _newStartStop, _newEndStop];

        
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"NtAVC - getLatestRailJSONData -- api url: %@", webStringURL);
        
        [SVProgressHUD showWithStatus:@"Loading..."]
;
        
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
                NSLog(@"NtAVC - getLatestJSONData: _jsonOp cancelled");
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
    
}

-(void) processJSONData:(NSData*) returnedData
{
    
    [SVProgressHUD dismiss];
    _stillWaitingOnWebRequest = NO;
    
    
//    NSMutableArray *tableData;  // Array of NextToArrivaJSONObjects
//    tableData = [[NSMutableArray alloc] init];
    
    [ntaDataSection removeAllObjects];
    
    NSMutableArray *myData;
    myData = [[NSMutableArray alloc] init];
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( json == nil )
        return;
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    

//    [masterList removeAllObjects];
    int index = [self.segmentRouteType selectedSegmentIndex];
    if ( index == 0 )
    {
        
    }
    else if ( index == 1 )
    {
        
//        [tableData removeAllObjects];
        
//        if ( [_tData numberOfSections] > kNextToArriveSectionData )   // We just need to clear the data and only the data
//        {
//            [_tData removeObjectsInSection: kNextToArriveSectionData];
//        }
        
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
            
            time = [data objectForKey:@"term_arrival_time"];
            [ntaObject setTerm_arrival_time: [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] ];
            
            [ntaObject setTerm_delay: [data objectForKey:@"term_delay"] ];
            
            time = [data objectForKey:@"term_depart_time"];
            [ntaObject setTerm_depart_time: [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] ];
            
            [ntaObject setTerm_line: [data objectForKey:@"term_line"] ];
            [ntaObject setTerm_train: [data objectForKey:@"term_train"] ];
            
            [myData addObject:ntaObject];
            
        }
        
        
        // Need a better explanation for what this does and why this is necessary
//        if ( [_tData numberOfSections] > kNextToArriveSectionData )   // We just need to clear the data and only the data
//        {
//            NSLog(@"NTAVC - processJSONData: removing objects in _tData section ");
//            [_tData removeObjectsInSection: kNextToArriveSectionData];
//        }
//        
//        _tableData = [myData copy];
//        
//        [_tData addName:@"Next To Arrive" toSection: kNextToArriveSectionData];
//        [_tData addObject:_tableData toSection: kNextToArriveSectionData];
        
    }
    
    ntaDataSection = myData;
        
    _launchUpdateTimer = YES;
    [self kickOffAnotherJSONRequest];
    
//    [self sortDataWithIndex: _previousIndex];
    [self.tableView reloadData];
    
}


-(void) selectedFavorites
{
    
    NTASaveObject *sObject = [[NTASaveObject alloc] init];
    [sObject setStartStopName: itinerarySection.startStopName];
    [sObject setEndStopName  : itinerarySection.endStopName  ];
    
    NSInteger locatedAt;
    locatedAt = [saveData addObject: sObject intoSection: kNTASectionFavorites];
    NSLog(@"NtAVC - saveData, locatedAt: %d", locatedAt);  // if locatedAt == NSNotFound, it wasn't found in the recentlyViewed
    
    [favoritesSection sortUsingComparator:sortNTASaveObjectByDate];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kNextToArriveSectionFavorites] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}


-(void) refreshJSONData
{
    
    if ( (_buttonPressed & 0x03) != 3 )
    {
        // Both buttons have been pressed
        return;
    }
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    NTASaveObject *sObject = [[NTASaveObject alloc] init];
    [sObject setStartStopName: itinerarySection.startStopName];
    [sObject setEndStopName  : itinerarySection.endStopName  ];
    
    NSInteger locatedAt;
    locatedAt = [saveData addObject: sObject intoSection: kNTASectionRecentlyViewed];
    NSLog(@"NtAVC -  saveData, locatedAt: %d", locatedAt);  // if locatedAt == NSNotFound, it wasn't found in the recentlyViewed
    
    [recentlyViewedSection sortUsingComparator:sortNTASaveObjectByDate];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kNextToArriveSectionRecent] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self invalidateTimer]; // Invalidate any timer that is already active.  If no timer is active, nothing happens
    [self getLatestJSONData];
    
}


#pragma mark -- REMenu
- (IBAction)toggleMenu:(id)sender
{

    if (_menu.isOpen)
    {
        [menuRefreshTimer invalidate];
        return [_menu close];
    }
    else
    {
        if ( ![menuRefreshTimer isValid] && [updateTimer isValid] )
            menuRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(menuRefreshUpdate:) userInfo:nil repeats:YES];
        
        if ( updateTimer != nil )
        {
//            REMenuItem *refreshItem = [[_menu items] objectAtIndex:0];
//            [refreshItem setSubtitle:@"refreshing in ..."];
            [self updateRefreshStatusWith:kNextToArriveRefreshStatusInUnknown];
        }
        
        [_menu showFromRect:self.view.frame inView:self.view ];
    }
    
    return;

}



-(void) menuRefreshUpdate: (NSTimer*) timer
{
    
    
    if ( [updateTimer isValid] )
    {
        NSTimeInterval seconds = [[updateTimer fireDate] timeIntervalSinceDate:[NSDate date] ];
        
        if ( seconds < 1.0f )
        {
//            [refreshItem setSubtitle:@"refreshing now..."];
            [self updateRefreshStatusWith:kNextToArriveRefreshStatusNow];
        }
        else
        {
            REMenuItem *refreshItem = [[_menu items] objectAtIndex:0];
            [refreshItem setSubtitle:[NSString stringWithFormat:@"refreshing in %d seconds", (int)round([[updateTimer fireDate] timeIntervalSinceDate:[NSDate date]]) ] ];
        }
    
    }
    
}

-(void) showMessage
{
    
    //[TSMessage showNotificationInViewController:self withTitle:@"Holiday" withMessage:@"SEPTA is running on a holiday schedule" withType:TSMessageNotificationTypeWarning];
    
    //[DMRNotificationView showInView:self.view title:@"Holiday" subTitle:@"SEPTA is running a holiday schedule today"];
    
    
    DMRNotificationView *notice = [[DMRNotificationView alloc] initWithTitle:@"Holiday" subTitle:@"SEPTA is running on a holday schedule today" targetView:self.view];
    [notice setTintColor:[UIColor redColor] ];
    
    [notice setIsTransparent:NO];
    
    [notice showAnimated:YES];
    
}

-(void) showTSMessage
{
    
    [self performSelector:@selector(showMessage) withObject:nil afterDelay:0.5f];
    
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


//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    NSLog(@"gestureRecognizerShouldBegin!");
//    return YES;
//}

#pragma mark - Gestures
- (IBAction)longPressRecognized:(id)sender
{
    // Since a long press is triggered before a tap, a LP on a favorite or recent will not actually load any data into the start/end fields
    // Do that now
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    UILongPressGestureRecognizer *gesture = (UILongPressGestureRecognizer*) sender;
    
    if ( gesture.state == UIGestureRecognizerStateBegan )
    {
        NSLog(@"NtAVC - Began");
        CGPoint touchPoint = [sender locationInView: self.view];
        NSIndexPath *row = [self.tableView indexPathForRowAtPoint:touchPoint];
        
        [self tableView:self.tableView didSelectRowAtIndexPath:row];
        [self refreshJSONData];
        
        NSLog(@"NtAVC - indexPath: %@", row);
    }
    else if ( gesture.state == UIGestureRecognizerStateRecognized )
    {
        NSLog(@"NtAVC - Recognized");

    }
    else if ( gesture.state == UIGestureRecognizerStateEnded )
    {
        NSLog(@"NtAVC - Ended");
    }
    
    
//    UITableView *tableView = (UITableView*)self.view;

    
//    [self refreshJSONData];
}


- (IBAction)doubleTapRecognized:(id)sender1
{
//    [self refreshJSONData];
    
    NSLog(@"NtAVC - Double Tab");
    
}


-(void) currentLocationSelectionMade:(BasicRouteObject *)routeObj
{
    NSLog(@"NtAVC -  currentLocationSelectionMade");
}


@end
