//
//  FindNearestRouteSaveObject.h
//  iSEPTA
//
//  Created by septa on 1/15/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FindNearestRouteSaveObject : NSObject <NSCoding>


@property (nonatomic, strong) NSNumber *radius;

+(NSArray*) returnAllKeys;

@end
