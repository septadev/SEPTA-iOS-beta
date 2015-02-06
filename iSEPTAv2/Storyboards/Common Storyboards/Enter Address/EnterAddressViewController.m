//
//  MDSGeocodingViewController.m
//  Map Kit Demo
//
//  Created by Ryan Johnson on 3/18/12.
//  Copyright (c) 2012 mobile data solutions.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.



#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

#import "EnterAddressViewController.h"

@interface EnterAddressViewController ()
{
    
    IBOutlet MKMapView *_mapView;
    NSMutableArray * _geocodingResults;
    CLGeocoder * _geocoder;
    NSTimer * _searchTimer;
    
    CLPlacemark *_placemark;
}

- (void) geocodeFromTimer:(NSTimer *)timer;
- (void) processForwardGeocodingResults:(NSArray *)placemarks;
- (void) processReverseGeocodingResults:(NSArray*)placemarks;
- (void) reverseGeocodeCoordinate:(CLLocationCoordinate2D)coord;
- (IBAction) didLongPress:(UILongPressGestureRecognizer*)gr;
- (void) addPinAnnotationForPlacemark:(CLPlacemark*)placemark;
- (void) zoomMapToPlacemark:(CLPlacemark *)selectedPlacemark;

@end


@implementation EnterAddressViewController
{
    CLLocationManager *_locationManager;

    BOOL _locationEnabled;
}


@synthesize stopData;
@synthesize selectionType;
@synthesize routeType;


+ (EnterAddressViewController*) viewController
{
    return [[self alloc] initWithNibName:@"EnterAddressViewController" bundle:nil];
}

- (void) viewDidLoad
{

    [super viewDidLoad];
    
    _geocodingResults = [NSMutableArray array];
    _geocoder = [[CLGeocoder alloc] init];
    
    
    // Add a DONE button
    [self.navigationItem setRightBarButtonItem: [ [UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)] ];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    
    //  --======
    //  --==  GPS enabled?  ==--
    //  --======
    if ( [CLLocationManager locationServicesEnabled])
    {
        
        _locationEnabled = YES;
        
        _locationManager = [[CLLocationManager alloc] init];
        
        [_locationManager setDelegate:self];
        
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [_locationManager requestWhenInUseAuthorization];
        }

        [_locationManager setDistanceFilter: kCLDistanceFilterNone];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [_locationManager startUpdatingLocation];
        
    }
    else
    {
        _locationEnabled = NO;
    }
    
    
    // --======
    // ==--  Setting up MapKit
    // --======
    // A little background on span, thanks to http://stackoverflow.com/questions/7381783/mkcoordinatespan-in-meters
    
    float displayRadius = 2.0;
    [_mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate, [self milesToMetersFor: displayRadius*2], [self milesToMetersFor: displayRadius*2] ) animated:YES];
    
    [_mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];
    [_mapView setZoomEnabled:YES];
    [_mapView setScrollEnabled:YES];
    
    [_mapView setShowsUserLocation:YES];
    [_mapView setDelegate:self];
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Geocoding Methods
NSString * const kSearchTextKey = @"Search Text"; /*< NSDictionary key for entered search text. Used by NSTimer userInfo.*/

- (void) geocodeFromTimer:(NSTimer *)timer {
    
    NSString * searchString = [timer.userInfo objectForKey:kSearchTextKey];
    
    // Cancel any active geocoding. Note: Cancelling calls the completion handler on the geocoder
    if (_geocoder.isGeocoding)
        [_geocoder cancelGeocode];
    
    [_geocoder geocodeAddressString:searchString
                  completionHandler:^(NSArray *placemark, NSError *error) {
                      if (!error)
                      {
                          [self processForwardGeocodingResults:placemark];
                      }
                      
                  }
     ];
}

- (void) processForwardGeocodingResults:(NSArray *)placemarks
{
    
    [_geocodingResults removeAllObjects];
    [_geocodingResults addObjectsFromArray:placemarks];
    
    NSLog(@"%@", placemarks);
    
//    [self savePlacemark: [placemarks objectAtIndex:0] ];
    
    [self.searchDisplayController.searchResultsTableView reloadData];
    
}

- (void) didLongPress:(UILongPressGestureRecognizer *)gr
{

    if (gr.state == UIGestureRecognizerStateBegan)
    {
        
        // convert the touch point to a CLLocationCoordinate & geocode
        CGPoint touchPoint = [gr locationInView:_mapView];
        CLLocationCoordinate2D coord = [_mapView convertPoint:touchPoint
                                         toCoordinateFromView:_mapView];
        [self reverseGeocodeCoordinate:coord];
    }
    
}

- (void) reverseGeocodeCoordinate:(CLLocationCoordinate2D)coord
{
    
    if ([_geocoder isGeocoding])
        [_geocoder cancelGeocode];
    
    CLLocation * location = [[CLLocation alloc] initWithLatitude:coord.latitude
                                                       longitude:coord.longitude];
    
    [_geocoder reverseGeocodeLocation:location
                    completionHandler:^(NSArray *placemarks, NSError *error) {
                        if (!error)
                            [self processReverseGeocodingResults:placemarks];
                    }];
}


- (void) processReverseGeocodingResults:(NSArray *)placemarks
{
    
    if ([placemarks count] == 0)
        return;
    
    CLPlacemark * placemark = [placemarks objectAtIndex:0];
    NSString * alertMessage = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO); // requires AddressBookUI framework
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Geocode Complete"
                                                     message:alertMessage
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    
    [self savePlacemark: placemark];
    
    
    [alert show];
    
}


- (void) addPinAnnotationForPlacemark:(CLPlacemark*)placemark
{
    
    MKPointAnnotation * placemarkAnnotation = [[MKPointAnnotation alloc] init];
    placemarkAnnotation.coordinate = placemark.location.coordinate;
    placemarkAnnotation.title = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
    [_mapView addAnnotation:placemarkAnnotation];
    
}


- (void) zoomMapToPlacemark:(CLPlacemark *)selectedPlacemark
{
    

    CLLocationCoordinate2D coordinate = selectedPlacemark.location.coordinate;
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);
//    double radius = (MKMapPointsPerMeterAtLatitude(coordinate.latitude) * [(CLCircularRegion*)selectedPlacemark.region radius])*10;
    double radius = (MKMapPointsPerMeterAtLatitude(coordinate.latitude) * selectedPlacemark.region.radius)*10;
    MKMapSize size = {radius, radius};
    MKMapRect mapRect = {mapPoint, size};
    
    mapRect = MKMapRectOffset(mapRect, -radius/2, -radius/2); // adjust the rect so the coordinate is in the middle
    [_mapView setVisibleMapRect:mapRect
                       animated:YES];
    
}

#pragma mark - UISearchDisplayController Delegate Methods
-(void) searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
//    NSLog(@"Bookmark Button Clicked");
    
    [self performSegueWithIdentifier:@"SavedAddressesSegue" sender:self];
    
}


-(BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}


- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    // Use a timer to only start geocoding when the user stops typing
    if ([_searchTimer isValid])
        [_searchTimer invalidate];
    
    const NSTimeInterval kSearchDelay = .25;
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:searchString
                                                          forKey:kSearchTextKey];
    _searchTimer = [NSTimer scheduledTimerWithTimeInterval:kSearchDelay
                                                    target:self
                                                  selector:@selector(geocodeFromTimer:)
                                                  userInfo:userInfo
                                                   repeats:NO];
    
    return NO;
}

#pragma mark - UITableView Data Source + Delegate Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_geocodingResults count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const  kCellIdentifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kCellIdentifier];
    
    
    CLPlacemark * placemark = [_geocodingResults objectAtIndex:indexPath.row];
    
    NSString * formattedAddress = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
    cell.textLabel.text = formattedAddress;
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Clear the map
    [_mapView removeAnnotations:_mapView.annotations];
    
    CLPlacemark * selectedPlacemark = [_geocodingResults objectAtIndex:indexPath.row];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    [self addPinAnnotationForPlacemark:selectedPlacemark];
    
    // hide the search display controller and reset the search results
    [self.searchDisplayController setActive:NO animated:YES];
    [_geocodingResults removeAllObjects];
    
    [self zoomMapToPlacemark:selectedPlacemark];
    [self savePlacemark: selectedPlacemark];
    
    _placemark = selectedPlacemark;
    
}

-(void) savePlacemark: (CLPlacemark*) placemark
{
    
    NSMutableArray *addresses = [[[NSUserDefaults standardUserDefaults] objectForKey:@"EnterAddress:Saved"] mutableCopy];
    
    if ( addresses == nil )
        addresses = [[NSMutableArray alloc] init];
    
    
    BOOL matchFound = NO;
    for (NSData *data in addresses)
    {
        CLPlacemark *pMark = (CLPlacemark*)[NSKeyedUnarchiver unarchiveObjectWithData: data];
        if ( [pMark.addressDictionary isEqualToDictionary: placemark.addressDictionary] )
        {
            matchFound = YES;
            break;
        }
    }
    
    
    if ( !matchFound )
    {
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject: placemark];
        [addresses addObject:data];
        
        [[NSUserDefaults standardUserDefaults] setObject:addresses forKey:@"EnterAddress:Saved"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
//    NSMutableArray *check = [[[NSUserDefaults standardUserDefaults] objectForKey:@"EnterAddress:Saved"] mutableCopy];
//    NSLog(@"check: %@", check);

}





#pragma mark - MKMapView Delegate Methods

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    if ( [annotation isKindOfClass:[MKUserLocation class]] )
        return nil;
    
    static NSString * const kPinIdentifier = @"Pin";
    MKPinAnnotationView * pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kPinIdentifier];
    
    if (!pin)
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinIdentifier];
    
    pin.annotation = annotation;
    
    return pin;
}


#pragma mark - Done Button
-(void) doneButtonPressed:(id) sender
{
    NSLog(@"Done Button Pressed");
    [self pushCurrentLocation];
}

-(void) pushCurrentLocation
{
    
    NSString * storyboardName = @"CurrentLocationStoryboard";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    CurrentLocationTableViewController *clVC = (CurrentLocationTableViewController*)[storyboard instantiateInitialViewController];
    
    [clVC setBackImageName: @"NTA-white.png"];
    
    if ( [stopData.route_type intValue] == kGTFSRouteTypeRail )
        [clVC setRouteType: [NSNumber numberWithInt:kCurrentLocationRouteTypeRailOnly] ];
    else
        [clVC setRouteType: [NSNumber numberWithInt:kCurrentLocationRouteTypeBusOnly] ];
    
    // Pass the location of the selected placemark to CurrentLocation
    LocationObject *locationObj = [[LocationObject alloc] init];
    CLLocationCoordinate2D coord = _placemark.location.coordinate;
    
    [locationObj setLatitude: [NSString stringWithFormat:@"%10.8f", coord.latitude] ];
    [locationObj setLongitude: [NSString stringWithFormat:@"%10.8f", coord.longitude] ];
    
    [clVC setCoordinates: locationObj];
    
    // Pass stopData to CurrentLocation for some reason
    [clVC setRouteData: stopData];
    [clVC setDelegate:self];
    
    [self.navigationController pushViewController:clVC animated:YES];

}

#pragma mark - Custom Methods
-(float) milesToMetersFor: (float) miles
{
    return 1609.344f * miles;
}


#pragma mark - Prepare Segue
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [segue.identifier isEqualToString:@"SavedAddressesSegue"] )
    {
        
        SavedAddressesViewController *saVC = [segue destinationViewController];
        [saVC setDelegate:self];
        // Any data to pass to it?
        
    }
    
    
}


#pragma mark - SavedAddressesProtocol
-(void) addressSelected:(CLPlacemark*) placemark
{
    
//    NSLog(@"Selected placemark: %@", placemark);

    _placemark = placemark;
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    [self addPinAnnotationForPlacemark:placemark];
    [self zoomMapToPlacemark:placemark];
    


}

#pragma mark - CurrentLocationProtocol
-(void) currentLocationSelectionMade:(BasicRouteObject*) routeObj
{
    NSLog(@"selection made");
}


@end
