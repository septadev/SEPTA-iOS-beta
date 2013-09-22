//
//  NotificationInfo.h
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, kNotificationInfoType)
{
    kNotificationInfoLocationAlarm,
};


@interface NotificationInfo : NSObject

@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSNumber *notificationType;

-(id) initWithNotification:(UILocalNotification*) notification;

+(NSArray*) returnAllKeyValues;

-(NSDictionary*) dict;

@end
