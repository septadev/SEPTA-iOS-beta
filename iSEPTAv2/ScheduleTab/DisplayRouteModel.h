//
//  DisplayRouteModel.h
//  iSEPTA
//
//  Created by septa on 11/2/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "DisplayRouteSectionIndex.h"


typedef NS_ENUM(NSInteger, DisplayRouteSectionType)
{
    kDisplayRouteOutboundSection  = 0,
    kDisplayRouteInboundSection   = 1,
};

@interface DisplayRouteModel : NSObject
{
//    NSMutableArray *_sections;
    
    NSMutableArray *_inbound;
    NSMutableArray *_outbound;
    
    NSMutableArray *_favorites;
    NSMutableArray *_recentlyViewed;
    
    NSMutableArray *_directions;
}

//@property (nonatomic, strong) NSMutableArray *sections;

@property (nonatomic, strong) NSMutableArray *inbound;
@property (nonatomic, strong) NSMutableArray *outbound;

@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableArray *recentlyViewed;

@property (nonatomic, strong) NSMutableArray *directions;

//@property (nonatomic, readonly) NSMutableArray *sectionName;
@property (nonatomic, strong) NSString *inboundName;
@property (nonatomic, strong) NSString *outboundName;

-(NSInteger) numberOfSections;
-(NSInteger) numberOfRowsForSection:(NSInteger) section;

-(NSString*) nameForSection:(NSInteger) section;

-(void) sort;

-(id) objectForIndexPath: (NSIndexPath *)indexPath;

-(NSInteger) numberOfInboundRows;
-(NSInteger) numberOfOutboundRows;

-(NSInteger) numberOfDirections;
-(NSString *) directionForID: (DisplayRouteSectionType) directionID;

-(NSInteger) getSectionForSection: (DisplayRouteSectionType) section withIndex:(NSInteger) index;
-(NSMutableArray*) getSectionTitleForSection: (DisplayRouteSectionType) section;

-(void) setInboundOrOutbound:(BOOL) inbound;

@end
