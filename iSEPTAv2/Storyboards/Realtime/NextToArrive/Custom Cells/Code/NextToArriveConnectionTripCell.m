//
//  NextToArriveConnectionTripCell.m
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NextToArriveConnectionTripCell.h"

@implementation NextToArriveConnectionTripCell

@synthesize lblStartLine;
@synthesize lblStartArrivesTime;
@synthesize lblStartArrivesUnit;

@synthesize lblStartDepartsTime;
@synthesize lblStartDepartsUnit;
@synthesize lblStartStatus;

@synthesize lblStartTrainNo;

@synthesize lblConnection;
@synthesize lblConnectionTitle;

@synthesize lblEndArrivesTime;
@synthesize lblEndArrivesUnit;
@synthesize lblEndDepartsTime;

@synthesize lblEndDepartsUnit;
@synthesize lblEndLine;
@synthesize lblEndStatus;

@synthesize lblEndTrainNo;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


// initWithCoder is called from the Storyboard
//-(id) initWithCoder:(NSCoder *)aDecoder
//{
//    
//    self = [super initWithCoder:aDecoder];
//    
//    if ( self )
//    {
//        [self.contentView.superview setBackgroundColor: [UIColor colorWithRed:216.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1] ];
//    }
//    
//    return self;
//    
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) updateCellUsingJsonData: (NextToArrivaJSONObject*) data
{
    
//    NSArray *timeArray;
//    int hour;
//    int minute;
//    NSString *unit;
    
    
    // Update the start line and train number
    [[self lblStartLine] setText: [data orig_line] ];
    [[self lblStartTrainNo] setText: [data orig_train] ];
    
    
    [[self lblStartDepartsTime] setText: [data orig_departure_time] ];
    [[self lblStartArrivesTime] setText: [data orig_arrival_time ] ];
    

    // Change delay text depending on the current train delay
    // Is it On-time, 1 min (late) or 2 or more mins (late)
    int late = [[data orig_delay] intValue];
    if ( late == 0 )
        [[self lblStartStatus] setText: @"On time"];
    else if ( late == 1 )
        [[self lblStartStatus] setText: [NSString stringWithFormat:@"%d min", late]];
    else
        [[self lblStartStatus] setText: [NSString stringWithFormat:@"%d mins", late]];
    
    
    // The above condition took care of the wording, now let's color coordinate
    if ( late == 0 )
        [[self lblStartStatus] setTextColor: [UIColor colorWithRed:12.0f/255.0f green:174.0f/255.0f blue:64.0/255.0f alpha:1.0f] ];
    else if ( ( late > 0 ) && ( late <= 4) )
        [[self lblStartStatus] setTextColor: [UIColor redColor] ];
    else if ( late > 4)
        [[self lblStartStatus] setTextColor: [UIColor redColor] ];
    
    
    // --==  Start Arrival Time  ==--
    //timeArray = [[object orig_arrival_time] componentsSeparatedByString:@":"];
    
//    hour = [[timeArray objectAtIndex:0] intValue];
//    minute = [[timeArray objectAtIndex:1] intValue];
//    
//    
//    //    NSLog(@"Start Arrives Time %02d:%02d vs %@", hour, minute, [object orig_arrival_time]);
//    [[self lblStartArrivesTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
//    if ( [[object orig_arrival_time] rangeOfString:@"PM"].location == NSNotFound)
//    {
//        unit = @"AM";
//    }
//    else
//    {
//        unit = @"PM";
//    }
//    [[self lblStartDepartsUnit] setText: unit];
    
    // --== Start Depart Time  ==--
    //    [[self lblStartDepartsTime] setText: [object orig_departure_time] ];
    //    timeArray = [NSArray arrayWithArray: [[object orig_departure_time] componentsSeparatedByString:@":"] ];
    //    hour = [[timeArray objectAtIndex:0] intValue];
    //
    //    [[self lblStartDepartsUnit] setText: [self amOrPm:hour] ];  // Need to align this as well as check if AM or PM
    // --==  Start Arrival Time  ==--
//    timeArray = [[object orig_departure_time] componentsSeparatedByString:@":"];
//    hour =   [[timeArray objectAtIndex:0] intValue];
//    minute = [[timeArray objectAtIndex:1] intValue];
    
    
    //    NSLog(@"Start Departs Time %02d:%02d vs %@", hour, minute, [object orig_departure_time]);
//    [[self lblStartDepartsTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
//    if ( [[object orig_departure_time] rangeOfString:@"PM"].location == NSNotFound)
//    {
//        unit = @"AM";
//    }
//    else
//    {
//        unit = @"PM";
//    }
    
//    [[self lblStartDepartsUnit] setText: unit];
    
    
    [[self lblEndLine]    setText: [data term_line] ];
    [[self lblEndTrainNo] setText: [data term_train] ];
    
    [[self lblEndStatus]  setText: [data term_delay] ];  // Change color depending on delay
    
    
    [[self lblEndDepartsTime] setText: [data term_depart_time  ] ];
    [[self lblEndArrivesTime] setText: [data term_arrival_time ] ];

    
    
    late = [[data orig_delay] intValue];
    if ( late == 0 )
        [[self lblEndStatus] setText: @"On time"];
    else if ( late == 1 )
        [[self lblEndStatus] setText: [NSString stringWithFormat:@"%d min", late]];
    else
        [[self lblEndStatus] setText: [NSString stringWithFormat:@"%d mins", late]];
    
    
    if ( late == 0 )
        [[self lblEndStatus] setTextColor: [UIColor colorWithRed:12.0f/255.0f green:174.0f/255.0f blue:64.0/255.0f alpha:1.0f] ];
    else if ( ( late > 0 ) && ( late <= 4) )
        [[self lblEndStatus] setTextColor: [UIColor redColor] ];
    else if ( late > 4)
        [[self lblEndStatus] setTextColor: [UIColor redColor] ];
    
    
    // --== End Arrives Time
    //    [[self lblEndArrivesTime] setText: [object term_arrival_time] ];
    //    timeArray = [NSArray arrayWithArray: [[object term_arrival_time] componentsSeparatedByString:@":"] ];
    //    hour = [[timeArray objectAtIndex:0] intValue];
    //
    //    [[self lblEndArrivesUnit] setText: [self amOrPm:hour] ];
    
    // --==  End Arrival Time  ==--
//    timeArray = [[object term_arrival_time] componentsSeparatedByString:@":"];
//    hour =   [[timeArray objectAtIndex:0] intValue];
//    minute = [[timeArray objectAtIndex:1] intValue];
//    
//    
//    //    NSLog(@"End Arrives Time %02d:%02d vs %@", hour, minute, [object term_arrival_time]);
//    [[self lblEndArrivesTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
//    if ( [[object term_arrival_time] rangeOfString:@"PM"].location == NSNotFound)
//        unit = @"AM";
//    else
//        unit = @"PM";
//    [[self lblEndArrivesUnit] setText: unit];
//    
//    //    [[self lblEndDepartsTime] setText: [object term_depart_time] ];
//    //    timeArray = [NSArray arrayWithArray: [[object term_depart_time] componentsSeparatedByString:@":"] ];
//    //    hour = [[timeArray objectAtIndex:0] intValue];
//    //
//    //    [[self lblEndDepartsUnit] setText: [self amOrPm:hour] ];  // Need to align this as well as check if AM or PM
//    
//    // --==  End Departs Time  ==--
//    timeArray = [[object term_depart_time] componentsSeparatedByString:@":"];
//    hour =   [[timeArray objectAtIndex:0] intValue];
//    minute = [[timeArray objectAtIndex:1] intValue];
//    
//    
//    //    NSLog(@"End Departs Time %02d:%02d vs %@", hour, minute, [object term_depart_time]);
//    [[self lblEndDepartsTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
//    if ( [[object term_depart_time] rangeOfString:@"PM"].location == NSNotFound)
//        unit = @"AM";
//    else
//        unit = @"PM";
//    [[self lblEndDepartsUnit] setText: unit];
    
    
    [[self lblConnection] setText: [data Connection] ];
    
}


@end
