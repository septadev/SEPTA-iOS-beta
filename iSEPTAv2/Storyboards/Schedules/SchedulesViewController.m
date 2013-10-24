//
//  SchedulesViewController.m
//  iSEPTA
//
//  Created by septa on 8/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "SchedulesViewController.h"

@interface SchedulesViewController ()

@end

@implementation SchedulesViewController

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
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    UIImage *logo = [UIImage imageNamed:@"SEPTA_logo.png"];
    
    SEPTATitle *newView = [[SEPTATitle alloc] initWithFrame:CGRectMake(0, 0, logo.size.width, logo.size.height) andWithTitle:@"Schedules"];
    [newView setImage: logo];
    [self.navigationItem setTitleView: newView];
//    [self.navigationItem.titleView setNeedsDisplay];


    
//    UIImageView *bgImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"mainBackground.png"] ];
//    [self.tableView setBackgroundView: bgImageView];

    UIColor *backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"newBG_pattern.png"] ];
    [self.tableView setBackgroundColor: backgroundColor];
    
    
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 7;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

//    NSLog(@"s/r : %d/%d", indexPath.section, indexPath.row);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"RouteSelectionStoryboard" bundle:nil];
    RouteSelectionViewController *rsVC = (RouteSelectionViewController*)[storyboard instantiateInitialViewController];
    
    switch (indexPath.row) {
        case 0:
            [rsVC setTravelMode:@"Rail"];
            break;
            
        case 1:
            [rsVC setTravelMode:@"MFL"];
            break;
            
        case 2:
            [rsVC setTravelMode:@"BSL"];
            break;
        
        case 3:
            [rsVC setTravelMode:@"Trolley"];
            break;
            
        case 4:
            [rsVC setTravelMode:@"NHSL"];
            break;
            
        case 5:
            [rsVC setTravelMode:@"Bus"];
            break;
            
        default:
            break;
    }
    
    [self.navigationController pushViewController: rsVC animated: YES];
    
     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
    
}

@end
