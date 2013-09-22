//
//  NTAConnectionCell.m
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "NTAConnectionCell.h"

@implementation NTAConnectionCell

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) addObjectToCell:(NextToArrivaJSONObject*) object
{
    
    NSArray *timeArray;
    int hour;
    int minute;
    NSString *unit;
    
    
    [[self lblStartLine] setText: [object orig_line] ];
    [[self lblStartTrainNo] setText: [object orig_train] ];
    
    //    [[self lblStartStatus] setText: [object orig_delay] ];  // Change color depending on delay
    
    
    int late = [[object orig_delay] intValue];
    if ( late == 0 )
        [[self lblStartStatus] setText: @"On-time"];
    else if ( late == 1 )
        [[self lblStartStatus] setText: [NSString stringWithFormat:@"%d min", late]];
    else
        [[self lblStartStatus] setText: [NSString stringWithFormat:@"%d mins", late]];
    
    if ( late == 0 )
        [[self lblStartStatus] setTextColor: [UIColor blackColor] ];
    else if ( ( late > 0 ) && ( late <= 4) )
        [[self lblStartStatus] setTextColor: [UIColor orangeColor] ];
    else if ( late > 4)
        [[self lblStartStatus] setTextColor: [UIColor redColor] ];

    // --==  Start Arrival Time  ==--
    timeArray = [[object orig_arrival_time] componentsSeparatedByString:@":"];
    
    hour = [[timeArray objectAtIndex:0] intValue];
    minute = [[timeArray objectAtIndex:1] intValue];
    
    
//    NSLog(@"Start Arrives Time %02d:%02d vs %@", hour, minute, [object orig_arrival_time]);
    [[self lblStartArrivesTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
    if ( [[object orig_arrival_time] rangeOfString:@"PM"].location == NSNotFound)
    {
        unit = @"AM";
    }
    else
    {
        unit = @"PM";
    }
    [[self lblStartDepartsUnit] setText: unit];
    
    // --== Start Depart Time  ==--
    //    [[self lblStartDepartsTime] setText: [object orig_departure_time] ];
    //    timeArray = [NSArray arrayWithArray: [[object orig_departure_time] componentsSeparatedByString:@":"] ];
    //    hour = [[timeArray objectAtIndex:0] intValue];
    //
    //    [[self lblStartDepartsUnit] setText: [self amOrPm:hour] ];  // Need to align this as well as check if AM or PM
    // --==  Start Arrival Time  ==--
    timeArray = [[object orig_departure_time] componentsSeparatedByString:@":"];
    hour =   [[timeArray objectAtIndex:0] intValue];
    minute = [[timeArray objectAtIndex:1] intValue];
    
    
//    NSLog(@"Start Departs Time %02d:%02d vs %@", hour, minute, [object orig_departure_time]);
    [[self lblStartDepartsTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
    if ( [[object orig_departure_time] rangeOfString:@"PM"].location == NSNotFound)
    {
        unit = @"AM";
    }
    else
    {
        unit = @"PM";
    }
    [[self lblStartDepartsUnit] setText: unit];
    
    [[self lblEndLine]    setText: [object term_line] ];
    [[self lblEndTrainNo] setText: [object term_train] ];
    
    [[self lblEndStatus]  setText: [object term_delay] ];  // Change color depending on delay
    
    late = [[object orig_delay] intValue];
    if ( late == 0 )
        [[self lblEndStatus] setText: @"On-time"];
    else if ( late == 1 )
        [[self lblEndStatus] setText: [NSString stringWithFormat:@"%d min", late]];
    else
        [[self lblEndStatus] setText: [NSString stringWithFormat:@"%d mins", late]];
    
    if ( late == 0 )
        [[self lblEndStatus] setTextColor: [UIColor blackColor] ];
    else if ( ( late > 0 ) && ( late <= 4) )
        [[self lblEndStatus] setTextColor: [UIColor orangeColor] ];
    else if ( late > 4)
        [[self lblEndStatus] setTextColor: [UIColor redColor] ];

        // --== End Arrives Time
        //    [[self lblEndArrivesTime] setText: [object term_arrival_time] ];
        //    timeArray = [NSArray arrayWithArray: [[object term_arrival_time] componentsSeparatedByString:@":"] ];
        //    hour = [[timeArray objectAtIndex:0] intValue];
        //
        //    [[self lblEndArrivesUnit] setText: [self amOrPm:hour] ];
        
        // --==  End Arrival Time  ==--
    timeArray = [[object term_arrival_time] componentsSeparatedByString:@":"];
    hour =   [[timeArray objectAtIndex:0] intValue];
    minute = [[timeArray objectAtIndex:1] intValue];
        
    
//    NSLog(@"End Arrives Time %02d:%02d vs %@", hour, minute, [object term_arrival_time]);
    [[self lblEndArrivesTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
    if ( [[object term_arrival_time] rangeOfString:@"PM"].location == NSNotFound)
        unit = @"AM";
    else
        unit = @"PM";
    [[self lblEndArrivesUnit] setText: unit];
    
    //    [[self lblEndDepartsTime] setText: [object term_depart_time] ];
    //    timeArray = [NSArray arrayWithArray: [[object term_depart_time] componentsSeparatedByString:@":"] ];
    //    hour = [[timeArray objectAtIndex:0] intValue];
    //
    //    [[self lblEndDepartsUnit] setText: [self amOrPm:hour] ];  // Need to align this as well as check if AM or PM
    
    // --==  End Departs Time  ==--
    timeArray = [[object term_depart_time] componentsSeparatedByString:@":"];
    hour =   [[timeArray objectAtIndex:0] intValue];
    minute = [[timeArray objectAtIndex:1] intValue];
    
    
//    NSLog(@"End Departs Time %02d:%02d vs %@", hour, minute, [object term_depart_time]);
    [[self lblEndDepartsTime] setText: [NSString stringWithFormat:@"%02d:%02d", hour, minute] ];
    if ( [[object term_depart_time] rangeOfString:@"PM"].location == NSNotFound)
        unit = @"AM";
    else
        unit = @"PM";
    [[self lblEndDepartsUnit] setText: unit];
    
    [[self lblConnection] setText: [object Connection] ];
    
}


@end
