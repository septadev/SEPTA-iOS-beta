//
//  TransitRouteListCell.m
//  iSEPTA
//
//  Created by septa on 8/1/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TransitRouteListCell.h"

@implementation TransitRouteListCell
{
    BOOL _isLoop;
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

-(void) setRouteType:(int) routeType
{
    
    NSLog(@"routeType (0 for trolley): %d", routeType);
    switch (routeType)
    {
        case 0:
            [self.imgRouteType setImage:[UIImage imageNamed:@"trolleyIndicator.png"] ];
            break;
        case 1:
            [self.imgRouteType setImage:[UIImage imageNamed:@"subwayIndicator.png"] ];
            break;
        case 2:
            [self.imgRouteType setImage:[UIImage imageNamed:@"railIndicator.png"] ];
            break;
        case 3:
            [self.imgRouteType setImage:[UIImage imageNamed:@"busIndicator.png"] ];
            break;
        default:  // Always default to Bus
            [self.imgRouteType setImage:[UIImage imageNamed:@"busIndicator.png"]];
            break;
    }  // switch (routeType)
    
}


//-(void) setAsLoop:(BOOL)isLoop
//{
//    _isLoop = isLoop;
//    [self.lblDirection1Title setText:@""];
//    [self.lblDirection1Hours setText:@""];
//}

-(void) setRouteInfo: (RouteInfo*) routeInfo
{
    
//    if ( routeInfo.direction0 != nil )
//    {
//        [self setDirectionTitle:routeInfo.direction0.cardinalDirection andHours:[NSString stringWithFormat:@"%@ - %@", routeInfo.direction0.minHours, routeInfo.direction0.maxHours] forDirectionID:[routeInfo.direction0.directionID intValue] ];
//    }
//    else
//    {
//        [self.lblDirection0Hours setText:@""];
//        [self.lblDirection0Hours setText:@""];
//    }
//    
//    if ( routeInfo.direction1 != nil )
//    {
//        [self setDirectionTitle:routeInfo.direction1.cardinalDirection andHours:[NSString stringWithFormat:@"%@ - %@", routeInfo.direction1.minHours, routeInfo.direction1.maxHours] forDirectionID:[routeInfo.direction1.directionID intValue] ];
//    }
//    else
//    {
//        [self.lblDirection1Hours setText:@""];
//        [self.lblDirection1Title setText:@""];
//    }
    
    
}


-(void) setDirectionTitle:(NSString*) title andHours:(NSString*) hours forDirectionID: (int) directionID
{
    
    UILabel *lblTitle;
    UILabel *lblHours;
    
    if ( directionID == 0 )
    {
        lblTitle = self.lblDirection0Title;
        lblHours = self.lblDirection0Hours;
    }
    else
    {
        lblTitle = self.lblDirection1Title;
        lblHours = self.lblDirection1Hours;
    }
    
    
    [lblTitle setText:title];
    [lblHours setText:hours];
    
}

@end


