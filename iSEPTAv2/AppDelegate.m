//
//  AppDelegate.m
//  iSEPTA
//
//  Created by Justin Brathwaite on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"

//#define ENABLE_PUSH_NOTIFICATIONS

@implementation AppDelegate

@synthesize window = _window;
@synthesize data;

@synthesize sBar;
@synthesize sBarStops;

@synthesize CanConnect;
@synthesize locationManager;
@synthesize currentLocation;


@synthesize deviceToken = _deviceToken;


- (void) checkReachability:   (Reachability*) curReach
{
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    NSString* statusString= @"";
    switch (netStatus)
    {
        case NotReachable:
        {
            statusString = @"Access Not Available";
            //imageView.image = [UIImage imageNamed: @"stop-32.png"] ;
            //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
            connectionRequired= NO;  
            NSLog(@"AppDelegate - checkReachability: %@",statusString);
            CanConnect.connection =statusString;
            break;
        }
            
        case ReachableViaWWAN:
        {
            statusString = @"Reachable WWAN";
            //imageView.image = [UIImage imageNamed: @"WWAN5.png"];
            NSLog(@"AppDelegate - checkReachability: %@",statusString);
            CanConnect.connection =statusString;
            break;
        }
        case ReachableViaWiFi:
        {
            statusString= @"Reachable WiFi";
            //imageView.image = [UIImage imageNamed: @"Airport.png"];
            NSLog(@"AppDelegate - checkReachability: %@",statusString);
            CanConnect.connection =statusString;
            break;
        }
    }
    
    if(connectionRequired)
    {
        statusString= [NSString stringWithFormat: @"%@, Connection Required", statusString];
    }
    NSLog(@"AppDelegate: %@", statusString);
    //textField.text= statusString;
}


- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
	{
		[self checkReachability:  curReach];
//        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        
        // Commented everything below on 12/14/12
//        BOOL connectionRequired= [curReach connectionRequired];
        
        //summaryLabel.hidden = (netStatus != ReachableViaWWAN);
//        NSString* baseLabel=  @"";
//        if(connectionRequired)
//        {
//            baseLabel=  @"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
//        }
//        else
//        {
//            baseLabel=  @"Cellular data network is active.\n  Internet traffic will be routed through it.";
//        }
        // summaryLabel.text= baseLabel;
        
    }
	if(curReach == internetReach)
	{	
        [self checkReachability:  curReach];
		//[self configureTextField: internetConnectionStatusField imageView: internetConnectionIcon reachability: curReach];
	}
	if(curReach == wifiReach)
	{	
        [self checkReachability:  curReach];
		//[self configureTextField: localWiFiConnectionStatusField imageView: localWiFiConnectionIcon reachability: curReach];
	}
	
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [NSThread sleepForTimeInterval:.5];
    // Override point for customization after application launch.
 
    UnitTest_TableViewStore *ut = [[UnitTest_TableViewStore alloc] init];
    
    [ut setup];
    [ut run];
    [ut cleanup];
    
    NSLog(@"Unit Testing Finished");
    
    
#ifdef ENABLE_PUSH_NOTIFICATIONS
    NSLog(@"AppDelegate - didFinishLaunchingWithOptions: Registering for push notifications");
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound) ];
    if ( [[UIApplication sharedApplication] enabledRemoteNotificationTypes] != (UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound) )
    {
        NSLog(@"AppDelegate - didFinishLaunchingWithOptions: Push notificatiosn were not enabled");
    }
#endif
    
    data=[[NSMutableString alloc] init];
//    busdata=[[BusSchedules alloc] init];
//    CanConnect=[[internetReachability alloc] init];
   
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ( userInfo == nil )
    {
        NSLog(@"AppDelegate - didFinishLaunchingWithOptions: No notifications information stored in launchOptions");
    }

    [self transferDb];
   
    
    NSDictionary *regionInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey];
    if ( regionInfo == nil )
    {
        
    }
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
    //remoteHostLabel.text = [NSString stringWithFormat: @"Remote Host: %@", @"www.apple.com"];
//	hostReach = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
    hostReach = [Reachability reachabilityWithHostname: @"www.apple.com"];
	[hostReach startNotifier];
	[self updateInterfaceWithReachability: hostReach];
	
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifier];
	[self updateInterfaceWithReachability: internetReach];
    
    wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	[wifiReach startNotifier];
	[self updateInterfaceWithReachability: wifiReach];
    
    
    return YES;
}





#ifdef ENABLE_PUSH_NOTIFICATIONS
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSString *str=[NSString stringWithFormat:@"Error =%@",error];
    NSLog(@"AppDelegate -- didFailToRegisterForRemoteNotificationsWithError -- %@",str);
}

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *str=[NSString stringWithFormat:@"Device Token=%@",deviceToken];
    NSLog(@"AppDelegate -- didRegisterForRemoteNotificationsWithDeviceToken -- %@",str);
    [self setDeviceToken: deviceToken];
    // Send Token To Server
}

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceError:(NSError *) err
{
    NSString *str=[NSString stringWithFormat:@"Error =%@",err];
    NSLog(@"AppDelegate -- didRegisterForRemoteNotificationsWithDeviceError -- %@",str);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    for (id key in userInfo)
    {
        NSLog(@"AppDelegate - didReceiveRemoteNotification -- key : %@, value: %@", key,[userInfo objectForKey:key]);
    }
}
#endif


// Add 12/9/12 to experiment with local notifications
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    NSLog(@"AppDelegate - Received Notification: %@", notification);
    
    NotificationInfo *infoObject = [[NotificationInfo alloc] initWithNotification:notification];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert!" message:[NSString stringWithFormat:@"Local notification for %@", infoObject.stopName] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

//-(BOOL) application:(UIApplication *) application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//{
//    
//    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"HelpStoryboard" bundle:nil];
//    UIViewController* initialHelpView = [storyboard instantiateInitialViewController];
//    
//    initialHelpView.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentModalViewController:initialHelpView animated:YES];
//    
//    return YES;
//}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
}

- (BOOL)transferDb {
    
    /* NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDirectory, YES);
     NSString *documentDir = [paths objectAtIndex:0];
     NSString *path = [documentDir stringByAppendingPathComponent:@"SEPTADB.sqlite3"];
     NSLog(@"%@",path);
     
     // NSFileManager *fileManager = [NSFileManager defaultManager];
     NSFileManager *fileManager = [[NSFileManager alloc] init];
     if (![fileManager fileExistsAtPath: path])
     {
     NSString *bundle =  [[ NSBundle mainBundle] pathForResource:@"SEPTADB" ofType:@"sqlite3"];
     
     [fileManager copyItemAtPath:bundle toPath:path error:nil];
     return YES;
     }*/
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
    
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath: bundleRoot error: nil];
    NSArray *onlyPdf = [dirContents filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"self ENDSWITH '.sqlite3'"]];
    
    //debugLog(@"Sample PDF %@", onlyPdf);
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex: 0];
    
    for (int i = 0; i < onlyPdf.count; i++) {
        NSString *pdfName = [onlyPdf objectAtIndex: i];
        
        NSString *docPdfFilePath = [documentsDir stringByAppendingPathComponent: pdfName];
        
        //Using NSFileManager we can perform many file system operations.
        BOOL success = [fileManager fileExistsAtPath: docPdfFilePath];
        
        if (!success) {
            NSString *samplePdfFile  = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: pdfName];
            
            success = [fileManager copyItemAtPath: samplePdfFile toPath: docPdfFilePath error:nil];
            
            if (!success)
                //              NSAssert1(0, @"Failed to copy file '%@'.", [error localizedDescription]);
                //debugLog(@"Failed to copy %@ file, error %@", pdfName, [error localizedDescription]);
                NSLog(@"AppDelegate - transferDb: db transfer Failure");
            else {
                //debugLog(@"File copied %@ OK", pdfName);
                NSLog(@"AppDelegate - transferDb: db transfer success");
            }
        }
        else {
            //debugLog(@"File exits %@, skip copy", pdfName);
            NSLog(@"AppDelgate - transferDb: Skip copy");
        }
    }
    return NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



@end
