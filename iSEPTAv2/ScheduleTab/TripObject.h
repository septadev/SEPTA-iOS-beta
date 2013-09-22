//
//  TripObject.h
//  iSEPTA
//
//  Created by septa on 3/4/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripObject : NSObject

//@property (nonatomic, strong) NSString *startTime;
//@property (nonatomic, strong) NSString *endTime;

@property (nonatomic, strong) NSNumber *startTime;
@property (nonatomic, strong) NSNumber *endTime;


@property (nonatomic, strong) NSNumber *trainNo;
@property (nonatomic, strong) NSString *routeName;

//@property (nonatomic, strong) NSString *routeStart;
//@property (nonatomic, strong) NSString *routeEnd;

@property (nonatomic, strong) NSNumber *serviceID;
@property (nonatomic, strong) NSNumber *directionID;

@property (nonatomic, strong) NSNumber *startSeq;
@property (nonatomic, strong) NSNumber *endSeq;

@property (nonatomic, strong) NSString *tripID;

@end
