//
//  StopSequenceObject.h
//  iSEPTA
//
//  Created by apessos on 3/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StopSequenceObject : NSObject

@property (nonatomic, strong) NSNumber *stopSequence;
@property (nonatomic, strong) NSString *stopName;
@property (nonatomic, strong) NSNumber *stopID;
@property (nonatomic, strong) NSString *arrivalTime;

@property (nonatomic, strong) NSString *stopLon;
@property (nonatomic, strong) NSString *stopLat;

@end
