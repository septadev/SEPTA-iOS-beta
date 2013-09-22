//
//  AttributionCell.m
//  iSEPTA
//
//  Created by septa on 9/13/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "AttributionCell.h"

@implementation AttributionCell

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



-(void) setObject:(AttributionData*) data
{
    [self.lblLibraryName setText: data.library];
}

@end
