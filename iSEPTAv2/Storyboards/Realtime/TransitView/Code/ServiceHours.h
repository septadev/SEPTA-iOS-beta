//
//  ServiceHours.h
//  iSEPTA
//
//  Created by Administrator on 9/4/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SEPTACommon.h"
#import "GTFSCommon.h"

@interface ServiceHours : NSObject

@property (nonatomic, strong) NSString *route_id;
@property (nonatomic, strong) NSString *route_short_name;
@property (nonatomic, strong) NSNumber *route_type;

@property (nonatomic, readonly) NSNumber *transitServiceStatus;
@property (nonatomic, readonly) NSString *status;


-(void) addMin:(int) min andMax:(int) max withServiceID:(int) service_id;
-(NSArray*) hoursForServiceID:(int) service_id;
-(NSString*) statusForTime:(int) time andServiceID: (int) service_id;
-(NSString*) statusForTime:(int) time andServiceIDs: (NSArray*) sids;


-(void) changeServiceStatus:(TransitServiceStatus) newStatus;

//-(int) getMinWithServiceID:(int) service_id;
//-(int) getMaxWithServiceID:(int) service_id;

@end


@interface MinMax : NSObject

@property (nonatomic, strong) NSNumber *min;
@property (nonatomic, strong) NSNumber *max;

@end
