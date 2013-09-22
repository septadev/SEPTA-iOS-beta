//
//  TransitServiceCell.m
//  iSEPTA
//
//  Created by Administrator on 8/11/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TransitServiceCell.h"


@implementation TransitServiceCell
{
    RouteInfo *_routeInfo;
    ServiceHours *_serviceHours;
}


@synthesize status = _status;


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


-(void) setServiceHours:(ServiceHours*) serviceHours
{
    _serviceHours = serviceHours;
    [self updateCellWithType: [serviceHours.route_type intValue] andName: serviceHours.route_id];
    [self setService: [serviceHours.transitServiceStatus intValue] ];
}



-(void) setRouteInfo: (RouteInfo*) routeInfo
{
    
 /*
  RouteInfo:
  
    @synthesize route_id;
    @synthesize route_long_name;
    @synthesize route_short_name;
    @synthesize route_type;
  
  */

    _routeInfo = routeInfo;
    
//    [self updateRouteName];
    [self updateRoute];
    
}

//-(void) updateRouteName
//{
//    
//    
//    [self.lblRouteName setText: _routeInfo.route_short_name];
//}

-(void) updateCellWithType: (int) route_type andName: (NSString*) route_name
{
    
    switch (route_type)
    {
        case kGTFSRouteTypeBus:
            
            if ( [route_name isEqualToString:@"MFO"] )
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-MFL_owl.png"] ];
                [self.lblRouteName setText:@""];
            }
            else if ( [route_name isEqualToString:@"BSO"] )
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-BSL_owl.png"] ];
                [self.lblRouteName setText:@""];
            }
            else if ( [route_name isEqualToString:@"LUCYGO"] )
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-LUCY.png"] ];
                [self.lblRouteName setText: @"GOLD"];
            }
            else if ( [route_name isEqualToString:@"LUCYGR"] )
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-LUCY.png"] ];
                [self.lblRouteName setText: @"GREEN"];
            }
            else
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-Bus.png"] ];
                [self.lblRouteName setText: route_name];
            }
            
            break;
            
        case kGTFSRouteTypeTrolley:
            
            if ( [route_name isEqualToString:@"NHSL"] )
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-NHSL.png"] ];
                [self.lblRouteName setText: route_name];
            }
            else
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-Trolley.png"] ];
                [self.lblRouteName setText: route_name];
            }
            break;
            
        default:
            // Other?
            
            [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-Bus.png"] ];
            [self.lblRouteName setText: route_name];
            break;
    }
    
}


-(void) updateRoute
{
    
    switch ([_routeInfo.route_type intValue])
    {
        case kGTFSRouteTypeBus:
            
            if ( [_routeInfo.route_short_name isEqualToString:@"MFO"] )
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-MFL_owl.png"] ];
                [self.lblRouteName setText:@""];
            }
            else if ( [_routeInfo.route_short_name isEqualToString:@"BSO"] )
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-BSL_owl.png"] ];
                [self.lblRouteName setText:@""];
            }
            else if ( [_routeInfo.route_short_name isEqualToString:@"LUCYGO"] )
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-LUCY.png"] ];
                [self.lblRouteName setText: @"GOLD"];
            }
            else if ( [_routeInfo.route_short_name isEqualToString:@"LUCYGR"] )
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-LUCY.png"] ];
                [self.lblRouteName setText: @"GREEN"];
            }
            else
            {
                [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-Bus.png"] ];
                [self.lblRouteName setText: _routeInfo.route_short_name];
            }
            
            break;
            
        case kGTFSRouteTypeTrolley:
            
            [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-Trolley.png"] ];
            [self.lblRouteName setText: _routeInfo.route_short_name];
            break;
            
        default:
            // Other?
            
            [self.imgRouteType setImage: [UIImage imageNamed:@"transitView-Bus.png"] ];
            [self.lblRouteName setText: _routeInfo.route_short_name];
            break;
    }
    
    
}



-(void) setService:(TransitServiceStatus) status
{
    
    
    switch (status)
    {
        case kTransitServiceIn:
            [self.imgServiceStatus setImage: [UIImage imageNamed:@"transitView-In-service.png"] ];
            [self.imgServiceLines  setImage: [UIImage imageNamed:@"transitView-In-service_lines.png"] ];
//            [self.lblServiceStatus setText:@"In Service"];
            [self.lblServiceStatus setText: _serviceHours.status];
            break;
            
        case kTransitServiceOut:
            [self.imgServiceStatus setImage: [UIImage imageNamed:@"transitView-Out-of-service.png"] ];
            [self.imgServiceLines  setImage: [UIImage imageNamed:@"transitView-Out-of-service_lines.png"] ];
//            [self.lblServiceStatus setText:@"Out of Service"];
            [self.lblServiceStatus setText: _serviceHours.status];
            break;
    }
    
}



@end
