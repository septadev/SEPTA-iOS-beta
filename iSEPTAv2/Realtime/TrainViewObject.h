//
//  TrainViewObject.h
//  iSEPTA
//
//  Created by septa on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainViewObject : NSObject

@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

@property (nonatomic, strong) NSString *trainNo;
@property (nonatomic, strong) NSString *startName;

@property (nonatomic, strong) NSString *endName;
@property (nonatomic, strong) NSNumber *late;

@property (nonatomic, strong) NSNumber *distance;

@end
