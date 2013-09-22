//
//  SystemStatusCell.h
//  iSEPTA
//
//  Created by apessos on 12/26/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SystemStatusObject.h"


@interface SystemStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgAdvisory;
@property (weak, nonatomic) IBOutlet UIImageView *imgSuspended;
@property (weak, nonatomic) IBOutlet UIImageView *imgDetour;
@property (weak, nonatomic) IBOutlet UIImageView *imgAlert;

@property (weak, nonatomic) IBOutlet UILabel *lblRouteName;

@property (weak, nonatomic) IBOutlet UIImageView *imgRouteIcon;


-(void) addSystemStatusObject:(SystemStatusObject*) ssObject;

@end

