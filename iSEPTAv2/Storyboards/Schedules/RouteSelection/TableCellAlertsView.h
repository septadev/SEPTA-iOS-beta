//
//  TableCellAlertsView.h
//  iSEPTA
//
//  Created by septa on 4/17/15.
//  Copyright (c) 2015 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TableCellAlertsImageType)
{
    kTableCellAlertsImageNone,
    kTableCellAlertsImageAlerts,
    kTableCellAlertsImageDetours,
    kTableCellAlertsImageAdvisories,
    kTableCellAlertsImageSuspend,
    kTableCellAlertsImageSnow
};


@interface TableCellAlertsView : UIView

@property (strong, nonatomic) UIImageView *imageView;

-(void) addAlert: (TableCellAlertsImageType) alertType;
-(void) removeAlert: (TableCellAlertsImageType) alertType;

-(void) removeAllAlerts;

-(void) nextLoop;

-(void) startLoop;
-(void) stopLoop;

//-(void) addTarget:(id) target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

-(void) setDuration:(int) duration;
-(void) setDelay:(int) delay;

-(void) hasSideIndex:(BOOL) yesNO;

//-(void) setBaseImage: (UIImage*) image;
//-(void) setOverlayImage: (UIImage*) image;

@end
