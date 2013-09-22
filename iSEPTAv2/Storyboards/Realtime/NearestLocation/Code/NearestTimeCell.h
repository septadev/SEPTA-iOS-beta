//
//  NearestTimeCell.h
//  iSEPTA
//
//  Created by Administrator on 9/11/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// --==  Common  ==--
#import "GTFSCommon.h"


// --==  Data Model  ==--
#import "BusScheduleData.h"
#import "SystemAlertObject.h"


@interface NearestTimeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgAdvisory;
@property (weak, nonatomic) IBOutlet UIImageView *imgDetour;
@property (weak, nonatomic) IBOutlet UIImageView *imgAlerts;

@property (weak, nonatomic) IBOutlet UILabel *lblRouteName;
@property (weak, nonatomic) IBOutlet UILabel *lblRouteTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeRemaining;

@property (weak, nonatomic) IBOutlet UIImageView *imgRouteIcon;

-(void) setAlerts:(NSMutableArray*) alert;
-(void) setSchedule:(BusScheduleData*) schedule;

-(BOOL) isAlert;

@end
