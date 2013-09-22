//
//  NTASingleCell.h
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NextToArrivaJSONObject.h"

@interface NTASingleCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *lblStartLine;
@property (weak, nonatomic) IBOutlet UILabel *lblDepartsTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDepartsUnit;

@property (weak, nonatomic) IBOutlet UILabel *lblArrivesTime;
@property (weak, nonatomic) IBOutlet UILabel *lblArrivesUnit;

@property (weak, nonatomic) IBOutlet UILabel *lblTrainNo;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

-(void) addObjectToCell:(NextToArrivaJSONObject*) object;

@end
