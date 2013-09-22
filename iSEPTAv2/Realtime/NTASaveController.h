//
//  NTASaveController.h
//  iSEPTA
//
//  Created by apessos on 12/21/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTASaveObject.h"

typedef NS_ENUM(NSInteger, NTASaveSection)
{
    kNTASectionFavorites   = 0,
    kNTASectionRecentlyViewed,
    kNTASectionNone,
    kNTASectionAll,
};

@interface NTASaveController : NSObject

@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableArray *recent;

-(id) init;
-(void) save;

-(void) sortSection:(NTASaveSection) section;

-(NSInteger) addObject:(NTASaveObject*) object intoSection:(NTASaveSection) section;  // Returns true if object was found in the section already
-(void) removeObject:(NTASaveObject*) object fromSection:(NTASaveSection) section;

-(void) makeSectionDirty:(NTASaveSection) section;

-(BOOL) isSectionDirty: (NTASaveSection) section;

@end
