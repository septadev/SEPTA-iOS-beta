//
//  AutomaticUpdatesViewController.h
//  iSEPTA
//
//  Created by septa on 1/15/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// --==  Helper Classes  ==--
#import "LineHeaderView.h"
#import "CustomFlatBarButton.h"
#import "GetDBVersionAPI.h"

// --==  Data Models  ==--
//#import "UpdateStatus.h"

#import <CommonCrypto/CommonCrypto.h>

// --==  PODs  ==--
#import <Reachability.h>
#import <SVProgressHUD.h>
#import <ALAlertBanner/ALAlertBanner.h>
#import <AFNetworking.h>
#import <AFDownloadRequestOperation.h>
#import <ZipArchive.h>
#import <FMDatabase.h>

#import "UpdateStateMachineObject.h"
#import "BackgroundDownloader.h"


#define VERSION_CHECKING  @"Checking for new schedules"
#define VERSION_NOUPDATE  @"Latest schedules installed"
#define VERSION_AVAILABLE @"New schedule found"
#define VERSION_DOWNLOAD  @"Download latest version?"

typedef NS_ENUM(NSInteger, AutomaticUpdateState)
{
    kAutomaticUpdateStartState,
    kAutomaticUpdateChecking,
    kAutomaticUpdateLatestAvailable,
    kAutomaticUpdateUpToDate,
    kAutomaticUpdateDownloading,
    kAutomaticUpdateCancelledDownload,
    kAutomaticUpdateFinishedDownload,
    kAutomaticUpdateInstalling,
    kAutomaticUpdateFinishedInstall,
    kAutomaticUpdateDoNothing,
    
    kAutomaticUpdateNoInternet,
    
};

/*
 
 Start up in StartState, however briefly
 Move right into Checking
 Results of checking decide if the Latest is Available or if it is Update To Date
 If LatestAvailable, make Download Button visible
 When button is pressed, switch to Downloading state, change button to Cancel
 If download has been cancelled, delete file downloaded
 If download has been completed, switch to finished download state (and save state)
 
 
 */

@interface AutomaticUpdatesViewController : UITableViewController <GetDBVersionDataAPIProtocol>

@property (weak, nonatomic) IBOutlet UILabel *lblAutoUpdate;
@property (weak, nonatomic) IBOutlet UISwitch *swtAutoUpdate;

@property (weak, nonatomic) IBOutlet UILabel *lblVersionStatus;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (weak, nonatomic) IBOutlet UIButton *btnMulti;

@property (nonatomic) BOOL startImmediately;

@end
