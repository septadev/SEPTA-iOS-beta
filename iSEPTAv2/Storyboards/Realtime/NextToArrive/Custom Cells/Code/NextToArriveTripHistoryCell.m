//
//  NextToArriveTripHistoryCell.m
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NextToArriveTripHistoryCell.h"

@implementation NextToArriveTripHistoryCell

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
//        [self.contentView setBackgroundColor: [UIColor colorWithRed:216.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1] ];
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

@end
