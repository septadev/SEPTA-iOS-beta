//
//  NextToArriveSingleTripCell.h
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NextToArrivaJSONObject.h"

@interface NextToArriveSingleTripCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orig_train;
@property (weak, nonatomic) IBOutlet UILabel *orig_delay;
@property (weak, nonatomic) IBOutlet UILabel *orig_arrival_time;
@property (weak, nonatomic) IBOutlet UILabel *orig_departure_time;

@property (weak, nonatomic) IBOutlet UILabel *orig_line;

@property (strong, nonatomic) NextToArrivaJSONObject *jsonData;

-(void) updateCellUsingJsonData: (NextToArrivaJSONObject*) data;

@end
