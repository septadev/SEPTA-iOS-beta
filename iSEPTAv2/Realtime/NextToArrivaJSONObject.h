//
//  NextToArrivaJSONObject.h
//  iSEPTA
//
//  Created by apessos on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NextToArrivaJSONObject : NSObject

// Variable names are the actually keys from the NTA JSON data
@property (nonatomic, strong) NSString* orig_train;
@property (nonatomic, strong) NSString* orig_line;

@property (nonatomic, strong) NSString* orig_departure_time;
@property (nonatomic, strong) NSString* orig_arrival_time;

@property (nonatomic, strong) NSString* orig_delay;
@property (nonatomic, strong) NSString* term_train;
@property (nonatomic, strong) NSString* term_line;

@property (nonatomic, strong) NSString *term_depart_time;
@property (nonatomic, strong) NSString *term_arrival_time;

@property (nonatomic, strong) NSString *Connection;  // Yes, it's captialized in the JSON data
@property (nonatomic, strong) NSString *term_delay;
@property (nonatomic, strong) NSString *isdirect;

@end
