//
//  UIColor+SEPTA.h
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEPTACommon.h"

@interface UIColor (SEPTA)

+(UIColor*) colorForRouteType:(SEPTARouteTypes)routeType alpha:(CGFloat) alpha;
+(UIColor*) colorForRouteType:(SEPTARouteTypes) routeType;

@end
