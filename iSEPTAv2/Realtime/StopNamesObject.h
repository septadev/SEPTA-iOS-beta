//
//  StopNamesObject.h
//  iSEPTA
//
//  Created by apessos on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StopNamesObject : NSObject

@property (nonatomic, strong) NSString *stop_name;
@property (nonatomic, strong) NSNumber *stop_id;
@property (nonatomic, strong) NSNumber *direction_id;
@property (nonatomic, strong) NSString *destination;

@end
