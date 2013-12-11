//
//  SystemAlertsViewController.m
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "SystemAlertsViewController.h"

@interface SystemAlertsViewController ()

@end

@implementation SystemAlertsViewController
{
    NSMutableArray *_alertData;
    NSMutableArray *_buttonsArr;
    
    ElevatorStatusObject *_esObject;
    
//    SystemStatusObject *_ssObject;
}

@synthesize segmentAlertType;
@synthesize webView;

//@synthesize alerts;
//@synthesize route_id;

@synthesize ssObject = _ssObject;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    
    return self;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float w = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
//    [titleView updateFrame: CGRectMake(0, 0, self.view.frame.size.width - (w*2) -8, 32)];
    float w = self.view.frame.size.width;
    [titleView updateWidth: w];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Segment is defaults to two segments
    [self.segmentAlertType removeAllSegments];

    
    [self.view setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"mainBackground.png"] ] ];

    NSString *html = @"<html><head><title> </title></head><body> </body></html>";
    [webView loadHTMLString:html baseURL:nil];

    // SystemStatusView will never call this if there are no alerts
//    SystemAlertType alertType;
    
    
    _buttonsArr = [[NSMutableArray alloc] init];
    
    if ( self.alertArr != nil )
    {
        
        // Quickly populate _ssObject
        
        _ssObject = [[SystemStatusObject alloc] init];
        
        SystemAlertObject *saObject = [self.alertArr objectAtIndex:0];  // <-- WTF?!
        
        if ( [saObject.current_message length] > 1 )
        {
            [_ssObject setIsalert:@"Y"];
        }
        else
        {
            [_ssObject setIsalert:@"N"];            
        }
        
        if ( [saObject.advisory_message length] > 1 )
        {
            [_ssObject setIsadvisory:@"Yes"];
        }
        else
        {
            [_ssObject setIsadvisory:@"No"];
        }
        
        if ( [saObject.detour_message length] > 1 )
        {
            [_ssObject setIsdetour:@"Y"];
        }
        else
        {
            [_ssObject setIsdetour:@"N"];            
        }
        
        [_ssObject setIssuspend:@"N"];
        [_ssObject setMode:@"Bus"];
        [_ssObject setRoute_id: saObject.route_id];
        [_ssObject setRoute_name: saObject.route_name];
        
    }  // if ( self.alertArr == nil )
    
    
    int count = 1;
    int numOfAlerts = [_ssObject numOfAlerts];
    
    if ( [[_ssObject isadvisory] isEqualToString:@"Yes"] )
    {
        UIButton *button = [self configureButtonX:count++ outOfY:numOfAlerts forAlertType:kSystemAlertTypeAdvisory];
        [_buttonsArr addObject: button];
    }
    
    if ( [[_ssObject isalert] isEqualToString:@"Y"] )
    {
        UIButton *button = [self configureButtonX:count++ outOfY:numOfAlerts forAlertType:kSystemAlertTypeAlert];
        [_buttonsArr addObject: button];
    }
    
    if ( [[_ssObject isdetour] isEqualToString:@"Y"] )
    {
        UIButton *button = [self configureButtonX:count++ outOfY:numOfAlerts forAlertType:kSystemAlertTypeDetour];
        [_buttonsArr addObject: button];
    }
    
    if ( [[_ssObject issuspend] isEqualToString:@"Y"] )
    {
        UIButton *button = [self configureButtonX:count++ outOfY:numOfAlerts forAlertType:kSystemAlertTypeSuspend];
        [_buttonsArr addObject: button];
    }
    
    for (UIButton *button in _buttonsArr)
    {
        [self.view addSubview: button];
        [self.view sendSubviewToBack: button];
    }
        
    
    
    // --==
    // --==   TITLE
    // --==
    if ( [[_ssObject mode] isEqualToString:@"Bus"] )
    {
        [self setTitle: [NSString stringWithFormat:@"Route %@", _ssObject.route_name] ];
    }
    else if ( [[_ssObject mode] isEqualToString:@"Trolley"] )
    {
        [self setTitle: [NSString stringWithFormat:@"Trolley %@", _ssObject.route_name] ];
    }
    else
        [self setTitle: _ssObject.route_name];
    
    
    
    
    // If only one button, automatically select it
//    if ( [alerts count] == 1 )
//    {
    
        // Always set the first option
        UIButton *button = [_buttonsArr objectAtIndex:0];
//        [self changeColorBarTo: button.tag];
        [button sendActionsForControlEvents: UIControlEventTouchUpInside];
//    }
    
    
    
    // --=============================--
    // --==  Configure Back Button  ==--
    // --=============================--
    CustomFlatBarButton *backBarButtonItem;
    if ( self.backImageName != NULL )
    {
        backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:self.backImageName withTarget:self andWithAction:@selector(backButtonPressed:)];
    }
    else
    {
        backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"system_status-white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    }
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    
    
    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0, 500, 32) withTitle: self.title];
    [self.navigationItem setTitleView:titleView];

    
    
    _alertData = [[NSMutableArray alloc] init];
    
    if ( self.alertArr == nil )
    {
        [self getAlertData];
    }
    else
    {
        [_alertData addObjectsFromArray: self.alertArr];
        [self displayHTML];
    }
    
    
}


-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    if ( [[_ssObject mode] isEqualToString:@"Elevator"] )
        [self displayElevatorHTML];
    else
        [self displayHTML];
    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    float w    = self.view.frame.size.width;
    [titleView updateWidth: w];
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
    
}

//-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
//    float w = self.view.frame.size.width;
//    float pad = 4.0f;
//    float tw; // = (w - pad) / 2.0f;
    
//    switch ( [_buttonsArr count] )
//    {
//        case 1:
//            tw = w;
//            break;
//            
//        case 2:
//            tw = (w - pad) / 2.0f;
//            break;
//            
//        case 3:
//            tw = (w - (2*pad) ) / 3.0f;
//            break;
//            
//        case 4:
//            tw = (w - (3*pad) ) / 4.0f;
//            break;
//            
//        default:
//            tw = w;
//            break;
//    }

    
    LineHeaderView *titleView = (LineHeaderView*)self.navigationItem.titleView;
//    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
//    [titleView updateFrame: CGRectMake(0, 0, w - (navW*2) -8, 32)];
    [titleView updateWidth: self.view.frame.size.width ];
    
}



//-(UIButton*) configureButtonX: (int) buttonNo outOfY: (int) totalButtons withTitle:(NSString*) title andWithImageNamed:(NSString*) imageNamed
-(UIButton*) configureButtonX: (int) buttonNo outOfY: (int) totalButtons forAlertType:(SystemAlertType) alertType
{
    
    NSString *title;
    NSString *imageNamed;
    
    switch (alertType) {
        case kSystemAlertTypeAlert:
            title = @"Alerts";
            imageNamed = @"system_status_alert.png";
            break;
            
        case kSystemAlertTypeAdvisory:
            title = @"Advisory";
            imageNamed = @"system_status_advisory.png";
            break;
            
        case kSystemAlertTypeDetour:
            title = @"Detour";
            imageNamed = @"system_status_detour.png";
            break;
            
        case kSystemAlertTypeSuspend:
            title = @"Suspend";
            imageNamed = @"system_status_suspend.png";
            break;
            
        default:
            break;
    }

    
    float w = self.view.frame.size.width;
    float pad = 4.0f;
    float tw; // = (w - pad) / 2.0f;
    
    switch (totalButtons)
    {
        case 1:
            tw = w - (2*pad);
            break;
            
        case 2:
            tw = (w - pad) / 2.0f;
            break;
            
        case 3:
            tw = (w - (2*pad) ) / 3.0f;
            break;
            
        case 4:
            tw = (w - (3*pad) ) / 4.0f;
            break;
            
        default:
            tw = w;
            break;
    }
        
    
    float x;
    float y;
    
    if ( totalButtons == 1 )
        x = pad;
    else
        x = (buttonNo - 1) * (tw+pad);
    
    y = 3;
    float th = 40.0f;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, tw, th)];
    [button setTag: alertType];
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    UIGraphicsBeginImageContext(rect.size);
//    context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [[UIColor blueColor] CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *blueimg = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    
//    [button setBackgroundImage:img forState:UIControlStateHighlighted];
    [button setBackgroundImage:img forState:UIControlStateSelected];
    
    UIImage *icon = [UIImage imageNamed: imageNamed];
    
    [button setImage: icon forState:UIControlStateNormal];
//    NSLog(@"icon width: %6.3f, offset: %6.3f", icon.size.width, -(icon.size.width/2-pad) );
//    NSLog(@"image frame: %@", NSStringFromCGRect(button.imageView.frame));
//    [button setImageEdgeInsets: UIEdgeInsetsMake(0, -(tw/2 + (icon.size.width/2-pad)), 0, 0)];
//    [button setTitleEdgeInsets: UIEdgeInsetsMake(0, -(tw/2-5), 0, 0)];
    
    [button setImageEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 0)];
    [button setTitleEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 0)];
    
    
    [button.layer setCornerRadius:5];
    [button setClipsToBounds:YES];
    
    [button setBackgroundColor: [UIColor whiteColor]];
    
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //[button1 setTitle:@"There is a lot of text in here so sit down and grab something to eat cause you're going to be here for a while." forState:UIControlStateNormal];
    [button setTitle: title forState:UIControlStateNormal];
    
//    [button setTag: buttonNo];
    
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = CGRectMake(0, 0, 0, 0);
//    [button.layer setMask:maskLayer];
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [button setHighlighted:NO];
    
    NSLog(@"image frame: %@", NSStringFromCGRect(button.imageView.frame));

    [button setAutoresizesSubviews:YES];
    [button setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin) ];
    
    [button setImageEdgeInsets: UIEdgeInsetsMake(-5, 0, 0, 0)];
//    [button setTitleEdgeInsets: UIEdgeInsetsMake(0, 0, 0, 0)];
    
    return button;
}


-(void) segmentPressed:(UISegmentedControl*) segment
{
    NSLog(@"Segment pressed");
}



#pragma mark - Buttons Pressed
-(void) backButtonPressed:(id) sender
{
    
//    NSLog(@"Custom Back Button -- %@", sender);
    //    [self dismissModalViewControllerAnimated:YES];  // Does not work
    //    [self removeFromParentViewController];   // Does nothing!
    //    [self.view removeFromSuperview];  // Removed from Superview but doesn't go back to previous VC
    
    
    //    [self.navigationController removeFromParentViewController];  // Does not work, does not do anything
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void) changeColorBarTo: (SystemAlertType) alertType
{
    
    switch (alertType)
    {
        case kSystemAlertTypeAlert:
            [self.imgColorBar setBackgroundColor: [UIColor colorWithRed:190.0f/255.0f green:30.0f/255.0f blue:45.0f/255.0f alpha:1.0f]];
            break;
            
        case kSystemAlertTypeAdvisory:
            [self.imgColorBar setBackgroundColor: [UIColor colorWithRed:249.0f/255.0f green:213.0f/255.0f blue:24.0f/255.0f alpha:1.0f]];
            break;
            
        case kSystemAlertTypeDetour:
            [self.imgColorBar setBackgroundColor: [UIColor colorWithRed:227.0/255.0f green:115.0f/255.0f blue:29.0f/255.0f alpha:1.0f]];
            break;
            
        case kSystemAlertTypeSuspend:
            [self.imgColorBar setBackgroundColor: [UIColor blackColor]];
            break;
            
        default:
            [self.imgColorBar setBackgroundColor: [UIColor lightGrayColor]];
            break;
    }
    
}


-(void) buttonPressed:(UIButton*) pressedButton
{
    
//    NSLog(@"tag: %d -- isSelected: %d, isHighlighted: %d", pressedButton.tag, pressedButton.isSelected, pressedButton.highlighted);

//    [pressedButton setSelected:YES];
    
//    [(UIButton*)[_buttonsArr objectAtIndex:0] setSelected: ![(UIButton*)[_buttonsArr objectAtIndex:0] isSelected] ];
    

    [self changeColorBarTo: pressedButton.tag];
    
    
    for ( UIButton *thisButton in _buttonsArr )
    {
//        NSLog(@"tag: %d -- isSelected: %d, isHighlighted: %d", thisButton.tag, thisButton.isSelected, thisButton.highlighted);
        if ( thisButton == pressedButton )
        {
            [thisButton setSelected:YES];
        }
        else
        {
            [thisButton setSelected:NO];
        }
    }

    if ( [[_ssObject mode] isEqualToString:@"Elevator"] )
        [self displayElevatorHTML];
    else
        [self displayHTML];

//    [self displayHTML];
    
//    NSLog(@" ");
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
    
}


- (void)viewDidUnload
{
    
    [self setSegmentAlertType:nil];
    [self setWebView:nil];
    
    [self setImgColorBar:nil];
    [super viewDidUnload];
    
}


#pragma mark - UISegmentedControl
- (IBAction)segmentAlertTypeChanged:(id)sender
{
    
    // Display data for selected segment
    NSLog(@"SAVC - Segment selected: %d) %@", self.segmentAlertType.selectedSegmentIndex, [self.segmentAlertType titleForSegmentAtIndex:self.segmentAlertType.selectedSegmentIndex]);
    
    [self displayHTML];
    
}


#pragma mark - Realtime Data Handling
-(void) getElevatorData
{
 
    NSString *elevatorURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/elevator/"];
    NSString *elevatorWebURL = [elevatorURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        
        NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString: elevatorWebURL] ];
        [self performSelectorOnMainThread:@selector(processElevatorStatusJSONData:) withObject: realTimeTrainInfo waitUntilDone:YES];
        
    });
    
}

-(void) getAlertData
{
    
    Reachability *network = [Reachability reachabilityForInternetConnection];
    if ( ![network isReachable] )
        return;  // Don't bother continuing if no internet connection is available
    
    
    if ( [_ssObject route_id] == nil )
        return;
    
    if ( [[_ssObject mode] isEqualToString:@"Elevator"] )
    {
        [self getElevatorData];
        return;
    }
    
    NSString* stringURL = [NSString stringWithFormat:@"http://www3.septa.org/hackathon/Alerts/get_alert_data.php?req1=%@", [_ssObject route_id] ];
    
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"SAVC - getAlertData -- api url: %@", webStringURL);
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        
        NSData *realTimeTrainInfo = [NSData dataWithContentsOfURL:[NSURL URLWithString:webStringURL] ];
        [self performSelectorOnMainThread:@selector(processSystemAlertJSONData:) withObject: realTimeTrainInfo waitUntilDone:YES];
        
    });
    
}


-(void) processElevatorStatusJSONData:(NSData*) returnedData
{
 
    [SVProgressHUD dismiss];
    
    if ( returnedData == nil )  // No data returned.  This will cause NSJSONSerialization to return an error.
        return;
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    
    _esObject = [[ElevatorStatusObject alloc] init];
    [_esObject setJSON: returnedData];
    
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( json == nil )
        return;
    
    if ( error != nil )
        return;  // Something bad happened, so just return.

    
    [self displayElevatorHTML];
    
}


-(void) processSystemAlertJSONData:(NSData*) returnedData
{
    [SVProgressHUD dismiss];
    
    if ( returnedData == nil )  // No data returned.  This will cause NSJSONSerialization to return an error.
        return;
    
    // This method is called once the realtime positioning data has been returned via the API is stored in data
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData: returnedData options:kNilOptions error:&error];
    
    if ( json == nil )
        return;
    
    if ( error != nil )
        return;  // Something bad happened, so just return.
    
    [_alertData removeAllObjects];
    
    for (NSDictionary *data in json)
    {
        SystemAlertObject *saObject = [[SystemAlertObject alloc] init];
        
        [saObject setRoute_id:   [data objectForKey:@"route_id"] ];
        [saObject setRoute_name: [data objectForKey:@"route_name"] ];
        
        [saObject setCurrent_message:  [data objectForKey:@"current_message"] ];
        [saObject setAdvisory_message: [data objectForKey:@"advisory_message"] ];
        
        [saObject setDetour_message:        [data objectForKey:@"detour_message"] ];
        [saObject setDetour_start_location: [data objectForKey:@"detour_start_location"] ];
        
        [saObject setDetour_start_date_time: [data objectForKey:@"detour_start_date_time"] ];
        [saObject setDetour_end_date_time:   [data objectForKey:@"detour_end_date_time"] ];
        
        [saObject setDetour_reason: [data objectForKey:@"detour_reason"] ];
        [saObject setLast_updated:  [data objectForKey:@"last_updated"] ];
        
        [_alertData addObject: saObject];
    }

    
    [self displayHTML];
    
}

-(void) displayHTML
{
    
    for (UIButton *button in _buttonsArr)
    {
        if ( [button isSelected] )
        {
            
            [self outputHTMLWithAlertType: button.tag];
            
        }
    }
    
}


-(void) displayElevatorHTML
{
    
    NSMutableString *html;
    html = [NSMutableString stringWithString:@"<html><style>body { font-family:\"Trebuchet MS\"; word-wrap:break-word;} tr:nth-child(2n+1) {background-color: #ddd;} </style><head><title>TITLE</title></head>"];
    
    
    for (ElevatorResultsObject *erObj in _esObject.results)
    {
        
        NSString *htmlTable = [NSString stringWithFormat:@"<div><br><font face=\"verdana\"><table><tbody><tr><td><b>Line:</b> </td><td>%@</td></tr><tr><td><b>Station:</b> </td><td>%@</td></tr><tr><td><b>Elevator:</b> </td><td>%@</td></tr><tr><td><b>Message:</b> </td><td>%@</td></tr></tbody></table><br></font></div>", [erObj line], [erObj station], [erObj elevator], [erObj message] ];
        
          [html appendFormat:@"<body>%@</body>", htmlTable];
        
    }
    
    [html appendFormat:@"</body>"];
    [html appendString:@"</html>"];
    
    [webView loadHTMLString:html baseURL:nil];
    
}


-(void) outputHTMLWithAlertType: (SystemAlertType) alertType
{

//    NSString *title;
    NSMutableString *html;

    
    html = [NSMutableString stringWithString:@"<html><style>body { font-family:\"Trebuchet MS\"; } tr:nth-child(2n+1) {background-color: #ddd;} </style><head><title>TITLE</title></head>"];

//    SystemAlertObject *saObject = [_alertData objectAtIndex:0];

    [html appendFormat:@"<body>"];
    
    NSString *previoudAdvisoryMessage;
    
    for (SystemAlertObject *saObject in _alertData)
    {
        
        switch ( alertType )
        {
            case kSystemAlertTypeAlert:
                [html appendFormat:@"<body>%@</body>", [saObject current_message] ];
                break;
                
            case kSystemAlertTypeAdvisory:

                // If there are 4 detours listed, there's a good chance the same damn advisory is listed all four times.
                // This filters out the message only if the one immediately proceeding it is the same.

                if ( ![previoudAdvisoryMessage isEqualToString: [saObject advisory_message] ] )
                    [html appendFormat:@"<body>%@</body>", [saObject advisory_message] ];
                previoudAdvisoryMessage = [saObject advisory_message];
                
                break;
                
            case kSystemAlertTypeDetour:
            {
                NSString *htmlTable = [NSString stringWithFormat:@"<div><br><font face=\"verdana\"><table><tbody><tr><td><b>Start Location:</b> </td><td>%@</td></tr><tr><td><b>Start Date:</b> </td><td>%@</td></tr><tr><td><b>End Date:</b> </td><td>%@</td></tr><tr><td><b>Reason for Detour:</b> </td><td>%@</td></tr><tr><td><b>Details:</b> </td><td>%@</td></tr></tbody></table><br></font></div>", [saObject detour_start_location], [saObject detour_start_date_time], [saObject detour_end_date_time], [saObject detour_reason], [saObject detour_message] ];
                
                [html appendFormat:@"<body>%@</body>", htmlTable ];
            }
                break;
                
            case kSystemAlertTypeSuspend:
                [html appendFormat:@"<body>%@</body>", [saObject current_message] ];
                break;
                
            default:
                
                break;
        }
        
    }
    
    /*
     [saObject setDetour_message:        [data objectForKey:@"detour_message"] ];
     [saObject setDetour_start_location: [data objectForKey:@"detour_start_location"] ];
     
     [saObject setDetour_start_date_time: [data objectForKey:@"detour_start_date_time"] ];
     [saObject setDetour_end_date_time:   [data objectForKey:@"detour_end_date_time"] ];
     
     [saObject setDetour_reason: [data objectForKey:@"detour_reason"] ];
     */
    

    [html appendFormat:@"</body>"];
    [html appendString:@"</html>"];

    [webView loadHTMLString:html baseURL:nil];

}

    
//    NSUInteger index = [[self segmentAlertType] selectedSegmentIndex];
//    if ( index == UISegmentedControlNoSegment )
//    {
//        if ( [[self segmentAlertType] numberOfSegments] == 0 )
//            index = -1;
//        else
//            index = 0;
//    }
//    
//    if ( index != -1 )
//        title = [[self segmentAlertType] titleForSegmentAtIndex:index];
//    
//    if ( [_alertData count] == 0 )
//        return;
//    
//    SystemAlertObject *saObject = [_alertData objectAtIndex:0];
//    
//    if ( [title isEqualToString:@"Alert"] )
//    {
//        html = [NSMutableString stringWithString:@"<html><head><title>Alert</title></head>"];
//        
//        [html appendFormat:@"<body>%@</body>", [saObject current_message] ];
//        [html appendString:@"</html>"];
//    }
//    else if ( [title isEqualToString:@"Advisory"] )
//    {
//        html = [NSMutableString stringWithString:@"<html><head><title>Alert</title></head>"];
//        
//        [html appendFormat:@"<body>%@</body>", [saObject advisory_message] ];
//        [html appendString:@"</html>"];
//    }
//    else if ( [title isEqualToString:@"Detour"] )
//    {
//        html = [NSMutableString stringWithString:@"<html><head><title>Alert</title></head>"];
//        
//        [html appendFormat:@"<body>%@</body>", [saObject detour_message] ];
//        [html appendString:@"</html>"];
//    }
//    else if ( [title isEqualToString:@"Suspend"] )
//    {
//        html = [NSMutableString stringWithString:@"<html><head><title>Alert</title></head>"];
//        
//        [html appendFormat:@"<body>%@</body>", [saObject current_message] ];
//        [html appendString:@"</html>"];
//    }
//    else
//    {
//        // Display default message indicating there were no Alerts, Advisories, Detours or Line Suspensions.
//        html = [NSMutableString stringWithString:@"<html><head><title>Alert</title></head>"];
//        
//        [html appendFormat:@"<body>%@</body>", @"No alerts, advisories, detours or suspensions to report."];
//        [html appendString:@"</html>"];
//    }
    
//    [webView loadHTMLString:html baseURL:nil];
    
//}

@end
