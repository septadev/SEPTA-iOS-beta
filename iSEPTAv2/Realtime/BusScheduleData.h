//
//  BusScheduleData.h
//  iSEPTA
//
//  Created by septa on 6/27/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusScheduleData : NSObject


// Name and Capitalization reflects names as they appear in the returned JSON data
@property (nonatomic, strong) NSString *Route;
@property (nonatomic, strong) NSString *DateCalender;
@property (nonatomic, strong) NSString *Direction;
@property (nonatomic, strong) NSString *StopName;

@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSString *dayOfWeek;

// Addditional fields
@property (nonatomic, strong) NSDate *dateTime;
@property (nonatomic, strong) NSNumber *routeType;




@end
