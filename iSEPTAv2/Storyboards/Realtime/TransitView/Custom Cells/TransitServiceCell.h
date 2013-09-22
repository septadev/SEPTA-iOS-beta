//
//  TransitServiceCell.h
//  iSEPTA
//
//  Created by Administrator on 8/11/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTFSCommon.h"
#import "SEPTACommon.h"

#import "RouteInfo.h"
#import "ServiceHours.h"


@interface TransitServiceCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *imgRouteType;
@property (weak, nonatomic) IBOutlet UIImageView *imgServiceStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgServiceLines;

@property (weak, nonatomic) IBOutlet UILabel *lblRouteName;
@property (weak, nonatomic) IBOutlet UILabel *lblServiceStatus;

@property (nonatomic, strong) NSString *status;

-(void) setService:(TransitServiceStatus) status;
//-(void) setRouteType:(GTFSRouteType) type;
//-(void) setRouteName: (NSString*) name;

-(void) setRouteInfo: (RouteInfo*) routeInfo;
-(void) setServiceHours:(ServiceHours*) serviceHours;

@end
