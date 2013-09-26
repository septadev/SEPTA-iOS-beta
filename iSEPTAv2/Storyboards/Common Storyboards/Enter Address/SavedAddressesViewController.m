//
//  SavedAddressesViewController.m
//  iSEPTA
//
//  Created by septa on 9/20/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "SavedAddressesViewController.h"

@interface SavedAddressesViewController ()

@end

@implementation SavedAddressesViewController
{
    
    NSMutableArray *_tableData;
    
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
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
    
    
    _tableData = [[NSMutableArray alloc] init];
    NSMutableArray *addresses = [[[NSUserDefaults standardUserDefaults] objectForKey:@"EnterAddress:Saved"] mutableCopy];

    if ( addresses != nil )
    {

        for (NSData *data in addresses)
        {
            CLPlacemark *pMark = (CLPlacemark*)[NSKeyedUnarchiver unarchiveObjectWithData: data];
            [_tableData addObject: pMark];
        }
        
    }
    
    
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
    static NSString *CellIdentifier = @"SavedCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    CLPlacemark *pMark = [_tableData objectAtIndex: indexPath.row];
    NSString *address = [NSString stringWithFormat:@"%@ %@, %@", [pMark.addressDictionary objectForKey: @"Street"], [pMark.addressDictionary objectForKey: @"City"], [pMark.addressDictionary objectForKey: @"State"] ];
    [[cell textLabel] setText: address ];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.delegate respondsToSelector:@selector(addressSelected:)] )
    {
        
        CLPlacemark *placemark = [_tableData objectAtIndex: indexPath.row];  // Get the selected placemark
        [self.delegate addressSelected:placemark];                           // Send placemark back to delegate

        [self.navigationController popViewControllerAnimated:YES];           // We're finished here, pop it!

    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_tableData removeObjectAtIndex: indexPath.row];

        [self updateUserDefaults];
        
        [tableView endUpdates];
    }
    
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }
    
}


-(void) updateUserDefaults
{
    
    NSMutableArray *addresses = [[NSMutableArray alloc] init];
    for (CLPlacemark *placemark in _tableData)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject: placemark];
        [addresses addObject: data];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:addresses forKey:@"EnterAddress:Saved"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}


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

@end
