//
//  TransitViewObject.h
//  iSEPTA
//
//  Created by septa on 12/20/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransitViewObject : NSObject

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;

@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *VehicleID;

@property (nonatomic, strong) NSString *BlockID;
@property (nonatomic, strong) NSString *Direction;

@property (nonatomic, strong) NSString *destination;
@property (nonatomic, strong) NSString *Offset;

@property (nonatomic, strong) NSNumber *distance;

@end
