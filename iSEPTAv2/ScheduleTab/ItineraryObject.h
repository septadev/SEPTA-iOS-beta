//
//  ItineraryObject.h
//  iSEPTA
//
//  Created by septa on 3/4/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StopObject.h"

@interface ItineraryObject : NSObject

//@property (nonatomic, strong) NSString *startStopName;
//@property (nonatomic, strong) NSString *endStopName;
//
//@property (nonatomic, strong) NSNumber *startStopID;
//@property (nonatomic, strong) NSNumber *endStopID;

//@property (nonatomic, strong) StopObject *currentStops;
//@property (nonatomic, strong) StopObject *reverseStops;

@property (nonatomic, strong) NSNumber *directionID;

@property (nonatomic, strong) NSString *routeID;
@property (nonatomic, strong) NSString *routeShortName;
@property (nonatomic, strong) NSString *routeLongName;

//@property (nonatomic, strong) NSNumber *routeType;


#pragma mark - Operational Methods
-(void) flipStops;
-(void) reset;

-(void) clearStops;

-(BOOL) isReverse;
-(void) setReverse:(BOOL) yesNo;

-(BOOL) isComplete;
//-(void) reverse;


#pragma mark - Setter Methods
-(void) setStartStopName:(NSString*) name;
-(void) setEndStopName:(NSString*) name;

-(void) setStartStopID:(NSNumber*) number;
-(void) setEndStopID:(NSNumber*) number;


#pragma mark - Getter Methods
-(NSString*) startStopName;
-(NSString*) endStopName;

-(NSNumber*) startStopID;
-(NSNumber*) endStopID;


@end


