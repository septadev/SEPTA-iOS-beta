//
//  Event.h
//  iSEPTA
//
//  Created by septa on 12/12/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * added_date;
@property (nonatomic, retain) NSNumber * database_type;
@property (nonatomic, retain) NSNumber * direction_id;
@property (nonatomic, retain) NSNumber * end_stop_id;
@property (nonatomic, retain) NSString * end_stop_name;
@property (nonatomic, retain) NSNumber * preference;
@property (nonatomic, retain) NSString * route_id;
@property (nonatomic, retain) NSString * route_short_name;
@property (nonatomic, retain) NSNumber * route_type;
@property (nonatomic, retain) NSNumber * start_stop_id;
@property (nonatomic, retain) NSString * start_stop_name;

@end
