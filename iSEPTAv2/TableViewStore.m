//
//  TableViewStore.m
//  iSEPTA
//
//  Created by septa on 6/28/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TableViewStore.h"

@implementation TVStoreObject

@synthesize data;
@synthesize section;
@synthesize tag;

-(id) init
{
    
    self = [super init];
    if ( self )
    {
        data = [[NSMutableArray alloc] init];
        section = @"Unnamed Section";
        tag = [NSNumber numberWithInt:-1];
    }
    return self;
    
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"section: %@, tag: %@ \n data: %@", section, tag, data];
}

@end



@implementation TableViewStore
{
    
    NSMutableArray       *_topStore;
    NSMutableDictionary  *_sectionTracker;
    
    NSIndexPath *_lastAccessPath;
    
    
    // For generating indeces
    NSMutableArray *_timesSectionIndex;
    NSMutableArray *_timesSectionTitle;

}


-(id) init
{
    if ( ( self = [super init] ) )
    {
        
        _topStore = [[NSMutableArray alloc] init];
        _sectionTracker = [[NSMutableDictionary alloc] init];
        _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
//        [self addSection];  // Add the first element in _topStore
        
//        [_topStore addObject: [[NSMutableArray alloc] init] ];  // Add the first element in _topStore
        
    }
    
    return self;
}



#pragma mark - Helper Methods
-(void) incrementLastAccessPath
{
    _lastAccessPath = [NSIndexPath indexPathForRow:_lastAccessPath.row+1 inSection:_lastAccessPath.section];
}


#pragma mark - Adding Objects to DataStore
-(void) addObject:(id) object  // Modified
{

    if ( [_topStore count] == 0 )
    {
        TVStoreObject *store = [[TVStoreObject alloc] init];
        [store.data addObject: object];
        [_topStore addObject: store];
    }
    else
    {
        TVStoreObject *store = [_topStore objectAtIndex: _lastAccessPath.section];
        [store.data addObject: object];
    }
    [self incrementLastAccessPath];
    
}


-(void) addObject:(id) object forSection:(NSInteger) section  // Modified
{
    
    if ( section < 0 )
        section = [_topStore count] -1;
    
    if ( [_topStore count] > section )
    {
        // Do something
    }
    else if ( [_topStore count] == section )
    {
        TVStoreObject *tvsObject = [[TVStoreObject alloc] init];
        [tvsObject.data addObject: object];
        [_topStore addObject: tvsObject];
    }
    
    TVStoreObject *tvsObject = [_topStore objectAtIndex: section];
    [tvsObject.data addObject: object];
    
    _lastAccessPath = [NSIndexPath indexPathForRow:[[(TVStoreObject*)[_topStore objectAtIndex:section] data] count]-1 inSection:section];

}



-(void) addObject:(id)object forTitle:(NSString *)title withTag: (NSInteger) tag
{
    
    //    int count = 0;
    BOOL matchFound = NO;
    for (TVStoreObject *sObject in _topStore)
    {
        
        if ([sObject.section isEqualToString:title] )
        {
            [sObject.data addObject: object];
            matchFound = YES;
            break;
        }
        else
        {
            //            count++;
        }
        
    }
    
    if ( !matchFound )
    {
        TVStoreObject *sObject = [[TVStoreObject alloc] init];
        [sObject.data addObject: object];
        [sObject setSection: title];
        [sObject setTag: [NSNumber numberWithLong:tag] ];
        [_topStore addObject: sObject];
    }
    
    [self incrementLastAccessPath];
    return;
    
}


-(void) addObject:(id) object forTitle:(NSString*) title  // Modified
{

    [self addObject:object forTitle:title withTag:-1];

    //    return;
//    
//    
//    NSNumber *secNum = [_sectionTracker objectForKey:title];
//    if ( secNum == nil )
//    {
//        // If section does not exist in the _sectionTracker, add it
//        [self addSectionWithTitle:title];
//        secNum = [_sectionTracker objectForKey:title];
//    }
//    
//    NSInteger section = [secNum intValue];
//
//    [self addObject:object forSection:section];
//
    
}


-(void) addSection  // Modified
{
    
    NSUInteger section = [_topStore count];
    [self addSectionWithTitle:[NSString stringWithFormat:@"Generic Section %lu", (unsigned long)section] ];
    
}

-(void) addSectionWithTitle:(NSString*) title  // Modified
{

    long section = [_topStore count] - 1;
    if ( section < 0 )
        section = 0;
    _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection: section];

    TVStoreObject *sObject = [[TVStoreObject alloc] init];
    [sObject setSection: title];
    
    [_topStore addObject: sObject];
    
}


// --==
// --==  Arrays
// --==

-(void) addArray:(NSMutableArray*) array
{
    [self addArray:array forSection:_lastAccessPath.section];
}


-(void) addArray:(NSMutableArray*) array forSection:(NSInteger) section  // Modified
{

    // Check if the object is nil
    if ( array == nil || [array count] == 0 )
        return;

    
    if ( section > [_topStore count] )
        return;
    else if ( section < 0 )
        return;
    else if ( section == [_topStore count] )
    {
        TVStoreObject *sObject = [[TVStoreObject alloc] init];
        [sObject setData: array];
        [_topStore addObject: sObject];
    }
    else
    {
        TVStoreObject *sObject = [_topStore objectAtIndex: section];
        [sObject setData: array];
    }
    
    return;
    
//    for (NSArray *object in array)
//    {
//        [self addObject:object forSection:section];
//    }
    
}

-(void) addArray:(NSMutableArray*) array forTitle:(NSString*) title  // Modified
{
 
    // Check if the object is nil
    if ( array == nil || [array count] == 0 )
        return;

    
    int count = 0;
    BOOL matchFound = NO;
    for (TVStoreObject *sObject in _topStore)
    {
        if ( [sObject.section isEqualToString:title] )
        {
            [sObject setData: array];
            _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:count];
            matchFound = YES;
            break;
        }
        count++;
    }
    
    
    if ( !matchFound )
    {
        TVStoreObject *sObject = [[TVStoreObject alloc] init];
        [sObject setData: array ];
        [sObject setSection: title];
        [_topStore addObject: sObject];
    }
    
}



-(void) replaceArrayWith:(NSMutableArray*) array
{
    [self replaceArrayWith:array forSection:_lastAccessPath.section];
}


-(void) replaceArrayWith:(NSMutableArray*) array forSection:(NSInteger) section  // Modified
{
    
    // Check if the object is nil
    if ( array == nil || [array count] == 0 )
        return;

    
    if ( section > [_topStore count] )  // If the section is larger than the current _topStore count, just return
    {
        // E.g. _topStore has a count of 4.  Valid sections are 0,1,2 and 3.
        return;
    }
    else if ( section == [_topStore count] )  // There should be an exception if section is equal to [_topStore]
    {
        [self addSection];  // Create a new section with an empty NSArray object, that will be replaced down below
    }
    
    
    TVStoreObject *sObject = [_topStore objectAtIndex: section];
    [sObject setData: array];
    _lastAccessPath = [NSIndexPath indexPathForRow:[array count] -1 inSection:section];
    
}


-(void) replaceArrayWith:(NSMutableArray*) array forTitle:(NSString*) title  // Modified
{

    // Check if object is nil before attempting to make any modifications to internal data store
    if ( array == nil | [array count] == 0 )
        return;

    int count = 0;
    for (TVStoreObject *sObject in _topStore)
    {
        if ( [sObject.section isEqualToString:title] )
        {
            [sObject setData: array];
            _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:count];
            return;
        }
        count++;
    }
    
    // If we're at this point, title wasn't found in _topStore
    
    [self addArray:array forTitle:title];
    
}






// Modify store title
#pragma mark - Modify Existing Section Title
-(BOOL) modifySectionTitle:(NSString*) newTitle forSectionIndex:(NSInteger) sectionIndex  // Modified
{

    if ( sectionIndex < 0 )
        return NO;
    else if ( sectionIndex >= [_topStore count] )
        return NO;
    
    
    TVStoreObject *sObject = [_topStore objectAtIndex: sectionIndex];
    [sObject setSection: newTitle];
    return YES;
    
}



#pragma mark - Removing Objects From DataStore
// Remove data from store
-(void) removeAllObjects
{
    [_topStore removeAllObjects];
    [_sectionTracker removeAllObjects];
    
    _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
}


-(void) removeObject:(id) object fromSection:(NSInteger) section  // Modified
{
    [[(TVStoreObject*)[_topStore objectAtIndex:section] data] removeObject: object];
}


-(void) removeObjectWithIndexPath:(NSIndexPath*) indexPath  // Modified
{
    // TODO: Perform some sane check that this is valid
    
    if ( indexPath.section >= [_topStore count] )
        return;
    else if ( indexPath.section < 0 )
        return;
    
    [[(TVStoreObject*)[_topStore objectAtIndex:indexPath.section] data] removeObjectAtIndex: indexPath.row];

}


-(void) removeSection:(NSInteger) section  // Modified
{
    
    if ( section >= [_topStore count] )
        return;
    else if ( section < 0 )
        return;
    
    [[(TVStoreObject*)[_topStore objectAtIndex:section] data] removeAllObjects];
    [_topStore removeObjectAtIndex:section];
    
    if ( _lastAccessPath.section == section )
        _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
}


-(void) clearSectionWithTitle:(NSString*) title  // Modified
{
    
    int count = 0;
    for (TVStoreObject *sObject in _topStore)
    {
        if ( [sObject.section isEqualToString:title] )
        {
            [sObject.data removeAllObjects];
            break;
        }
        count++;
    }
    
    _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:count];
    
}


-(void) removeSectionWithTitle:(NSString*) title
{
    
    int count = 0;
    for (TVStoreObject *sObject in _topStore)
    {
        if ( [sObject.section isEqualToString:title] )
        {
            [_topStore removeObjectAtIndex: count];
            break;
        }
        count++;
    }

}



#pragma mark - Retrieve Objects in DataStore
// Access data in store
-(id) objectForIndexPath:(NSIndexPath*) indexPath  // Modified
{
    return [[(TVStoreObject*)[_topStore objectAtIndex:indexPath.section] data] objectAtIndex:indexPath.row];
    
    return [[_topStore objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

-(id) objectForSectionWithTitle:(NSString*) title  // Modified
{
    
    for (TVStoreObject *sObject in _topStore)
    {
        if ( [sObject.section isEqualToString:title] )
        {
            return sObject.data;
        }
    }
    
    return nil;
    
}


-(id) objectForSection:(NSInteger) sectionIndex  // Modified
{
    if ( [_topStore count] > sectionIndex )
        return [(TVStoreObject*)[_topStore objectAtIndex:sectionIndex] data];
    else
        return nil;
    
//            return [_topStore objectAtIndex:sectionIndex];  // Was
}



-(NSString*) titleForSection:(NSInteger) sectionIndex  // Modified
{

    // Since _sectionTracker contains just the index for a particular object, cycle through all entries until
    //   the sectionIndex value is found, then return the key associated with that value.
    // E.g.
    //   _sectionTracker
    //   [0] => "Favorites"
    //   [1] => "Data"
    //   [2] => "Recent"
    
    // What is the title for sectionIndex 2?  (Recent, obviously)
    
    if ( sectionIndex >= [_topStore count] )
    {
        return nil;
    }
    
    TVStoreObject *sObject = [_topStore objectAtIndex: sectionIndex];
    return sObject.section;

}


-(NSInteger) indexForSectionTitle:(NSString*) title  // Modified
{
    
    
    int count = 0;
    for (TVStoreObject *sObject in _topStore)
    {
        if ( [sObject.section isEqualToString:title] )
            return count;
        count++;
    }
    return NSNotFound;
    
}


#pragma mark - Properties of DataStore
// Access properties of store
-(NSInteger) numOfSections  // Unchanged
{
    return [_topStore count];
}

-(NSInteger) numOfRowsForSection: (NSInteger) section  // Modified
{
    if ( section >= [_topStore count] )
        return 0;
    
    return [[(TVStoreObject*)[_topStore objectAtIndex:section] data] count];
    // return [ [_topStore objectAtIndex:section] count];
}

-(NSInteger) lastSection
{
    return _lastAccessPath.section;
}

-(NSInteger) lastRow
{
    return _lastAccessPath.row;
}


#pragma mark - Insert Object
-(void) moveSection:(NSUInteger) fromIndex toSection:(NSInteger)newSection
{

    // Need to find the key for the index we're moving
    NSString *fromKey;
    for (NSString *key in _sectionTracker)
    {
        if ( [[_sectionTracker objectForKey:key] intValue] == fromIndex )
        {
            fromKey = key;  // Found the key!
            break;
        }
    }
    
    if ( fromKey == nil )
        return;  // Something was wrong with the fromIndex, exit out before any changes are made to the data
    
    [_topStore moveObjectFromIndex:fromIndex toIndex: newSection];
    
    
    NSMutableDictionary *newTracker = [[NSMutableDictionary alloc] init];
    for (NSString *key in _sectionTracker)
    {
        int val = [[_sectionTracker objectForKey:key] intValue];
        if ( val > newSection )
            [newTracker setValue:[NSNumber numberWithInt:val+1] forKey:key];
        else
            [newTracker setValue:[NSNumber numberWithInt:val] forKey:key];
        
    }
    
    [newTracker setValue:[NSNumber numberWithLong:newSection+1] forKey:fromKey];
    
    _sectionTracker = newTracker;
    
//    [self rebuildSectionTracker];
    
}



-(void) moveSection:(NSUInteger) fromIndex afterSection:(NSUInteger) afterIndex
{
    
    // Usage:
    //   _topStore has 4 sections, "Itinerary", "Recent", "Data", "Favorites"
    //   section "Favorites" needs to be reorder to appear after "Itinerary"
    //   [_dataStore moveSection: 3 afterSection: 0]
    //   [_dataStore moveSectionTitle: @"Favorites" afterSection: @"Itinerary"]
    
    
    // Need to find the key for the index we're moving
    NSString *fromKey;
    for (NSString *key in _sectionTracker)
    {
        if ( [[_sectionTracker objectForKey:key] intValue] == fromIndex )
        {
            fromKey = key;  // Found the key!
            break;
        }
    }
    
    
    if ( fromKey == nil )
        return;  // Something was wrong with the fromIndex, exit out before any changes are made to the data
    
    
    [_topStore moveObjectFromIndex:fromIndex toIndex: afterIndex+1];  // Method from NSMutableArray+MoveObject
    
    
    NSMutableDictionary *newTracker = [[NSMutableDictionary alloc] init];
    for (NSString *key in _sectionTracker)
    {
        int val = [[_sectionTracker objectForKey:key] intValue];
        if ( val > afterIndex )
            [newTracker setValue:[NSNumber numberWithInt:val+1] forKey:key];
        else
            [newTracker setValue:[NSNumber numberWithInt:val] forKey:key];

    }
    
    [newTracker setValue:[NSNumber numberWithLong:afterIndex+1] forKey:fromKey];

    _sectionTracker = newTracker;
    
}


// Helper methods
-(NSArray*) splitArray:(NSArray*) array byKey:(NSString*) key
{

    NSMutableDictionary *mainDict = [[NSMutableDictionary alloc] init];
    
    for (id object in array)
    {
        
        id objectKey = [object valueForKey:key];  // Get the value of for the key in the object
        
        if ( [mainDict objectForKey:objectKey] == nil )  // Does the objectKey already exists?
        {
            // If no, create a new object
            [mainDict setValue:[[NSMutableArray alloc] initWithObjects:object, nil] forKey:objectKey];
        }
        else
        {
            // Otherwise, yes.
            NSMutableArray *oldArr = [mainDict objectForKey:objectKey];
            [oldArr addObject:object];
        }
        
    }  // for (id object in array)
    
    
    // What we have now is a dictionary split by key
    // But we want to return an array, not a dictionary
    
    NSMutableArray *returnArr = [[NSMutableArray alloc] init];
    for (NSString *key in mainDict)
    {
        [returnArr addObject: [mainDict objectForKey:key] ];
    }
    
    return returnArr;
    
}

// TODO: Define sortOptions later
//-(NSArray*) splitArrayBy:(NSString*) key withOption:(int) sortOption
//{
//    
//}


-(NSArray*) returnAllSections  // Modified
{

    NSMutableArray *listObject = [[NSMutableArray alloc] init];
    for ( TVStoreObject *sObject in _topStore )
    {
        [listObject addObject: sObject.section];
    }
    return listObject;
    
}


-(NSString*) description  // Modified
{
    
    NSMutableString *outputStr = [[NSMutableString alloc] init];
    
    for (int LCV = 0; LCV < [_topStore count]; LCV++)
    {
        [outputStr appendFormat:@"Data in index %d (%@): %@\n", LCV, [self titleForSection:LCV], [_topStore objectAtIndex:LCV] ];
    }

    [outputStr appendFormat:@"\n With sections:\n"];
    for (TVStoreObject *sObject in _topStore)
    {
        [outputStr appendFormat:@"\t%@\n", sObject.section];
    }
    
//    for (NSString *key in _sectionTracker)
//    {
//        [outputStr appendFormat:@"\t%@\n", key];
//    }
    
    [outputStr appendFormat:@"\n# of elements in topStore: %lu\n", (unsigned long)[_topStore count] ];
    [outputStr appendFormat:@"Last Path (s/r): %ld/%ld\n\n", (long)_lastAccessPath.section, (long)_lastAccessPath.row];
    
    return outputStr;
    
}



#pragma mark - Index/Titles
-(void) generateIndexWithKey: (NSString*) key forSectionTitles: (NSArray*) titles
{
    
    // Most of the time titles will only contain a single title.  However, there are certain
    //   times when mutliple titles will be used to generate the indices and titles
    BOOL firstTime = YES;
    
    
//    NSMutableArray *tempIndex = [[NSMutableArray alloc] init];
//    NSMutableArray *tempTitle = [[NSMutableArray alloc] init];

    // If neither of these arrays have been allocated before, do so now.
    if ( _timesSectionTitle == nil )
        _timesSectionTitle = [[NSMutableArray alloc] init];
    
    if ( _timesSectionIndex == nil )
        _timesSectionIndex = [[NSMutableArray alloc] init];
    
    [_timesSectionIndex removeAllObjects];
    [_timesSectionTitle removeAllObjects];
    
    
    for (NSString *title in titles)
    {

        if ( !firstTime )
        {
//            [_timesSectionIndex addObject:[NSIndexPath indexPathForRow:0 inSection: [self indexForSectionTitle:title] ] ];
//            [_timesSectionTitle addObject:@"-"];
            [_timesSectionIndex addObject: [NSIndexPath indexPathForRow:0 inSection: [self indexForSectionTitle:title] ] ];
            [_timesSectionTitle addObject:@"-"];
        }
        
        firstTime = NO;
        
        NSMutableArray *tempArr = (NSMutableArray*)[self objectForSectionWithTitle:title];
        NSDictionary *tempDict = [tempArr dictionaryOfIndicesandTitlesForKey:key forSection: [NSNumber numberWithLong:[self indexForSectionTitle:title] ] ];
        
        [_timesSectionIndex addObjectsFromArray: [tempDict objectForKey:@"index"] ];
        [_timesSectionTitle addObjectsFromArray: [tempDict objectForKey:@"title"] ];
        
    }
    
    
}

-(void) generateIndexWithKey: (NSString*) key
{
        
    NSMutableArray *tempArr = (NSMutableArray*)[self objectForSection:_lastAccessPath.section];
    
    NSDictionary *tempDict = [tempArr dictionaryOfIndicesandTitlesForKey:key forSection: [NSNumber numberWithLong: _lastAccessPath.section] ];
    
    _timesSectionIndex = [tempDict objectForKey:@"index"];
    _timesSectionTitle = [tempDict objectForKey:@"title"];
    
    
}


-(NSArray*) getSectionTitles
{
    return _timesSectionTitle;
}


-(NSIndexPath*) getIndexPathForIndex:(NSInteger) index
{
    return [_timesSectionIndex objectAtIndex:index];
}


-(NSInteger) getSectionWithIndex:(NSInteger) index
{
    
    id value = [_timesSectionIndex objectAtIndex:index];
    if ( [value isKindOfClass:[NSNumber class] ] )
    {
        return [(NSNumber*)value intValue];
    }
    else if ( [value isKindOfClass:[NSIndexPath class] ] )
    {
        return [(NSIndexPath*)value section];
    }
    
    return 0;
    
//    return [ (NSNumber*) [_timesSectionIndex objectAtIndex:index] intValue];
}


-(NSIndexPath*) accessPath
{
    return _lastAccessPath;
}


#pragma mark - Validation
-(BOOL) isSectionGood:(NSInteger) section
{
    
    if ( section < 0 )
        return NO;
    if ( section >= [_topStore count] )
        return NO;
    else
        return YES;
}

#pragma mark - Setting

-(void) setTag:(NSInteger) tag forSection:(NSInteger) section
{

    if ( ![self isSectionGood:section] )
        return;
    
    TVStoreObject *sObject = [_topStore objectAtIndex:section];
    [sObject setTag: [NSNumber numberWithLong: tag] ];
    
}


-(void) setTag:(NSInteger) tag forTitle:(NSString*) title
{
    
    for (TVStoreObject *sObject in _topStore)
    {
        if ( [sObject.section isEqualToString:title] )
        {
            [sObject setTag: [NSNumber numberWithLong:tag] ];
        }
    }
    
}


#pragma mark - Sorting
-(void) sortByTags
{
    
    if ( [_topStore count] <= 1 )
        return;
    
    [_topStore sortUsingComparator:^NSComparisonResult(TVStoreObject *a, TVStoreObject *b) {
        
        if ([a.tag intValue] < [b.tag intValue])
            return NSOrderedAscending;
        else if ( [a.tag intValue] > [b.tag intValue] )
            return NSOrderedDescending;
        else
            return NSOrderedSame;
        
    }];
    
}



-(void) sortBySectionTitles
{
    
    
    if ( [_topStore count] <= 1 )
        return;
    
    [_topStore sortUsingComparator:^NSComparisonResult(TVStoreObject *a, TVStoreObject *b) {
        
        return [a.section compare: b.section];
        
    }];
    
}


@end
