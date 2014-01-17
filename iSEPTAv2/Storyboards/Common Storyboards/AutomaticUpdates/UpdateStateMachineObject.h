//
//  UpdateStateMachineObject.h
//  iSEPTA
//
//  Created by septa on 1/17/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateStateMachineObject : NSObject <NSCoding>

@property (nonatomic, strong) NSString *effective_date;
@property (nonatomic, strong) NSNumber *saved_state;
@property (nonatomic, strong) NSString *md5;

@end
