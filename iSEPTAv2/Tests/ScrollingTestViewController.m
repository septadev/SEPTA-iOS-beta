//
//  ScrollingTestViewController.m
//  iSEPTA
//
//  Created by septa on 12/11/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "ScrollingTestViewController.h"

#import "StopTimesStartCell.h"
#import "StopTimesEndCell.h"

@interface ScrollingTestViewController ()

@end

@implementation ScrollingTestViewController
{
    NSMutableArray *_data;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        // Custom initialization
        
    }
    
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSLog(@"STVC - viewDidLoad");
    
    _data = [[NSMutableArray alloc] init];
    for (int LCV=-2; LCV<=30; LCV++)
    {
        [_data addObject:[NSString stringWithFormat:@"Row %d", LCV] ];
    }
 
//    [[self tableView] reloadData];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    NSLog(@"STVC - viewWillAppear");
    [[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    
    [self setScrollView:nil];
    [self setTableView:nil];
    
    [super viewDidUnload];
    
}

#pragma mark - TableView DataSource
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  // Required method
{
    
    static NSString *StartIdentifier = @"Hate";  // StartCellIdentifier
    static NSString *EndIdentifier   = @"You";    // EndCellIdentifier
    static NSString *DefaultIdentifier = @"DefaultCell";
    
    NSLog(@"STVC - cellForRowAtIndexPath");
    
    if ( indexPath.row == 0 )
    {

        StopTimesStartCell *cell = (StopTimesStartCell*)[tableView dequeueReusableCellWithIdentifier:StartIdentifier];
        
        if ( ( cell ==  nil ) || ( ![cell isKindOfClass:[StopTimesStartCell class] ] ) )
        {
            NSLog(@"Loading StopTimesStartCell...");
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StopTimesStartCell" owner:self options:nil];
            cell = (StopTimesStartCell*)[nib objectAtIndex:0];
        }
        
        cell.lblStopName.text = @"StartStart";
        NSLog(@"cell: %p, stopname: %@, hidden: %d, label: %@", cell, cell.lblStopName.text, cell.hidden, cell.textLabel.text);
        
        return cell;
        
    }
    else if ( indexPath.row == 1 )
    {
        
        StopTimesEndCell *cell = (StopTimesEndCell*)[tableView dequeueReusableCellWithIdentifier:EndIdentifier];
        
        if ( ( cell ==  nil ) || ( ![cell isKindOfClass:[StopTimesEndCell class] ] ) )
        {
            NSLog(@"Loading StopTimesEndCell...");
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StopTimesEndCell" owner:self options:nil];
            cell = (StopTimesEndCell*)[nib objectAtIndex:0];
        }
                
        cell.lblStopName.text = @"EndEnd";
        NSLog(@"cell: %p, stopname: %@, hidden: %d, label: %@", cell, cell.lblStopName.text, cell.hidden, cell.textLabel.text);
        
        return cell;

    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DefaultIdentifier];
        
        if ( cell ==  nil )
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultIdentifier];
        }
        
        [[cell textLabel] setText: [_data objectAtIndex: indexPath.row] ];
        
        return cell;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  // Required method
{
    return [_data count];
}


// Optional Methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - TableView Delegate






@end
