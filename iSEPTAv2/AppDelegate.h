//
//  AppDelegate.h
//  iSEPTAv2
//
//  Created by Justin Brathwaite on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "internetReachability.h"
#import <CoreLocation/CoreLocation.h>

#import "NotificationInfo.h"

#import "UnitTest_TableViewStore.h"


@class Reachability;


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    NSMutableString *data;
//    BusSchedules *busdata;
    UISearchBar *sBar;
    UISearchBar *sBarStops;
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;
    internetReachability *CanConnect;
    CLLocation   *currentLocation;
    CLLocationManager *locationManager;
    
    

}
@property (strong, nonatomic) UIWindow *window;
@property(strong,nonatomic)NSMutableString *data;
@property(strong,nonatomic)UISearchBar *sBar;
@property(strong,nonatomic)UISearchBar *sBarStops;
@property(strong,nonatomic)internetReachability *CanConnect;
@property (nonatomic, assign) CLLocation        *currentLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, strong) NSData *deviceToken;

- (BOOL)transferDb;


@end
