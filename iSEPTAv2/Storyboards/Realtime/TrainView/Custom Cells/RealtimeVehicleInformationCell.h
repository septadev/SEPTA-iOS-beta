//
//  RealtimeVehicleInformationCell.h
//  iSEPTA
//
//  Created by septa on 7/31/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// Custom Data Models
#import "TrainViewObject.h"
#import "TransitViewObject.h"


@interface RealtimeVehicleInformationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblStartName;
@property (weak, nonatomic) IBOutlet UILabel *lblEndName;

@property (weak, nonatomic) IBOutlet UILabel *lblTrainNo;
@property (weak, nonatomic) IBOutlet UILabel *lblLate;

@property (weak, nonatomic) IBOutlet UILabel *lblStartTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTitle;


-(void) addObjectToCell:(id) object;

@end
