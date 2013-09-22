//
//  UIColor+SEPTA.m
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "UIColor+SEPTA.h"

#define ALPHA 1.0f
#define CMAX 255.0f

@implementation UIColor (SEPTA)


+(UIColor*) colorForRouteType:(SEPTARouteTypes)routeType alpha:(CGFloat) alpha
{
    
    switch (routeType)
    {
        case kSEPTATypeBus:
        case kSEPTATypeTracklessTrolley:
            return [UIColor colorWithRed:56.0f/255.0f green:61.0f/255.0f blue:66.0f/255.0f alpha: alpha];
            break;
            
        case kSEPTATypeRail:
            return [UIColor colorWithRed:69.0f/255.0f green:99.0f/255.0f blue:122.0f/255.0f alpha: alpha];
            break;
            
        case kSEPTATypeMFL:
            return [UIColor colorWithRed:0.0f/255.0f green:125.0f/255.0f blue:195.0f/255.0f alpha: alpha];
            break;
            
        case kSEPTATypeBSL:
            return [UIColor colorWithRed:245.0f/255.0f green:132.0f/255.0f blue:38.0f/255.0f alpha: alpha];
            break;
            
        case kSEPTATypeNHSL:
            return [UIColor colorWithRed:121.0f/255.0f green:29.0f/255.0f blue:126.0f/255.0f alpha: alpha];
            break;
            
        case kSEPTATypeTrolley:
            return [UIColor colorWithRed:77.0f/255.0f green:121.0f/255.0f blue:0.0f/255.0f alpha: alpha];
            break;
            
        default:
            return [UIColor blackColor];
            break;
    }
    
}

+(UIColor*) colorForRouteType:(SEPTARouteTypes)routeType
{
    
    return [self colorForRouteType:routeType alpha:1.0f];
    
}

@end
