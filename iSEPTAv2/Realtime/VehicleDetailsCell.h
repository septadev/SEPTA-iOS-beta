//
//  VehicleDetailsCell.h
//  iSEPTA
//
//  Created by septa on 3/20/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteInfo.h"

@interface VehicleDetailsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblRouteName;
@property (weak, nonatomic) IBOutlet UIImageView *imgRouteType;

@property (weak, nonatomic) IBOutlet UILabel *lblDirection0Title;
@property (weak, nonatomic) IBOutlet UILabel *lblDirection0Hours;

@property (weak, nonatomic) IBOutlet UILabel *lblDirection1Title;
@property (weak, nonatomic) IBOutlet UILabel *lblDirection1Hours;

//-(void) setAsLoop:(BOOL) isLoop;
-(void) setRouteType:(int) routeType;
//-(void) setDirectionTitle:(NSString*) title andHours:(NSString*) hours forDirectionID: (int) directionID;

-(void) setRouteInfo: (RouteInfo*) routeInfo;

@end
