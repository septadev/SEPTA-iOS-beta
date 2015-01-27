//
//  RealtimeViewController.m
//  iSEPTA
//
//  Created by septa on 7/19/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "RealtimeViewController.h"

//#define BACKGROUND_DOWNLOAD 1

@interface RealtimeViewController ()

@end

@implementation RealtimeViewController
{
    UIImageView *_backgroundImage;
    BOOL _startTest;
    
    BOOL _testMode;
    
    int _counter;
    
    SecondMenuAlertImageCycle _loopState;
    UIView *_testView;
    
    NSMutableArray *_alertMessage;
//    NSMutableArray *_alertBannerArr;
    NSTimer *_alertTimer;
    
    GetAlertDataAPI *_alertAPI;
//    ALAlertBanner *_alertBanner;
    
    NSTimer *_dbVersionTimer;
//    NSTimer *_testTimer;
    GetDBVersionAPI *_dbVersionAPI;
    
    
    // Background Process for Schedule Automatic Refresh
    NSOperationQueue *_autoUpdateQueue;
    NSBlockOperation *_autoUpdateOp;
    
    
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
    
    [super viewWillDisappear:animated];
    
    NSLog(@"RVC - viewWillDisappear");
    
    NSLog(@"RVC - Alert Banners In View:%@", [ALAlertBanner alertBannersInView:self.view]);
    [ALAlertBanner forceHideAllAlertBannersInView:self.view];
    
//    for (ALAlertBanner *alertBanner in [ALAlertBanner alertBannersInView:self.view])
//    {
//        [ALAlertBanner hideAllAlertBanners];
//        [ALAlertBanner hideAlertBanner:alertBanner forced:YES];
//    }
    
//    for (ALAlertBanner *alertBanner in [ALAlertBanner alertBannersInView:self.view])
//    {
//        [ALAlertBanner hideAllAlertBanners];
//    }
    
    
//    [_alertBannerArr removeAllObjects];
    
    // Remove all timers from the main loop
    if ( _alertTimer != nil )
        [_alertTimer invalidate];

    if ( _dbVersionTimer != nil )
        [_dbVersionTimer invalidate];

    
//    [_alertAPI setDelegate:nil];
//    _alertAPI = nil;
    [_alertMessage removeAllObjects];
    
    [SVProgressHUD dismiss];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    [self checkDBExists];
    
    [SVProgressHUD dismiss];
    [ALAlertBanner forceHideAllAlertBannersInView:self.view];
    
    // Start timers back up
    _alertTimer = [NSTimer scheduledTimerWithTimeInterval:ALALERTBANNER_TIMER target:self selector:@selector(getGenericAlert) userInfo:nil repeats:YES];
    [self getGenericAlert];

    // This does not fail reachability safely
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


//-(void) popTheVC
//{
//    _counter++;
//    NSLog(@"Transition: %d", _counter);
////    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MemoryTestStoryboard" bundle:nil];
////    MapMemoryTestViewController *tvVC = (MapMemoryTestViewController*)[storyboard instantiateInitialViewController];
////    [tvVC setCounter: _counter];
////    [self.navigationController pushViewController:tvVC animated:YES];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TrainSlidingStoryboard" bundle:nil];
//    TrainViewViewController *tvVC = (TrainViewViewController*)[storyboard instantiateInitialViewController];
//    [self.navigationController pushViewController:tvVC animated:YES];
//
//}

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
    _testMode  = NO;
    _counter = 0;
    
    _loopState = kSecondMenuAlertImageNone;
    
    _alertMessage = [[NSMutableArray alloc] init];
    
    
//    NSString *version = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
//    NSLog(@"Version #: %@", version);
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.view setBackgroundColor: backgroundColor];
    
    
    UIImage *logo = [UIImage imageNamed:@"SEPTA_logo.png"];

    SEPTATitle *newView = [[SEPTATitle alloc] initWithFrame:CGRectMake(0, 0, logo.size.width, logo.size.height) andWithTitle:@"Realtime"];
    [newView setImage: logo];
    
    
    [self.navigationItem setTitleView: newView];
    [self.navigationItem.titleView setNeedsDisplay];
    
    
//    [self automaticDownloading];
//    [self checkDBVersion];
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
    
    
    
    
    
    //GTFSCommon *common = [[GTFSCommon alloc] init];
    

//    int serviceID_today = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetToday];
//    int serviceID_sat   = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetSat];
//    int serviceID_sun   = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetSun];
//    int serviceID_week  = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetWeekday];
//    
//    int serviceID_tom = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetTomorrow];
//    
//    NSLog(@"Today: %d", serviceID_today);
//    
//    NSLog(@"Sat  : %d", serviceID_sat);
//    NSLog(@"Sun  : %d", serviceID_sun);
//    NSLog(@"Week : %d", serviceID_week);
//    
//    NSLog(@"Tom  : %d", serviceID_tom);

    
//    NSArray *sids = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetToday];
//    NSLog(@"today: %@ - is it service_id 1? %d", sids, [GTFSCommon checkService:1 withArray:sids]);
//    
//    sids = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetTomorrow];
//    NSLog(@"tom: %@", sids);
//    NSLog(@"Does it match service_id 1? %@", [GTFSCommon checkService:1 withArray:sids] ? @"Yes" : @"No" );
//    NSLog(@"Does it match service_id 2? %@", [GTFSCommon checkService:2 withArray:sids] ? @"Yes" : @"No" );
//    NSLog(@"Does it match service_id 3? %@", [GTFSCommon checkService:3 withArray:sids] ? @"Yes" : @"No" );
//    NSLog(@"Does it match service_id 4? %@", [GTFSCommon checkService:4 withArray:sids] ? @"Yes" : @"No" );
//    NSLog(@"Does it match service_id 5? %@", [GTFSCommon checkService:5 withArray:sids] ? @"Yes" : @"No" );
//    
//    sids = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetSat];
//    NSLog(@"sat: %@", sids);
//    
//    sids = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetSun];
//    NSLog(@"sun: %@", sids);
//    
//    sids = [GTFSCommon getServiceIDFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetYesterday];
//    NSLog(@"yes: %@", sids);
//    
//    NSString *sStr = [GTFSCommon getServiceIDStrFor:kGTFSRouteTypeRail withOffset:kGTFSCalendarOffsetTomorrow];
//    NSLog(@"tomStr: %@", sStr);
//    
//    
//    NSLog(@"End of test");
    
    
//    [[Crashlytics sharedInstance] crash];

    
    /*  send a request for file modification date  */
//    NSURLRequest *modReq = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.septa.org/service/septa-app-mobile.html"]
//                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0f];
//    
//    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:modReq delegate:self];
//    
//    if ( !theConnection )
//    {
//        // Connect failed
//    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /*  convert response into an NSHTTPURLResponse,
     call the allHeaderFields property, then get the
     Last-Modified key.
     */
    
    // Get last stored modified date, if one exists.
    // If not, set to nil

    
    NSString * last_modified = [NSString stringWithFormat:@"%@",
                                [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Last-Modified"]];
    
    // Last-Modified = "Mon, 26 Jan 2015 19:14:05 GMT"
    // Convert to NSDate
    
    // If stored_date is nil, just store the new last_modified
    // If stored_date equals last_modified, do nothing
    // If last_modified is newer, add badge to Tips until tapped on
    
    
    NSLog(@"Last-Modified: %@", last_modified );
                                
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
    
    
    NSString *dbPath = [GTFSCommon filePath];
    NSLog(@"dbPath: %@", dbPath);
    NSLog(@"dbPath: %@", [dbPath stringByDeletingLastPathComponent] );
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath: dbPath error: NULL];
    UInt64 result = [attrs fileSize];
    
    formatted = [formatter stringFromNumber: [NSNumber numberWithLongLong: result] ];
    NSLog(@"db Size:    %@", formatted);

    
//    [self downloadTest];
    
}

-(void) checkDBExists
{
    
    [GTFSCommon filePath];
    
//    NSLog(@"Break point");
    
}

-(void) checkDBVersion
{
    
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
    {
        return;
    }
    
    if ( _dbVersionAPI == nil )
    {
        _dbVersionAPI = [[GetDBVersionAPI alloc] init];
        [_dbVersionAPI setDelegate:self];
    }

    
//    [_dbVersionAPI setTestMode: _testMode];

    [_dbVersionAPI fetchData];
    
    if ( _alertAPI == nil )
    {
        _alertAPI = [[GetAlertDataAPI alloc] init];
        [_alertAPI setDelegate:self];
        
        [_alertAPI addRoute:@"generic" ofModeType:kSEPTATypeNone];
    }
    
   
    [_alertAPI fetchAlert];
    
    
    
}

//-(void) downloadProgress
//{
//    
//    BackgroundDownloader *bDown = [BackgroundDownloader sharedInstance];
//    long long bytesRead;
//    float percent;
//    
//    [bDown downloadStatusForBytes: &bytesRead andPercentDone: &percent];
//    
//    NSLog(@"bytes: %lld, percent: %6.3f", bytesRead, percent);
//    
//    
//}


-(void) dbVersionFetched:(DBVersionDataObject*) obj
{
    
    
#ifdef BACKGROUND_DOWNLOAD
    // Check if Auto-Update has been turned on
//    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:Update:AutoUpdate"];
//    if ( object != nil )
//    {
//        if ( [object boolValue] )
//        {
//            BackgroundDownloader *bDown = [BackgroundDownloader sharedInstance];
//            [bDown setDbObject:obj];
//            [bDown downloadSchedule];
//        }
//    }
    
    //    _testTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(downloadProgress) userInfo:nil repeats:YES];
    
#endif
    

    if ( [obj.severity isEqualToString:@"high"] )
    {
        [self displayAlert:obj];
        return;
    }
    

    [_dbVersionAPI loadLocalMD5];
    if ( ( obj.message != nil ) && ( ![[_dbVersionAPI localMD5] isEqualToString: obj.md5] ) )
    {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/d/yy";
        
        NSDate *date = [dateFormatter dateFromString: obj.effective_date];
        
        NSTimeInterval effectiveDiff = [date timeIntervalSinceNow];
        NSTimeInterval lastDateDiff;
        
        NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:Update:DateOfLastNotification"];
        
        if ( lastDate == nil )
            lastDateDiff = 60*60*24*365;
        else
            lastDateDiff = [[NSDate date] timeIntervalSinceDate: lastDate];
        
        
        // Two checks are performed to determine if an alert message goes up
        //   Does the new schedule go into effect within the next 7 days?
        //                          AND
        //   Has it been 24 hours since the last time this message was displayed?
        //   Has the latest schedule been downloaded?
        
        if ( effectiveDiff < (60*60*24*7) && (lastDateDiff >= 60*2) )  // lastDateDiff was 60*60*24 (24 hours)
        {
            [self displayAlert: obj];
        }
        
    }
    
//    [self downloadTest];
}

-(void) displayAlert: (DBVersionDataObject*) obj
{
    
    if ( obj.message == nil )  // Don't bother if there is no message
        return;
    
    
    ALAlertBanner *alertBanner = [ALAlertBanner alertBannerForView:self.view
                                                             style:ALAlertBannerStyleFailure
                                                          position:ALAlertBannerPositionBottom
                                                             title:obj.title
                                                          subtitle:obj.message
                                                       tappedBlock:^(ALAlertBanner *alertBanner)
                                  {
                                      NSLog(@"Generic Message: %@!", obj.message);
                                      [alertBanner hide];
                                  }];
    
    NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *words = [obj.message componentsSeparatedByCharactersInSet:separators];
    
    NSIndexSet *separatorIndexes = [words indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqualToString:@""];
    }];
    
    int numOfSeconds = (int)( ([words count] - [separatorIndexes count])/3.0 );  // Assume, on average, a person reads 3 words per second
    
    // Maintain a minimum and maximum time
    if ( numOfSeconds < 10 )
        numOfSeconds = 10;
    else if ( numOfSeconds > 20 )
        numOfSeconds = 20;
    
    NSLog(@"numOfSeconds: %d", numOfSeconds);
    
    [alertBanner setSecondsToShow: numOfSeconds];
    [alertBanner show];
    
    [[NSUserDefaults standardUserDefaults] setObject: [NSDate date] forKey:@"Settings:Update:DateOfLastNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


-(void) downloadTest
{

//    NSURL *downloadURL = [[NSURL alloc] initWithString: @"http://www3.septa.org/hackathon/dbVersion/download.php"];
//    NSURLRequest *request = [NSURLRequest requestWithURL: downloadURL];
//    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[GTFSCommon filePath] stringByDeletingLastPathComponent] ];
//    
//    AFDownloadRequestOperation *dOp = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:zipPath shouldResume:YES];
//    dOp.outputStream = [NSOutputStream outputStreamToFileAtPath: zipPath append:NO];
//    
//    [dOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         NSLog(@"Successfully downloaded file to %@", zipPath);
//     }
//                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         NSLog(@"Error: %@", error);
//     }];
//    
//    
//    [dOp setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
////        NSLog(@"Operation%i: bytesRead: %d", 1, bytesRead);
////        NSLog(@"Operation%i: totalBytesRead: %lld", 1, totalBytesRead);
////        NSLog(@"Operation%i: totalBytesExpected: %lld", 1, totalBytesExpected);
////        NSLog(@"Operation%i: totalBytesReadForFile: %lld", 1, totalBytesReadForFile);
////        NSLog(@"Operation%i: totalBytesExpectedToReadForFile: %lld", 1, totalBytesExpectedToReadForFile);
//
//         float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToReadForFile));
//         NSLog(@"Sent %lld of %lld bytes, percent: %6.3f", totalBytesRead, totalBytesExpectedToReadForFile, percentDone);
//
//        
//    }];
//
//
////    [dOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
////     {
////         //        NSLog(@"Operation%i: bytesRead: %d", i, bytesRead);
////         //        NSLog(@"Operation%i: bytesRead: %lld", i, totalBytesRead);
////         //        NSLog(@"Operation%i: bytesRead: %lld", i, totalBytesExpectedToRead);
////         
//////         float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToRead));
//////         NSLog(@"Sent %lld of %lld bytes, percent: %6.3f", totalBytesRead, totalBytesExpectedToRead, percentDone);
////         
////         NSLog(@"bytesRead: %d, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
////         
////         
////     }];
//    
//    
//    [dOp setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
//        NSLog(@"Download expired!");
//    }];
//    
//    
//    [dOp start];
////    [dOp waitUntilFinished];
    
    
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


//-(void) dateCheck
//{
//    
//    NSDate *today = [[NSDate alloc] init];
//    NSCalendar *gregorian = [[NSCalendar alloc]
//                             initWithCalendarIdentifier:NSGregorianCalendar];
//    
//    // Get the weekday component of the current date
//    NSDateComponents *weekdayComponents = [gregorian components:NSWeekdayCalendarUnit
//                                                       fromDate:today];
//    
//    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
//    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
//    
//    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract
//                                                         toDate:today options:0];
//    
//    NSLog(@"Done");
//    
//}


-(void) md5check
{
    
    NSDate *start = [NSDate date];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    NSData *fileData = [NSData dataWithContentsOfFile: [GTFSCommon filePath] ];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(fileData.bytes, (unsigned int)fileData.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    NSTimeInterval secondsRan = [[NSDate date] timeIntervalSinceDate: start ];
    
    NSLog(@"output (%6.2f sec): %@", secondsRan, output);
    
    
//    start = [NSDate date];
    
    FMDatabase *database = [FMDatabase databaseWithPath: [GTFSCommon filePath] ];
    
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
//    NSString *finalStr;
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
        
//        finalStr = [string substringToIndex: [string length] -1 ];
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
        CC_MD5_Update(&md5, [rowData bytes], (unsigned int)[rowData length]);
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

    // --==  How to test alerts  ==--
//    SystemAlertObject *saObject = [[SystemAlertObject alloc] init];
//    [saObject setCurrent_message:@"Greg was here!"];
//    [alert addObject: saObject];
//
//    SystemAlertObject *saObject1 = [[SystemAlertObject alloc] init];
//    [saObject1 setCurrent_message:@"And now the whole place stinks!"];
//    [alert addObject: saObject1];
   
    
    
    if ( [alert count] == 0 )
        _alertMessage = nil;
    
//    SystemAlertObject *newAlert = [alert objectAtIndex:0];
//    [alert addObject: newAlert];
    
    BOOL duplicateFound = 0;
    for (SystemAlertObject *saObject in alert)
    {
     
        if ( [saObject numOfAlerts] < 1 )
            continue;
        
        for (NSString *message in _alertMessage)
        {
            NSLog(@"Checking for message: %@", message);
            if ( [message isEqualToString: saObject.current_message] )
            {
                duplicateFound = 1;
                NSLog(@"Duplicate message found");
                break;
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
        
        
            ALAlertBanner *alertBanner = [ALAlertBanner alertBannerForView:self.view
                                                   style:ALAlertBannerStyleFailure
                                                position:ALAlertBannerPositionBottom
                                                   title:@"General Alert"
                                                subtitle:saObject.current_message
                                             tappedBlock:^(ALAlertBanner *alertBanner)
                        {
                            NSLog(@"Generic Message: %@!", saObject.current_message);
                            [alertBanner hide];
                        }];
            
            
            
            NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSArray *words = [saObject.current_message componentsSeparatedByCharactersInSet:separators];
            
            NSIndexSet *separatorIndexes = [words indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                return [obj isEqualToString:@""];
            }];
            
            int numOfSeconds = (int)( ([words count] - [separatorIndexes count])/2.5 );  // Assume, on average, a person reads 2.5 words per second
            
            // Maintain a minimum and maximum time
            if ( numOfSeconds < 10 )
                numOfSeconds = 10;
            else if ( numOfSeconds > 20 )
                numOfSeconds = 20;
            
            NSLog(@"numOfSeconds: %d", numOfSeconds);
            
            [alertBanner setSecondsToShow: numOfSeconds];

//            NSTimeInterval showTime = 5.0f;
//            [alertBanner setSecondsToShow: showTime];

            [alertBanner show];
        }
        
    }
    
}


-(NSString*) md5FromString: (NSString *) baseString
{
    
    const char *ptr = [baseString UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (unsigned int)strlen(ptr), md5Buffer);
    
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


//-(NSString*) filePath
//{
//    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
//}


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

- (IBAction)btnTest:(id)sender
{
    
    self.lblTest.hidden = NO;
    
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
