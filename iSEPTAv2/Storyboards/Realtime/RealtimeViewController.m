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
    NSTimer *_alertTimer;
    
    GetAlertDataAPI *_alertAPI;
    
    NSTimer *_dbVersionTimer;
    GetDBVersionAPI *_dbVersionAPI;
    
    
    // Background Process for Schedule Automatic Refresh
    NSOperationQueue *_autoUpdateQueue;
    NSBlockOperation *_autoUpdateOp;
    
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
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - viewWillDisappear: %d", animated);
#endif
    
    [super viewWillDisappear:animated];
    
    
    [ALAlertBanner forceHideAllAlertBannersInView:self.view];
    
    // Remove all timers from the main loop
    if ( _alertTimer != nil )
        [_alertTimer invalidate];

    if ( _dbVersionTimer != nil )
        [_dbVersionTimer invalidate];

    
    [_alertMessage removeAllObjects];
    
    [SVProgressHUD dismiss];
    
}


- (void)viewDidLoad
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - viewDidLoad");
#endif
    
    [super viewDidLoad];
    
    _startTest = NO;
    _testMode  = NO;
    _counter = 0;
    
    _loopState = kSecondMenuAlertImageNone;
    
    _alertMessage = [[NSMutableArray alloc] init];
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.view setBackgroundColor: backgroundColor];
    
    UIImage *logo = [UIImage imageNamed:@"SEPTA_logo.png"];

    SEPTATitle *newView = [[SEPTATitle alloc] initWithFrame:CGRectMake(0, 0, logo.size.width, logo.size.height) andWithTitle:@"Realtime"];
    [newView setImage: logo];
    
    [self.navigationItem setTitleView: newView];
    [self.navigationItem.titleView setNeedsDisplay];
    
    // Accessibility
    [self.btnNextToArrive        setAccessibilityLabel:@"Next to Arrive"];
    [self.btnTrainView           setAccessibilityLabel:@"TrainView"];
    [self.btnTransitView         setAccessibilityLabel:@"TransitView"];
    [self.btnSystemStatus        setAccessibilityLabel:@"System Status"];
    [self.btnFindNearestLocation setAccessibilityLabel:@"Fine Nearest Location"];
    [self.btnGuide               setAccessibilityLabel:@"Guide"];
    [self.btnPassPerks           setAccessibilityLabel:@"Pass Perks"];

    
    [self.lblNextToArrive setAccessibilityElementsHidden:YES];
    [self.lblTrainView    setAccessibilityElementsHidden:YES];
    [self.lblTransitView  setAccessibilityElementsHidden:YES];
    [self.lblSystemStatus setAccessibilityElementsHidden:YES];
    [self.lblFindNeareset setAccessibilityElementsHidden:YES];
    [self.lblLocations    setAccessibilityElementsHidden:YES];
    [self.lblGuide        setAccessibilityElementsHidden:YES];
    [self.lblPassPerks    setAccessibilityElementsHidden:YES];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - viewWillAppear: %d", animated);
#endif
    
    [super viewWillAppear:animated];
    NSLog(@"RVC - viewWillAppear: %d", animated);

    // Check if the uncompress SQLite DB exists.  If it does not, uncompress it.  If it does, check the MD5 and make sure it's the latest.
    [self checkDBExists];
    
    [SVProgressHUD dismiss];
    [ALAlertBanner forceHideAllAlertBannersInView:self.view];
    
    // Start timers back up
    _alertTimer = [NSTimer scheduledTimerWithTimeInterval:ALALERTBANNER_TIMER target:self selector:@selector(getGenericAlert) userInfo:nil repeats:YES];
    [self getGenericAlert];
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
//    [self changeOrientation:currentOrientation];
    
    CGFloat width = [self.view frame].size.width;
    CGFloat height = [self.view frame].size.height;
    
    [self changeOrientation: [self.view frame].size ];
    
    NSLog(@"RVC:vWA - w: %5.3f, h: %5.3f", width, height);

    
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - connection: didReceivveResponse:");
#endif
    
    /*  convert response into an NSHTTPURLResponse,
     call the allHeaderFields property, then get the
     Last-Modified key.
     */
    
    // Get last stored modified date, if one exists.
    // If not, set to nil

    
//    NSString * last_modified = [NSString stringWithFormat:@"%@",
//                                [[(NSHTTPURLResponse *)response allHeaderFields] objectForKey:@"Last-Modified"]];
    
    // Last-Modified = "Mon, 26 Jan 2015 19:14:05 GMT"
    // Convert to NSDate
    
    // If stored_date is nil, just store the new last_modified
    // If stored_date equals last_modified, do nothing
    // If last_modified is newer, add badge to Tips until tapped on
    
    
//    NSLog(@"Last-Modified: %@", last_modified );
    
}

-(void) automaticDownloading
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - automaticDownloading");
#endif
    
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
    
//    NSLog(@"free space: %@", formatted);
    
    
    NSString *dbPath = [GTFSCommon filePath];
//    NSLog(@"dbPath: %@", dbPath);
//    NSLog(@"dbPath: %@", [dbPath stringByDeletingLastPathComponent] );
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath: dbPath error: NULL];
    UInt64 result = [attrs fileSize];
    
    formatted = [formatter stringFromNumber: [NSNumber numberWithLongLong: result] ];
//    NSLog(@"db Size:    %@", formatted);

    
//    [self downloadTest];
    
}

-(void) checkDBExists
{
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - checkDBExists");
#endif
    
    [GTFSCommon filePath];
    
}

-(void) checkDBVersion
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - checkDBVersion");
#endif
    
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

    
    [_dbVersionAPI setTestMode: _testMode];

    [_dbVersionAPI fetchData];
    
}


-(void) dbVersionFetched:(DBVersionDataObject*) obj
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - dbVersionFetched");
#endif
    
    
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
    [_dbVersionAPI loadZippedMD5];
    
    
    // API logic
    // Does the API md5 match the local MD5?  Yes, stop as there's nothing else to do
    // Does the API md5 match the zipped MD5?  Yes, unzip the bundled DB
    // Otherwise, the schedule is out of date and it needs to be updated.
    
    BOOL needUpdate = NO;
    if ( obj.message != nil )  // Did the API return data
    {
        
        if ( [obj.md5 isEqualToString: [_dbVersionAPI localMD5] ] )
        {
            NSLog(@"RVC - API MD5 matches local MD5");
            return;  // The schedule is up to date, there's nothing to do
        }
        else if ( [obj.md5 isEqualToString: [_dbVersionAPI zippedMD5] ] )
        {
            // The schedule is out of date, but fortunately it matches what's bundled with the app
            NSLog(@"RVC - API MD5 matches zipped MD5");
            
            NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *dbPath = [NSString stringWithFormat:@"%@/SEPTA.sqlite", [paths objectAtIndex:0] ];
            
            [GTFSCommon uncompressWithPath:dbPath];
        }
        else  // The schedule is out of date and a new one needs to be downloaded
        {
            NSLog(@"RVC - API MD5 does not matches any MD5");
            needUpdate = YES;
            [self displayAlert: obj];
            
        }
        
        [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:needUpdate] forKey:@"Settings:Update:NeedUpdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    
}


-(void) displayAlert: (DBVersionDataObject*) obj
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - displayAlert: %@", obj);
#endif
    
    if ( obj.message == nil )  // Don't bother if there is no message
        return;
    
    
    ALAlertBanner *alertBanner = [ALAlertBanner alertBannerForView:self.view
                                                             style:ALAlertBannerStyleFailure
                                                          position:ALAlertBannerPositionBottom
                                                             title:obj.title
                                                          subtitle:obj.message
                                                       tappedBlock:^(ALAlertBanner *alertBanner)
                                  {
//                                      NSLog(@"Generic Message: %@!", obj.message);
                                      [alertBanner hide];
                                  }];
    
    NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *words = [obj.message componentsSeparatedByCharactersInSet:separators];
    
    NSIndexSet *separatorIndexes = [words indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj isEqualToString:@""];
    }];
    
    int numOfSeconds = (int)( ([words count] - [separatorIndexes count])/3.0 );  // Assume, on average, a person reads 3 words per second
    
    // Maintain a minimum and maximum time; increased max time from 20 to 30 seconds
    if ( numOfSeconds < 10 )
        numOfSeconds = 10;
    else if ( numOfSeconds > 30 )
        numOfSeconds = 30;
    
//    NSLog(@"numOfSeconds: %d", numOfSeconds);
    
    [alertBanner setSecondsToShow: numOfSeconds];
    [alertBanner show];
    
    [[NSUserDefaults standardUserDefaults] setObject: [NSDate date] forKey:@"Settings:Update:DateOfLastNotification"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


-(void) downloadTest
{
    
}


-(unsigned long long)getFreeSpace
{

#if FUNCTION_NAMES_ON
    NSLog(@"RVC - getFreeSpace");
#endif
    
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


-(void) md5check
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - md5check");
#endif
    
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
    
//    NSTimeInterval secondsRan = [[NSDate date] timeIntervalSinceDate: start ];
    
//    NSLog(@"output (%6.2f sec): %@", secondsRan, output);
    
    
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
//        NSLog(@"%@: %@", tableName, [[results resultDictionary] allKeys]);
        
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
    
//    NSLog(@"routes_rail: %@", output);
    
    [database close];
    
}

-(void) getGenericAlert
{

#if FUNCTION_NAMES_ON
    NSLog(@"RVC - getGenericAlert");
#endif

    
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

    
//    NSArray *operations = [_alertAPI getOperations];
//    for (AFJSONRequestOperation *jOp in operations)
//    {
//        // Add all operations to the operation queue
//
//    }
    
    
}


-(void) alertFetched:(NSMutableArray*) alert
{
   
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - alertFetched: %@", alert);
#endif
    
//    NSLog(@"RVC - alertFeteched: %@", alert);
    
    
//    SystemAlertObject *saObject = [alert objectAtIndex:0];

    // --==  How to test alerts  ==--
//    SystemAlertObject *saObject = [[SystemAlertObject alloc] init];
//    [saObject setCurrent_message:@"Greg was here!"];
//    [alert addObject: saObject];
//
//    SystemAlertObject *saObject1 = [[SystemAlertObject alloc] init];
//    [saObject1 setCurrent_message:@"And now the whole place stinks!"];
//    [alert addObject: saObject1];
   
    
    // At this point, the Networking call for Alerts has already gone out, we can schedule the next one to kick off.
    if ( _dbVersionTimer == nil )
    {
        _dbVersionTimer = [NSTimer scheduledTimerWithTimeInterval:DBVERSION_REFRESH target:self selector:@selector(checkDBVersion) userInfo:nil repeats:YES];
        [self checkDBVersion];
    }
    
    
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
//            NSLog(@"Checking for message: %@", message);
            if ( [message isEqualToString: saObject.current_message] )
            {
                duplicateFound = 1;
//                NSLog(@"Duplicate message found");
                break;
            }
//            else
//                NSLog(@"No duplicate message found");
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
//                            NSLog(@"Generic Message: %@!", saObject.current_message);
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
            
//            NSLog(@"numOfSeconds: %d", numOfSeconds);
            
            [alertBanner setSecondsToShow: numOfSeconds];

//            NSTimeInterval showTime = 5.0f;
//            [alertBanner setSecondsToShow: showTime];

            [alertBanner show];
        }
        
    }
    
}


-(NSString*) md5FromString: (NSString *) baseString
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - md5FromString");
#endif
    
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
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - loopImages");
#endif
    
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


- (void)didReceiveMemoryWarning
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - didReceiveMemoryWarning");
#endif
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - viewDidUnload");
#endif
    
    [self setBtnNextToArrive:nil];
    [self setBtnTrainView:nil];
    [self setBtnTransitView:nil];
    
    [self setBtnFindNearestLocation:nil];
    [self setBtnSystemStatus:nil];
    [self setBtnGuide:nil];
    [self setBtnPassPerks:nil];
    
    [super viewDidUnload];
    
}

//-(void) viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    NSLog(@"RVC: viewWillLayoutSubviews");
//}

-(void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize: size withTransitionCoordinator:coordinator];
    NSLog(@"RVC: viewWillTransitionToSize");
 
    [self changeOrientation:size];
    
}


//-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//
////    [self changeOrientation:fromInterfaceOrientation];
//    
//}


//-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//
//    [self changeOrientation:toInterfaceOrientation];
//    
////    if ( UIInterfaceOrientationIsLandscape( toInterfaceOrientation ) )
////    {
////        // Add more padding to the buttons
////    }
////    else
////    {
////        // Squish the buttons together
////    }
//    
//}




-(void) changeOrientation:(CGSize) size
{

#if FUNCTION_NAMES_ON
    NSLog(@"RVC - changeOrientation: %@", NSStringFromCGSize(size) );
#endif

    NSLog(@"RVC - changeOrientation: %@", NSStringFromCGSize(size) );
    
    CGFloat width = size.width;
    int padding;
    int buttonWidth = 96;

    // This is stupid...
    int maxRow = 3;
    if ( width > 400 )
    {
        padding = (width - 4*buttonWidth)/5;
        maxRow = 4;
    }
    else
    {
        padding = (width - 3*buttonWidth)/4;
    }
    
    NSArray *btnArray = [NSArray arrayWithObjects: self.btnNextToArrive, self.btnTrainView, self.btnTransitView, self.btnSystemStatus, self.btnFindNearestLocation, self.btnGuide, self.btnPassPerks, nil];
    NSArray *lblArray = [NSArray arrayWithObjects: self.lblNextToArrive, self.lblTrainView, self.lblTransitView, self.lblSystemStatus, self.lblFindNeareset, self.lblGuide, self.lblPassPerks, nil];
    
    CGRect btnRect;
    CGRect lblRect;
    
    int n = 0;
    int r = 0;
    int c = 0;
    
    CGRect btnOrigin = self.btnNextToArrive.frame;
    
    for (UIButton *button in btnArray)
    {

        UILabel *label = [lblArray objectAtIndex:n];
        
        btnRect = button.frame;
        lblRect = label.frame;

//        NSLog(@"Before: btnRect: (%5.3f, %5.3f), (%5.3f, %5.3f)", btnRect.origin.x, btnRect.origin.y, btnRect.size.width, btnRect.size.height);
//        NSLog(@"Before: lblRect: (%5.3f, %5.3f), (%5.3f, %5.3f)", lblRect.origin.x, lblRect.origin.y, lblRect.size.width, lblRect.size.height);

        
//        btnRect.origin.x = (c+1)*padding + (r+1)*buttonWidth;
        btnRect.origin.x = padding + (c)*(padding+buttonWidth);
        btnRect.origin.y = r*(6+buttonWidth) + btnOrigin.origin.y;
    
        lblRect.origin.x = btnRect.origin.x;
        lblRect.origin.y = r*(6+buttonWidth) + (0.8f * buttonWidth);
    
//        NSLog(@"After : btnRect: (%5.3f, %5.3f), (%5.3f, %5.3f)", btnRect.origin.x, btnRect.origin.y, btnRect.size.width, btnRect.size.height);
//        NSLog(@"After : lblRect: (%5.3f, %5.3f), (%5.3f, %5.3f)", lblRect.origin.x, lblRect.origin.y, lblRect.size.width, lblRect.size.height);
        
        [button setFrame: btnRect];
        [label  setFrame: lblRect];
        
        if ( [button isEqual:self.btnFindNearestLocation] )
        {
            CGRect findRec = self.lblFindNeareset.frame;
            findRec.origin.y -= 6;
            [self.lblFindNeareset setFrame: findRec];
        }

        
//        NSLog(@"n: %d, c: %d, r: %d",n,c,r);
//        NSLog(@"");
        
        n++;

        c = (n % maxRow);  // Progress if maxRow = 3; n = 0,1,2 0,1,2, when maxRow = 4; n = 0,1,2,3 0,1,2,3
        r = (int)(n/maxRow);
        
        
    }

    
//    CGRect btnNextToArriveRect = self.btnNextToArrive.frame;
//    CGRect lblNextToArriveRect = self.lblNextToArrive.frame;
//    
//    btnNextToArriveRect.origin.x = padding;
//    lblNextToArriveRect.origin.x = btnNextToArriveRect.origin.x;
//    [self.btnNextToArrive setFrame: btnNextToArriveRect];
//    [self.lblNextToArrive setFrame: lblNextToArriveRect];
//    
//    
//    CGRect btnTrainViewRect = self.btnTrainView.frame;
//    CGRect lblTrainViewRect = self.lblTrainView.frame;
//    
//    btnTrainViewRect.origin.x = 2*padding+buttonWidth;
//    lblTrainViewRect.origin.x = btnTrainViewRect.origin.x;
//    [self.btnTrainView setFrame: btnTrainViewRect];
//    [self.lblTrainView setFrame: lblTrainViewRect];
//    
//    
//    CGRect btnTransitViewRect = self.btnTransitView.frame;
//    CGRect lblTransitViewRect = self.lblTransitView.frame;
//    
//    btnTransitViewRect.origin.x = 3*padding + 2*buttonWidth;
//    lblTransitViewRect.origin.x = btnTransitViewRect.origin.x;
//    [self.btnTransitView setFrame: btnTransitViewRect];
//    [self.lblTransitView setFrame: lblTransitViewRect];
//    
//    
//    CGRect btnSystemStatusRect = self.btnSystemStatus.frame;
//    CGRect lblSystemStatusRect = self.lblSystemStatus.frame;
//    btnSystemStatusRect.origin.x = padding;
//    lblSystemStatusRect.origin.x = btnSystemStatusRect.origin.x;
//    
//    [self.btnSystemStatus setFrame: btnSystemStatusRect];
//    [self.lblSystemStatus setFrame: lblSystemStatusRect];
//    
//    CGRect btnNearestLocationRect = self.btnFindNearestLocation.frame;
//    CGRect lblFindNearestRect     = self.lblFindNeareset.frame;
//    CGRect lblLocationRect        = self.lblLocations.frame;
//    btnNearestLocationRect.origin.x = 2*padding+buttonWidth;
//    lblFindNearestRect.origin.x     = btnNearestLocationRect.origin.x;
//    lblLocationRect.origin.x        = btnNearestLocationRect.origin.x;
//    
//    [self.btnFindNearestLocation setFrame: btnNearestLocationRect];
//    [self.lblFindNeareset setFrame: lblFindNearestRect];
//    [self.lblLocations setFrame: lblLocationRect];
//    
//    
//    // Guide/Special Events
//    CGRect btnGuideRect = self.btnGuide.frame;
//    CGRect lblGuideRect = self.lblGuide.frame;
//    
//    btnGuideRect.origin.x = 3*padding+2*buttonWidth;
//    lblGuideRect.origin.x = btnGuideRect.origin.x;
//    [self.btnGuide setFrame: btnGuideRect];
//    [self.lblGuide setFrame: lblGuideRect];
//    
//    
//    // Pass Perks
//    CGRect btnPassPerksRect = self.btnPassPerks.frame;
//    CGRect lblPassPerksRect = self.lblPassPerks.frame;
//    
//    btnPassPerksRect.origin.x = padding;
//    lblPassPerksRect.origin.x = btnPassPerksRect.origin.x;
//    [self.btnPassPerks setFrame: btnPassPerksRect];
//    [self.lblPassPerks setFrame: lblPassPerksRect];
    
}



#pragma mark -= Button Presses
- (IBAction)btnNextToArrivePressed:(id)sender
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - btnNextToArrivePressed");
#endif
    
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

#if FUNCTION_NAMES_ON
    NSLog(@"RVC - btnTrainViewPressed");
#endif
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

#if FUNCTION_NAMES_ON
    NSLog(@"RVC - btnTransitViewPressed");
#endif
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TransitViewStoryboard" bundle:nil];
    TransitViewViewController *tvVC = (TransitViewViewController*)[storyboard instantiateInitialViewController];
    
//    [tvVC setTravelMode:@"Rail"];
    
    [self.navigationController pushViewController:tvVC animated:YES];

    
}

- (IBAction)btnSystemStatusPressed:(id)sender
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - btnSystemStatusPressed");
#endif
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SystemStatusStoryboard" bundle:nil];
    SystemStatusViewController *ssVC = (SystemStatusViewController*)[storyboard instantiateInitialViewController];
    
    //    [tvVC setTravelMode:@"Rail"];
    
    [self.navigationController pushViewController:ssVC animated:YES];
}

- (IBAction)btnFindNearestLocationPressed:(id)sender
{
    
#if FUNCTION_NAMES_ON
    NSLog(@"RVC - btnFindNearestLocationPressed");
#endif
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NearestLocationStoryboard" bundle:nil];
    NearestLocationViewController *nlVC = (NearestLocationViewController*)[storyboard instantiateInitialViewController];
    
    //    [tvVC setTravelMode:@"Rail"];
    
    [self.navigationController pushViewController:nlVC animated:YES];
    
}



- (IBAction)btnGuidePressed:(id)sender
{
    
}


- (IBAction)btnPassPerksPressed:(id)sender
{
    
}


-(void) disableButtonsForSpecialEvent:(SpecialEvent *) sp andDisplayMessage:(BOOL) displayMessage
{
    
    // Accessibility
    //            [self.btnNextToArrive        setAccessibilityLabel:@"Next to Arrive"];
    //            [self.btnTrainView           setAccessibilityLabel:@"TrainView"];
    //            [self.btnTransitView         setAccessibilityLabel:@"TransitView"];
    //            [self.btnSystemStatus        setAccessibilityLabel:@"System Status"];
    //            [self.btnFindNearestLocation setAccessibilityLabel:@"Fine Nearest Location"];
    //            [self.btnGuide               setAccessibilityLabel:@"Guide"];
    
    //            [self.btnGuide setEnabled:NO];
    
    //            [self.btnNextToArrive setImage:[UIImage imageNamed:@"RT_NTA_GS.png"] forState:UIControlStateDisabled];
    
    [self.btnNextToArrive setEnabled:NO];
    [self.btnTransitView setEnabled:NO];
    [self.btnTrainView setEnabled:NO];
    
    [self.btnFindNearestLocation setEnabled:NO];
    
    //            [self.lblNextToArrive setTextColor:[UIColor colorWithRed:66.0/256.0 green:66.0/256.0 blue:66.0/256.0 alpha:1]];
    [self.lblNextToArrive setTextColor: [UIColor lightGrayColor] ];
    [self.lblTrainView setTextColor:[UIColor  lightGrayColor] ];
    [self.lblTransitView setTextColor:[UIColor lightGrayColor] ];
    [self.lblFindNeareset setTextColor:[UIColor lightGrayColor] ];
    [self.lblLocations setTextColor: [UIColor lightGrayColor] ];
    
    
    if ( displayMessage )
    {
    
        ALAlertBanner *alertBanner = [ALAlertBanner alertBannerForView:self.view
                                                                 style:ALAlertBannerStyleFailure
                                                              position:ALAlertBannerPositionBottom
                                                                 title:@"Special Event"
                                                              subtitle:sp.message
                                                           tappedBlock:^(ALAlertBanner *alertBanner)
                                      {
//                                          NSLog(@"Generic Message: %@!", sp.message);
                                          [alertBanner hide];
                                      }];
        
        NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSArray *words = [sp.message componentsSeparatedByCharactersInSet:separators];
        
        NSIndexSet *separatorIndexes = [words indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj isEqualToString:@""];
        }];
        
        int numOfSeconds = (int)( ([words count] - [separatorIndexes count])/3.0 );  // Assume, on average, a person reads 3 words per second
        
        // Maintain a minimum and maximum time; increased max from 20 to 30 seconds
        if ( numOfSeconds < 10 )
            numOfSeconds = 10;
        else if ( numOfSeconds > 30 )
            numOfSeconds = 30;
        
        //            NSLog(@"numOfSeconds: %d", numOfSeconds);
        
        [alertBanner setSecondsToShow: numOfSeconds];
        [alertBanner show];

    }
    
}




@end
