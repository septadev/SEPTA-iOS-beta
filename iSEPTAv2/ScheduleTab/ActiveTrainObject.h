//
//  ActiveTrainObject.h
//  iSEPTA
//
//  Created by septa on 3/14/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActiveTrainObject : NSObject

@property (nonatomic, strong) NSNumber *trainNo;
@property (nonatomic, strong) NSNumber *trainDelay;

@property (nonatomic, strong) NSString *serviceType;
@property (nonatomic, strong) NSString *nextStop;

// ???  More TrainView JSON fields that we might or might not use
@property (nonatomic, strong) NSString *destination;
@property (nonatomic, strong) NSString *source;

// These properties should mimics those in TripObject so it can be filtered the same way
@property (nonatomic, strong) NSNumber *serviceID;
@property (nonatomic, strong) NSNumber *directionID;

@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *tripID;


@end
