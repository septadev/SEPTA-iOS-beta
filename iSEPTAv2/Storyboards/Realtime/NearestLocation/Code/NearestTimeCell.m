//
//  NearestTimeCell.m
//  iSEPTA
//
//  Created by Administrator on 9/11/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NearestTimeCell.h"

@implementation NearestTimeCell
{
    BOOL _isAlert;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _isAlert = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void) setAlerts:(NSMutableArray*) alert
{
    
    SystemAlertObject *saObject = [alert objectAtIndex:0];
    _isAlert = NO;
    
    if ( saObject == nil )
    {
        [self.imgAlerts setHidden:YES];
        [self.imgAdvisory setHidden:YES];
        [self.imgDetour setHidden:YES];
        return;
    }
    
    // --==  Alerts  ==--
    if ( [saObject.current_message length] > 1 )
    {
        [self.imgAlerts setHidden:NO];
        _isAlert = YES;
    }
    else
        [self.imgAlerts setHidden:YES];
    
    
    // --==  Advisory  ==--
    if ( [saObject.advisory_message length] > 1 )
    {
        [self.imgAdvisory setHidden:NO];
        _isAlert = YES;
    }
    else
        [self.imgAdvisory setHidden:YES];
    
    
    // --==  Detour  ==--
    if ( [saObject.detour_message length] > 1 )
    {
        [self.imgDetour setHidden:NO];
        _isAlert = YES;
    }
    else
        [self.imgDetour setHidden:YES];
        
}


-(BOOL) isAlert
{
    return _isAlert;
}


-(void) setSchedule:(BusScheduleData*) schedule
{
 
    //    [thisCell.lblRouteName setText: data.Route];
    //    [thisCell.lblArrivalTime setText: data.date];
    //    [thisCell.lblMinutesRemaining setText:@""];
    
    [self.lblRouteName setText: schedule.Route];
    [self.lblRouteTime setText: schedule.date];
    
//    [self.lblTimeRemaining setText:@""];
    [self.lblDayOfTheWeek setText: schedule.dayOfWeek];
    
    UIImage *imageIcon;
    
    switch ([schedule.routeType intValue])
    {
        case kGTFSRouteTypeBus:
            if ( [schedule.Route isEqualToString:@"MFO"] )
            {
                    imageIcon = [UIImage imageNamed:@"MFL_Owl.png"];
            }
            else if ( [schedule.Route isEqualToString:@"BSO"] )
            {
                imageIcon = [UIImage imageNamed:@"BSL_Owl.png"];
            }
            else
                imageIcon = [UIImage imageNamed:@"Bus_black.png"];
            
            break;
        case kGTFSRouteTypeTrolley:
            imageIcon = [UIImage imageNamed:@"Trolley_green.png"];
            break;
        case kGTFSRouteTypeSubway:
            
            if ( [schedule.Route isEqualToString:@"MFL"] )
            {
                imageIcon = [UIImage imageNamed:@"MFL_Blue.png"];
            }
            else
            {
                imageIcon = [UIImage imageNamed:@"BSL_Orange.png"];
            }
            
            break;
        default:
            break;
    }
    
    
    
    [self.imgRouteIcon setImage: imageIcon ];
    
    
    [self.imgAdvisory setHidden:YES];
    [self.imgAlerts   setHidden:YES];
    [self.imgDetour   setHidden:YES];
    
}


@end
