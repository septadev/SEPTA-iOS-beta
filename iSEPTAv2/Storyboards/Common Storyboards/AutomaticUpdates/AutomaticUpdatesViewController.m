//
//  AutomaticUpdatesViewController.m
//  iSEPTA
//
//  Created by septa on 1/15/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "AutomaticUpdatesViewController.h"

@interface AutomaticUpdatesViewController ()

@end

@implementation AutomaticUpdatesViewController
{
    
    GetDBVersionAPI *_dbVersionAPI;
    NSString *_localMD5;
    BOOL _autoUpdate;
    
    AutomaticUpdateState _updateSM;
    
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
    
    // "Settings:Update
    
    [super viewDidLoad];
    
//    _updateSM = kAutomaticUpdateStartState;
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

    
//    CustomFlatBarButton *btnUpdate = [[CustomFlatBarButton alloc] initWithTitle:@"Update" style: UIBarButtonItemStylePlain target:self action:@selector(update:)];
//    [self.navigationItem setRightBarButtonItem: btnUpdate];
//    [btnUpdate setEnabled:NO];
    
    
//    UIBarButtonItem *btnUpdate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(update:)];
//    [self.navigationItem setRightBarButtonItem:btnUpdate];
    
    //    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    //    float w    = self.view.frame.size.width;
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0,500, 32) withTitle:@"Update"];
    [self.navigationItem setTitleView:titleView];
    
    
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
    
}


//-(BOOL) getLocalMD5
//{
//    
////    NSString *localMD5;
//    
//    NSString *md5Path = [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"md5"];
//    if ( md5Path == nil )
//        return NO;
//    
//    NSString *md5JSON = [[NSString alloc] initWithContentsOfFile:md5Path encoding:NSUTF8StringEncoding error:NULL];
//    if ( md5JSON == nil )
//        return NO;
//    
//    NSError *error = nil;
//    NSDictionary *md5dict = [NSJSONSerialization JSONObjectWithData: [md5JSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
//    
//    if ( error != nil )
//        return NO;
//    
//    NSArray *md5Arr = [md5dict valueForKeyPath:@"md5"];
//    
//    _localMD5 = [md5Arr firstObject];
//    
//    NSLog(@"localMD5: %@", _localMD5);
//    
//    return YES;
//}


-(void) updateStateTo:(AutomaticUpdateState) newState
{
    
    NSLog(@"Current State: %d", _updateSM);
    NSLog(@"New State    : %d", newState);
    
    _updateSM = newState;
    
    switch (newState)
    {
//        case kAutomaticUpdateStartState:
//            [self.lblVersionStatus setText:@""];
//            break;
            
        case kAutomaticUpdateChecking:
            [self.lblVersionStatus setText: VERSION_CHECKING];
            [self.progressBar setProgress:0.0f];
            
            [self.btnMulti setHidden:YES];
            [self checkAppVersion];
            
            break;
            
        case kAutomaticUpdateUpToDate:
            [self.lblVersionStatus setText: VERSION_NOUPDATE];
            break;
            
        case kAutomaticUpdateLatestAvailable:
            [self.lblVersionStatus setText: VERSION_AVAILABLE];
            [self.btnMulti setHidden:NO];
            [self.btnMulti setTitle:@"Download" forState:UIControlStateNormal];
            break;
            
        case kAutomaticUpdateDownloading:
            [self.lblVersionStatus setText: @"Downloading..."];
            [self.btnMulti setTitle:@"Cancel" forState:UIControlStateNormal];
            [self downloadSchedule];
            break;
            
        case kAutomaticUpdateCancelledDownload:
            [self.lblVersionStatus setText: @"Cancelled Download..."];
            [self.btnMulti setTitle:@"Download" forState:UIControlStateNormal];
            [self cleanUpDownload];
            break;
            
        case kAutomaticUpdateFinishedDownload:
            // TODO: When file was successfully downloaded, save state
            
            [self.lblVersionStatus setText: @"Finished Download"];
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
            
            // Either popup a message to install now or wait until effective_date before installing
            
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"MM/d/yy";
            
            DBVersionDataObject *obj = [_dbVersionAPI getData];
            NSDate *date = [dateFormatter dateFromString: obj.effective_date];
            
            NSTimeInterval effectiveDiff = [date timeIntervalSinceNow];
//            NSTimeInterval lastDateDiff;
            
            
            // Two checks are performed to determine if an alert message goes up
            //   Does the new schedule go into effect within the next 7 days?
            //                          AND
            //   Has it been 24 hours since the last time this message was displayed?
            //   Has the latest schedule been downloaded?


//            NSString *title = @"New schedule";
//            NSString *message = @"";
            
            if ( effectiveDiff < 0 )
            {
                // Install now
                
            }
            else
            {
                // Install in the future
                int numOfWeeks = (int)(effectiveDiff / (60*60*24*7) );
                int numOfDays  = (int)(effectiveDiff / (60*60*24) ) % 7;
                int numOfHrs   = (int)(effectiveDiff / (60*60) ) % 24;
                int numOfMins  = (int)(effectiveDiff / 60) % 60;
                int numOfSec   = ((int)effectiveDiff % 60);
                
                
                NSLog(@"wks: %d, days: %d, hrs: %d, min: %d, sec: %d", numOfWeeks, numOfDays, numOfHrs, numOfMins, numOfSec);
                
            }
            
            
            
//            if ( effectiveDiff < (60*60*24*7) )
//            {
//                
//                
//                ALAlertBanner *alertBanner = [ALAlertBanner alertBannerForView:self.view
//                                                                         style:ALAlertBannerStyleFailure
//                                                                      position:ALAlertBannerPositionBottom
//                                                                         title:@""
//                                                                      subtitle:@""
//                                                                   tappedBlock:^(ALAlertBanner *alertBanner)
//                                              {
//                                                  NSLog(@"Generic Message: %@!", obj.message);
//                                                  [alertBanner hide];
//                                              }];
//                
//                NSTimeInterval showTime = 5.0f;
//                [alertBanner setSecondsToShow: showTime];
//                
//                [alertBanner show];
//
//            }
            
        }
            
            
            
            break;
            
        case kAutomaticUpdateInstalling:
            [self.lblVersionStatus setText: @"Installing"];
            [self installNewSchedule];
            break;
            
        case kAutomaticUpdateFinishedInstall:
            [self.lblVersionStatus setText: @"New Schedule Installed"];
            [self.btnMulti setHidden:YES];
            [self updateStateTo: kAutomaticUpdateDoNothing];
            break;
            
        case kAutomaticUpdateDoNothing:
            break;
            
        case kAutomaticUpdateNoInternet:
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
        NSLog(@"OMG!!!  The MD5 MATCH!");
//        _updateSM = kAutomaticUpdateUpToDate;
        [self updateStateTo:kAutomaticUpdateUpToDate];
    }
    else
    {
        NSLog(@"The MD5s didn't match, I figured as much");
//        _updateSM = kAutomaticUpdateLatestAvailable;
        [self updateStateTo: kAutomaticUpdateLatestAvailable];
    }

    
    //    [self downloadTest];
}



-(NSString*) filePath
{
    return [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"sqlite"];
}


-(void) downloadSchedule
{
    
    // Install!
 
    NSURL *downloadURL = [[NSURL alloc] initWithString: @"http://www3.septa.org/hackathon/dbVersion/download.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL: downloadURL];
    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];
    
    
    if ( ![[Reachability reachabilityForInternetConnection] isReachable] )
        return;

    
    AFDownloadRequestOperation *dOp = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:zipPath shouldResume:YES];
    dOp.outputStream = [NSOutputStream outputStreamToFileAtPath: zipPath append:NO];
    
    [dOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"Successfully downloaded file to %@", zipPath);
     }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
    
    
    [dOp setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        //        NSLog(@"Operation%i: bytesRead: %d", 1, bytesRead);
        //        NSLog(@"Operation%i: totalBytesRead: %lld", 1, totalBytesRead);
        //        NSLog(@"Operation%i: totalBytesExpected: %lld", 1, totalBytesExpected);
        //        NSLog(@"Operation%i: totalBytesReadForFile: %lld", 1, totalBytesReadForFile);
        //        NSLog(@"Operation%i: totalBytesExpectedToReadForFile: %lld", 1, totalBytesExpectedToReadForFile);
        
        float percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToReadForFile));
        NSLog(@"Sent %lld of %lld bytes, percent: %6.3f", totalBytesRead, totalBytesExpectedToReadForFile, percentDone);
        
        [self.progressBar setProgress: percentDone];
        
        if ( totalBytesRead == totalBytesExpectedToReadForFile )
        {
//            [self updateStateTo: kAutomaticUpdateFinishedDownload];
            
            // This should be its own state
            [self.lblVersionStatus setText: @"Finished Download"];
            [self.btnMulti setHidden:NO];
            [self.btnMulti setTitle:@"Install" forState:UIControlStateNormal];
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
    
    
    [dOp setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Download expired!");
    }];
    
    
    [dOp setCompletionBlock:^{
        NSLog(@"Download completed!");
        [self updateStateTo: kAutomaticUpdateFinishedDownload];
    }];
    
    [dOp start];
    //    [dOp waitUntilFinished];
    

    
    
}


-(void) cleanUpDownload
{
    
    // Remove any partial file downloaded
    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];

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
        zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];
        NSLog(@"Deleted zip file! zipPath: %@", zipPath);
    }
    
    
}

-(void) installNewSchedule
{
    
    // Check current date versus the effective date in the API call / NSUserPreferences
    // Is current date before the effective date?
    //    YES - Put up alert, warn user the new schedule won't be active for X days (Y hours)
    //    NO  - Start install
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    
    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];
    
    if ( [zip UnzipOpenFile: zipPath] )
    {
        
        NSArray *contents = [zip getZipFileContents];
        NSLog(@"Contents: %@", contents);
        
        BOOL ret = [zip UnzipFileTo:[[self filePath] stringByDeletingLastPathComponent] overWrite:YES];
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

        NSLog(@"%d == %d, files extracted successfully", count, [contents count]);
        
    }
    [zip UnzipCloseFile];
    
    // The test!
//    FMDatabase *database = [FMDatabase databaseWithPath: [self filePath] ];
//    [database open];
//    
//    FMResultSet *results = [database executeQuery:@"SELECT * FROM SECRETTABLE"];
//    
//    if ( [database hadError] )  // Basic DB error checking
//    {
//        
//        int errorCode = [database lastErrorCode];
//        NSString *errorMsg = [database lastErrorMessage];
//        
//        NSLog(@"SNFRTC - query failure, code: %d, %@", errorCode, errorMsg);
//        NSLog(@"SNFRTC - query str: %@", @"SELECT * FROM SECRETTABLE");
//        
//        return;  // If an error occurred, there's nothing else to do but exit
//        
//    } // if ( [database hadError] )
//
//    while ( [results next] )
//    {
//        NSString *message = [results stringForColumn:@"message"];
//        NSLog(@"The secret message is: %@", message);
////        [self displayAlertWithTitle: @"Secret Message" andMessage: message];
//    }
//    
//    [database close];
    
    
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    NSData *fileData = [NSData dataWithContentsOfFile: [self filePath] ];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(fileData.bytes, fileData.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];

    NSLog(@"Old MD5: %@", _localMD5);
    
    DBVersionDataObject *dbObj = [_dbVersionAPI getData];

    NSLog(@"Dwn MD5: %@", dbObj.md5);
    
    NSLog(@"New MD5: %@", output);

    
    NSString *md5Path = [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"md5"];

    NSMutableDictionary *md5Dict = [[NSMutableDictionary alloc] init];
    [md5Dict setValue: output forKey:@"md5"];
    
    NSArray *md5Array = [[NSArray alloc] initWithObjects:md5Dict, nil];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:md5Array
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSError *jsonParsingError;
    [jsonData writeToFile:md5Path options:NSDataWritingAtomic error:&jsonParsingError];
    
    
    
//    BOOL retValue = [md5Dict writeToFile:md5Path atomically:YES];
    
    [_dbVersionAPI loadLocalMD5];
    
    NSLog(@"Lcl MD5: %@", [_dbVersionAPI localMD5]);
    
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
