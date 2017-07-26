//
//  TrainRealtimeDataViewController.h
//  iSEPTA
//
//  Created by septa on 9/23/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ECSlidingViewController/ECSlidingViewController.h>


// --==  Data Models  ==--
#import "TrainViewObject.h"
#import "TransitViewObject.h"


// --==  Xibs  ==--
#import "RealtimeVehicleInformationCell.h"



@interface TrainRealtimeDataViewController : UITableViewController

-(void) updateTableData: (NSMutableArray*) tableData;

@end
