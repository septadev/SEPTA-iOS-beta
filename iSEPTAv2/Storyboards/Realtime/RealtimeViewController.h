//
//  RealtimeViewController.h
//  iSEPTA
//
//  Created by septa on 7/19/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


// Subclassed ViewControllers
#import "NextToArriveTableViewController.h"
#import "TrainViewViewController.h"
#import "TransitViewViewController.h"
#import "SystemStatusViewController.h"
#import "NearestLocationViewController.h"

#import "MapMemoryTestViewController.h"
#import "MMDrawerTestViewController.h"

// -- Testing
//#import "TransitDrawerViewController.h"


// Subclassed, Others
#import "SEPTATitle.h"


// --==  PODs  ==--
#import <Reachability.h>
#import <SVProgressHUD.h>


@interface RealtimeViewController : UIViewController


// Top row buttons
@property (weak, nonatomic) IBOutlet UIButton *btnNextToArrive;
@property (weak, nonatomic) IBOutlet UIButton *btnTrainView;
@property (weak, nonatomic) IBOutlet UIButton *btnTransitView;

@property (weak, nonatomic) IBOutlet UILabel *lblNextToArrive;
@property (weak, nonatomic) IBOutlet UILabel *lblTrainView;
@property (weak, nonatomic) IBOutlet UILabel *lblTransitView;



// Botton row buttons
@property (weak, nonatomic) IBOutlet UIButton *btnSystemStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnFindNearestLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnGuide;

@property (weak, nonatomic) IBOutlet UILabel *lblSystemStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblFindNeareset;
@property (weak, nonatomic) IBOutlet UILabel *lblLocations;

@property (weak, nonatomic) IBOutlet UILabel *lblGuide;



@end
