//
//  BusRoutesDefaultCell.h
//  iSEPTA
//
//  Created by septa on 11/15/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BusRoutesDefaultCellImageType)  // According to the GTFS guidelines
{
    kBusRoutesDefaultCellImageTrolley = 0,
    kBusRoutesDefaultCellImageSubway  = 1,
    kBusRoutesDefaultCellImageRail    = 2,
    kBusRoutesDefaultCellImageBus     = 3,
    kBusRoutesDefaultCellImageFerry,
    kBusRoutesDefaultCellImageCableCar,
    kBusRoutesDefaultCellImageGondola,
    kBusRoutesDefaultCellImageFunicular,
    
    // Not GTFS compatible values
    kBusRoutesDefaultCellImageMFL,
    kBusRoutesDefaultCellImageBSS,
    kBusRoutesDefaultCellImageNHSL,
    
};

@interface BusRoutesDefaultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgType;
@property (weak, nonatomic) IBOutlet UILabel *lblRouteShortName;
@property (weak, nonatomic) IBOutlet UILabel *lblRouteLongName;

-(void) changeImageTo:(BusRoutesDefaultCellImageType) imageType;

@end
