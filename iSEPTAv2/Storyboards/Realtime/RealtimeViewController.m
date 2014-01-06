//
//  RealtimeViewController.m
//  iSEPTA
//
//  Created by septa on 7/19/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "RealtimeViewController.h"


@interface RealtimeViewController ()

@end

@implementation RealtimeViewController
{
    UIImageView *_backgroundImage;
    BOOL _startTest;
    int _counter;
    
    SecondMenuAlertImageCycle _loopState;
    UIView *_testView;
    
    NSMutableArray *_alertMessage;
    NSTimer *_alertTimer;
    
    GetAlertDataAPI *_alertAPI;
    ALAlertBanner *_alertBanner;
    
    NSTimer *_dbVersionTimer;
    GetDBVersionAPI *_dbVersionAPI;
    
//    MMDrawerController *_drawerController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillDisappear:(BOOL)animated
{
    
    NSLog(@"RVC - viewWillDisappear");

    // Remove all timers from the main loop
    if ( _alertTimer != nil )
        [_alertTimer invalidate];

    if ( _dbVersionTimer != nil )
        [_dbVersionTimer invalidate];

    
    [ALAlertBanner forceHideAllAlertBannersInView:self.view];
    _alertBanner = nil;
    
//    [_alertAPI setDelegate:nil];
//    _alertAPI = nil;
    [_alertMessage removeAllObjects];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    // Start timers back up
    _alertTimer = [NSTimer scheduledTimerWithTimeInterval:ALALERTBANNER_TIMER target:self selector:@selector(getGenericAlert) userInfo:nil repeats:YES];
    [self getGenericAlert];

    _dbVersionTimer = [NSTimer scheduledTimerWithTimeInterval:DBVERSION_REFRESH target:self selector:@selector(checkDBVersion) userInfo:nil repeats:YES];
    [self checkDBVersion];
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self changeOrientation:currentOrientation];
    
//    if ( _startTest )
//    {
//        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(popTheVC) userInfo:nil repeats:NO];
//    }

    
    // Hold for 1 sec, transition for 1 sec.
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(loopImages) userInfo:nil repeats:YES];

    
}


-(void) popTheVC
{
    _counter++;
    NSLog(@"Transition: %d", _counter);
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MemoryTestStoryboard" bundle:nil];
//    MapMemoryTestViewController *tvVC = (MapMemoryTestViewController*)[storyboard instantiateInitialViewController];
//    [tvVC setCounter: _counter];
//    [self.navigationController pushViewController:tvVC animated:YES];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TrainSlidingStoryboard" bundle:nil];
    TrainViewViewController *tvVC = (TrainViewViewController*)[storyboard instantiateInitialViewController];
    [self.navigationController pushViewController:tvVC animated:YES];

}

//-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    if ( !UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) )
//    {
//        [_backgroundImage setTransform: CGAffineTransformMakeRotation( -0.5*M_PI )];
//        [_backgroundImage setFrame:CGRectMake(0, 0, 480, 300)];
//    }
//    else
//    {
//        [_backgroundImage setTransform: CGAffineTransformMakeRotation( 0 )];
//        [_backgroundImage setFrame:CGRectMake(0, 0, 320, 460)];
//    }
//}


//-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//
//    
//    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
//    {
//        [_backgroundImage setTransform: CGAffineTransformMakeRotation( -0.5*M_PI )];
//        [_backgroundImage setFrame:CGRectMake(0, 0, 480, 300)];
//    }
//    else
//    {
//        [_backgroundImage setTransform: CGAffineTransformMakeRotation( 0 )];
//        [_backgroundImage setFrame:CGRectMake(0, 0, 320, 460)];
//    }
//
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _startTest = NO;
    _counter = 0;
    
    _loopState = kSecondMenuAlertImageNone;
    
    // Do any additional setup after loading the view.

//    [self.view setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ] ];  // Does not work
    
//    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainBackground.png"] ];
//    _backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG_pattern.png"] ];
//    backgroundImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [backgroundImage setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [backgroundImage setFrame:CGRectMake(0, 0, 320, 460)];

//    [self.view addSubview:_backgroundImage];
//    [self.view sendSubviewToBack:_backgroundImage];
    
//    [[UINavigationBar appearance] setTintColor: [UIColor blackColor] ];
    
    
    // TabBar BS
//    UITabBarItem *tbi = self.tabBarController.tabBarItem;
//    [tbi setFinishedSelectedImage:[UIImage imageNamed:@"tabRealtimeIcon.png"] withFinishedUnselectedImage: [UIImage imageNamed:@"tabRealtimeIconSelected.png"] ];
    
    
//    [[[self tabBarController] tabBar] setSelectionIndicatorImage: [UIImage imageNamed:@"tabRealtimeIconSelected.png"] ];

    
//    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabMapIconSelected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabMapIcon.png"] ];
    
    _alertMessage = [[NSMutableArray alloc] init];
    
    NSString *version = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSLog(@"Version #: %@", version);
    
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.view setBackgroundColor: backgroundColor];
    
    
    UIImage *logo = [UIImage imageNamed:@"SEPTA_logo.png"];

    SEPTATitle *newView = [[SEPTATitle alloc] initWithFrame:CGRectMake(0, 0, logo.size.width, logo.size.height) andWithTitle:@"Realtime"];
    [newView setImage: logo];
    
    [self.navigationItem setTitleView: newView];
    [self.navigationItem.titleView setNeedsDisplay];
    
    
    [self automaticDownloading];
    
//    [self md5check];

    
//     ALAlertBanner *aab = [ALAlertBanner alertBannerForView:self.view
//                                               style:ALAlertBannerStyleFailure
//                                            position:ALAlertBannerPositionBottom
//                                               title:@"Alert"
//                                                   subtitle:@"This is a test of the Emergency Alert System"];
//                        
//
//    [aab show];
    
    
    
//    unsigned char buff[CC_MD5_DIGEST_LENGTH];
//    CC_MD5_CTX md5;
//    CC_MD5_Init(&md5);
//    
//    NSString *string1 = @"Gr";
//    NSString *string2 = @"eg";
//    
//    NSData *data1 = [string1 dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *data2 = [string2 dataUsingEncoding:NSUTF8StringEncoding];
//    
//    CC_MD5_Update(&md5, [data1 bytes], [data1 length]);
//    CC_MD5_Update(&md5, [data2 bytes], [data2 length]);
//    
//    CC_MD5_Final(buff, &md5);
//    
//    output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
//    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
//        [output appendFormat:@"%02x",buff[i]];
//    
//    NSLog(@"Greg: %@", output);
//    NSLog(@"Greg: %@", [self md5FromString:@"Greg"] );
    

    
    // Accessibility
    [self.btnNextToArrive        setAccessibilityLabel:@"Next to Arrive"];
    [self.btnTrainView           setAccessibilityLabel:@"TrainView"];
    [self.btnTransitView         setAccessibilityLabel:@"TransitView"];
    [self.btnSystemStatus        setAccessibilityLabel:@"System Status"];
    [self.btnFindNearestLocation setAccessibilityLabel:@"Fine Nearest Location"];
    [self.btnGuide               setAccessibilityLabel:@"Guide"];

    
    [self.lblNextToArrive setAccessibilityElementsHidden:YES];
    [self.lblTrainView    setAccessibilityElementsHidden:YES];
    [self.lblTransitView  setAccessibilityElementsHidden:YES];
    [self.lblSystemStatus setAccessibilityElementsHidden:YES];
    [self.lblFindNeareset setAccessibilityElementsHidden:YES];
    [self.lblLocations    setAccessibilityElementsHidden:YES];
    [self.lblGuide        setAccessibilityElementsHidden:YES];
    
    
    
}

-(void) automaticDownloading
{
    
    // Automatic Downloading needs to be broken into a few parts:
    //   - check that the device has space for the new database
    //      - check the space taken up by downloading, deleting the old database, uncompressing the zip and replacing the new database
    //   - downloading
    //      - how to do it, where to put the file
    //      - background processing
    //      - autorecovery due to connectivity issues
    //   - allow downloading without regard of how many other people are downloading the app, or allow downloading at certain intervals
    //
    
    unsigned long long space = 0;
    
    space = [self getFreeSpace];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *formatted = [formatter stringFromNumber:[NSNumber numberWithLongLong:space] ];
    
    NSLog(@"free space: %@", formatted);
    
    
    NSString *dbPath = [self filePath];
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath: dbPath error: NULL];
    UInt64 result = [attrs fileSize];
    
    formatted = [formatter stringFromNumber: [NSNumber numberWithLongLong: result] ];
    NSLog(@"db Size:    %@", formatted);

    
    [self downloadTest];
    
}

-(void) checkDBVersion
{
    
    if ( _dbVersionAPI == nil )
    {
        _dbVersionAPI = [[GetDBVersionAPI alloc] init];
        [_dbVersionAPI setDelegate:self];
    }
    
    [_dbVersionAPI fetchData];
    
}

-(void) dbVersionFetched:(DBVersionDataObject*) obj
{
    NSLog(@"version: %@", obj);
}


-(void) downloadTest
{

    
    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    
//    NSURL *URL = [NSURL URLWithString:@"http://example.com/download.zip"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
//        return [documentsDirectoryPath URLByAppendingPathComponent:[response suggestedFilename]];
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        NSLog(@"File downloaded to: %@", filePath);
//    }];
//    [downloadTask resume];
    
}


-(unsigned long long)getFreeSpace
{

    unsigned long long freeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary)
    {
        NSNumber *fileSystemFreeSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];
        freeSpace = [fileSystemFreeSizeInBytes longLongValue];
    } else {
        //Handle error
    }
    
    return freeSpace;

}


-(void) dateCheck
{
    
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit
                                                       fromDate:today];
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
    
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract
                                                         toDate:today options:0];
    
    NSLog(@"Done");
    
}


-(void) md5check
{
    
    NSDate *start = [NSDate date];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    NSData *fileData = [NSData dataWithContentsOfFile: [self filePath] ];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(fileData.bytes, fileData.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    NSTimeInterval secondsRan = [[NSDate date] timeIntervalSinceDate: start ];
    
    NSLog(@"output (%6.2f sec): %@", secondsRan, output);
    
    
    start = [NSDate date];
    
    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
    
    if ( ![database open] )
    {
        [database close];
        return;
    }
    
    NSString *tableQuery = @"SELECT tbl_name FROM sqlite_master WHERE type='table';";  // type, name, tbl_name, rootpage, sql (where sql is CREATE TABLE x (y INT, z TEXT, etc.)
    FMResultSet *tableResults = [database executeQuery: tableQuery];
    NSMutableArray *tableArray = [[NSMutableArray alloc] init];
    
    while ( [tableResults next] )
    {
        [tableArray addObject: [tableResults stringForColumnIndex:0] ];
    }
    
    NSMutableString *string = [[NSMutableString alloc] init];
    NSString *finalStr;
    for (NSString *tableName in tableArray)
    {
        
//        unsigned char buff[CC_MD5_DIGEST_LENGTH];
        CC_MD5_CTX md5;
        CC_MD5_Init(&md5);
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
        FMResultSet *results = [database executeQuery:query];
        
        [string setString:@""];
        
        while ( [results next] )
        {
            for (int LCV = 0; LCV < [results columnCount]; LCV++ )
            {
                [string appendFormat:@"%@,", [results stringForColumnIndex:LCV] ];
            }
        }
        
        finalStr = [string substringToIndex: [string length] -1 ];
//        NSData *rowData = [finalStr dataUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@: %@", tableName, [[results resultDictionary] allKeys]);
        
    }
    
    
    // CREATE TABLE routes_rail(route_id TEXT, route_short_name TEXT, route_long_name TEXT, route_type INT);
    NSString *query = @"SELECT * FROM routes_rail";
    FMResultSet *results = [database executeQuery:query];
    
    unsigned char buff[CC_MD5_DIGEST_LENGTH];
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    while ( [results next] )
    {
        NSString *rowStr = [NSString stringWithFormat:@"%@,%@,%@,%d", [results stringForColumnIndex:0], [results stringForColumnIndex:1], [results stringForColumnIndex:2], [results intForColumnIndex:3] ];
        NSData *rowData = [rowStr dataUsingEncoding:NSUTF8StringEncoding];
        CC_MD5_Update(&md5, [rowData bytes], [rowData length]);
    }
    
    CC_MD5_Final(buff, &md5);
    
    output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",buff[i]];
    
    NSLog(@"routes_rail: %@", output);
    
    [database close];
    
}

-(void) getGenericAlert
{

    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
    {
        return;
    }
    
    // Run every minute
    if ( _alertAPI == nil )
    {
        _alertAPI = [[GetAlertDataAPI alloc] init];
        [_alertAPI setDelegate:self];
        
        [_alertAPI addRoute:@"generic" ofModeType:kSEPTATypeNone];
    }
    
    [_alertAPI fetchAlert];

    
}


-(void) alertFetched:(NSMutableArray*) alert
{
    
//    SystemAlertObject *saObject = [alert objectAtIndex:0];

    if ( [alert count] == 0 )
        _alertMessage = nil;
    
//    SystemAlertObject *newAlert = [alert objectAtIndex:0];
//    [alert addObject: newAlert];
    
    BOOL duplicateFound = 0;
    for (SystemAlertObject *saObject in alert)
    {
     
        if ( [saObject numOfAlerts] < 1 )
            break;
        
        for (NSString *message in _alertMessage)
        {
            NSLog(@"Checking for message: %@", message);
            if ( [message isEqualToString: saObject.current_message] )
            {
                duplicateFound = 1;
                break;
                NSLog(@"Duplicate message found");
            }
            else
                NSLog(@"No duplicate message found");
        }
        
        
        if ( saObject.current_message == nil )
            return;
        
        //    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        //    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        // appDelegate.window
        
//        _alertMessage = saObject.current_message;
        
        // No good mechanism for removing an alertMessage
        if ( !duplicateFound )
        {
            [_alertMessage addObject: saObject.current_message];
        
        
            _alertBanner = [ALAlertBanner alertBannerForView:self.view
                                                   style:ALAlertBannerStyleFailure
                                                position:ALAlertBannerPositionBottom
                                                   title:@"Alert"
                                                subtitle:saObject.current_message
                                             tappedBlock:^(ALAlertBanner *alertBanner)
                        {
                            NSLog(@"Generic Message: %@!", saObject.current_message);
                            [_alertBanner hide];
                        }];

            NSTimeInterval showTime = 5.0f;
            [_alertBanner setSecondsToShow: showTime];

            [_alertBanner show];
        }
        
    }
    
}


-(NSString*) md5FromString: (NSString *) baseString
{
    
    const char *ptr = [baseString UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
    
}


-(void) loopImages
{
    
    
    switch (_loopState)
    {
        case kSecondMenuAlertImageAlert:

            break;
            
        case kSecondMenuAlertImageAdvisory:
            
            break;
            
        case kSecondMenuAlertImageDetour:
            
            break;
            
        default:
            break;
    }

    
}


-(NSString*) filePath
{
    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
}


-(void) testImage
{
    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"second-menu.png"] ];
//
////    [imageView setFrame:CGRectMake(0, self.view.frame.size.height - 60, imageView.frame.size.width, imageView.frame.size.height)];
//    
//    [self.view addSubview: imageView];
//    [self.view bringSubviewToFront: imageView];

//    [self.navigationItem.rightBarButtonItem setImage: [UIImage imageNamed:@"second-menu.png"] ];
    
    
    
//    _testView = [[UIView alloc] initWithFrame:CGRectMake(10, 260, 50, 37.5)];
//    
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 40, 30)];
//    imgView.image = [UIImage imageNamed:@"second-menu.png"];
//    imgView.contentMode = UIViewContentModeCenter;
//    
//    UIImageView *alertImg = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, 40/2.0f, 30/2.0f)];
//    [alertImg setImage: [UIImage imageNamed:@"system_status_alert.png"] ];
//    
//    UIImageView *advisoryImg = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, 40/2.0f, 30/2.0f)];
//    [advisoryImg setImage: [UIImage imageNamed:@"system_status_advisory.png"] ];
//    [advisoryImg setAlpha:0.0f];
//    
//    UIImageView *detourImg = [[UIImageView alloc] initWithFrame:CGRectMake(23, 0, 40/2.0f, 30/2.0f)];
//    [detourImg setImage: [UIImage imageNamed:@"system_status_detour.png"] ];
//    [detourImg setAlpha:0.0f];


    
//    MenuAlertsImageView *mView = [[MenuAlertsImageView alloc] initWithFrame: CGRectMake(10, 260, 50, 37.5)];
//    
//    [mView setBaseImage: [UIImage imageNamed:@"second-menu.png"] ];
//    
//    [mView addAlert: kMenuAlertsImageAlerts];
//    [mView addAlert: kMenuAlertsImageDetours];
//    [mView addAlert: kMenuAlertsImageAdvisories];
//    
//    [self.view addSubview: mView];
//    
//    [mView startLoop];

    
    
    /*
     
     ObjectView: UIImageView
     
     [object addAlert: kSecondMenuAlert];
     [object addAlert: kSecondMenuAdvisory];
     [object addAlert: kSecondMenuDetour];
     
     [object removeAllAlerts];
     [object removeAlert: kSecondMenuAlert];
     
     [object nextLoop];  // duration + delay, starts state machine
     [object stopLoop];  <-- cancel running animation block?, ends state machine
     
     [object setDuration: 1.5f];
     [object setDelay:    0.5f];
     
     [object setBaseImageView: (UIImageView*) image];
     [object setOverlayImageView: (UIImageView*) image];
     
     // One alert   - always on
     // Two+ alerts - cycle through
     
     // Circular linked list
     
     [p][data][n]
     
     data
       - image
       - ???
     
     */
    
//    [UIView animateWithDuration:1.5f
//                          delay:0.5f
//                        options: UIViewAnimationCurveEaseInOut
//                     animations:^{
//                         [alertImg setAlpha:0.0f];
//                         [advisoryImg setAlpha:1.0f];
//                     }
//                     completion:^(BOOL finished) {
//
//                         
//                         [UIView animateWithDuration:1.5f
//                                               delay:0.5f
//                                             options: UIViewAnimationOptionOverrideInheritedCurve | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
//                                          animations:^{
//                                              [UIView setAnimationRepeatCount:2.5];
//                                              [advisoryImg setAlpha:0.0f];
//                                              [detourImg setAlpha:1.0f];
//                                          }
//                                          completion:^(BOOL finished) {
//                                              NSLog(@"Animation complete");
//                                          }];
//                     }];
    
//    [self.view addSubview: imgView];
    
//    [_testView addSubview:imgView];
//    
//    [_testView addSubview:alertImg];
//    [_testView addSubview:advisoryImg];
//    [_testView addSubview:detourImg];
//    
//    [self.view addSubview: _testView];
    
    NSLog(@"RVC - Added Image");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    
    [self setBtnNextToArrive:nil];
    [self setBtnTrainView:nil];
    [self setBtnTransitView:nil];
    
    [self setBtnFindNearestLocation:nil];
    [self setBtnSystemStatus:nil];
    [self setBtnGuide:nil];
    
    [super viewDidUnload];
    
}


-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

//    [self changeOrientation:fromInterfaceOrientation];
    
}


-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

    [self changeOrientation:toInterfaceOrientation];
    
//    if ( UIInterfaceOrientationIsLandscape( toInterfaceOrientation ) )
//    {
//        // Add more padding to the buttons
//    }
//    else
//    {
//        // Squish the buttons together
//    }
    
}


-(void) changeOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{

    CGFloat width;
    
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
    {
        width = [[UIScreen mainScreen] bounds].size.height;
    }
    else
    {
        width = [[UIScreen mainScreen] bounds].size.width;
    }
    

    int buttonWidth = 96;
    
    int padding = (width - buttonWidth*3)/4;
    
    // p = (w - 3*96) / 4
    
    CGRect btnNextToArriveRect = self.btnNextToArrive.frame;
    CGRect lblNextToArriveRect = self.lblNextToArrive.frame;
    
    btnNextToArriveRect.origin.x = padding;
    lblNextToArriveRect.origin.x = btnNextToArriveRect.origin.x;
    [self.btnNextToArrive setFrame: btnNextToArriveRect];
    [self.lblNextToArrive setFrame: lblNextToArriveRect];
    
    CGRect btnTrainViewRect = self.btnTrainView.frame;
    CGRect lblTrainViewRect = self.lblTrainView.frame;
    
    btnTrainViewRect.origin.x = 2*padding+buttonWidth;
    lblTrainViewRect.origin.x = btnTrainViewRect.origin.x;
    [self.btnTrainView setFrame: btnTrainViewRect];
    [self.lblTrainView setFrame: lblTrainViewRect];
    
    CGRect btnTransitViewRect = self.btnTransitView.frame;
    CGRect lblTransitViewRect = self.lblTransitView.frame;
    
    btnTransitViewRect.origin.x = 3*padding + 2*buttonWidth;
    lblTransitViewRect.origin.x = btnTransitViewRect.origin.x;
    [self.btnTransitView setFrame: btnTransitViewRect];
    [self.lblTransitView setFrame: lblTransitViewRect];
    
    
    CGRect btnSystemStatusRect = self.btnSystemStatus.frame;
    CGRect lblSystemStatusRect = self.lblSystemStatus.frame;
    btnSystemStatusRect.origin.x = padding;
    lblSystemStatusRect.origin.x = btnSystemStatusRect.origin.x;
    
    [self.btnSystemStatus setFrame: btnSystemStatusRect];
    [self.lblSystemStatus setFrame: lblSystemStatusRect];
    
    CGRect btnNearestLocationRect = self.btnFindNearestLocation.frame;
    CGRect lblFindNearestRect     = self.lblFindNeareset.frame;
    CGRect lblLocationRect        = self.lblLocations.frame;
    btnNearestLocationRect.origin.x = 2*padding+buttonWidth;
    lblFindNearestRect.origin.x = btnNearestLocationRect.origin.x;
    lblLocationRect.origin.x = btnNearestLocationRect.origin.x;
    
    [self.btnFindNearestLocation setFrame: btnNearestLocationRect];
    [self.lblFindNeareset setFrame: lblFindNearestRect];
    [self.lblLocations setFrame: lblLocationRect];
    
    
    CGRect btnGuideRect = self.btnGuide.frame;
    CGRect lblGuideRect = self.lblGuide.frame;
    
    btnGuideRect.origin.x = 3*padding+2*buttonWidth;
    lblGuideRect.origin.x = btnGuideRect.origin.x;
    [self.btnGuide setFrame: btnGuideRect];
    [self.lblGuide setFrame: lblGuideRect];
}



#pragma mark -= Button Presses
- (IBAction)btnNextToArrivePressed:(id)sender
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NextToArriveStoryboard" bundle:nil];
    NextToArriveTableViewController *ntaVC = (NextToArriveTableViewController*)[storyboard instantiateInitialViewController];
    
    [self.navigationController pushViewController:ntaVC animated:YES];
    
}

- (IBAction)btnTrainViewPressed:(id)sender
{

    
//    MMDrawerTestViewController *testVC = [[MMDrawerTestViewController alloc] init];
//    [self.navigationController pushViewController:testVC animated:YES];
    
    
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TrainViewStoryboard" bundle:nil];
//    TrainViewViewController *tvVC = (TrainViewViewController*)[storyboard instantiateInitialViewController];
//    [self.navigationController pushViewController:tvVC animated:YES];
//    
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MemoryTestStoryboard" bundle:nil];
//    MapMemoryTestViewController *tvVC = (MapMemoryTestViewController*)[storyboard instantiateInitialViewController];
//    _startTest = YES;
//    [tvVC setCounter: _counter];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TrainSlidingStoryboard" bundle:nil];
    TrainViewViewController *tvVC = (TrainViewViewController*)[storyboard instantiateInitialViewController];
    [self.navigationController pushViewController:tvVC animated:YES];
    

}


- (IBAction)btnTransitViewPress:(id)sender
{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TransitViewStoryboard" bundle:nil];
    TransitViewViewController *tvVC = (TransitViewViewController*)[storyboard instantiateInitialViewController];
    
//    [tvVC setTravelMode:@"Rail"];
    
    [self.navigationController pushViewController:tvVC animated:YES];

    
}

- (IBAction)btnSystemStatusPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SystemStatusStoryboard" bundle:nil];
    SystemStatusViewController *ssVC = (SystemStatusViewController*)[storyboard instantiateInitialViewController];
    
    //    [tvVC setTravelMode:@"Rail"];
    
    [self.navigationController pushViewController:ssVC animated:YES];
}

- (IBAction)btnFindNearestLocationPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NearestLocationStoryboard" bundle:nil];
    NearestLocationViewController *nlVC = (NearestLocationViewController*)[storyboard instantiateInitialViewController];
    
    //    [tvVC setTravelMode:@"Rail"];
    
    [self.navigationController pushViewController:nlVC animated:YES];
    
}


- (IBAction)btnGuidePressed:(id)sender
{
    
}






@end
