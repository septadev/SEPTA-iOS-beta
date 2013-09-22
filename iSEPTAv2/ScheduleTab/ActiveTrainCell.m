//
//  ActiveTrainCell.m
//  iSEPTA
//
//  Created by septa on 3/14/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "ActiveTrainCell.h"

@implementation ActiveTrainCell

@synthesize lblTrainNo;
@synthesize lblDestination;

@synthesize lblNextStop;
@synthesize lblTrainDelay;

@synthesize imgAlarm;
@synthesize imgMyTrain;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
