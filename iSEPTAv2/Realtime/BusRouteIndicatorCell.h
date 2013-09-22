//
//  BusRouteIndicatorCell.h
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAShapeLayer.h>

#import "BasicRouteObject.h"

// Categories
#import "UIColor+SEPTA.h"


// Common Headers
#import "GTFSCommon.h"
#import "SEPTACommon.h"


@interface BusRouteIndicatorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblDistanceUnits;

@property (weak, nonatomic) IBOutlet UILabel *lblStopName;
@property (weak, nonatomic) IBOutlet UIImageView *imgDivider;

-(void) addRouteInfo: (BasicRouteObject*) routeInfo;

@end
