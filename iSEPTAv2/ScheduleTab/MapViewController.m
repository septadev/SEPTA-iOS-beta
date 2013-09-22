//
//  MapViewController.m
//  iSEPTA
//
//  Created by septa on 3/22/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController
{
    
    KMLParser *kmlParser;
    MKMapRect flyTo;

    BOOL _stillWaitingOnWebRequest;
    CLLocationCoordinate2D lastLocation;

}


@synthesize travelMode;
@synthesize itinerary;


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
    
    [self loadkml];
    [self getLatestBusJSONData];  // Instead of waiting 15 seconds for the next update, grab the latest JSON data now, now, now!
    
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


#pragma mark - KMLParser
-(void)loadkml
{
    
    //    AppDelegate  *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *path;
    
    //    if([appDelegate.busdata.mode isEqualToString:@"Bus"])
    //    {
    //        path = [[NSBundle mainBundle] pathForResource:appDelegate.busdata.routeName ofType:@"kml"];
    //    }
    //    else if([appDelegate.busdata.mode isEqualToString:@"Regional Rail"])
    //    {
    //        path = [[NSBundle mainBundle] pathForResource:@"regionalrail" ofType:@"kml"];
    //    }
    
    if ( [self.travelMode isEqualToString:@"Bus"] )
        path = [[NSBundle mainBundle] pathForResource: itinerary.routeShortName ofType:@"kml"];
    else
        path = [[NSBundle mainBundle] pathForResource:@"regionalrail" ofType:@"kml"];
    
    
    if ( path == nil )
        return;
    
    
    NSURL *url = [NSURL fileURLWithPath:path];
    kmlParser = [[KMLParser alloc] initWithURL:url];
    [kmlParser parseKML];
    
    NSLog(@"KML: %@", url);
    
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    NSArray *overlays = [kmlParser overlays];
    NSLog(@"overlays - %d",[overlays count]);
    [_mapView addOverlays:overlays];
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    NSArray *annotations = [kmlParser points];
    NSLog(@"annotations - %d",[annotations count]);
    [_mapView addAnnotations:annotations];
    
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    flyTo = MKMapRectNull;
    for (id <MKOverlay> overlay in overlays)
    {
        
        if (MKMapRectIsNull(flyTo))
        {
            flyTo = [overlay boundingMapRect];
        }
        else
        {
            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
        }
        
    }
    
    
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    
    // Position the map so that all overlays and annotations are visible on screen.
    _mapView.visibleMapRect = flyTo;
    
    
}

#pragma mark - MapView
-(void) getLatestBusJSONData
{
    
    NSLog(@"DSTVC - getLatestBusJSONData");
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
    if ( [self.travelMode isEqualToString:@"Bus"] )  // Add MFL to this?  Need to investigate this further
    {
        
        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TransitView/%@",itinerary.routeShortName];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"DSTVC - getLatestBusJSONData -- api url: %@", webStringURL);
        
        //    [SVProgressHUD showWithStatus:@"Retrieving data..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            
            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
            [self performSelectorOnMainThread:@selector(addAnnotationsUsingJSONBusData:) withObject: realtimeBusInfo waitUntilDone:YES];
            
        });
        
    }
    else if ( [self.travelMode isEqualToString:@"Rail"] )
    {
        
        NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TrainView/"];
        NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"DSTVC - getLatestRailJSONData -- api url: %@", webStringURL);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
            
            NSData *realtimeBusInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
            [self performSelectorOnMainThread:@selector(addAnnotationsUsingJSONRailData:) withObject: realtimeBusInfo waitUntilDone:YES];
            
        });
        
    }
    
    
    
}

#pragma mark - JSON Processing
-(void) addAnnotationsUsingJSONRailData:(NSData*) returnedData
{
    
    NSLog(@"DSTVC - addAnnotationsUsingJSONRailData");
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    NSMutableArray *annotationsToRemove = [[_mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [_mapView userLocation] ];         // Keep the userLocation annotation on the map
    [_mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
    
    
    for (NSDictionary *railData in json)
    {
        
        //        NSString *trainno = [railData objectForKey:@"trainno"];
        //        if ( [trainNoArray containsObject:trainno] )
        //        {
        //            NSLog(@"Found %@ in JSON stream", trainno);
        //        }
        //        else
        //        {
        //            NSLog(@"Could not find %@ in JSON stream", trainno);
        //        }
        
        
        // Loop through all returned bus info...
        NSNumber *latitude   = [NSNumber numberWithDouble: [[railData objectForKey:@"lat"] doubleValue] ];
        NSNumber *longtitude = [NSNumber numberWithDouble: [[railData objectForKey:@"lon"] doubleValue] ];
        
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([latitude doubleValue], [longtitude doubleValue]);
        
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
        NSString *annotationTitle;
        if ( [[railData objectForKey:@"late"] intValue] == 0 )
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (on time)", [railData objectForKey:@"trainno"] ];
        else
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (%@ min late)", [railData objectForKey:@"trainno"], [railData objectForKey:@"late"]];
        
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"%@ to %@", [railData objectForKey:@"SOURCE"], [railData objectForKey:@"dest"] ] ];
        [annotation setCurrentTitle   : annotationTitle];
        
        if ( [[railData objectForKey:@"trainno"] intValue] % 2)
            [annotation setDirection      : @"TrainSouth"];  // Modulus returns 1 on odd
        else
            [annotation setDirection      : @"TrainNorth"];  // Modulus returns 0 on even
        
        
        [_mapView addAnnotation: annotation];
        
    }
    
    NSLog(@"DSTVC - addAnntoationsUsingJSONRailData -- added %d annotations", [json count]);
    
    
}


-(void) addAnnotationsUsingJSONBusData:(NSData*) returnedData
{
    
    NSLog(@"DSTVC - addAnnotationsUsingJSONBusData");
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    
    // Remove all previous annotations
    //    NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] init];
    //    for ( id currentAnnotation in [mapView annotations])
    //    {
    //        if ( currentAnnotation != mapView.userLocation)
    //            [annotationsToRemove addObject: currentAnnotation];
    //    }
    //    [mapView removeAnnotations: annotationsToRemove];
    
    
    NSMutableArray *annotationsToRemove = [[_mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [_mapView userLocation] ];         // Keep the userLocation annotation on the map
    [_mapView removeAnnotations: annotationsToRemove];                    // All annotations remaining in the array get removed
    
    
    for (NSDictionary *busData in [json objectForKey:@"bus"])
    {
        
        //        NSLog(@"DSTVC - Bus data: %@", busData);
        // Loop through all returned bus info...
        NSNumber *latitude   = [NSNumber numberWithDouble: [[busData objectForKey:@"lat"] doubleValue] ];
        NSNumber *longtitude = [NSNumber numberWithDouble: [[busData objectForKey:@"lng"] doubleValue] ];
        
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([latitude doubleValue], [longtitude doubleValue]);
        
        NSString *direction = [busData objectForKey:@"Direction"];
        
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
        NSString *annotationTitle  = [NSString stringWithFormat: @"BlockID: %@ (%@ min)", [busData objectForKey:@"BlockID"], [busData objectForKey:@"Offset"]];
        
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"Destination: %@", [busData objectForKey:@"destination"]] ];
        [annotation setCurrentTitle   : annotationTitle];
        [annotation setDirection      : direction];
        
        [_mapView addAnnotation: annotation];
        
    }
    
    NSLog(@"DSTVC - addAnntoationsUsingJSONBusData -- added %d annotations", [[json objectForKey:@"bus"] count]);
    
    //    [SVProgressHUD dismiss];  // We got data, even if it's nothing.  Dismiss the Loading screen...
    
}


#pragma mark - MKMapViewDelegate Methods
-(MKOverlayView*) mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    //    NSLog(@"DSTVC -mapView viewForOverlay");
    return [kmlParser viewForOverlay: overlay];
}

//-(MKAnnotationView*) mapView:(MKMapView *)thisMapView viewForAnnotation:(id<MKAnnotation>)annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    //    NSLog(@"DSTVC - viewForAnnotations");
    
    if ( [annotation isKindOfClass:[MKUserLocation class]] )
        return nil;
    
    static NSString *identifier = @"mapAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } else {
        annotationView.annotation = annotation;
    }
    
    [annotationView setEnabled: YES];
    [annotationView setCanShowCallout: YES];
    
    
    UIImage *image;
    if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"EastBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"SouthBound"] ) )
    {
        image = [UIImage imageNamed:@"bus_blue.png"];
    }
    else if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"WestBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"NorthBound"] ) )
    {
        image = [UIImage imageNamed:@"bus_red.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainSouth"] )
    {
        image = [UIImage imageNamed:@"train_blue.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainNorth"] )
    {
        image = [UIImage imageNamed:@"train_red.png"];
    }
    else
    {
        image = [UIImage imageNamed:@"bus_yellow.png"];
    }
    
    [annotationView setImage: image];
    
    return annotationView;
    
}


- (void)mapView:(MKMapView *)thisMapView regionDidChangeAnimated:(BOOL)animated
{
    //    NSLog(@"DSTVC - mapView regionDidChangeAnimated");
    MKCoordinateRegion mapRegion;
    // set the center of the map region to the now updated map view center
    mapRegion.center = thisMapView.centerCoordinate;
    
    mapRegion.span.latitudeDelta = 0.3; // you likely don't need these... just kinda hacked this out
    mapRegion.span.longitudeDelta = 0.3;
    
    // get the lat & lng of the map region
    //double lat = mapRegion.center.latitude;
    //double lng = mapRegion.center.longitude;
    
    // note: I have a variable I have saved called lastLocation. It is of type
    // CLLocationCoordinate2D and I initially set it in the didUpdateUserLocation
    // delegate method. I also update it again when this function is called
    // so I always have the last mapRegion center point to compare the present one with
    //CLLocation *before = [[CLLocation alloc] initWithLatitude:lastLocation.latitude longitude:lastLocation.longitude];
    //CLLocation *now = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    
//    CLLocationDistance distance = ([before distanceFromLocation:now]) * 0.000621371192;
    
    // resave the last location center for the next map move event
    lastLocation.latitude = mapRegion.center.latitude;
    lastLocation.longitude = mapRegion.center.longitude;
    
}


@end

