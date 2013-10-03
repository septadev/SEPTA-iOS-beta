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

//-(void) setProgressBar:(CGFloat) percent
//{
//    CGRect progressFrame = self.imgProgressBar.frame;
//    if ( percent < 0.01 )
//    {
////        [self.imgProgressBar setBackgroundColor: [UIColor clearColor] ];
////        [self.imgProgressBar setHidden:YES];
//    }
//    else
//    {
//        [self.imgProgressBar setBackgroundColor: [UIColor blueColor] ];
//        [self.imgProgressBar setHidden:NO];
//    }
//    
//    progressFrame.size.width = self.frame.size.width * percent;
////    NSLog(@"progressBar: %6.3f, width: %6.3f", percent, progressFrame.size.width);
//
//    [self.imgProgressBar setFrame: progressFrame];
//    
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
