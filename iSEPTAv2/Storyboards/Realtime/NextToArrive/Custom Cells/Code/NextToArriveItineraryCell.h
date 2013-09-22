//
//  NextToArriveItineraryCell.h
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitButton.h"


typedef NS_ENUM(NSInteger, NextToArriveItineraryCellButtonPressed)  // According to the GTFS guidelines
{
    kNextToArriveButtonTypeStart    = 0,
    kNextToArriveButtonTypeEnd,
    kNextToArriveButtonTypeStartEnd,
    kNextToArriveButtonTypeReverse,
};


@protocol NextToArriveItineraryCellProtocol <NSObject>

-(void) itineraryButtonPressed:(NSInteger) buttonType;

@end

@interface NextToArriveItineraryCell : UITableViewCell


@property (weak, nonatomic) IBOutlet SplitButton *btnStartEnd;
@property (weak, nonatomic) IBOutlet UIButton *btnReverse;

@property (weak, nonatomic) IBOutlet UIButton *btnStartDestination;
@property (weak, nonatomic) IBOutlet UIButton *btnEndDestination;

@property (weak, nonatomic) id<NextToArriveItineraryCellProtocol> delegate;

@end
