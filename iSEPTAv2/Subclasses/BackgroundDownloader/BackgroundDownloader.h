//
//  BackgroundDownloader.h
//  iSEPTA
//
//  Created by septa on 5/7/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

// Pods
#import <Reachability/Reachability.h>
#import <ZipArchive/ZipArchive.h>
#import <AFDownloadRequestOperation/AFDownloadRequestOperation.h>

#import "GetDBVersionAPI.h"

@interface BackgroundDownloader : NSObject

+(BackgroundDownloader*) sharedInstance;

-(void) downloadSchedule;
-(void) downloadStatusForBytes: (long long*)bytesRead andPercentDone: (float*)percent;

-(void) install;
-(BOOL) installComplete;

-(void) cleanup;

-(BOOL) isDownloading;

@property (nonatomic, strong) DBVersionDataObject *dbObject;

@end
