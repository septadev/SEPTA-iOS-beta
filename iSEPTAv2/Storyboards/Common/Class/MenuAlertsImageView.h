//
//  MenuAlertsImageView.h
//  iSEPTA
//
//  Created by Administrator on 11/22/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NSLinkedList.h"

/*
 
 ObjectView: UIImageView
 
 [object addAlert: kSecondMenuAlert];
 [object addAlert: kSecondMenuAdvisory];
 [object addAlert: kSecondMenuDetour];
 
 [object removeAllAlerts];
 [object removeAlert: kSecondMenuAlert];
 
 [object nextLoop];  // duration + delay, starts state machine
 [object stopLoop];  <-- cancel running animation block?, ends state machine
 
 [object setDuration: 1.5f];
 [object setDelay:    0.5f];
 
 [object setBaseImageView: (UIImageView*) image];
 [object setOverlayImageView: (UIImageView*) image];
 
 // One alert   - always on
 // Two+ alerts - cycle through
 
 // Circular linked list
 
 [p][data][n]
 
 data
 - image
 - ???
 
 */


typedef NS_ENUM(NSInteger, MenuAlertsImageType)
{
    kMenuAlertsImageNone,
    kMenuAlertsImageAlerts,
    kMenuAlertsImageDetours,
    kMenuAlertsImageAdvisories,
};



@interface MenuAlertsImageView : UIView

-(void) addAlert: (MenuAlertsImageType) alertType;
-(void) removeAlert: (MenuAlertsImageType) alertType;

-(void) removeAllAlerts;

-(void) nextLoop;

-(void) startLoop;
-(void) stopLoop;

-(void) addTarget:(id) target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

-(void) setDuration:(int) duration;
-(void) setDelay:(int) delay;

-(void) setBaseImage: (UIImage*) image;
//-(void) setOverlayImage: (UIImage*) image;

@end
