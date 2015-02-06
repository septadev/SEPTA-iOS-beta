//
//  TableViewStore.h
//  iSEPTA
//
//  Created by septa on 6/28/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+Indices.h"
#import "NSMutableArray+MoveObject.h"

#import <UIKit/UIKit.h>


@interface TVStoreObject : NSObject

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSString *section;
@property (nonatomic, strong) NSNumber *tag;

@end



@interface TableViewStore : NSObject



// Adding data to store
-(void) addObject:(id) object;
//-(void) addObject:(id) object forIndexPath:(NSIndexPath*) indexPath;
-(void) addObject:(id) object forSection:(NSInteger) section;
-(void) addObject:(id) object forTitle:(NSString*) title;
-(void) addObject:(id)object forTitle:(NSString *)title withTag: (NSInteger) tag;

-(void) addSection;
-(void) addSectionWithTitle:(NSString*) title;


-(void) addArray:(NSMutableArray*) array;
-(void) addArray:(NSMutableArray*) array forSection:(NSInteger) section;
-(void) addArray:(NSMutableArray*) array forTitle:(NSString*) title;

-(void) replaceArrayWith:(NSMutableArray*) array;

-(void) replaceArrayWith:(NSMutableArray*) array forSection:(NSInteger) section;
-(void) replaceArrayWith:(NSMutableArray*) array forTitle:(NSString*) title;


//-(void) addSectionWithTitle:(NSString*) title forSectionIndex:(int) index;
//-(void) addSectionWithTitle:(NSString*) title forIndexPath:(NSIndexPath*) indexPath;

-(void) setTag:(NSInteger) tag forSection:(NSInteger) section;
-(void) setTag:(NSInteger) tag forTitle:(NSString*) title;


// Modify store title
//-(void) modifySectionTitle:(NSString*) newTitle forIndexPath:(NSIndexPath*) indexPath;
-(BOOL) modifySectionTitle:(NSString*) newTitle forSectionIndex:(NSInteger) sectionIndex;


// Remove data from store
-(void) removeAllObjects;

-(void) removeObject:(id) object fromSection:(NSInteger) section;
-(void) removeObjectWithIndexPath:(NSIndexPath*) indexPath;

-(void) removeSection:(NSInteger) section;
//-(void) removeSectionWithIndexPath:(NSIndexPath*) indexPath;
-(void) removeSectionWithTitle:(NSString*) title;


// Access data in store
-(id) objectForIndexPath:(NSIndexPath*) indexPath;
-(id) objectForSectionWithTitle:(NSString*) title;
-(id) objectForSection:(NSInteger) sectionIndex;

-(NSString*) titleForSection:(NSInteger) sectionIndex;
-(NSInteger) indexForSectionTitle:(NSString*) title;
-(void) clearSectionWithTitle:(NSString*) title;

// Access properties of store
-(NSInteger) numOfSections;
-(NSInteger) numOfRowsForSection: (NSInteger) section;

-(NSInteger) lastSection;
-(NSInteger) lastRow;

-(NSArray*) returnAllSections;

// Helper methods
//-(NSArray*) splitArrayBy:(NSString*) key;
-(NSArray*) splitArray:(NSArray*) array byKey:(NSString*) key;

// TODO: Define sortOptions later
//-(NSArray*) splitArrayBy:(NSString*) key withOption:(int) sortOption;


//-(void) insertObject:(id) object atIndex:(NSUInteger)index;
-(void) moveSection:(NSUInteger) fromIndex afterSection:(NSUInteger) newIndex;
-(void) moveSection:(NSUInteger) fromIndex toSection:(NSInteger)newSection;


// Returns the current accessPath for the internal data store
-(NSIndexPath*) accessPath;


-(void) generateIndexWithKey: (NSString*) key;
-(void) generateIndexWithKey: (NSString*) key forSectionTitles: (NSArray*) titles;

-(NSArray*) getSectionTitles;

-(NSIndexPath*) getIndexPathForIndex:(NSInteger) index;
-(NSInteger) getSectionWithIndex:(NSInteger) index;

-(void) sortByTags;
-(void) sortBySectionTitles;

@end
