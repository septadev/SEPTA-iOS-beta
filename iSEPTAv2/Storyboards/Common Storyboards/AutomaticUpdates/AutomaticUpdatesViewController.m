//
//  AutomaticUpdatesViewController.m
//  iSEPTA
//
//  Created by septa on 1/15/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "AutomaticUpdatesViewController.h"

@implementation UIProgressView (customView)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(size.width, 5);
    return newSize;
//    NSLog(@"old size: %@",NSStringFromCGSize(size) );
//    NSLog(@"new size: %@", NSStringFromCGSize(newSize) );
//    return size;
}
@end

@interface AutomaticUpdatesViewController ()

@end

@implementation AutomaticUpdatesViewController
{

    GetDBVersionAPI *_dbVersionAPI;
    NSString *_localMD5;
    BOOL _autoUpdate;
    
    BOOL _testMode;
    
    AutomaticUpdateState _updateSM;
    
    NSString *_path;
    NSTimer *_progressTimer;
    
    
    AFDownloadRequestOperation *_dOp;
    
}

@synthesize startImmediately;

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
    
    // "Settings:Update
    
    [super viewDidLoad];
    
    
    // ---===
    // ---===   TEST MODE; SET TO NO BEFORE SUBMITTING!!!
    // ---===
    
    _testMode = NO;
    
//    _updateSM = kAutomaticUpdateStartState;
//    [self updateStateTo: kAutomaticUpdateChecking];
    
    [self updateStateTo: kAutomaticUpdateChecking];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.tableView setBackgroundColor: backgroundColor];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"update-white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0,500, 32) withTitle:@"Update"];
    [self.navigationItem setTitleView:titleView];
    
    
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    _path = [paths objectAtIndex:0];
    
    
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:Update:AutoUpdate"];
    if ( object == nil )
    {
        _autoUpdate = NO;  // If nil, no data is in @"Settings:24HourTime" so default to NO
    }
    else
    {
        _autoUpdate = [object boolValue];
    }
    
    [self.swtAutoUpdate setOn: _autoUpdate];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    BOOL onOff = self.swtAutoUpdate.isOn;
    
    if (_autoUpdate != onOff )
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:onOff] forKey:@"Settings:Update:AutoUpdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ( _progressTimer != nil )
        [_progressTimer invalidate];
    
}



-(void) updateStateTo:(AutomaticUpdateState) newState
{
    
    NSLog(@"Current State: %ld", (long)_updateSM);
    NSLog(@"New State    : %ld", (long)newState);
    
    _updateSM = newState;
    
    /* 
     kAutomaticUpdateStartState,            0
     kAutomaticUpdateChecking,              1
     kAutomaticUpdateLatestAvailable,       2
     kAutomaticUpdateUpToDate,              3
     kAutomaticUpdateDownloading,           4
     kAutomaticUpdateCancelledDownload,     5
     kAutomaticUpdateFinishedDownload,      6
     kAutomaticUpdateInstalling,            7
     kAutomaticUpdateFinishedInstall,       8
     kAutomaticUpdateDoNothing,             9
     
     kAutomaticUpdateNoInternet,            A
     
     */
    
    switch (newState)
    {
//        case kAutomaticUpdateStartState:
//            [self.lblVersionStatus setText:@""];
//            break;
            
        case kAutomaticUpdateChecking:          // 1
            [self.lblVersionStatus setText: VERSION_CHECKING];
            [self.progressBar setProgress:0.0f];
            
            [self.btnMulti setHidden:YES];
            [self checkAppVersion];
            
            break;
            
        case kAutomaticUpdateUpToDate:          // 3
            [self.lblVersionStatus setText: VERSION_NOUPDATE];
            break;
            
        case kAutomaticUpdateLatestAvailable:   // 2
            [self.lblVersionStatus setText: VERSION_AVAILABLE];
            
            if ( self.startImmediately )
                [self.btnMulti setHidden:YES];
            else
                [self.btnMulti setHidden:NO];
            
            [self.btnMulti setTitle:@"Download" forState:UIControlStateNormal];
            break;
            
        case kAutomaticUpdateDownloading:       // 4
            [self.lblVersionStatus setText: @"Downloading..."];
            
            if ( self.startImmediately )
                [self.btnMulti setHidden:YES];
            else
            {
                [self.btnMulti setHidden:NO];
                [self.btnMulti setTitle:@"Cancel" forState:UIControlStateNormal];
            }
            
#ifdef BACKGROUND_DOWNLOAD
        {
            BackgroundDownloader *bDown = [BackgroundDownloader sharedInstance];
            if ( ![bDown isDownloading] )
                [bDown downloadSchedule];
        }
            
            _progressTimer = [NSTimer scheduledTimerWithTimeInterval:1/10.0f target:self selector:@selector(downloadProgress) userInfo:nil repeats:YES];
#else
            [self downloadSchedule];
#endif
            
            break;
            
        case kAutomaticUpdateCancelledDownload:  // 5
            [self.lblVersionStatus setText: @"Cancelled Download..."];
            [self.btnMulti setTitle:@"Download" forState:UIControlStateNormal];
            
            if ( self.startImmediately )
                [self.btnMulti setHidden:YES];
            else
                [self.btnMulti setHidden:NO];
            
            [self cancelDownload];
            [self cleanUpDownload];
            break;
            
        case kAutomaticUpdateFinishedDownload:  // 6
            // TODO: When file was successfully downloaded, save state
            
//            [self.lblVersionStatus setText: @"Finished Download"];
//            [self.btnMulti setHidden:NO];
            
            if ( self.startImmediately )
                [self.btnMulti setHidden:YES];
            else
                [self.btnMulti setHidden:NO];
            
            [self.btnMulti setTitle:@"Install" forState:UIControlStateNormal];
            
            {
                UpdateStateMachineObject *currentState = [[UpdateStateMachineObject alloc] init];
                DBVersionDataObject *dbObj = [_dbVersionAPI getData];
                
                [currentState setEffective_date: dbObj.effective_date];
                [currentState setSaved_state: [NSNumber numberWithInt: _updateSM] ];
                [currentState setMd5: dbObj.md5];
                
                NSData *currentObj = [NSKeyedArchiver archivedDataWithRootObject: currentState];
                
                [[NSUserDefaults standardUserDefaults] setObject: currentObj forKey:@"Settings:Update:StateMachineStatus"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }

            // Immediately start the installing
            [self.lblVersionStatus setText: @"Please Wait While Installing..."];
            [self installNewSchedule];
            
            break;
            
//        case kAutomaticUpdateInstalling:      // 7
//            [self.lblVersionStatus setText: @"Installing"];
//            [self installNewSchedule];
//            break;
            
        case kAutomaticUpdateFinishedInstall:   // 8
            [self.lblVersionStatus setText: @"New Schedule Installed"];
            [self.btnMulti setHidden:YES];
            [self updateStateTo: kAutomaticUpdateDoNothing];
            break;
            
        case kAutomaticUpdateDoNothing:         // 9
            break;
            
        case kAutomaticUpdateNoInternet:        // A
            [self.lblVersionStatus setText:@"No Internet Connection Available"];
            [self.btnMulti setHidden:NO];
            [self.btnMulti setTitle:@"Retry" forState:UIControlStateNormal];
            
            break;
            
        default:
            break;
    }
    
}



-(void) checkAppVersion
{
    
//    _updateSM = kAutomaticUpdateChecking;
//    [self updateStateTo: kAutomaticUpdateChecking];
    
    if ( ![[Reachability reachabilityForInternetConnection] isReachable] )
    {
        [self updateStateTo:kAutomaticUpdateNoInternet];
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

    
    // Check if the state has already been saved, then compare the saved effective date with the current effective date
    // If they are the same, load the saved state of the FSM, otherwise delete the saved state and continue as normal.
    
    UpdateStateMachineObject *savedSMStatus;
    
    NSData *userData = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:Update:StateMachineStatus"];
    savedSMStatus = (UpdateStateMachineObject*)[NSKeyedUnarchiver unarchiveObjectWithData: userData];
    
    if ( [savedSMStatus.effective_date isEqualToString: obj.effective_date] && ![savedSMStatus.md5 isEqualToString:obj.md5] )
    {
        [self updateStateTo: (AutomaticUpdateState)[savedSMStatus.saved_state intValue] ];
        return;
    }
    else
    {
        UpdateStateMachineObject *blankObj = [[UpdateStateMachineObject alloc] init];
        NSData *dataObj = [NSKeyedArchiver archivedDataWithRootObject: blankObj];

        [self cleanUpDownload];
        
        [[NSUserDefaults standardUserDefaults] setObject: dataObj forKey:@"Settings:Update:StateMachineStatus"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if ( [_dbVersionAPI loadLocalMD5] )
    {
        _localMD5 = [_dbVersionAPI localMD5];
    }
    
    NSLog(@"locMD5: %@", _localMD5);
    NSLog(@"apiMD5: %@", obj.md5);
    if ( [_localMD5 isEqualToString: [obj md5] ] )
    {
//        NSLog(@"OMG!!!  The MD5 MATCH!");
//        _updateSM = kAutomaticUpdateUpToDate;
        [self updateStateTo:kAutomaticUpdateUpToDate];
    }
    else
    {
//        NSLog(@"The MD5s didn't match, I figured as much");
//        _updateSM = kAutomaticUpdateLatestAvailable;
        
#ifdef BACKGROUND_DOWNLOAD
        BackgroundDownloader *bdDown = [BackgroundDownloader sharedInstance];
        if ( [bdDown isDownloading] )
            [self updateStateTo: kAutomaticUpdateDownloading];
        else
#endif
            
        if ( self.startImmediately )
            [self updateStateTo: kAutomaticUpdateDownloading];
        else
            [self updateStateTo: kAutomaticUpdateLatestAvailable];

    
    }

}


-(void) downloadProgress
{
    
#ifdef BACKGROUND_DOWNLOAD
    BackgroundDownloader *bDown = [BackgroundDownloader sharedInstance];
    long long bytesRead;
    float percent;

    [bDown downloadStatusForBytes: &bytesRead andPercentDone: &percent];

    [self.progressBar setProgress: percent];
    
    if ( percent > .9999 )
    {
        [self.progressBar setProgress:1.0f];
        if ( _progressTimer != nil )
            [_progressTimer invalidate];
        
        [self updateStateTo: kAutomaticUpdateFinishedDownload];
//        [self.lblVersionStatus setText: @"Finished Download"];
        [self.btnMulti setHidden:NO];
        [self.btnMulti setTitle:@"Install" forState:UIControlStateNormal];
    }
#endif
    
    
}

-(void) cancelDownload
{
    
}

-(void) downloadSchedule
{
    
    // Install!
    NSString  *zipPath = [NSString stringWithFormat:@"%@/%@", _path, @"SEPTA.zip"];

    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath: zipPath error:&error];
    
    if ( error )
    {
        NSLog(@"Unable to delete %@", zipPath);
    }
    else
    {
        //zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];
        NSLog(@"Deleted zip file! zipPath: %@", zipPath);
    }
    
    // Note: v1.0.4 of the app used api0.septa.org/gga8893/dbVersion/download.php as the downloadURL
    NSURL *downloadURL;
    
//    if ( _testMode )
//        downloadURL = [[NSURL alloc] initWithString: @"https://api0.septa.org/gga8893/dbVersion/download.php"];
//    else
        downloadURL = [[NSURL alloc] initWithString: @"https://www3.septa.org/api/dbVersion/download.php"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL: downloadURL];

    
    if ( ![[Reachability reachabilityForInternetConnection] isReachable] )
        return;


    _dOp = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:zipPath shouldResume:YES];

    _dOp.outputStream = [NSOutputStream outputStreamToFileAtPath: zipPath append:NO];

    
    [_dOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"Successfully downloaded file to %@", zipPath);
     }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
    
//    dOp.response.statusCode
    
    __weak AutomaticUpdatesViewController *weakSelf = self;
    [_dOp setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile)
    {

        //        NSLog(@"Operation%i: bytesRead: %d", 1, bytesRead);
        //        NSLog(@"Operation%i: totalBytesRead: %lld", 1, totalBytesRead);
        //        NSLog(@"Operation%i: totalBytesExpected: %lld", 1, totalBytesExpected);
        //        NSLog(@"Operation%i: totalBytesReadForFile: %lld", 1, totalBytesReadForFile);
        //        NSLog(@"Operation%i: totalBytesExpectedToReadForFile: %lld", 1, totalBytesExpectedToReadForFile);
        
        float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToReadForFile));
//        NSLog(@"Sent %lld of %lld bytes, percent: %6.3f", totalBytesRead, totalBytesExpectedToReadForFile, percentDone);
        
        [weakSelf.progressBar setProgress: percentDone];
        
        if ( totalBytesRead == totalBytesExpectedToReadForFile )
        {
            // This should be its own state
            [weakSelf.lblVersionStatus setText: @"Installing..."];
            
            [weakSelf.btnMulti setHidden:NO];
            [weakSelf.btnMulti setTitle:@"Install" forState:UIControlStateNormal];
            // Change the text of the button but don't update the state until the completion block executes
        }
        
    }];
    
    
    //    [dOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
    //     {
    //         //        NSLog(@"Operation%i: bytesRead: %d", i, bytesRead);
    //         //        NSLog(@"Operation%i: bytesRead: %lld", i, totalBytesRead);
    //         //        NSLog(@"Operation%i: bytesRead: %lld", i, totalBytesExpectedToRead);
    //
    ////         float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToRead));
    ////         NSLog(@"Sent %lld of %lld bytes, percent: %6.3f", totalBytesRead, totalBytesExpectedToRead, percentDone);
    //
    //         NSLog(@"bytesRead: %d, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
    //
    //
    //     }];
    
    
    [_dOp setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Download expired!");
    }];
    
    
    [_dOp setCompletionBlock:^{

        NSLog(@"Successfully downloaded file to %@", zipPath);
        [weakSelf updateStateTo: kAutomaticUpdateFinishedDownload];
        
    }];
    
    
    [_dOp start];
    //    [dOp waitUntilFinished];
    

    
    
}


-(void) cleanUpDownload
{
    
    // Remove any partial file downloaded
//    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];
    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", _path];

    if ( zipPath == nil )
        return;  // Nothing to delete
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath: zipPath error:&error];
    
    if ( error )
    {
        NSLog(@"Unable to delete %@", zipPath);
    }
    else
    {
//        zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];
        NSLog(@"Deleted zip file! zipPath: %@", zipPath);
    }
    
    
}

-(void) installNewSchedule
{
    
    // Check current date versus the effective date in the API call / NSUserPreferences
    // Is current date before the effective date?
    //    YES - Put up alert, warn user the new schedule won't be active for X days (Y hours)
    //    NO  - Start install
    
    [SVProgressHUD showWithStatus:@"Installing..."];
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    
//    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];
    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", _path];
//    NSString *dataPath = [NSString stringWithFormat:@"%@/SEPTA.sqlite", _path];
    
    if ( [zip UnzipOpenFile: zipPath ] )
    {
        
        NSArray *contents = [zip getZipFileContents];
//        NSLog(@"Contents: %@", contents);
        NSLog(@"Unzipped DB to: %@", _path);
        
//        BOOL ret = [zip UnzipFileTo:[[self filePath] stringByDeletingLastPathComponent] overWrite:YES];
        BOOL ret = [zip UnzipFileTo:_path overWrite:YES];
        if ( NO == ret )
        {
            NSLog(@"Unable to unzip");
        }
        
        
        NSDirectoryEnumerator* dirEnum = [[NSFileManager defaultManager] enumeratorAtPath: zipPath];
        NSString* file;
        NSError* error = nil;
        NSUInteger count = 0;
        while ((file = [dirEnum nextObject]))
        {
            count += 1;
            NSString* fullPath = [zipPath stringByAppendingPathComponent:file];
            NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
            NSLog(@"file is not zero length: %@", attrs);
        }

        NSLog(@"%lu == %lu, files extracted successfully", (unsigned long)count, (unsigned long)[contents count]);
        
    }
    [zip UnzipCloseFile];
    

    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    NSString *dbPath = [NSString stringWithFormat:@"%@/SEPTA.sqlite", _path];
    
    if ( dbPath == nil )
        return;
    
    NSData *fileData = [NSData dataWithContentsOfFile: dbPath ];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(fileData.bytes, (unsigned int)fileData.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];

    _localMD5 = [_dbVersionAPI loadLocalMD5];

    NSString *md5Path = _path;

    NSMutableDictionary *md5Dict = [[NSMutableDictionary alloc] init];
    [md5Dict setValue: output forKey:@"md5"];
    
    NSArray *md5Array = [[NSArray alloc] initWithObjects:md5Dict, nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:md5Array
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSError *jsonParsingError;
    [jsonData writeToFile:md5Path options:NSDataWritingAtomic error:&jsonParsingError];
    

    [_dbVersionAPI loadLocalMD5];
    
    NSLog(@"Lcl MD5: %@", [_dbVersionAPI localMD5]);
    
    [SVProgressHUD dismiss];

    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO] forKey:@"Settings:Update:NeedUpdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateStateTo:kAutomaticUpdateFinishedInstall];
    
}



-(void) displayAlertWithTitle:(NSString*) title andMessage:(NSString*) message
{
    
                ALAlertBanner *alertBanner = [ALAlertBanner alertBannerForView:self.view
                                                                         style:ALAlertBannerStyleFailure
                                                                      position:ALAlertBannerPositionBottom
                                                                         title: title
                                                                      subtitle: message
                                                                   tappedBlock:^(ALAlertBanner *alertBanner)
                                              {
                                                  NSLog(@"Generic Message: %@!", message);
                                                  [alertBanner hide];
                                              }];

                NSTimeInterval showTime = 5.0f;
                [alertBanner setSecondsToShow: showTime];

                [alertBanner show];
    
}


-(void) update: (id) sender
{
    
}

#pragma mark - CustomBackBarButton
-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Keeps the even number sections clear, makes the odd numbered ones slightly transparent
    if ( (indexPath.section % 2 ) == 1 )
        cell.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    else
        cell.backgroundColor = [UIColor clearColor];
    
}



//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    static NSString *CellIdentifier = @"Cell";
////    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
//    
//    cell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:.75];
//    
//    return cell;
//}

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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


#pragma mark - Multi Button Pressed
- (IBAction)btnMultiPressed:(id)sender
{
    
    switch (_updateSM)
    {
        case kAutomaticUpdateLatestAvailable:
            
            // Ensure that the internet is reachabilty before moving into the next state
            if ( ![[Reachability reachabilityForInternetConnection] isReachable] )
                return;
            
            [self updateStateTo: kAutomaticUpdateDownloading];
            break;
        
        case kAutomaticUpdateDownloading:
            // Cancel button has been pressed
            
            [self updateStateTo:kAutomaticUpdateCancelledDownload];
            
            break;
            
        case kAutomaticUpdateFinishedDownload:
            
            [self updateStateTo:kAutomaticUpdateInstalling];
            
            
            break;
            
        case kAutomaticUpdateNoInternet:
            
            // Retry what tho?  Check API or Download?
            
            break;
            
            
        default:
            break;
    }
    
}





@end
