//
//  MapMemoryTestViewController.m
//  iSEPTA
//
//  Created by septa on 10/4/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "MapMemoryTestViewController.h"

@interface MapMemoryTestViewController ()

@end

@implementation MapMemoryTestViewController
{
    
    BOOL _stillWaitingOnWebRequest;

    NSBlockOperation *_jsonOp;
    NSOperationQueue *_jsonQueue;
    
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
    
    _jsonQueue = [[NSOperationQueue alloc] init];

    [self getLatestJSONData];       // Grabs the last updated data on the vehciles of the requested route

    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mapView setDelegate:self];
}


-(void) popTheVC
{
    self.counter++;
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) viewDidDisappear:(BOOL)animated
{
//    [self applyMapViewMemoryHotFix];
    [self.mapView setDelegate:nil];
    
    _jsonQueue = nil;
    _jsonOp = nil;
    
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
//    [self applyMapViewMemoryHotFix];
    // Dispose of any resources that can be recreated.
}


- (void)applyMapViewMemoryHotFix
{
    
    _jsonOp = nil;
    _jsonQueue = nil;
    
    switch (self.mapView.mapType)
    {
        case MKMapTypeHybrid:
        {
            self.mapView.mapType = MKMapTypeStandard;
        }
            
            break;
        case MKMapTypeStandard:
        {
            self.mapView.mapType = MKMapTypeHybrid;
        }
            
            break;
        default:
            break;
    }
    
    self.mapView.showsUserLocation = NO;
    self.mapView.delegate = nil;
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    
}



#pragma mark - JSON Data
-(void) getLatestJSONData
{
    
    if ( _stillWaitingOnWebRequest )  // The attempt here is to avoid asking the web server for data if it hasn't returned anything from the previous request
        return;
    else
        _stillWaitingOnWebRequest = YES;
    
    
    NSString* webStringURL;
    NSString *stringURL;
    
    stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/TrainView/"];
    webStringURL = [stringURL stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
    NSLog(@"NTVVC - getLatestJSONData (rail) -- api url: %@", webStringURL);
    
    _jsonOp     = [[NSBlockOperation alloc] init];
    
    __weak NSBlockOperation *weakOp = _jsonOp;  // weak reference avoids retain cycle when calling [self processJSONData:...]
    [weakOp addExecutionBlock:^{
        
        NSData *realTimeJSONData = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
        
        if ( ![weakOp isCancelled] )
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self processJSONData:realTimeJSONData];
            }];
        }
        else
        {
            NSLog(@"NTVVC - getLatestJSONData: _jsonOp cancelled");
        }
        
    }];
    
    [_jsonQueue addOperation: _jsonOp];
    
}


-(void) processJSONData:(NSData*) returnedData
{
    
//    [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(popTheVC) userInfo:Nil repeats:NO];

    
    _stillWaitingOnWebRequest = NO;  // We're no longer waiting on the web request
    
    if ( returnedData == nil )
        return;
    
    // This method is called once the realtime positioning data has been returned via the API
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    NSMutableArray *readData = [[NSMutableArray alloc] init];
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    
    NSMutableArray *annotationsToRemove = [[self.mapView annotations] mutableCopy];  // We want to remove all the annotations minus one
    [annotationsToRemove removeObject: [self.mapView userLocation] ];                // Keep the userLocation annotation on the map
    [self.mapView removeAnnotations: annotationsToRemove];                           // All annotations remaining in the array get removed
    annotationsToRemove = nil;
    
    
    for (NSDictionary *data in json)
    {
        
        if ( [_jsonOp isCancelled] )
            return;
        
        TrainViewObject *tvObject = [[TrainViewObject alloc] init];
        // These keys need to be exactly as they appear in the returned JSON data
        [tvObject setStartName:[data objectForKey:@"SOURCE"] ];
        [tvObject setEndName  :[data objectForKey:@"dest"] ];
        
        [tvObject setLatitude :[data objectForKey:@"lat"] ];
        [tvObject setLongitude:[data objectForKey:@"lon"] ];
        
        [tvObject setLate     :[data objectForKey:@"late"] ];
        [tvObject setTrainNo  :[data objectForKey:@"trainno"] ];
        
        //                CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:[[data objectForKey:@"lat"] doubleValue] longitude: [[data objectForKey:@"lon"] doubleValue] ];
        //                CLLocationDistance dist = [_locationManager.location distanceFromLocation: stopLocation] / 1609.34f;
        
        //                [tvObject setDistance: [NSNumber numberWithDouble: dist] ];
        
        [readData addObject: tvObject];
        [self addAnnotationUsingwithObject: tvObject];
        
    }
    
    
    [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(popTheVC) userInfo:Nil repeats:NO];
    
    
    //    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    //    [readData sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    
    
    //    _tableData = readData;
    //    if ( _trainDataVC != nil )
    //    {
    //        [_trainDataVC updateTableData: _tableData];
    //    }
    
    //    [self kickOffAnotherJSONRequest];
    
    
}


-(void) addAnnotationUsingwithObject: (id) object
{
    
        TrainViewObject *tvObject = (TrainViewObject*) object;
        
        CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake([tvObject.latitude doubleValue], [tvObject.longitude doubleValue]);
        
        mapAnnotation *annotation  = [[mapAnnotation alloc] initWithCoordinate: newCoord];
    
        
        if ( [tvObject.trainNo intValue] % 2)
            [annotation setDirection      : @"TrainSouth"];  // Modulus returns 1 on odd
        else
            [annotation setDirection      : @"TrainNorth"];  // Modulus returns 0 on even
        
        // Create the annonation title
        NSString *annotationTitle;
        if ( [tvObject.late intValue] == 0 )
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (on time)", tvObject.trainNo ];
        else
            annotationTitle  = [NSString stringWithFormat: @"Train #%@ (%d min late)", tvObject.trainNo, [tvObject.late intValue] ];
        
        [annotation setCurrentTitle   : annotationTitle];
        [annotation setCurrentSubTitle: [NSString stringWithFormat: @"%@ to %@", tvObject.startName, tvObject.endName ] ];
        
//        [_annotationLookup setObject: [NSValue valueWithNonretainedObject: annotation] forKey: tvObject.trainNo];
    
        [self.mapView addAnnotation: annotation];
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    
    if ( [annotation isKindOfClass:[MKUserLocation class]] )
        return nil;
    
    //    NSLog(@"TVVC - viewForAnnotations");
    
    static NSString *identifier = @"mapAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier: identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } else {
        annotationView.annotation = annotation;
    }
    
    [annotationView setEnabled: YES];
    [annotationView setCanShowCallout: YES];
    
    
    GTFSRouteType routeType = kGTFSRouteTypeRail;
    
    UIImage *image;
    if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"EastBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"SouthBound"] ) )
    {
        //        if ( [self.routeType intValue] == 0)
        if ( routeType == kGTFSRouteTypeTrolley )
            image = [UIImage imageNamed:@"transitView-Trolley-Blue.png"];
        else
            image = [UIImage imageNamed:@"transitView-Bus-Blue.png"];
    }
    else if ( ( [[(mapAnnotation*)annotation direction] isEqualToString:@"WestBound"] ) || ( [[(mapAnnotation*)annotation direction] isEqualToString:@"NorthBound"] ) )
    {
        if ( routeType == kGTFSRouteTypeTrolley )
            image = [UIImage imageNamed:@"transitView-Trolley-Red.png"];
        else
            image = [UIImage imageNamed:@"transitView-Bus-Red.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainSouth"] )
    {
        image = [UIImage imageNamed:@"trainView-RRL-Blue.png"];
    }
    else if ( [[(mapAnnotation*)annotation direction] isEqualToString: @"TrainNorth"] )
    {
        image = [UIImage imageNamed:@"trainView-RRL-Red.png"];
    }
    else
    {
        if ( routeType == kGTFSRouteTypeTrolley )
            image = [UIImage imageNamed:@"trolley_yellow.png"];
        else
            image = [UIImage imageNamed:@"bus_yellow.png"];
    }
    
    
    [annotationView setImage: image];
    //    [annotationView setCenter:CGPointMake(image.size.width/2, image.size.height/2)];
    //    [annotationView setCenterOffset:CGPointMake(image.size.width/2, image.size.height/2)];
    //    NSLog(@"image size: %@", NSStringFromCGSize( image.size));
    
    return annotationView;
    
}


@end
