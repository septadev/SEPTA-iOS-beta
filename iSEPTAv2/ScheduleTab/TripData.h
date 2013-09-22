//
//  TripData.h
//  iSEPTA
//
//  Created by septa on 11/15/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripData : NSObject <NSCopying>
{
    
}

@property (nonatomic, strong) NSString *start_stop_name;
@property (nonatomic, strong) NSString *end_stop_name;

@property (nonatomic, strong) NSNumber *start_stop_id;
@property (nonatomic, strong) NSNumber *end_stop_id;

@property (nonatomic, strong) NSString *start_arrival_time;
@property (nonatomic, strong) NSString *end_arrival_time;

@property (nonatomic, strong) NSString *trip_id;
@property (nonatomic, strong) NSString *start_stop_sequence;
@property (nonatomic, strong) NSString *end_stop_sequence;

@property (nonatomic, strong) NSNumber *direction_id;
@property (nonatomic, strong) NSString *train_no;

-(void) switchStartEnd;
+(NSArray*) returnKeyValues;

@end
