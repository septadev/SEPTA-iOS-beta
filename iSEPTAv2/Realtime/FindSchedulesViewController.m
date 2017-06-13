//
//  FindSchedulesViewController.m
//  iSEPTA
//
//  Created by septa on 6/27/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "FindSchedulesViewController.h"

#define NUMBER_OF_RESULTS 5

@interface FindSchedulesViewController ()

@end


@implementation FindSchedulesViewController
{
    NSMutableArray *_tableData;
    AFJSONRequestOperation *_jsonOperation;
    
    int _numResults;
    NSMutableArray *_operationArr;
    BOOL _cancelAllOperations;
    
}

@synthesize basicRoute;


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
    
    _numResults = NUMBER_OF_RESULTS;
    _cancelAllOperations = NO;
    
    // Register all NIBs right here!   Do it!  Do it naaaaaaa-ow!
    [self.tableView registerNib:[UINib nibWithNibName:@"FindSchedulesCell" bundle:nil] forCellReuseIdentifier:@"FindSchedulesCell"];

    
//    __weak FindSchedulesViewController *weakSelf = self;    
//    
//    // setup pull-to-refresh
//    [self.tableView addPullToRefreshWithActionHandler:^{
//        [weakSelf loadNewTimes];
//    } position:SVPullToRefreshPositionBottom];
    
    
    
    // Initialize our table data source
    _tableData = [[NSMutableArray alloc] init];
    
    _operationArr = [[NSMutableArray alloc] init];
    
    [self loadJSONParallel];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSegFilter:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}


-(void)viewDidAppear:(BOOL)animated
{
    // Refresh?
}


-(void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    
//    [_jsonOperation cancel];
    
    _cancelAllOperations = YES;
    for (AFJSONRequestOperation *op in _operationArr)
    {
        [op cancel];
    }
    
}


#pragma mark - UITableViewDataSource
#pragma mark - UITableViewDelegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    return [_tableData count] + 2;  // Plus 2 for the Start and End cell
    //    NSLog(@"FNRVC -  # of rows :%d in section: %d", [_tData numberOfRowsInSection:section], section);
    //    return [_tData numberOfRowsInSection:section];
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    static NSString *cellName = @"FindSchedulesCell";
    
    FindSchedulesCell *thisCell = [thisTableView dequeueReusableCellWithIdentifier:cellName];
    
    if ( thisCell == nil )
    {
        thisCell = [[FindSchedulesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    
    BusScheduleData *data = [_tableData objectAtIndex:indexPath.row];
    [thisCell.lblRouteName setText: data.Route];
    [thisCell.lblArrivalTime setText: data.date];
    [thisCell.lblMinutesRemaining setText:@""];
    
    return thisCell;
    
}


#pragma mark - Asynchronous Requests
-(void) loadJSONParallel
{
    //    NSString *url = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/BusSchedules/?req1=%@&req6=%d", basicRoute.stop_id, NUMBER_OF_RESULTS ];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: url]];
    
    [SVProgressHUD showWithStatus:@"Loading schedule..."];
    
    
    // One request per route
    
    NSMutableArray *routes = basicRoute.routeData;
    [_tableData removeAllObjects];
    for (RouteDetailsObject *rdObj in routes)
    {
        
        NSString *url = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/BusSchedules/?req1=%@&req2=%@&req6=%d", basicRoute.stop_id, rdObj.route_short_name, _numResults];
        //NSString *url = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/BusSchedules/?req1=%@&req6=%d", basicRoute.stop_id, _numResults ];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] ];
        
        NSLog(@"|%@|", url);
        
        _jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
             
                 NSLog(@"url: %@", url);
                 [SVProgressHUD dismiss];
                 NSDictionary *jsonDict = (NSDictionary *) JSON;
                 
                 [self loadIndividualScheduleData: jsonDict];
             
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                     NSError *error, id JSON) {
             
                 [SVProgressHUD dismiss];
                 NSLog(@"Request Failure Because %@",[error userInfo]);
                
            }
      ];
        
        [_jsonOperation start];
        [_operationArr addObject:_jsonOperation];
        
    }
    
    return;
    
    //    _jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    //    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
    //
    //        [SVProgressHUD dismiss];
    //        
    //        NSDictionary *jsonDict = (NSDictionary *) JSON;
    //      
    //        [self loadScheduleData: jsonDict];
    //        
    //        
    //    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
    //                NSError *error, id JSON) {
    //        
    //        [SVProgressHUD dismiss];
    //        NSLog(@"Request Failure Because %@",[error userInfo]);
    //    }];
    //    
    //    [_jsonOperation start];
}



-(void) loadJSON
{
    
    NSString *url = [NSString stringWithFormat:@"https://www3.septa.org/hackathon/BusSchedules/?req1=%@&req6=%d", basicRoute.stop_id, _numResults ];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString: url]];
    
    NSLog(@"FSVC - url: %@", url);
    [SVProgressHUD showWithStatus:@"Loading schedule..."];
    
    
    // One request per route
    [_tableData removeAllObjects];
    
    
    _jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        // Do this all in the main thread
        [SVProgressHUD dismiss];
        NSDictionary *jsonDict = (NSDictionary *) JSON;
        [self loadScheduleData: jsonDict];
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,
                NSError *error, id JSON) {
        
        [SVProgressHUD dismiss];
        NSLog(@"FSVC - Request Failure Because %@",[error userInfo]);
        NSLog(@"FSVC - err : %@", error);
        NSLog(@"FSVC - url : %@", request);
        NSLog(@"FSVC - dict: %@", JSON);
        NSLog(@"FSVC - response statusCode: %ld", (long)response.statusCode);
    }];
    
    [_jsonOperation start];
    
}


-(void) loadIndividualScheduleData: (NSDictionary*) jsonDict
{
    
    // Setup NSDateFormatter once
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yy hh:mm a"];  // DateCalender format: 06/27/13 12:52 pm
    
    
    //    [_tableData removeAllObjects];
    for (NSString *topKey in jsonDict)
    {
        
        for (NSDictionary *subDict in [jsonDict objectForKey:topKey])
        {
            
            //            if ( [_jsonOperation isCancelled] )
            //                return;
            
            if ( _cancelAllOperations )
                return;
            
            BusScheduleData *data = [[BusScheduleData alloc] init];
            [data setValuesForKeysWithDictionary: subDict];
            [data setDateTime:[dateFormat dateFromString:data.DateCalender] ];
            
            [_tableData addObject:data];
            //            NSLog(@"%@", data);
        }
        
    }
    
    [_tableData sortUsingComparator:^NSComparisonResult(BusScheduleData *a, BusScheduleData *b)
     {
         return [[a dateTime] compare:[b dateTime] ];
     }];
    
    
    //    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    //    [self.tableView endUpdates];
    
}


-(void) loadScheduleData: (NSDictionary*) jsonDict
{
    
    // Setup NSDateFormatter once
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yy hh:mm a"];  // DateCalender format: 06/27/13 12:52 pm
    
    
//    [_tableData removeAllObjects];
    for (NSString *topKey in jsonDict)
    {
        
        for (NSString *subKey in [jsonDict objectForKey:topKey])
        {
            
//            if ( [_jsonOperation isCancelled] )
//                return;

            if ( _cancelAllOperations )
                return;
            
            BusScheduleData *data = [[BusScheduleData alloc] init];
            [data setValuesForKeysWithDictionary: [ [jsonDict objectForKey:topKey] objectForKey: subKey] ];
            [data setDateTime:[dateFormat dateFromString:data.DateCalender] ];            
            
            [_tableData addObject:data];
//            NSLog(@"%@", data);
        }
        
    }
    
    [_tableData sortUsingComparator:^NSComparisonResult(BusScheduleData *a, BusScheduleData *b)
     {
         return [[a dateTime] compare:[b dateTime] ];
     }];
    
    
//    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView endUpdates];
    
}


#pragma mark - SVPullToRefresh
-(void) loadNewTimes
{
    
}

@end
