//
//  PlainNamesCell.h
//  iSEPTA
//
//  Created by Administrator on 11/15/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlainNamesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblStopName;
@property (weak, nonatomic) IBOutlet UIImageView *imgWheelchair;


-(void) setWheelchairAccessiblity:(BOOL) yesNO;

@end
