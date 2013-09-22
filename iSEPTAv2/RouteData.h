//
//  RouteData.h
//  iSEPTA
//
//  Created by septa on 11/12/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteData : NSObject <NSCopying>
{
    
}

@property (nonatomic, strong) NSString *route_long_name;

@property (nonatomic, strong) NSString *route_short_name;
@property (nonatomic, strong) NSString *route_id;
@property (nonatomic, strong) NSNumber *route_type;

@property (nonatomic) NSInteger direction_id;
@property (nonatomic) NSInteger start_stop_id;
@property (nonatomic) NSInteger end_stop_id;

@property (nonatomic, strong) NSString *start_stop_name;
@property (nonatomic, strong) NSString *end_stop_name;

//@property (nonatomic, strong) NSString *start_arrival_time;
//@property (nonatomic, strong) NSString *end_arrival_time;

@property (nonatomic) NSInteger preference;
@property (nonatomic) NSInteger database_type;
@property (nonatomic) NSDate *added_date;

-(void) flipStartEndStops;

+(NSArray*) returnImportantKeyValues;  // Was going to use Key instead of Important but that just seemed redundant...
+(NSArray*) returnAllKeyValues;

@end
