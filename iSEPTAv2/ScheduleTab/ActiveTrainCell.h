//
//  ActiveTrainCell.h
//  iSEPTA
//
//  Created by septa on 3/14/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActiveTrainCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTrainNo;
@property (weak, nonatomic) IBOutlet UILabel *lblTrainDelay;

@property (weak, nonatomic) IBOutlet UILabel *lblNextStop;
@property (weak, nonatomic) IBOutlet UILabel *lblDestination;

//@property (weak, nonatomic) IBOutlet UIImageView *imgAlarm;
//@property (weak, nonatomic) IBOutlet UIImageView *imgMyTrain;

//@property (weak, nonatomic) IBOutlet UIImageView *imgDisclaimer;

@property (weak, nonatomic) IBOutlet UIButton *btnDisclaimer;


@end
