//
//  SystemStatusObject.h
//  iSEPTA
//
//  Created by apessos on 12/26/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemStatusObject : NSObject

@property (nonatomic, strong) NSString *route_id;
@property (nonatomic, strong) NSString *route_name;
@property (nonatomic, strong) NSString *mode;

@property (nonatomic, strong) NSString *isadvisory;
@property (nonatomic, strong) NSString *isdetour;
@property (nonatomic, strong) NSString *isalert;
@property (nonatomic, strong) NSString *issuspend;

@property (nonatomic, strong) NSString *last_updated;

-(NSInteger) numOfNonCriticalAlerts;
-(NSInteger) numOfAlerts;

-(BOOL) isAlert;
-(BOOL) isAdvisory;
-(BOOL) isDetour;
-(BOOL) isSuspend;

@end
