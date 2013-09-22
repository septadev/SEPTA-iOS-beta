//
//  CachedRoutesData.h
//  iSEPTA
//
//  Created by septa on 1/2/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CachedRoutesData : NSManagedObject

@property (nonatomic, retain) NSNumber * start_stop_id;
@property (nonatomic, retain) NSNumber * end_stop_id;
@property (nonatomic, retain) NSString * trip_id;
@property (nonatomic, retain) NSString * start_arrival_time;
@property (nonatomic, retain) NSString * end_arrival_time;
@property (nonatomic, retain) NSNumber * direction_id;
@property (nonatomic, retain) NSNumber * start_stop_sequence;
@property (nonatomic, retain) NSNumber * end_stop_sequence;

@end
