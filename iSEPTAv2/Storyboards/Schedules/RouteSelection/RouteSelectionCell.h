//
//  RouteSelectionCell.h
//  iSEPTA
//
//  Created by septa on 8/16/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// --==  Data Models  ==--
#import "RouteData.h"


// --==  Common  ==--
#import "GTFSCommon.h"


@interface RouteSelectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imgCell;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblShortName;


-(void) setRouteData: (RouteData*) routeData;

@end
