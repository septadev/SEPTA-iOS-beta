//
//  augmentedreality.m
//  iSEPTA
//
//  Created by Justin Brathwaite on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SeptaVisionViewController.h"
#import "WTArchitectView.h"
#import "WTPoiDetailViewController.h"
#import "AppDelegate.h"
#import "WTPoiManager.h"
#import "WTPoi.h"

//#import "SBJson.h"

@interface SeptaVisionViewController ()
{
     BOOL    didFinishArchitectInitialisation;
}
- (void)presentPoiDetailViewControllerWithPoiID:(NSString *)theSelectedPoiID;

- (NSMutableArray *)generatePois:(NSUInteger)numberOfPois;
- (NSString *)convertPoiModelToJson:(NSArray *)pois;
@end

@implementation SeptaVisionViewController
@synthesize architectView, currentSelectedPoiID, poiDetailViewController;
@synthesize locationManager;
- (void)dealloc
{
    //[_architectView release];
    //[_currentSelectedPoiID release];
    //[_poiDetailViewController release];
    
    //[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [NSString stringWithFormat:@"AR Browser"];
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        
        // set the init flag to false to load the architect view
        didFinishArchitectInitialisation = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    return;
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.title=@"SEPTAVision";
       self.navigationController.title=@"SEPTAVision";
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // generate some poi data -thats might be done in your app in a more complex way, but for a quick demo, it should be enough-
    
 
   // [WTPoiManager sharedInstance].pois = [self generatePois:WTNUMBER_OF_POIS];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
     [WTPoiManager sharedInstance].pois = [self generatePois:WTNUMBER_OF_POIS];
   
    // because we're in viewDidAppear (which can get called more often when we switch views) we check if we already initialized the sdk view
    if (!didFinishArchitectInitialisation) {
        
        // standard alloc/init with frame call for a uiView subclass
        self.architectView = [[WTArchitectView alloc] initWithFrame:self.view.bounds];
        
        // initialize the sdk with your key
        [self.architectView initializeWithKey:@"" motionManager:nil];
        
        // now we're going to check if the current device supports the needs from the sdk view (see the documentation for more details)
        if ([self.architectView isDeviceSupported]) {
            
            // we set the delegate from our sdk view to this view controller (see the documentation for more details about the delegate protocol)
            self.architectView.delegate = self;
            
            // add the sdk view as a subview to the view controllers view
            [self.view addSubview:self.architectView];
            
            // specify a url for the architect world. this can be a local resource from the bundle, or a web link
                        
            // now you can give your architect world more information on what it should display. We are converting our data model into a JSON string and put that string via a javascript function into the world
           /* NSString *javaScript = [self convertPoiModelToJson:[WTPoiManager sharedInstance].pois];
            NSString *javaScriptToCall = [NSString stringWithFormat:@"newData('%@')", javaScript, javaScript];
            
            // tell the sdk view to execute the javascript
            [self.architectView callJavaScript:javaScriptToCall];*/
        }
        NSString *architectWorldURL = [[NSBundle mainBundle] pathForResource:@"ARchitectBrowser" ofType:@"html"];
        
        // load the architect world            
        [self.architectView loadArchitectWorldFromUrl:architectWorldURL];

        NSString *javaScript = [self convertPoiModelToJson:[WTPoiManager sharedInstance].pois];
        NSString *javaScriptToCall = [NSString stringWithFormat:@"newData('%@')", javaScript];
        
        // tell the sdk view to execute the javascript
        [self.architectView callJavaScript:javaScriptToCall];
        
        didFinishArchitectInitialisation = YES;
    }
    
    // this call actually starts the camera and the sdk view update cycle
    [self.architectView start];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    // we're gona to leave the view, so we can stop the sdk view rendering and the camera updates
    [self.architectView stop];
   
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];    // Call the super class implementation.
    // Usually calling super class implementation is done before self class implementation, but it's up to your application.
   
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}






#pragma mark - WTArchitectView delegate methods
// this delegate method gets called, every time a url with the scheme 'architectsdk://' was called inside javascript. You can use this delegate method to respond to such events in your native app.
- (void)urlWasInvoked:(NSString*)url
{
    if ( [url hasPrefix:@"architectsdk://opendetailpage"] ) {
        
        // the user clicked on the poi detail bubble. The next lines of code are seperating the arguments from the url
        NSRange optionsRange = [url rangeOfString:@"?"];
        if (optionsRange.location != NSNotFound) {
            url = [url substringFromIndex:optionsRange.location+1 ];
            
            NSMutableDictionary *keyValuePairs = [NSMutableDictionary dictionary];
            NSArray *pairs = [url componentsSeparatedByString:@"&"];
            if (pairs.count > 0) {
                for (NSString *pair in pairs) {
                    NSArray *componentPair = [pair componentsSeparatedByString:@"="];
                    NSString *key = [[componentPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                    NSString *value = [[componentPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                    
                    [keyValuePairs setObject:value forKey:key];
                }
            }
            
            // we filtered all parameters and can set the selected poi id in our view controller
            NSString *selectedPoiID = [keyValuePairs objectForKey:@"id"];
            if ( nil != selectedPoiID ) {
                self.currentSelectedPoiID = selectedPoiID;
                
                // this line performs the actual view switch
                [self presentPoiDetailViewControllerWithPoiID:self.currentSelectedPoiID];
            }    
        }
    }
}

#pragma mark - View Switch
// this methods gets called, when we wan't to display the detail view controller
- (void)presentPoiDetailViewControllerWithPoiID:(NSString *)theSelectedPoiID
{
    // we retrieve the poi data from the model
    WTPoi *selectedPoi = [[WTPoiManager sharedInstance] poiForID:[theSelectedPoiID intValue]];
    if (nil != selectedPoi) {
        
        self.poiDetailViewController.poi = selectedPoi;
        if (self.navigationController) {
            [self.navigationController pushViewController:self.poiDetailViewController animated:YES];
        }
    }
}


- (WTPoiDetailViewController *)poiDetailViewController
{
    if (nil == _poiDetailViewController) {
        if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ) {
            _poiDetailViewController = [[WTPoiDetailViewController alloc] initWithNibName:@"WTPoiDetailViewController_iPhone" bundle:nil];
        }else
            _poiDetailViewController = [[WTPoiDetailViewController alloc] initWithNibName:@"WTPoiDetailViewController_iPad" bundle:nil];
        
    }
    return _poiDetailViewController;
}

#pragma mark - Helper
// generate some dummy poi data
- (NSMutableArray *)generatePois:(NSUInteger)numberOfPois
{
    
    NSMutableArray *poiArray = [NSMutableArray arrayWithCapacity:numberOfPois];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self; 
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; 
    locationManager.distanceFilter = kCLDistanceFilterNone; 
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    NSString* stringURL = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/locations/get_locations.php?lon=%f&lat=%f&radius=2&number_of_results=10&type=",coordinate.longitude,coordinate.latitude];
    NSLog(@"url %@",stringURL);
    NSString* webStringURL = [stringURL stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];;
    NSData *buses = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL]];
    
    NSInputStream *busStream = [[NSInputStream alloc] initWithData:buses];
    
    [busStream open];
    
    
    
    if (busStream) {
        
        NSError *parseError = nil;
        
        id jsonObject = [NSJSONSerialization JSONObjectWithStream:busStream options:NSJSONReadingAllowFragments error:&parseError];       
        
        
        int counter = 0;
        for (NSDictionary *bus in jsonObject) {
            
//             NSString *location_id = [bus objectForKey:@"location_id"];
            NSString *location_name = [bus objectForKey:@"location_name"];
            NSString *location_lat = [bus objectForKey:@"location_lat"];
            NSString *location_lon = [bus objectForKey:@"location_lon"];
            NSString *location_type = [bus objectForKey:@"location_type"];

            if(location_name != nil)
                location_name = [location_name stringByReplacingOccurrencesOfString:@"\'" withString:@" "];
            
            int type = 0;
            
            if([location_type isEqualToString:@"bus_stops"])
            {
                type=0; 
            }
            else if([location_type isEqualToString:@"sales_locations"])
            {
                type=1; 
            }
            else if([location_type isEqualToString:@"trolley_stops"])
            {
                type=0; 
            }
            else if([location_type isEqualToString:@"perk_locations"])
            {
                type=2; 
            }
            else if([location_type isEqualToString:@"rail_stations"])
            {
                type=2; 
            }
            NSLog(@"loc name %@ %d type-%d",location_name,counter,type);
            WTPoi *poi = [[WTPoi alloc] init];
            poi.id = counter;
            poi.name = location_name;
            poi.detailedDescription = location_name;
           
            poi.type =  type; // set the type from 0->2->0->2...
            poi.latitude =[location_lat doubleValue]; // set the latitude around your current location
            poi.longitude = [location_lon doubleValue];
            poi.altitude = location.altitude + WT_RANDOM(0, 20); // altitude offset
            
            [poiArray addObject:poi];
           
            counter++;
           
        }
        
        
        
    } else {
        
        NSLog(@"Failed to open stream.");
        
    }

    
    
    for (NSUInteger i = 0; i < numberOfPois; ++i) {
      /*  WTPoi *poi = [[WTPoi alloc] init];
        poi.id = i;
        poi.name = [NSString stringWithFormat:@"POI #%i", i];
        poi.detailedDescription = [NSString stringWithFormat:@"Probably one of the best POIs you have ever seen. This is the description of Poi #%i", i];
        poi.type =  i%3; // set the type from 0->2->0->2...
        poi.latitude = coordinate.latitude + WT_RANDOM(-0.01, 0.01); // set the latitude around your current location
        poi.longitude = coordinate.longitude + WT_RANDOM(-0.01, 0.01);
        poi.altitude = location.altitude + WT_RANDOM(0, 200); // altitude offset
        
        [poiArray addObject:poi];
       // [poi release];*/
    }
    
    return poiArray;
}

// converts our poi model to a JSON string
- (NSString *)convertPoiModelToJson:(NSArray *)pois
{
    NSMutableArray *jsonModelRepresentation = [NSMutableArray arrayWithCapacity:pois.count];
    
    for (WTPoi *poi in pois) {
        [jsonModelRepresentation addObject:[poi jsonRepresentation]];
    }
    
//    SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
//    NSString *generatedJSON = [jsonWriter stringWithObject:jsonModelRepresentation];
//
//    return generatedJSON;
    return nil;
}

@end

