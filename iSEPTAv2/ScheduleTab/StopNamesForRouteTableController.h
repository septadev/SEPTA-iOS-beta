//
//  StopNamesForRouteTableController.h
//  iSEPTA
//
//  Created by apessos on 3/5/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSMutableArray+Indices.h"
#import "ItineraryObject.h"

@class StopNamesForRouteTableController;

@protocol StopNamesForRouteDelegate <NSObject>
-(void) doneButtonPressed:(StopNamesForRouteTableController*) view WithStopName:(NSString*) selectedStopName andStopID:(NSInteger) selectedStopID;
-(void) doneButtonPressed:(StopNamesForRouteTableController*) view WithStopName:(NSString*) selectedStopName andStopID:(NSInteger) selectedStopID withDirectionID: (NSNumber*) directionID;
-(void) cancelButtonPressed:(StopNamesForRouteTableController*) view;

@end

@interface StopNamesForRouteTableController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDone;

//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureDoubleTap;
//@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *gestureLongPress;

@property (nonatomic, assign) id <StopNamesForRouteDelegate> delegate;

@property (nonatomic, strong) NSString *queryStr;
@property (nonatomic, strong) NSString *travelMode;

@property (nonatomic, strong) NSNumber *direction;
@property (nonatomic, strong) ItineraryObject *itinerary;

@end
