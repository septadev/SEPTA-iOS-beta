//
//  TripListCell.h
//  iSEPTA
//
//  Created by Administrator on 8/11/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TripListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgDivider;
@property (weak, nonatomic) IBOutlet UIImageView *imgCircle;

@property (weak, nonatomic) IBOutlet UILabel *lblStartName;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;


@end
