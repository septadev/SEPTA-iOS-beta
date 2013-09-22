//
//  StopNameData.h
//  iSEPTA
//
//  Created by septa on 11/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "DisplayedRouteData.h"

typedef NS_ENUM(NSInteger, StopNameSectionType)
{
    kStopNameOutboundSection  = 0,
    kStopNameInboundSection   = 1,
};

@interface StopNameData : DisplayedRouteData
{
    NSMutableArray *_inbound;
    NSMutableArray *_outbound;
    
    NSMutableArray *_directions;
}

@property (nonatomic, strong) NSMutableArray *inbound;
@property (nonatomic, strong) NSMutableArray *outbound;

@property (nonatomic, strong) NSMutableArray *directions;

@property (nonatomic, strong) NSString *inboundName;
@property (nonatomic, strong) NSString *outboundName;

-(id) initWithDisplayedRouteData:(DisplayedRouteData *)data andDatabaseType:(DisplayedRouteDatabaseType) database;

-(void) sort;
-(void) clear;

-(NSInteger) numberOfInboundRows;
-(NSInteger) numberOfOutboundRows;

-(NSInteger) numberOfDirections;
-(NSString *) directionForID: (StopNameSectionType) directionID;

-(NSString*) nameForSection:(NSInteger) section;
-(NSInteger) numberOfRowsInSection;

-(NSInteger) getSectionForSection: (StopNameSectionType) section withIndex:(NSInteger) index;
-(NSMutableArray*) getSectionTitleForSection: (StopNameSectionType) section;

-(void) setInboundOrOutbound:(BOOL) isInbound;

@end
