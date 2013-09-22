//
//  NTAResultsCell.m
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "NTAResultsCell.h"

@implementation NTAResultsCell

@synthesize lblEnd;
@synthesize lblEndTitle;

@synthesize lblStart;
@synthesize lblStartTitle;

@synthesize lblStatus;
@synthesize lblTrainNo;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) addObjectToCell:(NextToArrivaJSONObject*)object
{
    
    [[self lblEnd  ] setText: [object orig_arrival_time] ];
    [[self lblStart] setText: [object orig_departure_time] ];
    
    [[self lblTrainNo] setText: [object orig_train] ];
    
    int late = [[object orig_delay] intValue];
    if ( late == 0 )
        [[self lblStatus] setText: @"On-time"];
    else if ( late == 1 )
        [[self lblStatus] setText: [NSString stringWithFormat:@"%d min", late]];
    else
        [[self lblStatus] setText: [NSString stringWithFormat:@"%d mins", late]];
    
    if ( late == 0 )
        [[self lblStatus] setTextColor: [UIColor blackColor] ];
    else if ( ( late > 0 ) && ( late <= 4) )
        [[self lblStatus] setTextColor: [UIColor orangeColor] ];
    else if ( late > 4)
        [[self lblStatus] setTextColor: [UIColor redColor] ];
    
    [[self lblStatus] setText: [object orig_delay] ];
    
}

@end
