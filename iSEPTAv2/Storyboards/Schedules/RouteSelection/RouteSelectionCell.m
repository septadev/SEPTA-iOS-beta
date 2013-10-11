//
//  RouteSelectionCell.m
//  iSEPTA
//
//  Created by septa on 8/16/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "RouteSelectionCell.h"

@implementation RouteSelectionCell
{
    RouteData *_routeData;
}

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

-(void) setRouteData: (RouteData*) routeData
{
    _routeData = routeData;
    
    /* 
     
     RouteData: 
     @synthesize route_long_name;
     
     @synthesize route_short_name;
     @synthesize route_id;
     @synthesize route_type;
     
     @synthesize direction_id;
     @synthesize start_stop_id;
     @synthesize end_stop_id;
     
     @synthesize start_stop_name;
     @synthesize end_stop_name;
     
     //@synthesize end_arrival_time;
     //@synthesize start_arrival_time;
     
     @synthesize preference;
     @synthesize database_type;
     @synthesize added_date;
     
     */
    

    switch ( (GTFSRouteType)[_routeData.route_type intValue] )
    {
            
        case kGTFSRouteTypeSubway:   // MFL, BSL, NHSL
            
            if ( [_routeData.route_short_name isEqualToString:@"MFL"] )
            {
                [self.imgIcon setImage: [UIImage imageNamed:@"Schedule_MFL_small.png"] ];
                [self.imgCell setImage: [UIImage imageNamed:@"Schedule_MFL-BG.png"] ];
            }
            else if ( [_routeData.route_short_name isEqualToString:@"BSL"] || [_routeData.route_short_name isEqualToString:@"BSL"] )
            {
                [self.imgIcon setImage: [UIImage imageNamed:@"Schedule_BSL_small.png"] ];
                [self.imgCell setImage: [UIImage imageNamed:@"Schedule_BSL-BG.png"] ];
            }

            [self.lblShortName setText: _routeData.route_short_name];
            [self.lblTitle     setText: _routeData.route_long_name];

            break;
            
        case kGTFSRouteTypeBus:
            
            [self.imgIcon setImage: [UIImage imageNamed:@"Schedule_Bus_small.png"] ];
            [self.imgCell setImage: [UIImage imageNamed:@"Schedule_Bus-BG.png"] ];
            
            [self.lblShortName setText: _routeData.route_short_name];
            [self.lblTitle     setText: _routeData.route_long_name];
            
            break;
            
        case kGTFSRouteTypeTrolley:
            
            if ( [_routeData.route_short_name isEqualToString:@"NHSL"] )
            {
                [self.imgIcon setImage: [UIImage imageNamed:@"Schedule_NHSL_small.png"] ];
                [self.imgCell setImage: [UIImage imageNamed:@"Schedule_NHSL-BG.png"] ];
            }
            else
            {
                [self.imgIcon setImage: [UIImage imageNamed:@"Schedule_Trolley_small.png"] ];
                [self.imgCell setImage: [UIImage imageNamed:@"Schedule_Trolley-BG.png"] ];
            }
            
            [self.lblShortName setText: _routeData.route_short_name];
            [self.lblTitle     setText: _routeData.route_long_name];
            
            break;
            
        case kGTFSRouteTypeRail:

            [self.imgIcon setImage: [UIImage imageNamed:@"Schedule_RRL_small.png"] ];
            [self.imgCell setImage: [UIImage imageNamed:@"Schedule_RRL-BG.png"] ];
            
            [self.lblShortName setText: _routeData.route_id];
            [self.lblTitle setText: _routeData.route_long_name];
            break;
            
        default:
            break;
    }




}

@end
