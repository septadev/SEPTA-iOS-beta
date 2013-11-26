//
//  ElevatorStatusObject.h
//  iSEPTA
//
//  Created by septa on 11/26/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ElevatorMetaObject : NSObject

@property (nonatomic, strong) NSString *elevators_out;
@property (nonatomic, strong) NSString *updated;

@end

@interface ElevatorResultsObject : NSObject

@property (nonatomic, strong) NSString *line;
@property (nonatomic, strong) NSString *station;
@property (nonatomic, strong) NSString *elevator;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *alternate_url;

@end


@interface ElevatorStatusObject : NSObject

@property (nonatomic, strong) ElevatorMetaObject *meta;
@property (nonatomic, strong) NSMutableArray     *results;


-(BOOL) setJSON:(NSData*) data;

@end
