//
//  NTASingleCell.m
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "NTASingleCell.h"

@implementation NTASingleCell

@synthesize lblStatus;
@synthesize lblTrainNo;

@synthesize lblArrivesTime;
@synthesize lblArrivesUnit;

@synthesize lblDepartsTime;
@synthesize lblDepartsUnit;

@synthesize lblStartLine;


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

-(void) addObjectToCell:(NextToArrivaJSONObject *)object
{
    NSArray *timeArray;
    int hour, minute;
    NSString *unit;
    
    [[self lblStartLine] setText: [object orig_line] ];
    [[self lblTrainNo] setText: [object orig_train] ];
    
    [[self lblStatus] setText: [object orig_delay] ];  // Change color depending on delay
    
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

    // --==  Start Arrival Time  ==--
    timeArray = [NSArray arrayWithArray: [[object orig_arrival_time] componentsSeparatedByString:@":"] ];
    hour =   [[timeArray objectAtIndex:0] intValue];
    minute = [[timeArray objectAtIndex:1] intValue];
    
    [[self lblArrivesTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
    if ( [[object orig_arrival_time] rangeOfString:@"PM"].location == NSNotFound)
    {
        unit = @"AM";
    }
    else
    {
        unit = @"PM";
    }
    
    [[self lblArrivesUnit] setText: unit ];  // Need to align this as well as check if AM or PM
    
    // --== Start Depart Time  ==--
    timeArray = [NSArray arrayWithArray: [[object orig_departure_time] componentsSeparatedByString:@":"] ];
    hour =   [[timeArray objectAtIndex:0] intValue];
    minute = [[timeArray objectAtIndex:1] intValue];

    [[self lblDepartsTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
    if ( [[object orig_departure_time] rangeOfString:@"PM"].location == NSNotFound)
    {
        unit = @"AM";
    }
    else
    {
        unit = @"PM";
    }
    
    [[self lblDepartsUnit] setText: unit ];  // Need to align this as well as check if AM or PM
}


@end
