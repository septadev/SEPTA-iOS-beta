//
//  BackgroundDownloader.m
//  iSEPTA
//
//  Created by septa on 5/7/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "BackgroundDownloader.h"



@implementation BackgroundDownloader
{
    
    long long _totalBytesRead;
    long long _totalBytesExpectedToReadForFile;
    float _percentDone;
    
    BOOL _installInProgress;
    BOOL _installComplete;
    BOOL _downloadInProgress;
    
}

@synthesize dbObject = _dbObject;

+(BackgroundDownloader*) sharedInstance
{
    
    static BackgroundDownloader *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once( &oncePredicate, ^{
       
        _sharedInstance = [[BackgroundDownloader alloc] init];
    
    });
    
    return _sharedInstance;
}

-(id) init
{
    
    self = [super init];
    
    if (self)
    {
        // Initialization code
        _installInProgress = NO;
        _installComplete = NO;
        _downloadInProgress = NO;
    }
    
    return self;
    
}



-(void) downloadSchedule
{
    
    // Keeps repeated calls from downloadSchedule from running
    if ( _downloadInProgress )
        return;
    
    _downloadInProgress = YES;
    
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *path  = [paths objectAtIndex:0];
    
    NSString  *zipPath = [NSString stringWithFormat:@"%@/%@", path, @"SEPTA.zip"];

    // Check if a previously downloaded schedule exists
    // If it exists, delete the last downloaded schedule
    // TODO: Check if the MD5 matches that of the new schedule.  If so, no need to delete it, use it!
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath: zipPath error:&error];
    
    if ( error )
    {
        NSLog(@"BD: Unable to delete %@", zipPath);
    }
    else
    {
        //zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];
        NSLog(@"BD: Deleted zip file! zipPath: %@", zipPath);
    }
    
    
    NSURL *downloadURL = [[NSURL alloc] initWithString: @"http://www3.septa.org/api/dbVersion/download.php"];
    NSURLRequest *request = [NSURLRequest requestWithURL: downloadURL];
    
    if ( ![[Reachability reachabilityForInternetConnection] isReachable] )
        return;
    
    
    AFDownloadRequestOperation *dOp = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:zipPath shouldResume:YES];
    dOp.outputStream = [NSOutputStream outputStreamToFileAtPath: zipPath append:NO];
    
    [dOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSLog(@"BD: Successfully downloaded file to %@", zipPath);
     }
                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"BD: Error: %@", error);
     }];
    
    //    dOp.response.statusCode
    
    [dOp setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        //        NSLog(@"Operation%i: bytesRead: %d", 1, bytesRead);
        //        NSLog(@"Operation%i: totalBytesRead: %lld", 1, totalBytesRead);
        //        NSLog(@"Operation%i: totalBytesExpected: %lld", 1, totalBytesExpected);
        //        NSLog(@"Operation%i: totalBytesReadForFile: %lld", 1, totalBytesReadForFile);
        //        NSLog(@"Operation%i: totalBytesExpectedToReadForFile: %lld", 1, totalBytesExpectedToReadForFile);
        
        _percentDone = ((float)((int)totalBytesRead) / (float)((int)totalBytesExpectedToReadForFile));
        _totalBytesRead = totalBytesRead;
        _totalBytesExpectedToReadForFile = totalBytesExpectedToReadForFile;

//        NSLog(@"Sent %lld of %lld bytes, percent: %6.3f", totalBytesRead, totalBytesExpectedToReadForFile, _percentDone);
        
    }];
    
    [dOp setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        NSLog(@"BD: Download expired!");
    }];
    
    
    [dOp setCompletionBlock:^{
        
        _downloadInProgress = NO;
        NSLog(@"BD: Download completed!");
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/d/yy";
        
        NSDate *date = [dateFormatter dateFromString: _dbObject.effective_date];
        
        NSTimeInterval effectiveDiff = [date timeIntervalSinceNow];
        
        if ( effectiveDiff < 0 )
        {
            [self install];
        }
        else
        {
            
        }
        
    }];
    
    
    [dOp start];
    
}

-(void) downloadStatusForBytes: (long long*) bytesRead andPercentDone: (float*) percent
{
    *bytesRead = _totalBytesRead;
    *percent  = _percentDone;
}


-(void) install
{
    
    _installInProgress = YES;
    _installComplete   = NO;
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *path  = [paths objectAtIndex:0];
    
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    
    //    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", [[self filePath] stringByDeletingLastPathComponent] ];
    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", path];
    
    if ( [zip UnzipOpenFile: zipPath] )
    {
        
        NSArray *contents = [zip getZipFileContents];
        NSLog(@"Contents: %@", contents);
        
        BOOL ret = [zip UnzipFileTo:path overWrite:YES];
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
    _installInProgress = NO;
    _installComplete = YES;
    [zip UnzipCloseFile];
    
}

-(BOOL) installComplete
{
    return _installComplete;
}


-(void) cleanup
{

    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *path  = [paths objectAtIndex:0];
    
    NSString *zipPath = [NSString stringWithFormat:@"%@/SEPTA.zip", path];
    
    if ( zipPath == nil )
        return;  // Nothing to delete
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath: zipPath error:&error];
    
    if ( error )
    {
        NSLog(@"BD: Unable to delete %@", zipPath);
    }
    else
    {
        NSLog(@"BD: Deleted zip file! zipPath: %@", zipPath);
    }
    
}

-(BOOL) isDownloading
{
    return _downloadInProgress;
}

@end
