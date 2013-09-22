//
//  FindLocationsViewController.h
//  iSEPTA
//
//  Created by septa on 11/6/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "ShowTimesModel.h"

//#import "PassedRouteData.h"
#import "DisplayedRouteData.h"

#import "StandardDefinitions.h"

@class FindLocationsViewController;

@protocol FindLocationsDelegate <NSObject>
    -(void) doneButtonPressed:(FindLocationsViewController*) view WithStopName:(NSString*) selectedStopName andStopID:(NSInteger) selectedStopID;
    -(void) cancelButtonPressed:(FindLocationsViewController*) view;
@end

@interface FindLocationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    sqlite3 *db;
}


@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnDone;


@property (nonatomic) ShowTimesButtonPressed buttonType;

@property (nonatomic, strong) DisplayedRouteData *routeData;

@property (nonatomic, strong) NSString *travelMode;

@property (nonatomic, assign) id <FindLocationsDelegate> delegate;

//- (IBAction)doneButtonPressed:(id)sender;

@end
