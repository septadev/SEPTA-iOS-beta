//
//  AttributionsViewController.m
//  iSEPTA
//
//  Created by septa on 9/11/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "AttributionsViewController.h"

@interface AttributionsViewController ()

@end

@implementation AttributionsViewController
{
    NSMutableArray *_tableData;
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
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"mainBackground.png"] ];
    [self.tableView setBackgroundView: bgImageView];
    

    // --==  Register All the Xibs!  ==--
    [self.tableView registerNib:[UINib nibWithNibName:@"AttributionCell" bundle:nil] forCellReuseIdentifier:@"AttributionCell"];

    
//    NSArray *attDict = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"Attribution" ofType:@"plist"] ];
    NSArray *attArr = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"Attributions" ofType:@"plist"] ];
    _tableData = [[NSMutableArray alloc] init];
    
    
    for (NSDictionary *attDict in attArr)
    {
        
        AttributionData *attData = [[AttributionData alloc] init];
        
        [attData setValuesForKeysWithDictionary: attDict];
        [_tableData addObject: attData];
        
    }
    
    
    [_tableData sortUsingComparator:^NSComparisonResult(AttributionData *a, AttributionData *b)
     {
         return [a.library compare:b.library options:NSCaseInsensitiveSearch];
     }];
    
    
    /*
     
     AFNetworking
     FMDB
     SVProgressHUD
     QuickDialog
     CHInput
     REMenu
     Reachability
     
     */
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"AttributionCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    AttributionCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
    [cell setObject: [_tableData objectAtIndex: indexPath.row] ];
    
    // Configure the cell...
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */

    
//    AttributionsTextViewController *attTextVC = [[AttributionsTextViewController alloc] initWithNibName:@"AttributionTextViewController" bundle:nil];
//    
//    AttributionData *attData = [_tableData objectAtIndex: indexPath.row];
//    
//    [attTextVC setData: attData];
//
//    
//    [self.navigationController pushViewController: attTextVC animated:YES];

    
    [self performSegueWithIdentifier:@"LicenseSegue" sender:self];
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ( [[segue identifier] isEqualToString:@"LicenseSegue"] )
    {
                
        AttributionsTextViewController *atVC = [segue destinationViewController];
        int row = [[[self tableView] indexPathForSelectedRow] row];
        
        AttributionData *attData = [_tableData objectAtIndex: row];
        [atVC setData: attData];
        
    }
    
    
}

@end
