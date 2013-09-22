//
//  StopTimesStartCell.h
//  iSEPTA
//
//  Created by septa on 12/11/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StopTimesStartCellProtocol
@required
-(void) flippedButtonPressed;
-(void) leftButtonPressedInRow:(NSInteger) row;

@end

@interface StopTimesStartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (weak, nonatomic) IBOutlet UIButton *btnFlip;

@property (weak, nonatomic) IBOutlet UILabel *lblStopName;

@end
