//
//  TransitViewTableController.h
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransitViewTableController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *lblRouteName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleServiceHours;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceHours;

@end
