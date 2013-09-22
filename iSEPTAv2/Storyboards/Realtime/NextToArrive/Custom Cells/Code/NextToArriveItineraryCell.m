//
//  NextToArriveItineraryCell.m
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NextToArriveItineraryCell.h"

@implementation NextToArriveItineraryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        // Initialization code
        
//        UITapGestureRecognizer *labelStartTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelWasTapped:)];
//        UITapGestureRecognizer *labelEndTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelWasTapped:)];
//        
//        [self.lblStart setUserInteractionEnabled:YES];
//        [self.lblStart addGestureRecognizer: labelStartTapped];
//
//        [self.lblEnd setUserInteractionEnabled:YES];
//        [self.lblEnd addGestureRecognizer: labelEndTapped];

        
    }
    return self;
}


//-(id) initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//
//    if (self)
//    {
//        
//        NSLog(@"NtAIC - color changing bullshit!");
////        [self setOpaque:YES];
////        [self setBackgroundColor: [UIColor clearColor] ];
////        [self setBackgroundView: nil];
//        
//        [self.contentView setBackgroundColor: [UIColor colorWithRed:216.0/255.0 green:218.0/255.0 blue:217.0/255.0 alpha:1] ];
//        
////        UITapGestureRecognizer *labelStartTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelWasTapped:)];
////        UITapGestureRecognizer *labelEndTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelWasTapped:)];
////        
////        [self.lblStart setUserInteractionEnabled:YES];
////        [self.lblStart addGestureRecognizer: labelStartTapped];
////        
////        [self.lblEnd setUserInteractionEnabled:YES];
////        [self.lblEnd addGestureRecognizer: labelEndTapped];
//    }
//    
//    return self;
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Button Pressed
- (IBAction)btnStartEndPressed:(id)sender
{
//    NSLog(@"NtAIC - startEnd pressed");
    
    if ( [self.delegate respondsToSelector:@selector(itineraryButtonPressed:)])
    {
        [self.delegate itineraryButtonPressed:kNextToArriveButtonTypeStartEnd];
    }
    
}


- (IBAction)btnReversePressed:(id)sender
{
//    NSLog(@"NtAIC - reverse pressed");
    
    if ( [self.delegate respondsToSelector:@selector(itineraryButtonPressed:)])
    {
        [self.delegate itineraryButtonPressed:kNextToArriveButtonTypeReverse];
    }

}

- (IBAction)btnStartDestinationPressed:(id)sender
{
//    NSLog(@"NtAIC - start destination pressed");
    
    if ( [self.delegate respondsToSelector:@selector(itineraryButtonPressed:)])
    {
        [self.delegate itineraryButtonPressed:kNextToArriveButtonTypeStart];
    }

}


- (IBAction)btnEndDestinationPressed:(id)sender
{
//    NSLog(@"NtAIC - end destination pressed");
    
    if ( [self.delegate respondsToSelector:@selector(itineraryButtonPressed:)])
    {
        [self.delegate itineraryButtonPressed:kNextToArriveButtonTypeEnd];
    }

}



//#pragma mark - Gesture Recognizer
//-(void) labelWasTapped:(UIGestureRecognizer*) recognizer
//{
//    NSLog(@"NtAIC - label was tapped");
//}


@end
