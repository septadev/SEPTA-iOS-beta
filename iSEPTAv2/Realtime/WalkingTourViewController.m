//
//  WalkingTourViewController.m
//  iSEPTA
//
//  Created by septa on 6/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "WalkingTourViewController.h"

@interface WalkingTourViewController ()

@end

@implementation WalkingTourViewController
{
    
    NSMutableArray *_walkingTourPoints;
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _currentLocation;
    
    float _viewingRadiusInMiles;
    float _overlayRadiusInMeters;
    float _distanceFilterInMeters;
    
    BOOL _updateOnce;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _viewingRadiusInMiles   = 1.00f;
    _overlayRadiusInMeters  = 50.0f;
    _distanceFilterInMeters = 1000.0f;
    
    _updateOnce = YES;
    
    // For testing purposes: let's clear all previous notifications.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    

    
    [self configureMap];
    
//    UILocalNotification *localNote = [[UILocalNotification alloc] init];
//    //    NSDate *fireWhen = [NSDate date];
//    //    NSTimeInterval seconds = 10;
//    //    fireWhen = [fireWhen dateByAddingTimeInterval:seconds];
//    
//    [localNote setFireDate: [NSDate date] ];
//    
//    [localNote setAlertBody:[NSString stringWithFormat:@"Entered %@", @"Market East"] ];
//    [localNote setAlertAction:@"Notification"];
//    
//    [localNote setSoundName: @"Train.caf"];
//    
//    NotificationInfo *infoObject = [[NotificationInfo alloc] init];
//    
//    [infoObject setStopName: @"Market East"];
//    [localNote setUserInfo: [infoObject dict]];
//    
//    NotificationInfo *newObject = [[NotificationInfo alloc] initWithNotification:localNote];
//    
//    NSLog(@"%@", newObject);
    
}


- (void)viewDidUnload
{
    
    [self setMapView:nil];
    [super viewDidUnload];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidDisappear:(BOOL)animated
{
    if ( [CLLocationManager regionMonitoringAvailable])
    {
        [_locationManager stopUpdatingLocation];
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    if ( [CLLocationManager regionMonitoringAvailable])
    {
        [_locationManager startUpdatingLocation];
    }
}


#pragma mark - Custom Methods
-(float) milesToMetersFor: (float) miles
{
    return 1609.344f * miles;
}


#pragma mark - Map
-(void) configureMap
{
    
    // Configure MapView  (should occur prior to start location manager
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
    [self.mapView setDelegate:self];
    
    // Configure the CLLocationManager
    if ( [CLLocationManager regionMonitoringAvailable])
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDistanceFilter:kCLDistanceFilterNone];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
       [_locationManager startUpdatingLocation];
    }

    
    WalkingTourStops *stopsData = [[WalkingTourStops alloc] init];
    
    NSArray *stopsArr = [stopsData allStops];

    for (PinLocation *pls in stopsArr)
    {
        
        [self.mapView addAnnotation:pls];

        MKCircle *circle = [MKCircle circleWithCenterCoordinate:pls.coordinate radius:_overlayRadiusInMeters];  // meters from center
        [self.mapView addOverlay: circle];
        
        if ( [CLLocationManager regionMonitoringAvailable])
        {
            CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:pls.coordinate radius:_overlayRadiusInMeters identifier:pls.title ];
            [_locationManager startMonitoringForRegion:region];
        }
        
    }
    
}


#pragma mark - MKMapViewDelegate
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    NSLog(@"Adding annotations");
    
    MKPinAnnotationView *pinView = nil;
    
    if ( annotation != [self.mapView userLocation] )
    {

        static NSString *defaultPinID = @"com.septa.pin";
        pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
        {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            
            [pinView setPinColor: MKPinAnnotationColorRed];
            [pinView setCanShowCallout: YES];
            [pinView setAnimatesDrop  : YES];
            
        }
        
    }
    else
    {
        [self.mapView.userLocation setTitle:@"You are here"];
    }
    
    return pinView;
    
}


-(MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    
    NSLog(@"Adding overlay");
    
    
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:(MKCircle*)overlay];
    [circleView setFillColor: [[UIColor redColor] colorWithAlphaComponent:0.2] ];
    [circleView setStrokeColor: [[UIColor redColor] colorWithAlphaComponent:0.7f] ];
    [circleView setLineWidth:2];
    
    return circleView;
    
    
}


#pragma mark - CLLocationManager Delegates
// iOS 5
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
}


// iOS 6
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

//    if ( [locations count] >= 1 )
//    {

    if ( _updateOnce == YES )
    {

        _currentLocation = [(CLLocation*)[locations objectAtIndex:0] coordinate];
        
        MKCoordinateRegion viewingRegion = MKCoordinateRegionMakeWithDistance(_currentLocation, [self milesToMetersFor:_viewingRadiusInMiles], [self milesToMetersFor:_viewingRadiusInMiles]);
        [self.mapView setRegion:viewingRegion];

        _updateOnce = NO;
    }
    
//    }
    
}


-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
//    NSLog(@"Entered Region");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Region Alert"
//                                                    message:[NSString stringWithFormat:@"You entered the region: %@", region.identifier]
//                                                   delegate:self
//                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];
    
    
    UILocalNotification *localNote = [[UILocalNotification alloc] init];
//    NSDate *fireWhen = [NSDate date];
//    NSTimeInterval seconds = 10;
//    fireWhen = [fireWhen dateByAddingTimeInterval:seconds];

    [localNote setFireDate: [NSDate date] ];

    [localNote setAlertBody:[NSString stringWithFormat:@"Entered %@", region.identifier] ];
    [localNote setAlertAction:@"Notification"];
    
    [localNote setSoundName: @"Train.caf"];

    NotificationInfo *infoObject = [[NotificationInfo alloc] init];
    
    [infoObject setStopName: region.identifier];
    [localNote setUserInfo: [infoObject dict]];
    
    NotificationInfo *newObject = [[NotificationInfo alloc] initWithNotification:localNote];
    
    NSLog(@"%@", newObject);
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
    
}


-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
//    NSLog(@"Exited Region");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Region Alert"
//                                                    message:[NSString stringWithFormat:@"You left the region: %@", region.identifier]
//                                                   delegate:self
//                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];

    UILocalNotification *localNote = [[UILocalNotification alloc] init];
    [localNote setFireDate: [NSDate date] ];
    
    [localNote setAlertBody:[NSString stringWithFormat:@"Left %@", region.identifier] ];
    [localNote setAlertAction:@"Notification"];
    
    [localNote setSoundName: @"Train.caf"];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
    
}


- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    
    NSLog(@"Monitoring failed");
    NSLog(@"error: %@", error);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Alert"
                                                    message:[NSString stringWithFormat:@"Monitoring Failed for Region: %@",region.identifier]
                                                   delegate:self
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];

}


-(void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Start Monitoring Region: %@", region.identifier);
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitor Start"
//                                                    message:[NSString stringWithFormat:@"Now monitoring region: %@", region.identifier]
//                                                   delegate:self
//                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];

}

@end
