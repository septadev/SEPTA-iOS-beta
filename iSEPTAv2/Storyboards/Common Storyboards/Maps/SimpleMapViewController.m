//
//  SimpleMapViewController.m
//  iSEPTA
//
//  Created by septa on 7/31/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "SimpleMapViewController.h"

#import "mapAnnotation.h"

#import "TrainViewObject.h"
#import "TransitViewObject.h"

#import "SVProgressHUD.h"

#define JSON_REFRESH_RATE 20.0f

@interface SimpleMapViewController ()

@end

@implementation SimpleMapViewController
{
    
    NSMutableArray *_tableData;
    GetLocationsObject *_location;
    
    CLLocationManager *_locationManager;
    
}

@synthesize masterList;
@synthesize filterType;

@synthesize radius;

@synthesize mapView;

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
    
    
    // --==
    // ==--  Setting up CLLocation Manager
    // --==
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    [_locationManager startUpdatingLocation];
    
    
    //    float radiusInMiles = 2.0;
    //    [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor:radiusInMiles*2], [self milesToMetersFor:radiusInMiles*2] ) animated:YES];
    
    //    CLLocation *location = [_locationManager location];
    
    float radiusInMiles = [radius floatValue];
    if ( radiusInMiles < 1 )
        [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor:radiusInMiles*2], [self milesToMetersFor:radiusInMiles*2] ) animated:YES];
    else
        [mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor:radiusInMiles], [self milesToMetersFor:radiusInMiles] ) animated:YES];
    
    
    [mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    
    [mapView setShowsUserLocation:YES];
    [mapView setDelegate:self];
    
    [self filterData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CLLocation Delegates
// Depreciated in iOS 6, needed to support iOS5.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Location (iOS5): %@", [newLocation description]);
    [manager stopUpdatingLocation];
    
}

// Use for iOS6
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        NSLog(@"Location (iOS6):%@", location);
    }
    
    [manager stopUpdatingLocation];
    
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error description]);
}


#pragma mark - Filtering
-(void) filterData
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"location_type == %@", self.filterType ];
    _tableData = [[self.masterList filteredArrayUsingPredicate:predicate] mutableCopy];
    
    //    for (GetLocationsObject *glObject in _tableData)
    //    {
    //        NSLog(@"%@", glObject);
    //    }
    
    //    [_tableData sortUsingComparator:sortGetLocationObjectByLocationName];
    
    //    NSSortDescriptor *desc = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];  // But this won't do an NSNumericSearch sort
    //    [_tableData sortUsingDescriptors:[NSArray arrayWithObject:desc] ];
    
    [self updateAnnotations];
    
}


#pragma mark - Custom Methods
-(float) milesToMetersFor: (float) miles
{
    return 1609.344f * miles;
}


#pragma mark - MapKit and Annotations
-(void) updateAnnotations
{
    
    // --==
    // ==--  Annontations
    // --==
    NSMutableArray *annotationsToRemove = [[mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [mapView userLocation] ];         // Keep the userLocation annotation on the map
    [mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
    
    
    for (GetLocationsObject *glObject in _tableData)
    {
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([[glObject location_lat] doubleValue], [[glObject location_lon] doubleValue]);
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
        //            NSString *annotationTitle  = [NSString stringWithFormat: @"BlockID: %@ (%@ min)", [busData objectForKey:@"BlockID"], [busData objectForKey:@"Offset"]];
        
        NSString *annotationTitle = [NSString stringWithFormat:@"%@", [glObject location_name] ];
        
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"Stop ID: %@", [glObject location_id] ] ];
        [annotation setCurrentTitle   : annotationTitle];
        
        //        NSLog(@"FNRVC -(void) updateAnnotations: %@", glObject);
        
        [mapView addAnnotation: annotation];
        [mapView selectAnnotation:annotation animated:YES];
    }
    
}


@end
