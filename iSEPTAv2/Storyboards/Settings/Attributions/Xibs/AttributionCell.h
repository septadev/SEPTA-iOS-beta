//
//  AttributionCell.h
//  iSEPTA
//
//  Created by septa on 9/13/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AttributionData.h"

@interface AttributionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblLibraryName;

-(void) setObject:(AttributionData*) data;

@end
