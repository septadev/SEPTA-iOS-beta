//
//  SystemStatusCell.m
//  iSEPTA
//
//  Created by SEPTA on 12/26/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "SystemStatusCell.h"

@implementation SystemStatusCell

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


-(void) addSystemStatusObject:(SystemStatusObject*) ssObject
{
    
    [self.lblRouteName setText: ssObject.route_name];
    
    if ( [[ssObject mode] isEqualToString:@"Bus"] )
    {
        if ( [[ssObject route_id] isEqualToString:@"bus_route_LUCY"] )
            [self.imgRouteIcon setImage: [UIImage imageNamed:@"LUCY.png"]];
        else
            [self.imgRouteIcon setImage: [UIImage imageNamed:@"Bus_black.png"]];
    }
    else if ( [[ssObject mode] isEqualToString:@"Trolley"] )
    {
        [self.imgRouteIcon setImage: [UIImage imageNamed:@"Trolley_green.png"]];
    }
    else if ( [[ssObject mode] isEqualToString:@"Regional Rail"] )
    {
        [self.imgRouteIcon setImage: [UIImage imageNamed:@"RRL.png"]];
    }
    else if ( [[ssObject mode] isEqualToString:@"Norristown High Speed Line"] )
    {
        [self.imgRouteIcon setImage: [UIImage imageNamed:@"NHSL_Purple.png"]];
    }
    else if ( [[ssObject route_id] isEqualToString:@"rr_route_mfl"] )
    {
        [self.imgRouteIcon setImage: [UIImage imageNamed:@"MFL_Blue.png"]];
    }
    else if ( [[ssObject route_id] isEqualToString:@"rr_route_mfo"] )
    {
        [self.imgRouteIcon setImage: [UIImage imageNamed:@"MFL_Owl.png"]];
    }
    else if ( [[ssObject route_id] isEqualToString:@"rr_route_bsl"] )
    {
        [self.imgRouteIcon setImage: [UIImage imageNamed:@"BSL_Orange.png"]];
    }
    else if ( [[ssObject route_id] isEqualToString:@"rr_route_bso"] )
    {
        [self.imgRouteIcon setImage: [UIImage imageNamed:@"BSL_Owl.png"]];
    }
    
    
}


-(NSString*) description
{
    return [NSString stringWithFormat:@"isHidden: Advisory/Alert/Detour/Suspend - %d/%d/%d/%d", self.imgAdvisory.hidden, self.imgAlert.hidden, self.imgDetour.hidden, self.imgSuspended.hidden];
}

@end