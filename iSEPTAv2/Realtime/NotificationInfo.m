//
//  NotificationInfo.m
//  iSEPTA
//
//  Created by septa on 6/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NotificationInfo.h"

@implementation NotificationInfo

@synthesize stopName;
@synthesize notificationType;

-(id) initWithNotification:(UILocalNotification*) notification
{
    
    if ( ( self = [super init] ) )
    {
        
        NSDictionary *info = [notification userInfo];
        [self setValuesForKeysWithDictionary: info];
        
    }
    
    return self;

}


-(NSDictionary*) dict
{
    return [self dictionaryWithValuesForKeys: [NotificationInfo returnAllKeyValues] ];
}


+(NSArray*) returnAllKeyValues
{
    return [NSArray arrayWithObjects:@"stopName", nil];
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"NI: %@", [self dictionaryWithValuesForKeys: [NotificationInfo returnAllKeyValues] ] ];
}


@end
