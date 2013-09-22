//
//  UserPreferenceCell.h
//  iSEPTA
//
//  Created by septa on 11/15/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPreferenceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblStartStopName;
@property (weak, nonatomic) IBOutlet UILabel *lblEndStopName;
@property (weak, nonatomic) IBOutlet UILabel *lblStart;
@property (weak, nonatomic) IBOutlet UILabel *lblEnd;
@property (weak, nonatomic) IBOutlet UILabel *lblFromTO;

@property (weak, nonatomic) IBOutlet UILabel *lblRouteShortName;

@end
