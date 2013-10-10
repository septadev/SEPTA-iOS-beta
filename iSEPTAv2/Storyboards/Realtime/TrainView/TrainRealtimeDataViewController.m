//
//  TrainRealtimeDataViewController.m
//  iSEPTA
//
//  Created by septa on 9/23/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TrainRealtimeDataViewController.h"

@interface TrainRealtimeDataViewController ()
@property (nonatomic, assign) CGFloat peekLeftAmount;
@end

@implementation TrainRealtimeDataViewController
{
    NSMutableArray *_tableData;
}

@synthesize peekLeftAmount;


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
    
    self.peekLeftAmount = 40.0f;
    [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
    self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;
    
    // --==  Register Your Nibs!
    [self.tableView registerNib: [UINib nibWithNibName:@"RealtimeVehicleInformationCell" bundle:nil] forCellReuseIdentifier: @"RealtimeVehicleInformationCell"];

    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"mainBackground.png"] ];
    [self.tableView setBackgroundView: bgImageView];
    
    NSLog(@"TRDVC:vDL - Done!");
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    _tableData = nil;
    
    // Dispose of any resources that can be recreated.
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    NSLog(@"tableView frame: %@", NSStringFromCGRect(self.tableView.frame) );
//    NSLog(@" view     frame: %@", NSStringFromCGRect(self.view.frame) );
//    NSLog(@"tabBar   height: %@", NSStringFromCGRect( self.tabBarController.view.frame) );
    
    [self.tableView setFrame: CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 44)];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    NSLog(@"TRDVC - viewDidDisappear");
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_tableData count];
}


-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [cell setBackgroundColor: [UIColor colorWithWhite:1.0f alpha:.8] ];
    
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient_line.png"]];
    //    [separator setAutoresizesSubviews:YES];
    //    [separator setAutoresizingMask: (UIViewAutoresizingFlexibleWidth) ];
    //    [separator setContentMode: UIViewContentModeScaleAspectFit];
    
    UITableViewCell *newCell = (UITableViewCell*)cell;
    
    [separator setFrame: CGRectOffset(separator.frame, 0, newCell.frame.size.height-separator.frame.size.height)];
    [newCell.contentView addSubview: separator];
    
}


- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *vehicleCell = @"RealtimeVehicleInformationCell";
    
    
    RealtimeVehicleInformationCell *cell;
    
    cell = (RealtimeVehicleInformationCell*)[thisTableView dequeueReusableCellWithIdentifier: vehicleCell];
    [cell setBackgroundColor: [UIColor redColor] ];
    
    id object = [_tableData objectAtIndex: indexPath.row];
    if ( [object isKindOfClass:[TransitViewObject class] ] )
    {
        
    }
    else
    {
        
    }
    

    {
        TrainViewObject *tvObject = [_tableData objectAtIndex:indexPath.row];
        [cell addObjectToCell: tvObject];
        
        
        //        if ( indexPath.row == 0 )
        //        {
        //            NSLog(@"f.str label : %@", NSStringFromCGRect(cell.lblStartName.frame));
        //            NSLog(@"f.end label : %@", NSStringFromCGRect(cell.lblEndName.frame));
        //            NSLog(@"b.end label : %@", NSStringFromCGRect(cell.lblEndName.bounds));
        
        
//        if ( UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) )
//        {
//            [cell.lblEndName setFrame:CGRectMake(129, 22, 180, 21)];
//            [cell.lblStartName setFrame:CGRectMake(129, 4, 180, 21)];
//        }
//        else
//        {
//            float aspectRatio = [UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height;
//            [cell.lblEndName   setFrame:CGRectMake(129, 22, 180 * aspectRatio, 21)];
//            [cell.lblStartName setFrame:CGRectMake(129,  4, 180 * aspectRatio, 21)];
//        }
        
        
        //        }
        
        
        //        NSLog(@"cell frame: %@", NSStringFromCGRect(self.imgTableViewBG.frame));
        //        NSLog(@"cell bound: %@", NSStringFromCGRect(self.imgTableViewBG.bounds));
        //        [cell setFrame: self.imgTableViewBG.frame];
        //
        //        NSLog(@"f.end label : %@", NSStringFromCGRect(cell.lblEndName.frame));
        //        NSLog(@"b.end label : %@", NSStringFromCGRect(cell.lblEndName.bounds));
        //        [cell.lblEndName setBounds: CGRectMake(0, 0, 100, 21)];
        
        
        //        NSLog(@"%d/%d: %@", indexPath.section, indexPath.row, tvObject);
    }
    
    //    NSLog(@"%d/%d - cell: %@", indexPath.section, indexPath.row, cell);
    return cell;
    
}


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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


-(void) updateTableData: (NSMutableArray*) tableData
{

    NSLog(@"TRDVC:uTD - Got new data");
    _tableData = tableData;
    
    [self.tableView reloadData];
    
    
}


@end
