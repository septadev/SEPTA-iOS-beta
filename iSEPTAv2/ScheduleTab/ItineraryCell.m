//
//  StopTimesCell.m
//  iSEPTA
//
//  Created by apessos on 12/11/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "ItineraryCell.h"

@implementation ItineraryCell

@synthesize row;
@synthesize delegate;

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


- (IBAction)getStopNamesButtonTapped:(id)sender
{
    
    if ( (sender == self.btnStart) || (sender == self.btnStartStopName) )
    {
//        NSLog(@"IC - start button tapped");
        if ( [self.delegate respondsToSelector:@selector(getStopNamesButtonTapped:)] )
            [[self delegate] getStopNamesButtonTapped:1];
        
    }
    else if ( (sender == self.btnEnd) || (sender == self.btnEndStopName) )
    {
//        NSLog(@"IC - end button tapped");
        if ( [self.delegate respondsToSelector:@selector(getStopNamesButtonTapped:)] )
            [[self delegate] getStopNamesButtonTapped:0];
        
    }
    
    
}

// Switch directions isn't needed anymore
//- (IBAction)switchDirectionsButtonTapped:(id)sender
//{
//    
//    // Switch direction from 1 to 0 or 0 to 1.
//    
//    // Reload table with data with new direction
////    NSLog(@"IC - Switch Directions");
//    
//    if ( [self.delegate respondsToSelector:@selector(switchDirectionButtonTapped)] )
//        [[self delegate] switchDirectionButtonTapped];
//
//    
//}


- (IBAction)flipStopNamesButtonTapped:(id)sender
{
    NSLog(@"IC - flip button tapped");
//    if ( [self.delegate respondsToSelector:@selector(flipStopNamesButtonPressed)] )
//        [[self delegate] flipStopNamesButtonPressed];
    
    if ( [self.delegate respondsToSelector:@selector(flipStopNamesButtonTapped)])
        [[self delegate] flipStopNamesButtonTapped];
    
}


//-(void) flipDataInCell: (RouteCell*) firstCell withCell: (StopTimesCell*) secondCell
//{
//    NSString *tmpStr = [[firstCell lblStopName] text];
//    [[firstCell lblStopName] setText: [[secondCell lblStopName] text] ];
//    [[secondCell lblStopName] setText:tmpStr];
//}
//
//-(void) flipDataWithCell:(StopTimesCell *)secondCell
//{
//    NSString *tmpStr = [[self lblStopName] text];
//    [[self lblStopName] setText: [[secondCell lblStopName] text] ];
//    [[secondCell lblStopName] setText:tmpStr];
//    
//}


@end
