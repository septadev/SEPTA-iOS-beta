//
//  NTAResultsCell.h
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NextToArrivaJSONObject.h"

@interface NTAResultsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTrainNo;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@property (weak, nonatomic) IBOutlet UILabel *lblStartTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblStart;
@property (weak, nonatomic) IBOutlet UILabel *lblEnd;


-(void) addObjectToCell:(NextToArrivaJSONObject*) object;

@end
