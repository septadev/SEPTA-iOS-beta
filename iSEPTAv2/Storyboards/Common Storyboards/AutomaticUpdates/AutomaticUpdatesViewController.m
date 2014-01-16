//
//  AutomaticUpdatesViewController.m
//  iSEPTA
//
//  Created by septa on 1/15/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "AutomaticUpdatesViewController.h"

@interface AutomaticUpdatesViewController ()

@end

@implementation AutomaticUpdatesViewController
{
    
    GetDBVersionAPI *_dbVersionAPI;
    NSString *_localMD5;
    BOOL _autoUpdate;
    
    AutomaticUpdateState _updateSM;
    
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    // "Settings:Update
    
    [super viewDidLoad];
    
//    _updateSM = kAutomaticUpdateStartState;
    [self updateStateTo: kAutomaticUpdateStartState];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.tableView setBackgroundColor: backgroundColor];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    
    CustomFlatBarButton *backBarButtonItem = [[CustomFlatBarButton alloc] initWithImageNamed:@"update-white.png" withTarget:self andWithAction:@selector(backButtonPressed:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    CustomFlatBarButton *btnUpdate = [[CustomFlatBarButton alloc] initWithTitle:@"Update" style: UIBarButtonItemStylePlain target:self action:@selector(update:)];
    [self.navigationItem setRightBarButtonItem: btnUpdate];
    [btnUpdate setEnabled:NO];
    
//    UIBarButtonItem *btnUpdate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(update:)];
//    [self.navigationItem setRightBarButtonItem:btnUpdate];
    
    //    float navW = [(UIView*)[self.navigationItem.leftBarButtonItem  valueForKey:@"view"] frame].size.width;
    //    float w    = self.view.frame.size.width;
//    LineHeaderView *titleView = [[LineHeaderView alloc] initWithFrame:CGRectMake(0, 0,500, 32) withTitle:@"Update"];
//    [self.navigationItem setTitleView:titleView];
    
    [self checkAppVersion];
    
    
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:Update:AutoUpdate"];
    if ( object == nil )
    {
        _autoUpdate = NO;  // If nil, no data is in @"Settings:24HourTime" so default to NO
    }
    else
    {
        _autoUpdate = [object boolValue];
    }
    
    [self.swtAutoUpdate setOn: _autoUpdate];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    BOOL onOff = self.swtAutoUpdate.isOn;
    
    if (_autoUpdate != onOff )
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:onOff] forKey:@"Settings:Update:AutoUpdate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}


//-(BOOL) getLocalMD5
//{
//    
////    NSString *localMD5;
//    
//    NSString *md5Path = [[NSBundle mainBundle] pathForResource:@"SEPTA" ofType:@"md5"];
//    if ( md5Path == nil )
//        return NO;
//    
//    NSString *md5JSON = [[NSString alloc] initWithContentsOfFile:md5Path encoding:NSUTF8StringEncoding error:NULL];
//    if ( md5JSON == nil )
//        return NO;
//    
//    NSError *error = nil;
//    NSDictionary *md5dict = [NSJSONSerialization JSONObjectWithData: [md5JSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
//    
//    if ( error != nil )
//        return NO;
//    
//    NSArray *md5Arr = [md5dict valueForKeyPath:@"md5"];
//    
//    _localMD5 = [md5Arr firstObject];
//    
//    NSLog(@"localMD5: %@", _localMD5);
//    
//    return YES;
//}


-(void) updateStateTo:(AutomaticUpdateState) newState
{
    
    NSLog(@"Current State: %d", _updateSM);
    NSLog(@"New State    : %d", newState);
    
    _updateSM = newState;
    
    switch (newState)
    {
//        case kAutomaticUpdateStartState:
//            [self.lblVersionStatus setText:@""];
//            break;
            
        case kAutomaticUpdateChecking:
            [self.lblVersionStatus setText: VERSION_CHECKING];
            [self.progressBar setProgress:0.0f];
            
//        {
//            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:5] ];
//            [cell setHidden:YES];
//            NSLog(@"");
//        }
            
            [self.btnMulti setHidden:YES];
            
            break;
            
        case kAutomaticUpdateUpToDate:
            [self.lblVersionStatus setText: VERSION_NOUPDATE];
            break;
            
        case kAutomaticUpdateLatestAvailable:
            [self.lblVersionStatus setText: VERSION_AVAILABLE];
            [self.btnMulti setHidden:NO];
            [self.btnMulti setTitle:@"Download" forState:UIControlStateNormal];
            break;
            
        case kAutomaticUpdateDownloading:
            [self.lblVersionStatus setText: @"Downloading..."];
            [self.btnMulti setTitle:@"Cancel" forState:UIControlStateNormal];
            break;
            
        case kAutomaticUpdateCancelledDownload:
            [self.lblVersionStatus setText: @"Cancelled Download..."];
            [self.btnMulti setTitle:@"Download" forState:UIControlStateNormal];
            break;
            
        case kAutomaticUpdateFinishedDownload:
            [self.lblVersionStatus setText: @"Finished Download"];
            [self.btnMulti setTitle:@"Install" forState:UIControlStateNormal];
            break;
            
        case kAutomaticUpdateInstalling:
            [self.lblVersionStatus setText: @"Installing"];
            break;
            
        case kAutomaticUpdateFinishedInstall:
            [self.lblVersionStatus setText: @"Finished Installing"];
            [self.btnMulti setHidden:YES];
            [self updateStateTo: kAutomaticUpdateDoNothing];
            break;
            
        case kAutomaticUpdateDoNothing:
            break;
            
        default:
            break;
    }
    
}



-(void) checkAppVersion
{
    
//    _updateSM = kAutomaticUpdateChecking;
    [self updateStateTo: kAutomaticUpdateChecking];
    
    if ( _dbVersionAPI == nil )
    {
        _dbVersionAPI = [[GetDBVersionAPI alloc] init];
        [_dbVersionAPI setDelegate:self];
    }
    
    [_dbVersionAPI fetchData];
    
}

-(void) dbVersionFetched:(DBVersionDataObject*) obj
{

    
    if ( [_dbVersionAPI loadLocalMD5] )
    {
        _localMD5 = [_dbVersionAPI localMD5];
    }
    
    NSLog(@"locMD5: %@", _localMD5);
    NSLog(@"apiMD5: %@", obj.md5);
    if ( [_localMD5 isEqualToString: [obj md5] ] )
    {
        NSLog(@"OMG!!!  The MD5 MATCH!");
//        _updateSM = kAutomaticUpdateUpToDate;
        [self updateStateTo:kAutomaticUpdateUpToDate];
    }
    else
    {
        NSLog(@"The MD5s didn't match, I figured as much");
//        _updateSM = kAutomaticUpdateLatestAvailable;
        [self updateStateTo: kAutomaticUpdateLatestAvailable];
    }

    
    //    [self downloadTest];
}


-(void) update: (id) sender
{
    
}

#pragma mark - CustomBackBarButton
-(void) backButtonPressed:(id) sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Keeps the even number sections clear, makes the odd numbered ones slightly transparent
    if ( (indexPath.section % 2 ) == 1 )
        cell.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
    else
        cell.backgroundColor = [UIColor clearColor];
    
}



//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    static NSString *CellIdentifier = @"Cell";
////    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
//    
//    cell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:.75];
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


#pragma mark - Multi Button Pressed
- (IBAction)btnMultiPressed:(id)sender
{
    
    switch (_updateSM)
    {
        case kAutomaticUpdateLatestAvailable:
            // Start downloading
            [self updateStateTo: kAutomaticUpdateDownloading];
            break;
        
        case kAutomaticUpdateDownloading:
            // Cancel button has been pressed
            
            [self updateStateTo:kAutomaticUpdateCancelledDownload];
            
            break;
            
            
        default:
            break;
    }
    
}


@end
