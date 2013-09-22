//
//  FindSchedulesCell.h
//  iSEPTA
//
//  Created by septa on 6/27/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindSchedulesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblRouteName;
@property (weak, nonatomic) IBOutlet UIImageView *imgRouteIcon;

@property (weak, nonatomic) IBOutlet UILabel *lblArrivalTime;
@property (weak, nonatomic) IBOutlet UILabel *lblMinutesRemaining;

@end
