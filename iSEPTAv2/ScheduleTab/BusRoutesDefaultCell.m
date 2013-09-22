//
//  BusRoutesDefaultCell.m
//  iSEPTA
//
//  Created by septa on 11/15/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "BusRoutesDefaultCell.h"

@implementation BusRoutesDefaultCell

@synthesize imgType;
@synthesize lblRouteShortName;
@synthesize lblRouteLongName;

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

-(void) changeImageTo:(BusRoutesDefaultCellImageType)imageType
{
    
    switch (imageType)
    {
        case kBusRoutesDefaultCellImageBus:
            [self.imgType setImage:[UIImage imageNamed:@"busIndicator.png"]];
            break;
        case kBusRoutesDefaultCellImageTrolley:
            [self.imgType setImage:[UIImage imageNamed:@"trolleyIndicator.png"]];
            break;
        case kBusRoutesDefaultCellImageRail:
            [self.imgType setImage:[UIImage imageNamed:@"railIndicator.png"] ];
            break;
        case kBusRoutesDefaultCellImageSubway:
            [self.imgType setImage:[UIImage imageNamed:@"subwayIndicator.png"] ];
            break;
        case kBusRoutesDefaultCellImageMFL:
            [self.imgType setImage:[UIImage imageNamed:@"mflIndicator.png"] ];
            break;
        case kBusRoutesDefaultCellImageBSS:
            [self.imgType setImage:[UIImage imageNamed:@"bslIndicator.png"] ];
            break;
        case kBusRoutesDefaultCellImageNHSL:
            [self.imgType setImage:[UIImage imageNamed:@"nhsIndicator.png"] ];
            break;
        default:  // Always default to Bus
            [self.imgType setImage:[UIImage imageNamed:@"busIndicator.png"]];
            break;
    }
}

@end
