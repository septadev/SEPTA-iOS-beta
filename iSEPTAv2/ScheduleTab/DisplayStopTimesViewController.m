//
//  DisplayStopTimesViewController.m
//  iSEPTA
//
//  Created by septa on 11/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "DisplayStopTimesViewController.h"


#import "ItineraryObject.h"
#import "TripObject.h"

//#import "RouteSelectionCell.h"
//#import "DisplayTimesCell.h"


#define CELL_REFRESH_RATE 5.0f
#define JSON_REFRESH_RATE 20.0f
#define SCROLL_UPDATE_DISTANCE 10.0f

#define TRAIN_STRING_DESCRIPTION @"I'm On a Train!"

//#define NSLog //

@interface DisplayStopTimesViewController ()
    -(void) fiveSecondsLater;
@end

@implementation DisplayStopTimesViewController
{
    
    BOOL _pageControlUsed;
    
    ShowTimesModel *_showTimes;
    ShowTimesModel *_stopSequence;
    
    NSInteger _stopSequenceRow;
    
    NSInteger oldIndex;
    NSInteger oldPage;
    
    NSTimer *timer;
    
//    UITapGestureRecognizer *editEndTap;
//    UITapGestureRecognizer *editStartTap;
    
    ShowTimesButtonPressed leftButtonType;   // Used to indicate which button was pressed, start or end.
    ShowTimesLocationType  locationType;     // Used to change the UITableViewCell being displayed.  When two locations have been choose, the arrival time of the second one needs to be displayed
    
    CLLocationCoordinate2D lastLocation;
    MKMapRect flyTo;
    
    NSTimer *updateTimer;
    
    BOOL _displayCountDown;
    BOOL _findLocationsSegue;
    
    BOOL _stillWaitingOnWebRequest;
    
    BOOL _use24HourTime;
    
    NSInteger _startSequence;
    NSInteger _endSequence;
    
    NSString *tripList;
    
    UITableView *currentView;
    

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

}


@synthesize btnFavorite;

@synthesize scrollView;
@synthesize pageControl;

@synthesize segmentDays;
@synthesize tableView;
@synthesize tableSeq;

@synthesize viewMain;
@synthesize viewSeq;

@synthesize mapView;

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
//    _pageControlUsed = NO;
//    _stillWaitingOnWebRequest = NO;
//    
//
//    // --==  PageControl Setup  ==--
//    [self.scrollView setContentSize: CGSizeMake(self.scrollView.frame.size.width*3, self.scrollView.frame.size.height) ];
//    CGRect frame = self.scrollView.frame;
//    frame.origin.x = frame.size.width * 0;
//    frame.origin.y = 0;
//    [self.scrollView scrollRectToVisible:frame animated:NO];
//    
//    [self.pageControl setCurrentPage:0];
//
//    
//    // --==  MapKit  ==--
//    [mapView setShowsUserLocation: YES ];
//    [mapView setScrollEnabled    : YES ];
//    [mapView setDelegate:self];
//    
//    
//    // Left and Right Swipes to traverse the views
//    [self.view addGestureRecognizer:self.gestureLeftSwipe];
//    [self.view addGestureRecognizer:self.gestureRightSwipe];
    
    
    // --==  TableView Sections  ==--
    itinerary       = [[ItineraryObject alloc] init];
    masterTripsArr  = [[NSMutableArray alloc] init];
    activeTrainsArr = [[NSMutableArray alloc] init];
    currentTripsArr = [[NSMutableArray alloc] init];
    
    
    // --==  Set Title of the ViewController  ==--
    [self setTitle:@"Schedule Info"];  

    
    
    
    
    
    
    
//    _showTimes = [[ShowTimesModel alloc] initWithPlaceholders:2];  // Start and End will occupy the 1st and 2nd cells of this table view
//    _stopSequence = [[ShowTimesModel alloc] init];  // tableSeq will have a different method for selecting the start/end points.  2 placeholders are not necessary
    
    // Populate the Start Cell with the first stop_id
//    TripData *trip = [[TripData alloc] init];
//    [trip setStart_stop_id  : [NSNumber numberWithInt:routeData.current.start_stop_id] ];
//    [trip setStart_stop_name: routeData.current.start_stop_name];
//    [_showTimes replaceObjectForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withObject:trip];
//    locationType   = kLocationOnlyHasStart;
    
    
    // Populate the End Cell only if the end_stop_id being passed in contains data
//    if ( routeData.current.end_stop_id != 0 )
//    {
//        TripData *end = [[TripData alloc] init];
//        [end setEnd_stop_id: [NSNumber numberWithInt:routeData.current.end_stop_id] ];
//        [end setEnd_stop_name: routeData.current.end_stop_name];
//        [_showTimes replaceObjectForIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] withObject:end];
//        locationType = kLocationHasBoth;
//    }
    
    
//    oldIndex = 0;  // No idea with this does
//    leftButtonType = kLeftButtonIsUndefined;  // Set this to the default position.  Only when either the Start or End button from the cells are clicked will this change
    
//    _displayCountDown = YES;  // No idea
//    _findLocationsSegue = NO; // Slight idea
    
    
    
    
//    [self getStopTimes];  // Load the UITableView database
    
    
//    if ( ![SVProgressHUD isVisible] )
//        [SVProgressHUD showWithStatus:@"Loading..."];
//    dispatch_queue_t initialQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
//    dispatch_async(initialQueue, ^{
//        
//        //        NSLog(@"FLVC -(void) viewDidLoad -- Loading SVProgressHUD");
//        [self getStopTimes];
//        
//        NSLog(@"FLVC - inside dispatch_async, reloadData");
//        
//        //        [self performSelector:@selector(reloadTableData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
//        //        [self performSelectorOnMainThread:@selector(reloadTableData) withObject:nil waitUntilDone:NO];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView reloadData];
//            [SVProgressHUD dismiss];
//            timer = [NSTimer scheduledTimerWithTimeInterval:5.0f
//                                                     target:self
//                                                   selector:@selector(fiveSecondsLater)
//                                                   userInfo:nil
//                                                    repeats:NO];
//        });
//    
//    });
//    
//    
//    [self updateTimeSettings];
//    
//    
//    [self.tableView setContentOffset:CGPointMake(0, -44 * 2)];  // 44 is the cell height, don't hardcode it
//    
//    
//    // Change color of favorites
//    if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
//        [self setFavoriteHighlight:YES];
//    else
//        [self setFavoriteHighlight:NO];

    
}

-(void) updateTimeSettings
{
    // Get 24HourTime setting
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:24HourTime"];
    if ( object == nil )
    {
        _use24HourTime = NO;  // Defaults to NO.
    }
    else
    {
        _use24HourTime = [object boolValue];
    }
    
}


-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"DSTVC - viewWillAppear");
    
    [super viewWillAppear:animated];
    
    if ( [_showTimes numberOfRows] >= 3 )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:CELL_REFRESH_RATE
                                                  target:self
                                                selector:@selector(updateStopTimesData)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self updateTimeSettings];
//    [self updateStopTimesData];
    
    _findLocationsSegue = NO;
    
}


-(void) viewWillDisappear:(BOOL)animated
{
    
    if ( updateTimer != nil )  // Might not be necessary but for now, better safe than CRASH!
    {
        
        if ( [updateTimer isValid]  )
        {
            [updateTimer invalidate];
            updateTimer = nil;
            NSLog(@"DSTVC - Killing updateTimer");
        }
        
    }
    
    if ( !_findLocationsSegue )  // Only true if the segue goes to FindLocationsVC, otherwise we're leaving this VC.  Later punks!
    {
        [routeData addCurrentToSection: kDisplayedRouteDataRecentlyViewed];
        
        // Erase this data as it is only gained through this VC.
//        [routeData.current setEnd_stop_id:0];
//        [routeData.current setEnd_stop_name:nil];
    }
    
}


- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
//    trainNoArray   = nil;
    _showTimes     = nil;
    _stopSequence  = nil;
    
}


- (void)viewDidUnload
{
    
    [self setSegmentDays:nil];
    [self setPageControl:nil];
    [self setScrollView:nil];
    [self setTableSeq:nil];
    
    [self setTableView:nil];
    [self setMapView:nil];
    
    [self setViewSeq:nil];
    [self setViewMain:nil];
    [self setBtnFavorite:nil];
    
    // Anything defined in viewDidLoad should be nil'ed here.  (As a call to viewDidLoad will just reload it all.)
//    editEndTap   = nil;
//    editStartTap = nil;
    
    _showTimes = nil;
    
    [self setGestureLeftSwipe:nil];
    [self setGestureRightSwipe:nil];
    [super viewDidUnload];
    
}



#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)thisTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Don't do a thing
    
    if ( thisTableView == self.tableView )  // Why are we scrolling to position none again?  Comments, Greg!  COMMENTS!  Future Greg can't follow Past Greg's insane logic
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        
        if ( self.tableView.indexPathForSelectedRow == indexPath)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        NSLog(@"DSTVC - didSelectRow/Section: %d/%d - %@", indexPath.row, indexPath.section, [_showTimes objectForIndexPath:indexPath] );
    }
    else
    {
        [self.tableSeq scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone  animated:YES];
    }
    
    NSLog(@"DSTVC - didSelect - RouteData current start/end ids: %d/%d", routeData.current.start_stop_id, routeData.current.end_stop_id);
    
//    if ( thisTableView == self.tableView)
//    {
//        
//    }
    
}


//-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  // Required method
//{
//    
//    static NSString *StartIdentifier = @"StopTimesStartCell";
//    static NSString *EndIdentifier   = @"StopTimesEndCell";
//    static NSString *DefaultIdentifier = @"DefaultCell";
//    
//    NSLog(@"STVC - cellForRowAtIndexPath");
//    
//    if ( indexPath.row == 0 )
//    {
//        
//        StopTimesStartCell *cell = (StopTimesStartCell*)[tableView dequeueReusableCellWithIdentifier:StartIdentifier];
//        
//        if ( ( cell ==  nil ) || ( ![cell isKindOfClass:[StopTimesStartCell class] ] ) )
//        {
//            NSLog(@"Loading StopTimesStartCell...");
//            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StopTimesStartCell" owner:self options:nil];
//            cell = (StopTimesStartCell*)[nib objectAtIndex:0];
//        }
//        
//        cell.lblStopName.text = @"StartStart";
//        NSLog(@"cell: %p, stopname: %@, hidden: %d, label: %@", cell, cell.lblStopName.text, cell.hidden, cell.textLabel.text);
//        
//        return cell;
//        
//    }
//    else if ( indexPath.row == 1 )
//    {
//        
//        StopTimesEndCell *cell = (StopTimesEndCell*)[tableView dequeueReusableCellWithIdentifier:EndIdentifier];
//        
//        if ( ( cell ==  nil ) || ( ![cell isKindOfClass:[StopTimesEndCell class] ] ) )
//        {
//            NSLog(@"Loading StopTimesEndCell...");
//            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StopTimesEndCell" owner:self options:nil];
//            cell = (StopTimesEndCell*)[nib objectAtIndex:0];
//        }
//        
//        cell.lblStopName.text = @"EndEnd";
//        NSLog(@"cell: %p, stopname: %@, hidden: %d, label: %@", cell, cell.lblStopName.text, cell.hidden, cell.textLabel.text);
//        
//        return cell;
//        
//    }
//    else
//    {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultIdentifier];
//        
//        if ( cell ==  nil )
//        {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultIdentifier];
//        }
//        
//        [[cell textLabel] setText: [NSString stringWithFormat:@"Row %d", indexPath.row] ];
//        
//        return cell;
//    }
//}


- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // In this view there are two Table Views: one that displays the stop times and one that displays the stop sequence
    //   for a particular stop times.  If no stop time has been selected before the transition to stop sequence,
    //   use the most recently stop time.
    
    static NSString *itineraryCellName = @"ItineraryCell";
    
    id cell;
    
    
    // NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NTASingleCell" owner:self options:nil];
    // cell = (NTASingleCell*)[nib objectAtIndex:0];
//    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    switch (indexPath.section)
    {
        case 0:  // Itinerary

            cell = [self.tableView dequeueReusableCellWithIdentifier: itineraryCellName];
            
            //cell = (RouteSelectionCell*)[thisTableView dequeueReusableCellWithIdentifier: itineraryCellName];
            
//            if ( cell == nil )
//            {
//                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RouteSelectionCell" owner:self options:nil];
//                cell = (RouteSelectionCell*)[nib objectAtIndex:0];
//            }
            
            break;
        case 1:  // Active Trains
            
            break;
        case 2:  // Trips
            
            break;
        default:
            break;
    }
    
    
//    currentView = thisTableView;
//    if ( thisTableView == self.tableView )
//    {
////        NSLog(@"TABLEVIEW!");
//        cell = [self returnCellForStopTimes:indexPath];  // Moved cell creation and population to helper function        
//    }
//    else if ( thisTableView == self.tableSeq )
//    {
//        cell = [self returnCellForStopSequence:indexPath];  // Moved cell creation and population to helper function
//    }
    
    return cell;
    
}


// Functions that support tableView
-(id) returnCellForStopTimes:(NSIndexPath*) indexPath
{
    
    
    static NSString *startCellIdentifier   = @"ShowTimesStartIdentifier";
    static NSString *endCellIdentifier     = @"ShowTimesEndIdentifier";
//    static NSString *displayCellIdentifier = @"ShowTimesCellIdentifier";

    
    
    /*
     
     New structure is going to depend on Sections.  3 Sections to be precise, possibly 4 but we'll be able to easily add more
       in the future.
     
     Seciton 0 - contains the double high start/end cell with all it's goodies
     Section 1 - contains a list of all active trains that are part of that line.  When view is initially loaded, this section is empty and not displayed.  As the data is loaded, it will be inserted into the array.  Sorted by final arrival time.
     Section 2 - contains all the stop times remaining for the entered trip using the new cell
     
     
     
     */
    
    
//    NSLog(@"%d/%d: %@", indexPath.section, indexPath.row, [_showTimes objectForIndexPath:indexPath]);
    
    if ( indexPath.row == 0 )
    {

        StopTimesCell *cell = (StopTimesCell*)[self.tableView dequeueReusableCellWithIdentifier:startCellIdentifier];
        
        if ( ( cell ==  nil ) || ( ![cell isKindOfClass:[StopTimesCell class] ] ) )
        {
//            NSLog(@"Loading StopTimesCell...");
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StopTimesCell" owner:self options:nil];
            cell = (StopTimesCell*)[nib objectAtIndex:0];
            
        }
        
//        cell.lblStopName.text = @"StartStart";
//        [[cell lblStopName] setText: [ [_showTimes objectForIndexPath: indexPath] start_stop_name ] ];
        [cell setRow:0];
        [cell setDelegate:self];
//        [cell addGestureRecognizer: editStartTap];
        
//        NSLog(@"cell: %p, stopname: %@, hidden: %d, label: %@", cell, cell.lblStopName.text, cell.hidden, cell.textLabel.text);
        
        return cell;
        
//        cell = (ShowTimesStartCell*)[tableView dequeueReusableCellWithIdentifier:startCellIdentifier];
//        
//        if ( cell ==  nil )
//        {
//            cell = [[ShowTimesStartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:startCellIdentifier];
//            [cell setRow:0];
//        }
//        
//        [[(ShowTimesStartCell*)cell lblStopName] setText: [ [_showTimes objectForIndexPath: indexPath] start_stop_name ] ];
//        [(ShowTimesStartCell*)cell setDelegate:self];
//        [(ShowTimesStartCell*)cell setRow:0];
//        [(ShowTimesStartCell*)cell addGestureRecognizer:editStartTap];
//        
//        return cell;

    }
    else if ( indexPath.row == 1 )
    {

        StopTimesCell *cell = (StopTimesCell*)[self.tableView dequeueReusableCellWithIdentifier:endCellIdentifier];
        
        if ( ( cell ==  nil ) || ( ![cell isKindOfClass:[StopTimesCell class] ] ) )
        {
//            NSLog(@"Loading StopTimesCell...");            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StopTimesCell" owner:self options:nil];
            cell = (StopTimesCell*)[nib objectAtIndex:0];
        }
        
//        [[cell lblStopName] setText: [ [_showTimes objectForIndexPath: indexPath] end_stop_name ] ];
        
        [cell setRow:1];
        [cell setDelegate:self];
//        [cell addGestureRecognizer: editEndTap];
        
        return cell;

        
//        cell = (ShowTimesStartCell*)[tableView dequeueReusableCellWithIdentifier:endCellIdentifier];
//        
//        if ( cell ==  nil )
//        {
//            cell = [[ShowTimesStartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:endCellIdentifier];
//            [cell setRow:1];
//            
//        }
//        
//        [[(ShowTimesStartCell*)cell lblStopName] setText: [ [_showTimes objectForIndexPath: indexPath] end_stop_name ] ];
//        [(ShowTimesStartCell*)cell setDelegate:self];
//        [(ShowTimesStartCell*)cell setRow:1];
//        [(ShowTimesStartCell*)cell addGestureRecognizer:editEndTap];
//
//        return cell;

    }
    else  // if ( indexPath.row == 0 ), row >= 2
    {
    
//        DisplayTimesCell *cell = (DisplayTimesCell*)[self.tableView dequeueReusableCellWithIdentifier:displayCellIdentifier];
//        
//        if ( cell ==  nil )
//        {
//            NSLog(@"DSTVC - cell was nil, allocing DisplayTimesCell");
//            cell = [[DisplayTimesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:displayCellIdentifier];
//        }
//        
//        [cell setUse24HourTime:_use24HourTime];
//        NSString *timeStr =  [[_showTimes objectForIndexPath:indexPath] start_arrival_time ];
//        
//        NSString * train_no = [[_showTimes objectForIndexPath:indexPath] train_no];
////        [[cell lblTrainNo] setText: train_no ];
//        NSLog(@"DSTVC - row: %d, train_no: %@", indexPath.row, train_no);
//        
//        // Time format is XX:XX, if there is no semicolon, then hide some of the elements of the cell
//        
//        if ( [timeStr rangeOfString:@":"].location == NSNotFound )
//        {
////            [[cell btnAlarm] setHidden:YES];
//            [[cell lblTimeBeforeArrival] setHidden:YES];
//            [[cell textLabel] setText: timeStr];
//            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//            return cell;
//        }
//        else
//        {
//            //            [[cell btnAlarm] setHidden:NO];
//            [[cell lblTimeBeforeArrival] setHidden:NO];
//            [[cell textLabel] setText:@""];
//        }
        

        
        
//        if ( timeStr != nil )  // As long as the timeStr isn't nil...
//        {
//            
//            // meaning it has some data, do something.
//            switch (locationType) {
//                {
//                case kLocationOnlyHasStart:
//                    
//                    [cell addArrivalTimeStr: timeStr];
//                    [cell removeDepartureTimeStr];
//                    
//                    break;
//                }
//                case kLocationOnlyHasEnd:
//                    
//                    [cell addDepartureTimeStr: timeStr];
//                    [cell removeArrivalTimeStr];
//                    
//                    break;
//                {
//                case kLocationHasBoth:
//                    
//                    [cell addArrivalTimeStr: timeStr];
//                    [cell addDepartureTimeStr: [[_showTimes objectForIndexPath:indexPath] end_arrival_time] ];
//                    
//                    break;
//                }
//                case kLocationUndefined:
//                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//                    return cell;
//                    break;
//            }  // switch (locationType)
//            
//            [cell setDisplayCountdown: _displayCountDown ];
//            [cell updateCell];  // Regardless of locationType, this update needs to happen.  Moved it outside of switch statement
//            
//        }
//        else
//        {
//            [cell hideCell];
//            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//            return cell;
//        }
//        
//        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];  // Always allow selecting unless otherwise specified
//        return cell;
//        
    }  // if ( indexPath.row == 0 )
    
    
//    switch (indexPath.row) {
//        case 0:
//            cell = (ShowTimesStartCell*)[self.tableView dequeueReusableCellWithIdentifier:startCellIdentifier];
//            if ( cell == nil )
//            {
//                cell = [[ShowTimesStartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:startCellIdentifier];
//                [cell setRow:0];
//            }
//            
//            [[cell textLabel] setText:@"START!"];
//            break;
//        case 1:
//            cell = (ShowTimesStartCell*)[self.tableView dequeueReusableCellWithIdentifier:endCellIdentifier];
//            
//            if ( cell ==  nil )
//            {
//                cell = [[ShowTimesStartCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:endCellIdentifier];
//                [cell setRow:1];
//                
//            }
//            
//            [[cell textLabel] setText:@"END!"];
//            break;
//        default:
//            cell = (DisplayTimesCell*)[self.tableView dequeueReusableCellWithIdentifier:displayCellIdentifier];
//            
//            if ( cell ==  nil )
//                cell = [[DisplayTimesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:displayCellIdentifier];
//            
//            [[cell textLabel] setText:@"DISPLAY!"];
//            break;
//    }
    
    id cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyString"];
    return cell;
    
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
    cell = (StopSequenceCell*)[self.tableSeq dequeueReusableCellWithIdentifier: sequenceCellIdentifier];
    
    if ( cell == nil )
    {
//        cell = [[StopSequenceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sequenceCellIdentifier];
        NSLog(@"DSTVC - creating StopSeqeuenceCell");
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StopSequenceCell" owner:self options:nil];
        cell = (StopSequenceCell*)[nib objectAtIndex:0];
    }
    
    TripData *trip = [_stopSequence objectForIndexPath:indexPath];
//    int stopID = [[trip start_stop_id] intValue];
    
    [[cell lblStopName] setText: [trip start_stop_name   ] ];
    [[cell lblStopTime] setText: [trip start_arrival_time] ];
    [cell setDelegate: self];
    
    int currentSequence = [[trip start_stop_sequence] intValue];
    
    if ( [_stopSequence numberOfRows] == indexPath.row+1 )
    {
        if ( currentSequence != _endSequence )
        {
            // C
            UIImage *temp = [UIImage imageNamed:@"stopSequenceTopBubble.png"];
            [[cell imgSequence] setImage: [UIImage imageWithCGImage: temp.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
        }
        else
        {
            // D
            UIImage *tempSeq = [UIImage imageNamed:@"stopSequenceTopHighBubble.png"];
            UIImage *tempPro = [UIImage imageNamed:@"stopSequenceTopGreenBubble.png"];
            [[cell imgSequence] setImage: [UIImage imageWithCGImage: tempSeq.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
            [[cell imgProgress] setImage: [UIImage imageWithCGImage: tempPro.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
        }
        
    }
    else if ( indexPath.row == 0 )
    {
        
        // A or B depending on highlighted
        if ( currentSequence != _startSequence )
        {
            // A
            [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceTopBubble.png"] ];
        }
        else
        {
            // B
            [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceTopHighBubble.png"] ];
            [[cell imgProgress] setImage: [UIImage imageNamed:@"stopSequenceTopGreenBubble.png"] ];
        }
    
    }
    else if ( currentSequence < _startSequence )
    {
        // E as long as currentSequence before _startSequence
        [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceMidBubble.png"] ];
    }
    else if ( currentSequence == _startSequence )
    {
        // G
        [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceMidHighDownBubble.png"] ];
        [[cell imgProgress] setImage: [UIImage imageNamed:@"stopSequenceMidGreenDownBubble.png"] ];
    }
    else if ( currentSequence < _endSequence )
    {
        // H
        [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceMidHighBubble.png"] ];
        [[cell imgProgress] setImage: [UIImage imageNamed:@"stopSequenceMidGreenBubble.png"] ];
    }
    else if ( currentSequence == _endSequence )
    {
        // F
        UIImage *tempSeq = [UIImage imageNamed:@"stopSequenceMidHighDownBubble.png"];
        UIImage *tempPro = [UIImage imageNamed:@"stopSequenceMidGreenDownBubble.png"];
        [[cell imgSequence] setImage: [UIImage imageWithCGImage: tempSeq.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
        [[cell imgProgress] setImage: [UIImage imageWithCGImage: tempPro.CGImage scale:1.0f orientation:UIImageOrientationDownMirrored] ];
    }
    else
    {
        // E
        [[cell imgSequence] setImage: [UIImage imageNamed:@"stopSequenceMidBubble.png"] ];
    }
    

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


- (NSInteger)tableView:(UITableView *)thisTableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
    
    if ( thisTableView == self.tableView )
    {
        return [_showTimes numberOfRows];
    }
    else if ( thisTableView == self.tableSeq )
    {
        return [_stopSequence numberOfRows];
    }
    else
        return 0;  // This should never be executed, but for completeness...
    
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;  // As of now, either Table View has only one section
}


- (NSInteger)tableView:(UITableView *)thisTableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    
    if ( thisTableView != self.tableSeq)
        return -1;

    NSInteger row = [_stopSequence getSectionWithIndex:index];
    NSInteger section = [_stopSequence numberOfSections] - 1;
    
    if ( section < 0 )
        section = 0;
    
    // TODO: This won't work with Favorites and Recently Viewed
    [self.tableSeq scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:YES];

    return -1;  // Tells the tableview that you'll handle jumping to the appropriate row.  (If we had more than one section, maybe we'd return something different)
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)thisTableView
{
    
    if ( thisTableView == self.tableSeq )
        return [_stopSequence getSectionTitle];
    else
        return nil;
    
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


#pragma mark - UIScrollView
-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{

    if ( _pageControlUsed )
    {
        return;
    }
    
//    [self.scrollView setContentOffset:self.scrollView.frame.origin];
//    
//    CGFloat pageWidth = self.scrollView.frame.size.width;
//    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
//    [self.pageControl setCurrentPage:page];

////    NSLog(@"page: %d, offset: %@, frame: %@, viewSeq frame: %@", page, NSStringFromCGPoint( self.scrollView.contentOffset), NSStringFromCGRect(self.scrollView.frame), NSStringFromCGRect(self.viewSeq.frame) );
//    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, self.scrollView.frame.origin.y)];
    
    
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}


#pragma mark - UIPageControl
- (IBAction)pageWillChange:(id)sender
{
    // A touch down event was registered.  This should hopefull occur before the value changed event.
    NSLog(@"DSTVC - pageWillChange");
    oldPage = [self.pageControl currentPage];
}

- (IBAction)pageDidChange:(id)sender
{
    
    NSLog(@"DSTVC - pageDidChange");
    // Only called when the page has changed
    
    
    // Invalidate old timer
    if ( [updateTimer isValid]  )
    {
        [updateTimer invalidate];
        updateTimer = nil;
        NSLog(@"DSTVC - Killing updateTimer");
    }
    
    
    int page = [self.pageControl currentPage];
    
    // update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    
    switch (page)  // To which page did we switch?
    {
        case 0:  // Page 0 is the Stop Sequence tableView
//            if ( ![SVProgressHUD isVisible] )
//                [SVProgressHUD showWithStatus:@"Loading..."];
            [self pageChangedToStopSequence];
            break;
        case 1:  // Page 1 is the Stop Times tableView
            [self pageChangedToStopTimes];
            break;
        case 2:  // Page 2 is Map
//            if ( [[self travelMode] isEqualToString:@"Bus"] )
//            {
                [self pageChangedToMap];
//            }
            break;
        default:
            // Whatever page triggers the default was not put there by me!  LOOK OUT!
            break;
    }
        
    NSLog(@"page: %d, frame: %@", self.pageControl.currentPage, NSStringFromCGRect(frame) );
    _pageControlUsed = YES;

}


// Methods called on page change
-(void) pageChangedToStopSequence
{
    [self getStopSequence];
}

-(void) pageChangedToStopTimes
{
    
    // Scheudle the method to be called every 5 seconds
    NSLog(@"DSTVC -(void) pageChangedToStopTimes");
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:CELL_REFRESH_RATE
                                                  target:self
                                                selector:@selector(updateStopTimesData)
                                                userInfo:nil
                                                 repeats:YES];

    [self updateStopTimesData];
    
    // If the user just came from mapView (page 2), there's no need to update this.  If the user came from tableSeq (page 0) then there might be such a need
    if ( oldPage == 0 )
    {
        // Even if the user came from tableSeq (page 0), neither the start nor end stop_id had to have changed.
        // TODO: Create an _isDirty value if either the start or stop times have changed
//        [self getStopTimes];
    }
    
//    [self getStopTimes];
    
}

-(void) pageChangedToMap
{
    
    // Load Map assets... KML for current route along with gathering real-time information
    
    // Update map with annotations and KML
    // Party.
    
    // Schedule getLatestBusJSONData to run every 15 seconds
    updateTimer =[NSTimer scheduledTimerWithTimeInterval:JSON_REFRESH_RATE
                                                  target:self
                                                selector:@selector(getLatestBusJSONData)
                                                userInfo:nil
                                                 repeats:YES];
    
    [self loadkml];
    [self getLatestBusJSONData];  // Instead of waiting 15 seconds for the next update, grab the latest JSON data now, now, now!
    
}

-(void) getLatestBusJSONData
{
    
    NSLog(@"DSTVC - getLatestBusJSONData");
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;

    
    if ( [self.travelMode isEqualToString:@"Bus"] )  // Add MFL to this?  Need to investigate this further
    {
    
        NSString* stringURL = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/TransitView/%@",routeData.current.route_short_name];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"DSTVC - getLatestBusJSONData -- api url: %@", webStringURL);
        
    //    [SVProgressHUD showWithStatus:@"Retrieving data..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            
            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
            [self performSelectorOnMainThread:@selector(addAnnotationsUsingJSONBusData:) withObject: realtimeBusInfo waitUntilDone:YES];
            
        });
    
    }
    else if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        
        NSString* stringURL = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/TrainView/"];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"DSTVC - getLatestRailJSONData -- api url: %@", webStringURL);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            
            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
            [self performSelectorOnMainThread:@selector(addAnnotationsUsingJSONRailData:) withObject: realtimeBusInfo waitUntilDone:YES];
            
        });
        
    }
    
    
    
}

#pragma mark - JSON Processing
-(void) addAnnotationsUsingJSONRailData:(NSData*) returnedData
{
    
    NSLog(@"DSTVC - addAnnotationsUsingJSONRailData");
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    NSMutableArray *annotationsToRemove = [[mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [mapView userLocation] ];         // Keep the userLocation annotation on the map
    [mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
    
    
    for (NSDictionary *railData in json)
    {
        
//        NSString *trainno = [railData objectForKey:@"trainno"];
//        if ( [trainNoArray containsObject:trainno] )
//        {
//            NSLog(@"Found %@ in JSON stream", trainno);
//        }
//        else
//        {
//            NSLog(@"Could not find %@ in JSON stream", trainno);
//        }
        

        // Loop through all returned bus info...
        NSNumber *latitude   = [NSNumber numberWithDouble: [[railData objectForKey:@"lat"] doubleValue] ];
        NSNumber *longtitude = [NSNumber numberWithDouble: [[railData objectForKey:@"lon"] doubleValue] ];
        
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([latitude doubleValue], [longtitude doubleValue]);
                
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
        NSString *annotationTitle;
        if ( [[railData objectForKey:@"late"] intValue] == 0 )
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (on time)", [railData objectForKey:@"trainno"] ];
        else
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (%@ min late)", [railData objectForKey:@"trainno"], [railData objectForKey:@"late"]];
        
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"%@ to %@", [railData objectForKey:@"SOURCE"], [railData objectForKey:@"dest"] ] ];
        [annotation setCurrentTitle   : annotationTitle];
        
        if ( [[railData objectForKey:@"trainno"] intValue] % 2)
            [annotation setDirection      : @"TrainSouth"];  // Modulus returns 1 on odd
        else
            [annotation setDirection      : @"TrainNorth"];  // Modulus returns 0 on even
        
        
        [mapView addAnnotation: annotation];
        
    }
    
    NSLog(@"DSTVC - addAnntoationsUsingJSONRailData -- added %d annotations", [json count]);
    
    
}


-(void) addAnnotationsUsingJSONBusData:(NSData*) returnedData
{
    
    NSLog(@"DSTVC - addAnnotationsUsingJSONBusData");
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.

    
    // Remove all previous annotations
//    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] init];
//    for ( id currentAnnotation in [mapView annotations])
//    {
//        if ( currentAnnotation != mapView.userLocation)
//            [annotationsToRemove addObject: currentAnnotation];
//    }
//    [mapView removeAnnotations: annotationsToRemove];
    
    
    NSMutableArray *annotationsToRemove = [[mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [mapView userLocation] ];         // Keep the userLocation annotation on the map
    [mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
    
    
    for (NSDictionary *busData in [json objectForKey:@"bus"])
    {
        
//        NSLog(@"DSTVC - Bus data: %@", busData);
        // Loop through all returned bus info...
        NSNumber *latitude   = [NSNumber numberWithDouble: [[busData objectForKey:@"lat"] doubleValue] ];
        NSNumber *longtitude = [NSNumber numberWithDouble: [[busData objectForKey:@"lng"] doubleValue] ];
        
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([latitude doubleValue], [longtitude doubleValue]);
        
        NSString *direction = [busData objectForKey:@"Direction"];

        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
        NSString *annotationTitle  = [NSString stringWithFormat: @"BlockID: %@ (%@ min)", [busData objectForKey:@"BlockID"], [busData objectForKey:@"Offset"]];
        
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"Destination: %@", [busData objectForKey:@"destination"]] ];
        [annotation setCurrentTitle   : annotationTitle];
        [annotation setDirection      : direction];
        
        [mapView addAnnotation: annotation];
        
    }
    
    NSLog(@"DSTVC - addAnntoationsUsingJSONBusData -- added %d annotations", [[json objectForKey:@"bus"] count]);
 
//    [SVProgressHUD dismiss];  // We got data, even if it's nothing.  Dismiss the Loading screen...
    
}

#pragma mark - KMLParser
-(void)loadkml
{
    
//    AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *path;
    
//    if([appDelegate.busdata.mode isEqualToString:@"Bus"])
//    {
//        path = [[NSBundle mainBundle] pathForResource:appDelegate.busdata.routeName ofType:@"kml"];
//    }
//    else if([appDelegate.busdata.mode isEqualToString:@"Regional Rail"])
//    {
//        path = [[NSBundle mainBundle] pathForResource:@"regionalrail" ofType:@"kml"];
//    }

    if ( [self.travelMode isEqualToString:@"Bus"] )
        path = [[NSBundle mainBundle] pathForResource: routeData.current.route_short_name ofType:@"kml"];
    else
        path = [[NSBundle mainBundle] pathForResource:@"regionalrail" ofType:@"kml"];
    
    
    if ( path == nil )
        return;
    
    
    NSURL *url = [NSURL fileURLWithPath:path];
    kmlParser = [[KMLParser alloc] initWithURL:url];
    [kmlParser parseKML];
    
    NSLog(@"KML: %@", url);
    
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    NSArray *overlays = [kmlParser overlays];
    NSLog(@"overlays - %d",[overlays count]);
    [mapView addOverlays:overlays];
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    NSArray *annotations = [kmlParser points];
    NSLog(@"annotations - %d",[annotations count]);
    [mapView addAnnotations:annotations];
    
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    flyTo = MKMapRectNull;
    for (id <MKOverlay> overlay in overlays)
    {
        
        if (MKMapRectIsNull(flyTo))
        {
            flyTo = [overlay boundingMapRect];
        }
        else
        {
            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
        }
        
    }
    
    
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    
    // Position the map so that all overlays and annotations are visible on screen.
    mapView.visibleMapRect = flyTo;
    
    
}


#pragma mark - SQLite Functions

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
////    if ( [self.travelMode isEqualToString:@"Bus"] )
////        databaseName = @"SEPTAbus";
////    else if ( [self.travelMode isEqualToString:@"Rail"] )
////        databaseName = @"SEPTArail";
////    else
////        return nil;
////    
////    return [[NSBundle mainBundle] pathForResource:databaseName ofType:@"sqlite"];
//    
//}

-(void) getStopSequence
{
    // Routes not covered will be grayed out
    // Routes covered will be shown
    
    // Query route_XX for just routeData.current.trip_id and order by sequence
    
    // Reload data (cellForIndexPath will handle displaying new information)
 
    [_stopSequence clearData];
    
//    if (sqlite3_open( [[GTFSCommon filePath] UTF8String], &db) == SQLITE_OK)
//    {
  
    _startSequence = 0;
    _endSequence   = 0;
    
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    NSString *tripID;
    NSString *queryStr;
    
    NSString *routeName = routeData.current.route_short_name;
    TripData *tripData;
    
    if ( [self.tableView indexPathForSelectedRow] == nil )
    {
        if ( [_showTimes numberOfRows] >= 3 )
            tripData  = [_showTimes objectForIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] ];  // 2 is the first stop after the start {0,0} and end {1,0} cells
        else
            tripData = nil;  // Set tripData to nil and allow the if statement after this to clean up before return
    }
    else
    {
        tripData  = [_showTimes objectForIndexPath: [self.tableView indexPathForSelectedRow] ];
    }
    
    
    tripID = [tripData trip_id];  // Get the trip_id from tripData.  If tripData is nil, [nil trip_id] returns nil so we're good
    if ( [tripID isEqualToString:@""] )
    {
        [SVProgressHUD dismiss];
        return;
    }
    
    
    if ( [[self travelMode] isEqualToString:@"Bus"] || [[self travelMode] isEqualToString:@"MFL"] || [[self travelMode] isEqualToString:@"NHSL"] || [[self travelMode] isEqualToString:@"BSS"] )
    {
        queryStr = [NSString stringWithFormat:@"SELECT route_ROUTE.*, stop_name FROM route_ROUTE JOIN stops ON route_ROUTE.stop_id=stops.stop_id WHERE trip_id=%@ ORDER BY stop_sequence", tripID];
    }
    else if ( [[self travelMode] isEqualToString:@"Rail"] )
    {
        queryStr = [NSString stringWithFormat:@"SELECT stops.stop_id, trip_id, stop_sequence, direction_id, arrival_time, departure_time, stop_name FROM route_ROUTE JOIN stop_times ON route_ROUTE.stop_times_uid=stop_times.uid JOIN stops ON stop_times.stop_id=stops.stop_id WHERE trip_id=\"%@\" GROUP BY stops.stop_id ORDER BY stop_sequence", tripID];
    }
    queryStr = [queryStr stringByReplacingOccurrencesOfString:@"ROUTE" withString: routeName];
    
    
    NSLog(@"DSTVC -(void) seq: %@", queryStr);
    FMResultSet *results = [database executeQuery: queryStr];
    
    while ( [results next] )
    {
        
        NSNumber *stop_id       = [NSNumber numberWithInt: [results intForColumn:@"stop_id"] ];
        NSString *trip_id       = [results stringForColumn:@"trip_id"];
//        NSString *stop_sequence = [results stringForColumn:@"stop_sequence"];
        NSNumber *stop_sequence = [NSNumber numberWithInt: [results intForColumn:@"stop_sequence"] ];
        NSNumber *direction_id  = [NSNumber numberWithInt: [results intForColumn:@"direction_id"] ];
//        NSNumber *service_id    = [NSNumber numberWithInt: [results intForColumn:@"service_id"] ];
        
        NSString *arrivalTime   = [results stringForColumn:@"arrival_time"];
        NSString *departureTime; // = [results stringForColumn:@"departure_time"];
        NSString *stop_name     = [results stringForColumn:@"stop_name"];
        
        arrivalTime   = [arrivalTime substringToIndex: [arrivalTime length] -3];
        departureTime = [arrivalTime substringToIndex: [arrivalTime length] -3];
        
        if ( [stop_id integerValue] == routeData.current.start_stop_id)
        {
            _stopSequenceRow = [_stopSequence numberOfRows];
        }
        
        TripData *newTrip = [[TripData alloc] init];
        [newTrip setStart_stop_id: stop_id];
        [newTrip setTrip_id: trip_id];
        [newTrip setStart_stop_sequence: stop_sequence];
        [newTrip setStart_stop_name: stop_name];
        
        [newTrip setDirection_id: direction_id];
        [newTrip setStart_arrival_time: arrivalTime];
        [newTrip setEnd_arrival_time: departureTime];

        
        // Used for highlighting purposes in tableSeq
        if ( [stop_id integerValue] == routeData.current.start_stop_id )
        {
            _startSequence = [stop_sequence integerValue];
        }
        else if ( [stop_id integerValue] == routeData.current.end_stop_id )
        {
            _endSequence = [stop_sequence integerValue];
        }
        
        
        [_stopSequence addTimes: newTrip];
        
    }
        
        
        
//    } // if (sqlite3_open( [[GTFSCommon filePath] UTF8String], &db) == SQLITE_OK)

    if  ( ( [_stopSequence numberOfRows] >= _stopSequenceRow ) && ( [_stopSequence numberOfRows] != 0 ) )
    {
//        NSLog(@"seqRow: %d, seqCnt: %d", _stopSequenceRow, [_stopSequence numberOfRows]);
        [_stopSequence generateIndex];
        [self.tableSeq reloadData];
        [self.tableSeq scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_stopSequenceRow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    else
    {
        [_stopSequence clearIndex];
        TripData *newTrip = [[TripData alloc] init];
        [newTrip setStart_stop_name:@"No scheduled stops"];
        [newTrip setStart_stop_sequence: [NSNumber numberWithInt:-1] ];
        [newTrip setStart_arrival_time:@"23:59"];
        [_stopSequence addTimes: newTrip];
        
        [self.tableSeq reloadData];
        
    }

    [SVProgressHUD dismiss];
    
    
}


 -(void) fiveSecondsLater
 {
     
     NSLog(@"DSTVC - 5 Seconds Later");
     
     [self.tableView beginUpdates];
     
     TripData *trip = [[TripData alloc] init];
     [trip setStart_arrival_time: @"15:12"];
     [trip setStart_stop_id     : [NSNumber numberWithInt:0] ];
     
     [trip setEnd_arrival_time: @"16:12"];
     [trip setEnd_stop_id: [NSNumber numberWithInt:0]];
     
     [trip setTrip_id           : @"" ];
     [trip setDirection_id      : [NSNumber numberWithInt:0] ];
     [trip setStart_stop_sequence : [NSNumber numberWithInt:-1] ];
     [trip setEnd_stop_sequence   : [NSNumber numberWithInt:-2]];
     
//     [_showTimes addTimes: trip];
     NSUInteger insertPoint = 2;
     [_showTimes insert:trip atIndex: insertPoint];
     
     NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                 [NSIndexPath indexPathForRow:insertPoint inSection:0],
                                 nil];
     [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
     [self.tableView endUpdates];
 }


-(void) getStopTimes
{
    
    if ( ![SVProgressHUD isVisible] )
        [SVProgressHUD showWithStatus:@"Loading..."];
    
    [_showTimes clearData];  // Removes all data but the placeholders, in this case the data for the start and end cells
    
    if ( [[self travelMode] isEqualToString:@"Bus"] || [[self travelMode] isEqualToString:@"Rail"] || [[self travelMode] isEqualToString:@"MFL"] || [[self travelMode] isEqualToString:@"BSS"] || [[self travelMode] isEqualToString:@"NHSL"] )
    {
        // We're good
    }
    else  // Otherwise travelMode is not Bus or Rail
    {
        [SVProgressHUD dismiss];
        return;
    }
    
    // Begin SQL3 db process
//    NSLog(@"filename: %@", [GTFSCommon filePath]);
    
    if (sqlite3_open( [[GTFSCommon filePath] UTF8String], &db) == SQLITE_OK)
    {
        
        sqlite3_stmt * statement;
        NSString *queryStr;

        
        queryStr = [self returnQueryWithTravelModeForLocationType:locationType];
        NSLog(@"DSTVC - queryStr: %@", queryStr);

        
        // stop_id        INT
        // trip_id        TEXT
        // arrival_time   TIMESTAMP
        // departure_time TIMESTAMP
        // stop_sequence  TEXT
        // direction_id   INT
        
//        [trainNoArray removeAllObjects];
        
        if ( sqlite3_prepare_v2(db, [queryStr UTF8String], -1, &statement, nil) == SQLITE_OK )
        {
            
            while (sqlite3_step(statement)==SQLITE_ROW)
            {
                
                /*
                 BOTH: fields = @"start.stop_id, end.stop_id, end.trip_id, start.arrival_time, end.arrival_time, end.direction_id, start.stop_sequence, end.stop_sequence";
                 ONLY: fields = @"stop_id, trip_id, arrival_time, departure_time, direction_id, stop_sequence";
                 */
                
                NSDictionary *dict;
                if ( locationType == kLocationHasBoth )
                {
                    int start_stop_id         = (int) sqlite3_column_int(statement, 0);
                    int end_stop_id           = (int) sqlite3_column_int(statement, 1);
                    
                    char *trip_id             = (char*) sqlite3_column_text(statement, 2);  // Was column_int for buses, but rails trip_id isn't an integer
                    
                    char train_no[10];
                    int count = 0;
                    int LCV = 0;
                    
                    for (; LCV < strlen(trip_id); LCV++)  // Find first '_'
                    {
                        if ( trip_id[LCV] == '_' )
                            break;
                    }
                    
                    for (LCV = LCV+1; LCV < strlen(trip_id); LCV++)  // Read in numbers until next '_' is found
                    {
                        if ( trip_id[LCV] == '_' )
                            break;
                        
                        train_no[count++] = trip_id[LCV];
                    }
                    
//                    for (int LCV = 0; LCV < strlen(trip_id); LCV++)
//                    {
//                        if ( (int)trip_id[LCV] >= 48 && (int)trip_id[LCV] <= 57 )
//                        {
//                            train_no[count++] = trip_id[LCV];
//                        }
//                    }
                    train_no[count] = '\0';
                    
                    char *start_arrival_time  = (char*) sqlite3_column_text(statement, 3);
                    char *end_arrival_time    = (char*) sqlite3_column_text(statement, 4);
                    
                    char start_time[20];
                    char end_time[20];
                    strncpy(start_time, start_arrival_time, strlen(start_arrival_time)-3);
                    strncpy(end_time  , end_arrival_time  , strlen(end_arrival_time  )-3);
                    start_time[strlen(start_arrival_time)-3] = '\0';
                    end_time  [strlen(end_arrival_time  )-3] = '\0';
                    
                    int direction_id          = (int) sqlite3_column_int(statement, 5);
                    char *start_stop_sequence = (char*) sqlite3_column_text(statement,6);
                    char *end_stop_sequence   = (char*) sqlite3_column_text(statement,7);
                    
                    // Remove last 3 digits in start and end arrival_time
                    
                    if ( strcmp(start_time, end_time) >= 0 )
                    {
                        // If start_times is larger than end_time, this trip is invalid
                        continue;
                    }
                    
                    dict = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:
                                                                 [NSNumber numberWithInt: start_stop_id],
                                                                 [NSNumber numberWithInt: end_stop_id],
                                                                 [NSString stringWithCString:trip_id encoding:NSStringEncodingConversionAllowLossy],
                                                                 [NSString stringWithCString:train_no encoding:NSStringEncodingConversionAllowLossy],
                                                                 [NSString stringWithCString:start_time encoding:NSStringEncodingConversionAllowLossy],
                                                                 [NSString stringWithCString:end_time   encoding:NSStringEncodingConversionAllowLossy],
                                                                 [NSNumber numberWithInt: direction_id],
                                                                 [NSString stringWithUTF8String: start_stop_sequence],
                                                                 [NSString stringWithUTF8String: end_stop_sequence],
                                                                 nil]
                            
                                                       forKeys:[NSArray arrayWithObjects:
                                                                @"start_stop_id",
                                                                @"end_stop_id",
                                                                @"trip_id",
                                                                @"train_no",
                                                                @"start_arrival_time",
                                                                @"end_arrival_time",
                                                                @"direction_id",
                                                                @"start_stop_sequence",
                                                                @"end_stop_sequence",
                                                                nil] ];
                    
                }
                else
                {
                    int stop_id        = (int) sqlite3_column_int(statement, 0);
                    char *trip_id      = (char*) sqlite3_column_text(statement, 1);
                    
                    char *arrival_time = (char*) sqlite3_column_text(statement, 2);
                    
                    char time[20];
                    strncpy(time, arrival_time, strlen(arrival_time)-3);
                    time[strlen(arrival_time)-3] = '\0';
                    
                    int direction_id   = (int) sqlite3_column_int(statement, 4);
                    char *stop_sequence= (char*) sqlite3_column_text(statement,5);
                    
                    if ( locationType == kLocationOnlyHasStart )
                    {
                        dict = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:
                                                                     [NSNumber numberWithInt: stop_id],
                                                                     [NSString stringWithCString:trip_id encoding:NSStringEncodingConversionAllowLossy],
                                                                     [NSString stringWithCString:time encoding:NSStringEncodingConversionAllowLossy],
                                                                     [NSNumber numberWithInt: direction_id],
                                                                     [NSString stringWithUTF8String: stop_sequence],
                                                                     nil]
                                
                                                           forKeys:[NSArray arrayWithObjects:
                                                                    @"start_stop_id",
                                                                    @"trip_id",
                                                                    @"start_arrival_time",
                                                                    @"direction_id",
                                                                    @"start_stop_sequence",
                                                                    nil] ];
                    }
                    else
                    {
                        dict = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects:
                                                                     [NSNumber numberWithInt: stop_id],
                                                                     [NSString stringWithCString:trip_id encoding:NSStringEncodingConversionAllowLossy],
                                                                     [NSString stringWithCString:time encoding:NSStringEncodingConversionAllowLossy],
                                                                     [NSNumber numberWithInt: direction_id],
                                                                     [NSString stringWithUTF8String: stop_sequence],
                                                                     nil]
                                
                                                           forKeys:[NSArray arrayWithObjects:
                                                                    @"end_stop_id",
                                                                    @"trip_id",
                                                                    @"end_arrival_time",
                                                                    @"direction_id",
                                                                    @"end_stop_sequence",
                                                                    nil] ];
                        
                    }
                    
                    
                }
                
                TripData *trip = [[TripData alloc] init];
                [trip setValuesForKeysWithDictionary: dict];
                
//                [trainNoArray addObject:[trip train_no] ];
                
                [_showTimes addTimes: trip];

            } // while (sqlite3_step(statement)==SQLITE_ROW)
            
            sqlite3_finalize(statement);
            
        }
        else
        {
            int errorCode = sqlite3_step( statement );
            char *errMsg = (char *)sqlite3_errmsg(db);
            NSString *errStr = [[NSString alloc] initWithUTF8String:errMsg];
            NSLog(@"query failure, code: %d, %@", errorCode, errStr);
            NSLog(@"query str: %@", queryStr);
        } // if ( sqlite3_prepare_v2(db, [queryStr UTF8String], -1, &statement, nil) == SQLITE_OK )
        
    } // if(sqlite3_open([[GTFSCommon filepath] UTF8String], &db) == SQLITE_OK)
    
    //    [stops sort];
    //    [self configureSegmentedControl];
    
    NSLog(@"Number of rows: %d", [_showTimes numberOfRows]);
    sqlite3_close(db);  // Should probably open and close the database once, not multiple times.
    
    if ( [_showTimes numberOfRows] == 2 )  // 2 is considered empty now
    {
        //        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        //        [dict setObject:@"No scheduled stops" forKey:@"arrival_time"];
        //        [dict setObject:[NSNumber numberWithInt:0] forKey:@"stop_id"];
        //        [dict setObject:[NSNumber numberWithInt:0] forKey:@"trip_id"];
        //        [dict setObject:[NSNumber numberWithInt:0] forKey:@"direction_id"];
        //        [dict setObject:@"-1" forKey:@"stop_sequence"];
        
        TripData *trip = [[TripData alloc] init];
        [trip setStart_arrival_time: @"No scheduled stops"];
        [trip setStart_stop_id     : [NSNumber numberWithInt:0] ];
        [trip setTrip_id           : @"" ];
        [trip setDirection_id      : [NSNumber numberWithInt:0] ];
        [trip setStart_stop_sequence : [NSNumber numberWithInt:-1] ];
        [trip setEnd_stop_sequence   : [NSNumber numberWithInt:-2]];
        
        [_showTimes addTimes: trip];
    }
    
//    NSInteger numberOfRowsPerScreen = 10;
//    NSInteger numberOfRows = [_showTimes numberOfRows];
//    if ( numberOfRows < numberOfRowsPerScreen )  // If under 8 rows, add filler
//    {
//        for(int LCV=0; LCV< numberOfRowsPerScreen-numberOfRows; LCV++ )
//        {
//            TripData *trip = [[TripData alloc] init];
//            [trip setStart_arrival_time: nil];
//            [trip setStart_stop_id     : [NSNumber numberWithInt:0] ];
//            [trip setTrip_id           : @"" ];
//            [trip setDirection_id      : [NSNumber numberWithInt:0] ];
//            [trip setStart_stop_sequence : @"-1"];
//            [trip setEnd_stop_sequence   : @"-2"];
//            
//            [_showTimes addTimes: trip];
//        }
//    }
    
    [SVProgressHUD dismiss];
    
}

-(NSString*) returnQueryWithTravelModeForLocationType: (ShowTimesLocationType) location
{

    // Trying to keep this organized is such a way that doesn't make my eyes bleed
    NSString *fields;
    NSString *innerSQL;
    NSString *whereTime;
    NSString *where;
    
    NSString *groupBy;
    NSString *orderBy;
    NSString *queryStr = @"";
    
    NSInteger serviceID = 0;
    NSInteger index = [self.segmentDays selectedSegmentIndex];

    
    // Determine which service id was selected or which one is needed.
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;

    
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    [components setDay:21];
//    [components setMonth:12];
//    [components setYear:2012];
//    NSDate *thisDate = [gregorian dateFromComponents: components];

//    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate: thisDate];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate: [NSDate date] ];
//    comps = [gregorian components:NSWeekCalendarUnit fromDate:thisDate];
    
    
    BOOL now = NO;
    switch (index)
    {
        case 0:  // Now was selected.  So, what is today?  Week, Sat or Sun?
            ;
            
            now = YES;
            //                CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
            //                CFTimeZoneRef tz = CFTimeZoneCopySystem();
            //                SInt32 WeekdayNumber = CFAbsoluteTimeGetDayOfWeek(at, tz);
            //                CFRelease(tz);
            
            int service_id;
            switch ([comps weekday])
        {
            case 1:  // Sunday is 0
                service_id = 7;
                break;
            case 7:  // Saturday is 6
                service_id = 5;
                break;
            default: // Monday thru Friday are 2 thru 6, respectively
                service_id = 1;
                break;
        }
            
            serviceID = service_id;
            break;
        case 1:
            // Week
            serviceID = 1;
            break;
        case 2:
            // Sat
            serviceID = 5;
            break;
        case 3:
            // Sun
            serviceID = 7;
            break;
        case UISegmentedControlNoSegment:
            // Nothing was selected
            NSLog(@"DSTVC - Nothing was selected... this actually shouldn't be possible but there you go.");
            return nil;
            break;
        default:
            serviceID = 1;  // Default to 1
            break;
    }
    
    
    if ( [[self travelMode] isEqualToString:@"Bus"] || [[self travelMode] isEqualToString:@"MFL"] || [[self travelMode] isEqualToString:@"NHSL"] || [[self travelMode] isEqualToString:@"BSS"] )
    {
    
        switch (locationType)
        {
            case kLocationHasBoth:
                
                fields   = @"start.stop_id, end.stop_id, end.trip_id, start.arrival_time, end.arrival_time, end.direction_id, start.stop_sequence, end.stop_sequence";
                innerSQL = [NSString stringWithFormat:@"(SELECT * FROM route_ROUTE WHERE stop_id=%d AND direction_id=%d AND service_id=%d) as start", routeData.current.start_stop_id, routeData.current.direction_id, serviceID];
                
                if ( now )
                    whereTime = @"start.arrival_time > time('now','localtime') AND";
                else
                    whereTime = @"";
                
                where    = [NSString stringWithFormat:@"end.stop_id=%d AND end.direction_id=%d AND end.service_id=%d AND %@ start.trip_id=end.trip_id", routeData.current.end_stop_id, routeData.current.direction_id, serviceID, whereTime ];
                groupBy  = @"start.trip_id";
                orderBy  = @"start.arrival_time";
                queryStr = [NSString stringWithFormat:@"SELECT %@ FROM route_ROUTE as end, %@ WHERE %@ GROUP BY %@ ORDER BY %@", fields, innerSQL, where, groupBy, orderBy];
                
                break;
            case kLocationOnlyHasStart:
            case kLocationOnlyHasEnd:
                fields = @"stop_id, trip_id, arrival_time, departure_time, direction_id, stop_sequence";
                
                if ( now )
                    whereTime = @"route_ROUTE.arrival_time > time('now','localtime') AND";
                else
                    whereTime = @"";
                
                if ( locationType == kLocationOnlyHasStart )
                    where  = [NSString stringWithFormat:@"route_ROUTE.stop_id=%d AND %@ route_ROUTE.service_id=%d AND route_ROUTE.direction_id=%d", routeData.current.start_stop_id, whereTime, serviceID, routeData.current.direction_id];
                else if ( locationType == kLocationOnlyHasEnd )
                    where = [NSString stringWithFormat:@"route_ROUTE.stop_id=%d AND %@ route_ROUTE.service_id=%d AND route_ROUTE.direction_id=%d", routeData.current.end_stop_id, whereTime, serviceID, routeData.current.direction_id];
                
                groupBy = @"trip_id";
                orderBy = @"arrival_time";
                queryStr = [NSString stringWithFormat:@"SELECT %@ FROM route_ROUTE WHERE %@ GROUP BY %@ ORDER BY %@", fields, where, groupBy, orderBy];
                
                
                break;
                
            default:
                break;
        }  // switch (locationType)
    
        
    }  // if ( [self travelMode] isEqualToString:@"Bus")
    else if ( [[self travelMode] isEqualToString:@"Rail"])  // Rails!
    {
        
        NSString *startSQL = @"";
        NSString *endSQL   = @"";
        
        
        NSString *serviceStr;
        switch (serviceID)
        {
            case 1:
                serviceStr = @"S1";
                break;
            case 4:
                serviceStr = @"S4";  // Friday only trips
                break;
            case 5:
                serviceStr = @"S2";
                break;
            case 7:
                serviceStr = @"S3";
                break;
            default:
                serviceStr = @"";
                break;
        }
        
        
        switch (locationType)
        {
            case kLocationHasBoth:
                
        
                if ( now )
                    whereTime = @"AND start.arrival_time > time('now','localtime')";
//                    whereTime = @"AND start.arrival_time > time('23:55')";
                else
                    whereTime = @"";
                
                fields = @"start.stop_id, end.stop_id, start.trip_id, start.arrival_time, end.arrival_time, direction_id, start.stop_sequence, end.stop_sequence";
                
                startSQL = [NSString stringWithFormat:@"(SELECT trip_id, stop_id, arrival_time, direction_id, stop_sequence, service_id FROM route_ROUTE JOIN stop_times ON stop_times.uid = route_ROUTE.stop_times_uid WHERE stop_id=%d) as start", routeData.current.start_stop_id];
                endSQL   = [NSString stringWithFormat:@"(SELECT trip_id, stop_id, arrival_time, stop_sequence FROM route_ROUTE JOIN stop_times ON stop_times.uid = route_ROUTE.stop_times_uid WHERE stop_id=%d) as end", routeData.current.end_stop_id];
                
                where = [NSString stringWithFormat:@"start.trip_id = end.trip_id AND direction_id=%d AND service_id=\"%@\"", routeData.current.direction_id, serviceStr];
                
                groupBy = @"start.trip_id";
                orderBy = @"start.arrival_time";
                
                queryStr = [NSString stringWithFormat:@"SELECT %@ FROM %@, %@ WHERE %@ %@ GROUP BY %@ ORDER BY %@", fields, startSQL, endSQL, where, whereTime, groupBy, orderBy];
                
                
//                SELECT start.stop_id, end.stop_id, start.trip_id, start.arrival_time, end.arrival_time, direction_id, start.stop_sequence, end.stop_sequence FROM (SELECT trip_id, stop_id, arrival_time, direction_id, stop_sequence FROM route_WAR JOIN stop_times ON stop_times.uid=route_WAR.stop_times_uid WHERE stop_id=90413) as start, (SELECT trip_id, stop_id, arrival_time, stop_sequence FROM route_WAR JOIN stop_times ON stop_times.uid=route_WAR.stop_times_uid WHERE stop_id=90006) as end WHERE start.trip_id=end.trip_id AND direction_id=0 ORDER BY start.arrival_time;
                
                
                
                
                
                break;
            case kLocationOnlyHasStart:
            case kLocationOnlyHasEnd:
            {
                
//                if ( now )
//                    whereTime = @"start.arrival_time > time('now','localtime') AND";
//                else
//                    whereTime = @"";
                
                fields = @"stop_times.stop_id, trip_id, arrival_time, departure_time, \"-1\" as direction_id, stop_sequence";  // Redefine fields to handle ambiguious case
                //                NSString *joins = @"JOIN stop_times ON route_ROUTE.stop_times_uid=stop_times.uid";
                
                where    = [NSString stringWithFormat:@"stop_id=%d AND direction_id=%d", routeData.current.start_stop_id, routeData.current.direction_id];
                innerSQL = [NSString stringWithFormat:@"SELECT trip_id FROM route_ROUTE JOIN stop_times ON route_ROUTE.stop_times_uid=stop_times.uid WHERE %@", where];
                
                groupBy  = @"trip_id";
                orderBy  = @"arrival_time";
                
                if ( now )
                    whereTime = @"arrival_time > time('now','localtime') AND";
                else
                    whereTime = @"";
                
                queryStr = [NSString stringWithFormat:@"SELECT %@ FROM stop_times WHERE trip_id IN (%@) AND stop_id=%d AND %@ service_id=\"%@\" GROUP BY %@ ORDER BY %@", fields, innerSQL, routeData.current.start_stop_id, whereTime, serviceStr, groupBy, orderBy];
                
                break;
            }
            default:
                break;
        }  // switch (locationType)

        
    }  // else if ( [[self travelMode] isEqualToString:@"Rail"])
    
    queryStr = [queryStr stringByReplacingOccurrencesOfString:@"ROUTE" withString:routeData.current.route_short_name];

    
    return queryStr;
    
}


#pragma mark - Update Time in Cells
-(void) updateStopTimesData
{
    
//    NSArray *rows = [self.tableView visibleCells];
    //    NSLog(@"DSTVC - updateStopTimesData");
    
//    for (UITableViewCell *cell in rows)
//    {
//        if ( [cell isKindOfClass:[DisplayTimesCell class] ] )
//        {
//            if ( [(DisplayTimesCell*) cell use24HourTime] != _use24HourTime )
//            {
//                [(DisplayTimesCell*) cell setUse24HourTime:_use24HourTime];
//                [(DisplayTimesCell*) cell updateTimeFormats];
//            }
//
//            [(DisplayTimesCell*) cell updateCell];
//        }
//        
//    }
    
}


#pragma mark - Favorites
- (IBAction)favoritesButtonPressed:(id)sender
{
    
    // Add current selection to the favorites tab
    
    // First, check if a selection has been made, if not alert user with drop-down message (should last a few seconds before disappearing)
    
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
    if ( yesNO )
        [self.btnFavorite setTintColor:[UIColor yellowColor] ];
    else
        [self.btnFavorite setTintColor:[UIColor clearColor] ];
}


#pragma mark - Segment Display
- (IBAction)segmentDayPressed:(id)sender
{

    if ( oldIndex == [(TapableSegmentControl*)sender selectedSegmentIndex] )  // If the active segment is pressed again, display the start/end cells
    {
        //        NSLog(@"%@",self.tableView.indexPathsForVisibleRows);
        NSArray *visibleRows = self.tableView.indexPathsForVisibleRows;
        if ( [(NSIndexPath*)[visibleRows objectAtIndex:0] row] == 0 )  // If the first visibleRow is 0, the start/end cells are showing so hide them
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        else  // Likewise, the first visibleRow is not 0, so scroll up
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    }
    else  // Otherwise a new segment was pressed.  Determine if the cell countdown should be displayed, and then reload the data for that day
    {
        
        // TODO: Fold this into [self getStopTimes] as this is somewhat redundant
        /*
         
         Here is Justin's much better way of getting the current day of the week, known in the vernacular as "the weekday"
         
         NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
         NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
         int weekday;
         switch ([comps weekday])
         
         */
        
        CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
        CFTimeZoneRef tz = CFTimeZoneCopySystem();
        SInt32 WeekdayNumber = CFAbsoluteTimeGetDayOfWeek(at, tz);
        CFRelease(tz);
        
        NSInteger index = [(TapableSegmentControl*)sender selectedSegmentIndex];
        
        _displayCountDown = NO;  // Defaults to no, unless something turns it on.
        
//        WeekdayNumber = 0;  // It's a me, Sunday!

        // Note: _displayCountDown is set here, but used elsewhere.  Mainly when the timer kicks in and updates all the cells.
        switch ( WeekdayNumber )  // Get the current weekday.
        {
            case 0:  // It's Sunday!  Check if the Sunday index has been pressed
                if ( ( index == kTapableSegmentIndexSunday ) || ( index == kTapableSegmentIndexNow ) )
                    _displayCountDown = YES;
                break;
            case 6:  // It's Saturday!  Check if the Saturday index has been pressed
                if ( ( index == kTapableSegmentIndexSaturday ) || ( index == kTapableSegmentIndexNow ) )
                    _displayCountDown = YES;
                
            default: // It's the Weekday!  Check if Now or Week has been pressed
//                if ( ( index == kTapableSegmentIndexNow ) || (index == kTapableSegmentIndexWeek ) )
                if ( ( index == kTapableSegmentIndexWeek ) || ( index == kTapableSegmentIndexNow ) )
                    _displayCountDown = YES;
                break;
        }
        
        
        // Was these two lines before adding the dispatch queue portion
//        [self getStopTimes];
//        [self.tableView reloadData];

        if ( ![SVProgressHUD isVisible] )
            [SVProgressHUD showWithStatus:@"Loading..."];
        dispatch_queue_t initialQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(initialQueue, ^{
            
            //        NSLog(@"FLVC -(void) viewDidLoad -- Loading SVProgressHUD");
            [self getStopTimes];
            
            NSLog(@"FLVC - inside dispatch_async, reloadData");
            
            //        [self performSelector:@selector(reloadTableData) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
            //        [self performSelectorOnMainThread:@selector(reloadTableData) withObject:nil waitUntilDone:NO];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [SVProgressHUD dismiss];

                // When new segment is pressed, ensure that the start/end cell are hidden
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];

            });
            
        });
        
        
        
    }
    
    oldIndex = [(TapableSegmentControl*)sender selectedSegmentIndex];
    
}


#pragma mark - UIGestureRecoginzer Events
-(void) editLocation:(UITapGestureRecognizer*) recognizer
{
    
    NSLog(@"DSTVC - Edit Location recognized");
//    return;
    
//    if ( recognizer == editStartTap )
//    {
//        NSLog(@"DSTVC - Edit new start point");
//        StopTimesCell *thisCell = (StopTimesCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        [thisCell.btnGetStopNames sendActionsForControlEvents:UIControlEventTouchUpInside];  // In Storyboard, the button press triggers the transition to FindLocationVC.  This simulates a button press to the same affect
//    }
//    else if ( recognizer == editEndTap )
//    {
//        NSLog(@"DSTVC - Edit new end point");
//        StopTimesCell *thisCell = (StopTimesCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//        [thisCell.btnGetStopNames sendActionsForControlEvents:UIControlEventTouchUpInside];  // In Storyboard, the button press triggers the transition to FindLocationVC.  This simulates a button press to the same affect
//    }
}

#pragma mark - StopTimesCellProtocol
// TODO: Rename that to something that doesn't make me want to cringe, ok?

-(void) flipStopNamesButtonPressed
{
    
//    NSLog(@"DSTVC -(void)flippedButtonPressed");
//    return;
    
    // Flip start and end labels
    StopTimesCell *startCell = (StopTimesCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ];
    StopTimesCell *endCell   = (StopTimesCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] ];
    
    [startCell flipDataWithCell: endCell];
    //    [_showTimes switchRow:0 withRow:1];
    [_showTimes flipStartEnd];
    [routeData.current flipStartEndStops];
    
//    routeData.current.start_stop_name = [[startCell lblStopName] text];
    
    // There are two types of flips.  change start/end stops in the same direction and then keeping the same start/end stops but switching directions
//    routeData.current.direction_id = !routeData.current.direction_id;  // 0 direction becomes 1, 1 becomes 0.  Cats and dogs living together!
    
    // If there is only a start location choosing, flipping it now means there is only an end location.
    if ( locationType == kLocationOnlyHasStart )
    {
        locationType = kLocationOnlyHasEnd;
    }
    else if ( locationType == kLocationOnlyHasEnd )
    {
        locationType = kLocationOnlyHasStart;
    }
    
    
    // Check if flipped stop names are a favorite location
    if ( [routeData isObject:routeData.current inSection:kDisplayedRouteDataFavorites] )
        [self setFavoriteHighlight:YES];
    else
        [self setFavoriteHighlight:NO];
    
    
    [self getStopTimes];
    [self.tableView reloadData];
}


-(void) getStopNamesButtonPressed:(NSInteger) row
{
    NSLog(@"DSTVC -(void)getStopNamesButtonPressed: %d", row);
    
    if ( row == 0 )
        leftButtonType = kLeftButtonIsStart;
    else if ( row == 1 )
        leftButtonType = kLeftButtonIsEnd;
    else
        leftButtonType = kLeftButtonIsUndefined;
}


#pragma mark - Cell Button Events
//- (IBAction)flipButtonPressed:(id)sender
//{
//    NSLog(@"DSTVC -(void)flipButtonPressed");
//
//    // Flip start and end labels
//    ShowTimesStartCell *startCell = (ShowTimesStartCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ];
//    ShowTimesStartCell *endCell   = (ShowTimesStartCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] ];
//    
//    [startCell flipDataWithCell: endCell];
//    //    [_showTimes switchRow:0 withRow:1];
//    [_showTimes flipStartEnd];
//    [routeData.current flipStartEndStops];
//    
////    routeData.current.start_stop_name = [[startCell lblStopName] text];  // This gets handled in the flipStartEndStops
//    routeData.current.direction_id = !routeData.current.direction_id;  // 0 direction becomes 1, 1 becomes 0.  Cats and dogs living together!
//    
//    // If there is only a start location choosing, flipping it now means there is only an end location.
//    if ( locationType == kLocationOnlyHasStart )
//    {
//        locationType = kLocationOnlyHasEnd;
//    }
//    else if ( locationType == kLocationOnlyHasEnd )
//    {
//        locationType = kLocationOnlyHasStart;
//    }
//    
//    [self getStopTimes];
//    [self.tableView reloadData];
//    
//}


#pragma mark - Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSLog(@"DSTVC - prepareForSegue");
    if ( [[segue identifier] isEqualToString:@"FindLocationsStartSegue"] || [[segue identifier] isEqualToString:@"FindLocationsEndSegue"]  )
    {
        
        UINavigationController *navController = [segue destinationViewController];
        FindLocationsViewController *findVC = (FindLocationsViewController*)[navController topViewController];
        _findLocationsSegue = YES;
        
//        NSIndexPath *thisPath;
//        if ( leftButtonType == kLeftButtonIsStart )
//            thisPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        else if ( leftButtonType == kLeftButtonIsEnd )
//            thisPath = [NSIndexPath indexPathForRow:1 inSection:0];
        
        [findVC setTravelMode: self.travelMode];
        
        [findVC setRouteData: routeData];
        [findVC setButtonType: leftButtonType];
        [findVC setDelegate: self];
        
    }
    
}


#pragma mark - FindLocationsDelegate Protocol
-(void) doneButtonPressed:(FindLocationsViewController *)view WithStopName:(NSString *)selectedStopName andStopID:(NSInteger)selectedStopID
{
    
    NSLog(@"DSTVC -(void) doneButtonPressed, stopID: %d, stopName: %@", selectedStopID, selectedStopName);
    if ( [[self modalViewController] isBeingDismissed] )
        return;
    else
        [view dismissModalViewControllerAnimated:YES];
    
    
//    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    //    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    
    // Update Start or End
    NSIndexPath *thisPath; //, *thatPath;
    if ( leftButtonType == kLeftButtonIsStart )
    {
        thisPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        thatPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [routeData.current setStart_stop_name: selectedStopName];
        [routeData.current setStart_stop_id  :   selectedStopID];
        
        NSLog(@"DSTVC -(void) doneButtonPressed, set new start id/names.");
        if ( locationType == kLocationOnlyHasEnd )  // The start button was pressed but only the end location had a valid stop name.  Now they both do!
            locationType = kLocationHasBoth;
        
    }
    else if ( leftButtonType == kLeftButtonIsEnd )
    {
        thisPath = [NSIndexPath indexPathForRow:1 inSection:0];
//        thatPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [routeData.current setEnd_stop_name: selectedStopName];
        [routeData.current setEnd_stop_id  :   selectedStopID];
        
        NSLog(@"DSTVC -(void) doneButtonPressed, set new end id/names.");
        if ( locationType == kLocationOnlyHasStart )  // If start has a location and end just got a location, now they both have one.
            locationType = kLocationHasBoth;
    }
    
//    ShowTimesStartCell *thisCell = (ShowTimesStartCell*)[self.tableView cellForRowAtIndexPath:thisPath];
//    [[thisCell lblStopName] setText: selectedStopName];
    
    
    //    NSMutableDictionary *dict = [_showTimes objectForIndexPath:indexPath];
    //    [dict setObject: selectedStopName forKey:@"stop_name"];
    //    [_showTimes replaceObjectForIndexPath:thisPath withObject: dict];
    
    TripData *trip = [_showTimes objectForIndexPath: thisPath];
    
    if ( leftButtonType == kLeftButtonIsStart)
    {
        [trip setStart_stop_name : selectedStopName];
        [trip setStart_stop_id   : [NSNumber numberWithInt: selectedStopID] ];
    }
    else if ( leftButtonType == kLeftButtonIsEnd )
    {
        [trip setEnd_stop_name : selectedStopName];
        [trip setEnd_stop_id   : [NSNumber numberWithInt: selectedStopID] ];
    }
    
    [_showTimes replaceObjectForIndexPath:thisPath withObject:trip];
    
    [self getStopTimes];  // New stop_name has been selected, refresh data
    [self.tableView reloadData];  // Once data has been refreshed, reload the tableview to display new data
    
    
    if ( locationType == kLocationHasBoth )
    {
        // Reload the data
        //[self.tableView reloadData];
    }
    
}

-(void) cancelButtonPressed:(FindLocationsViewController *)view
{
    NSLog(@"DSTVC -(void) cancelButtonPressed");
    [view dismissModalViewControllerAnimated:YES];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark - MKMapViewDelegate Methods
-(MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
//    NSLog(@"DSTVC -mapView viewForOverlay");
    return [kmlParser viewForOverlay: overlay];
}

//-(MKAnnotationView*) mapView:(MKMapView *)thisMapView viewForAnnotation:(id<MKAnnotation>)annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
//    NSLog(@"DSTVC - viewForAnnotations");
    
    if ( [annotation isKindOfClass:[MKUserLocation class]] )
        return nil;
    
    static NSString *identifier = @"mapAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } else {
        annotationView.annotation = annotation;
    }
    
    [annotationView setEnabled: YES];
    [annotationView setCanShowCallout: YES];
    
    
    UIImage *image;
    if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"EastBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"SouthBound"] ) )
    {
        image = [UIImage imageNamed:@"bus_blue.png"];
    }
    else if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"WestBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"NorthBound"] ) )
    {
        image = [UIImage imageNamed:@"bus_red.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainSouth"] )
    {
        image = [UIImage imageNamed:@"train_blue.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainNorth"] )
    {
        image = [UIImage imageNamed:@"train_red.png"];
    }
    else
    {
        image = [UIImage imageNamed:@"bus_yellow.png"];
    }
    
    [annotationView setImage: image];

    return annotationView;
    
}


- (void)mapView:(MKMapView *)thisMapView regionDidChangeAnimated:(BOOL)animated
{
//    NSLog(@"DSTVC - mapView regionDidChangeAnimated");
    MKCoordinateRegion mapRegion;
    // set the center of the map region to the now updated map view center
    mapRegion.center = thisMapView.centerCoordinate;
    
    mapRegion.span.latitudeDelta = 0.3; // you likely don't need these... just kinda hacked this out
    mapRegion.span.longitudeDelta = 0.3;
    
    // get the lat & lng of the map region
    double lat = mapRegion.center.latitude;
    double lng = mapRegion.center.longitude;
    
    // note: I have a variable I have saved called lastLocation. It is of type
    // CLLocationCoordinate2D and I initially set it in the didUpdateUserLocation
    // delegate method. I also update it again when this function is called
    // so I always have the last mapRegion center point to compare the present one with
    CLLocation *before = [[CLLocation alloc] initWithLatitude:lastLocation.latitude longitude:lastLocation.longitude];
    CLLocation *now = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    
    CLLocationDistance distance = ([before distanceFromLocation:now]) * 0.000621371192;
    
    
//    NSLog(@"Scrolled distance: %@", [NSString stringWithFormat:@"%.02f", distance]);
    
    if( distance > SCROLL_UPDATE_DISTANCE )
    {
        // do something awesome
        
//        if(isSystemScroll)
//        {
//            isSystemScroll=NO;
//            thisMapView.visibleMapRect = flyTo;
//            
//            isSystemScroll=YES;
//            NSLog(@"scrolled out of bounds");
//            TransitmapView.frame = mapFrame;
//        }
        
    }
    
    // resave the last location center for the next map move event
    lastLocation.latitude = mapRegion.center.latitude;
    lastLocation.longitude = mapRegion.center.longitude;
    
}


#pragma mark - StopSequenceProtocol
-(void) doubleTapRecognized
{
    NSLog(@"doubleTap recognized in cell row: %d", [self.tableSeq indexPathForSelectedRow].row);
}


-(void) longPressRecognized
{
    NSLog(@"longPress recognized in cell row: %d", [self.tableSeq indexPathForSelectedRow].row);    
}

#pragma mark - UIGestureRecognizer Protocol
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
//    StopTimesCell *startCell = (StopTimesCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    StopTimesCell *endCell   = (StopTimesCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
//    if ( ( touch.view == startCell.btnFlipStopNames ) && ( gestureRecognizer == editStartTap ) )
//    if ( ( touch.view == startCell.btnFlipStopNames ) || (touch.view == endCell.btnFlipStopNames ) || ( touch.view == endCell.btnGetStopNames) || (touch.view == startCell.btnFlipStopNames) )
    {
//        NSLog(@"GesutreRecognizer NO!");
        return NO;
    }
    
//    NSLog(@"GestureRecognizer YES!");
    return YES;
    
}



- (IBAction)swipeGestureRecognized:(id)sender
{
    
    UISwipeGestureRecognizer *recognizer = (UISwipeGestureRecognizer*) sender;
//    CGPoint location = [recognizer locationInView:self.view];
    
    if ( recognizer.direction == UISwipeGestureRecognizerDirectionRight )
    {
        NSLog(@"Right swipe!");
        if (self.pageControl.currentPage > 0 )
        {
//            [self.pageControl setCurrentPage: self.pageControl.currentPage-1];
            self.pageControl.currentPage--;
            [self.pageControl sendActionsForControlEvents: UIControlEventTouchDown];
            [self.pageControl sendActionsForControlEvents: UIControlEventValueChanged];
//         [thisCell.btnGetStopNames sendActionsForControlEvents:UIControlEventTouchUpInside];  // In Storyboard, the button press triggers the transition to 
        }
    }
    else if ( recognizer.direction == UISwipeGestureRecognizerDirectionLeft )
    {
        NSLog(@"Left swipe!");
        if ( self.pageControl.currentPage < self.pageControl.numberOfPages )
        {
//            [self.pageControl setCurrentPage: self.pageControl.currentPage+1];
            self.pageControl.currentPage++;
            [self.pageControl sendActionsForControlEvents: UIControlEventTouchDown];
            [self.pageControl sendActionsForControlEvents: UIControlEventValueChanged];            
        }
    }
    
    
    
}


@end
