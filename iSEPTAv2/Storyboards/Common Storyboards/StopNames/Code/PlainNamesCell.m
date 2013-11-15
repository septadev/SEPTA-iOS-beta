//
//  PlainNamesCell.m
//  iSEPTA
//
//  Created by Administrator on 11/15/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "PlainNamesCell.h"

@implementation PlainNamesCell

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

-(void) setWheelchairAccessiblity:(BOOL) yesNO
{
    [self.imgWheelchair setHidden: !yesNO];
}

@end
