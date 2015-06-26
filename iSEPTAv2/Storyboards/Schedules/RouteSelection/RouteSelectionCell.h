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

#import "TableCellAlertsView.h"


// --==  Common  ==--
#import "GTFSCommon.h"


@protocol RouteSelectionCellProtocol <NSObject>
@required

//-(void) switchDirectionButtonTapped;
-(void) alertTapped;

@end

typedef NS_ENUM(NSInteger, RouteAlertsImageType)
{
    kRouteAlertsImageNone,
    kRouteAlertsImageAlerts,
    kRouteAlertsImageDetours,
    kRouteAlertsImageAdvisories,
};


@interface RouteSelectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imgCell;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblShortName;

@property (weak, nonatomic) IBOutlet UIButton *btnAlert;

//@property (weak, nonatomic) IBOutlet UIImageView *imgAlert;
@property (weak, nonatomic) IBOutlet UIView *alertView;

@property (weak, nonatomic) id<RouteSelectionCellProtocol> delegate;


-(void) setRouteData: (RouteData*) routeData;

// -- Side Alert Notification
//-(void) removeAlert: (RouteAlertsImageType) alertType;
//-(void) addAlert: (RouteAlertsImageType) alertType;
//-(void) next;
//-(void) start;

@end
