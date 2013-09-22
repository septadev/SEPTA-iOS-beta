//
//  TrainViewCell.h
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TrainViewObject.h"
#import "TransitViewObject.h"

@interface TrainViewCell : UITableViewCell



@property (weak, nonatomic) IBOutlet UILabel *lblStartName;
@property (weak, nonatomic) IBOutlet UILabel *lblEndName;

@property (weak, nonatomic) IBOutlet UILabel *lblTrainNo;
@property (weak, nonatomic) IBOutlet UILabel *lblLate;

@property (weak, nonatomic) IBOutlet UILabel *lblStartTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTitle;


-(void) addObjectToCell:(id) object;

@end
