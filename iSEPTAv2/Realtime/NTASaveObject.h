//
//  NTASaveObject.h
//  iSEPTA
//
//  Created by apessos on 12/21/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTASaveObject : NSObject <NSCoding>

@property (nonatomic, strong) NSString *startStopName;
@property (nonatomic, strong) NSString *endStopName;

@property (nonatomic, strong) NSDate *addedDate;  // Used for sorting

+(NSArray*) returnAllKeys;
+(NSArray*) returnImportantKeys;

@end
