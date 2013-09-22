//
//  ShowTimesStartCell.h
//  iSEPTA
//
//  Created by septa on 11/5/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ShowTimesStartCellProtocol <NSObject>
@required
-(void) flippedButtonPressed;
-(void) leftButtonPressedInRow:(NSInteger) row;

@end

@interface ShowTimesStartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnFlip;
@property (weak, nonatomic) IBOutlet UILabel *lblStopName;

@property (nonatomic) NSInteger row;
@property (weak, nonatomic) id delegate;

-(void) flipDataInCell: (ShowTimesStartCell*) firstCell withCell: (ShowTimesStartCell*) secondCell;
-(void) flipDataWithCell: (ShowTimesStartCell*) secondCell;

@end
