//
//  SystemAlertObject.h
//  iSEPTA
//
//  Created by apessos on 12/26/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemAlertObject : NSObject

@property (nonatomic, strong) NSString *route_id;
@property (nonatomic, strong) NSString *route_name;
@property (nonatomic, strong) NSString *current_message;

@property (nonatomic, strong) NSString *advisory_message;
@property (nonatomic, strong) NSString *detour_message;

@property (nonatomic, strong) NSString *detour_start_location;
@property (nonatomic, strong) NSString *detour_start_date_time;

@property (nonatomic, strong) NSString *detour_end_date_time;
@property (nonatomic, strong) NSString *detour_reason;

@property (nonatomic, strong) NSString *last_updated;

-(BOOL) isAlert;

@end
