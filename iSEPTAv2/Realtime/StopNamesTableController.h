//
//  StopNamesTableController.h
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StopNamesObject.h"
#import "CurrentLocationTableViewController.h"
#import "EnterAddressViewController.h"

//#import "ForwardViewController.h"

@class StopNamesTableController;  // Forward declaraction

@protocol StopNamesDelegate <NSObject>
-(void) doneButtonPressed:(StopNamesTableController*) view WithStopName:(NSString*) selectedStopName andStopID:(NSInteger) selectedStopID;
-(void) cancelButtonPressed:(StopNamesTableController*) view;
@end


@interface StopNamesTableController : UITableViewController <CurrentLocationProtocol>

@property (nonatomic, assign) id delegate;

@end
