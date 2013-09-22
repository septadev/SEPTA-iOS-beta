//
//  NTASaveObjectCell.m
//  iSEPTA
//
//  Created by septa on 12/24/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "NTASaveObjectCell.h"

@implementation NTASaveObjectCell

@synthesize lblStartName;
@synthesize lblEndName;

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

-(NSString*) description
{
    return [NSString stringWithFormat:@"start: %@, end: %@", [lblStartName text], [lblEndName text] ];
}

@end
