//
//  StopObject.h
//  iSEPTA
//
//  Created by septa on 4/8/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StopObject : NSObject

@property (nonatomic, strong) NSString *startStopName;
@property (nonatomic, strong) NSString *endStopName;

@property (nonatomic, strong) NSNumber *startStopID;
@property (nonatomic, strong) NSNumber *endStopID;

-(void) flipStops;
-(void) clear;
-(BOOL) isComplete;

@end
