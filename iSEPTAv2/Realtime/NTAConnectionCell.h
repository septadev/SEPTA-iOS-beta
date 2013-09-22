//
//  NTAConnectionCell.h
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NextToArrivaJSONObject.h"

@interface NTAConnectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblStartLine;
@property (weak, nonatomic) IBOutlet UILabel *lblStartDepartsTime;
@property (weak, nonatomic) IBOutlet UILabel *lblStartDepartsUnit;

@property (weak, nonatomic) IBOutlet UILabel *lblStartArrivesTime;
@property (weak, nonatomic) IBOutlet UILabel *lblStartArrivesUnit;

@property (weak, nonatomic) IBOutlet UILabel *lblStartTrainNo;
@property (weak, nonatomic) IBOutlet UILabel *lblStartStatus;

@property (weak, nonatomic) IBOutlet UILabel *lblConnectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblConnection;

@property (weak, nonatomic) IBOutlet UIImageView *imgArrowConnection;


@property (weak, nonatomic) IBOutlet UILabel *lblEndLine;
@property (weak, nonatomic) IBOutlet UILabel *lblEndDepartsTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndDepartsUnit;

@property (weak, nonatomic) IBOutlet UILabel *lblEndArrivesTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndArrivesUnit;

@property (weak, nonatomic) IBOutlet UILabel *lblEndTrainNo;
@property (weak, nonatomic) IBOutlet UILabel *lblEndStatus;


-(void) addObjectToCell:(NextToArrivaJSONObject*) object;


@end
