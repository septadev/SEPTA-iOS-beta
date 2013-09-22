//
//  ShowTimesModel.h
//  iSEPTA
//
//  Created by septa on 11/5/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TripData.h"

@interface ShowTimesModel : NSObject
{
    NSMutableArray *_times;  // Holder of TripData objects
}



-(void) addTimes:(TripData*) times;
-(void) insert:(TripData *) times atIndex: (NSUInteger) index;

-(NSInteger) numberOfRows;
-(NSInteger) numberOfSections;
-(TripData*) objectForIndexPath:(NSIndexPath*) path;

-(void) clearIndex;
-(void) generateIndex;
-(void) sort;

-(id) initWithPlaceholders:(NSInteger) numberOfPlaceholders;

-(void) replaceObjectForIndexPath:(NSIndexPath*) path withObject:(id) object;
-(void) clearData;
-(void) switchRow:(NSInteger) firstRow withRow:(NSInteger) secondRow;

//-(NSInteger) getSectionForSection: (NSInteger) section withIndex:(NSInteger) index;
//-(NSMutableArray*) getSectionTitleForSection: (NSInteger) section;

-(NSInteger) getSectionWithIndex: (NSInteger) index;
-(NSMutableArray*) getSectionTitle;

-(void) flipStartEnd;

@end

