//
//  StopSequenceCellData.h
//  iSEPTA
//
//  Created by apessos on 3/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StopSequenceCellData : NSObject

@property (nonatomic, strong) NSNumber *firstSequence;
@property (nonatomic, strong) NSNumber *lastSequence;

@property (nonatomic, strong) NSNumber *startOfTrip;
@property (nonatomic, strong) NSNumber *endOfTrip;

@end
