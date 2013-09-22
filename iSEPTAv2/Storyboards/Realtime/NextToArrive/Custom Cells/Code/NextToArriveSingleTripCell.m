//
//  NextToArriveSingleTripCell.m
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NextToArriveSingleTripCell.h"

@implementation NextToArriveSingleTripCell

@synthesize orig_arrival_time;
@synthesize orig_delay;
@synthesize orig_departure_time;
@synthesize orig_line;

@synthesize orig_train;

@synthesize jsonData;


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
//        
////        UIView *myView = [[UIView alloc] initWithFrame: self.frame];
////        [myView setBackgroundColor: [UIColor colorWithRed:216.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1] ];
////        [self setBackgroundView: myView];
//        
////        [self setBackgroundColor: [UIColor colorWithRed:216.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1] ];  // Background is transparent
//        
////        [self.contentView setBackgroundColor: [UIColor colorWithRed:216.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1] ];    // This only changes the contentView, not the accessoryView
////        [self.accessoryView setBackgroundColor: [UIColor colorWithRed:255.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:0.5] ];  // This does nothing
//        
////        [self setAccessoryType:UITableViewCellAccessoryCheckmark];  // This changes the accessory type but the background is still see-thru
//        
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
    
    [[self orig_train]          setText: [data orig_train] ];
    [[self orig_arrival_time]   setText: [data orig_arrival_time] ];
    [[self orig_departure_time] setText: [data orig_departure_time] ];
    [[self orig_delay]          setText: [data orig_delay] ];
    [[self orig_line]           setText: [data orig_line] ];
    
}

@end
