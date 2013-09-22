//
//  TableViewStore.m
//  iSEPTA
//
//  Created by septa on 6/28/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TableViewStore.h"

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
// Adding data to store
-(void) addObject:(id) object
{
    [self addObject:object forSection:_lastAccessPath.section];
}


//-(void) addObject:(id) object forIndexPath:(NSIndexPath*) indexPath
-(void) addObject:(id) object forSection:(int) section
{
    
    // section = 0
    // [_topStore count] always starts at 1
    // But would get accessed as [_topStore objectAtIndex:0]
    
    
    // _topStore structure
    
    // _topStore
    //   * 1st Section (section 0, count 1)
    //   * 2nd Section (section 1, count 2)
    //   * 3rd Section (section 2, count 3)
    
    if ( section < 0 )  // Consider any negative number to mean the last section of _topStore
    {
        section = [_topStore count] - 1;
    }
    
    
    if ( [_topStore count] > section )
    {
        // If the number of elements in _topStore is larger than the section the user is trying to write
    }
    else if ( [_topStore count] == section )
    {
        // A section was requested that doesn't exist.  As only adding one section would meet this request, create it then add the object to the new section
        [self addSection];
    }
    else
    {
        // More than one section would need to be created to accomodate this request.  Was the section entered wrong?
        return;
    }

    [[_topStore objectAtIndex:section] addObject:object];
    _lastAccessPath = [NSIndexPath indexPathForRow:[[_topStore objectAtIndex:section] count]-1 inSection:section];
    
    
}


-(void) addObject:(id) object forTitle:(NSString*) title
{
    
    NSNumber *secNum = [_sectionTracker objectForKey:title];
    if ( secNum == nil )
    {
        // If section does not exist in the _sectionTracker, add it
        [self addSectionWithTitle:title];
        secNum = [_sectionTracker objectForKey:title];
    }
    
    NSInteger section = [secNum intValue];

    [self addObject:object forSection:section];
    
}


-(void) addSection
{
    
    int section = [_topStore count];
    [self addSectionWithTitle:[NSString stringWithFormat:@"Generic Section %d", section] ];
    
}

-(void) addSectionWithTitle:(NSString*) title
{

    // Check if title already exists
    if ( [_sectionTracker objectForKey:title] != nil)
        return;
    
    // Create a new NSMutableArray and add it to the section
    [_topStore addObject:[[NSMutableArray alloc] init] ];
    
    int section = [_topStore count] - 1;
    
    // Update the _sectionTracker
//    [_sectionTracker setValue:[_topStore objectAtIndex:section] forKey:title ];
    [_sectionTracker setValue:[NSNumber numberWithInt:section] forKey:title ];
    
    
    // Change _lastAccessPath
    _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection: section];

    
}


// --==
// --==  Arrays
// --==

-(void) addArray:(NSArray*) array
{
    [self addArray:array forSection:_lastAccessPath.section];
}

-(void) addArray:(NSArray*) array forSection:(int) section
{

    for (NSArray *object in array)
    {
        [self addObject:array forSection:section];
    }
    
}

-(void) addArray:(NSArray*) array forTitle:(NSString*) title
{
    NSNumber *sectionNum = [_sectionTracker objectForKey: title];
    if ( sectionNum == nil )
        return;
    else
        [self addArray:array forSection: [sectionNum intValue] ];
}



-(void) replaceArrayWith:(NSArray*) array
{
    [self replaceArrayWith:array forSection:_lastAccessPath.section];
}


-(void) replaceArrayWith:(NSArray*) array forSection:(int) section
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
    
    
    [_topStore replaceObjectAtIndex:section withObject: array];
    
}


-(void) replaceArrayWith:(NSArray*) array forTitle:(NSString*) title
{

    // Check if object is nil before attempting to make any modifications to internal data store
    if ( array == nil | [array count] == 0 )
        return;

    
    NSNumber *sectionNum = [_sectionTracker objectForKey: title];
    if ( sectionNum == nil )  // If section doesn't exist, create it!
    {
        [self addSectionWithTitle:title];
        sectionNum = [_sectionTracker objectForKey: title];
    }
    
    [self replaceArrayWith:array forSection:[sectionNum intValue] ];
    
}






// Modify store title
#pragma mark - Modify Existing Section Title
-(BOOL) modifySectionTitle:(NSString*) newTitle forSectionIndex:(int) sectionIndex
{

    // First check that the key exists
    if ( [_sectionTracker objectForKey:newTitle] != nil )
        return NO;
    
    
    // Since the key doesn't exist, let's find the old key that points to the sectionIndex
    for (NSString *key in _sectionTracker)  // Loop through all keys
    {
        
        if ( [[_sectionTracker objectForKey:key] intValue] == sectionIndex )
        {
            [_sectionTracker removeObjectForKey:key];
            [_sectionTracker setValue: [NSNumber numberWithInt:sectionIndex] forKey:newTitle];
            return YES;
        }
        
        
//        if ( [_sectionTracker objectForKey:key] == [_topStore objectAtIndex:sectionIndex] )
//        {
//            [_sectionTracker removeObjectForKey:key];
//            [_sectionTracker setValue:[_topStore objectAtIndex:sectionIndex] forKey:@"newTitle"];
//            return YES;
//        }
    
    }
    
    return NO;
}



#pragma mark - Removing Objects From DataStore
// Remove data from store
-(void) removeAllObjects
{
    [_topStore removeAllObjects];
    [_sectionTracker removeAllObjects];
    
    _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
}


-(void) removeObject:(id) object fromSection:(int) section
{
    [[_topStore objectAtIndex:section] removeObject: object];
}

-(void) removeObjectWithIndexPath:(NSIndexPath*) indexPath
{
    // TODO: Perform some sane check that this is valid
    
    [[_topStore objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
}


-(void) removeSection:(int) section
{
    
    // How to properly remove a section:
    //   Let _sectionTracker be: "Itinerary" => 0, "Favorites" => 1, "Recent" => 2, "Data" => 3
    //   If we remove "Favorites", _sectionTracker will look like this:
    //   Let _sectionTracker be: "Itinerary" => 0, "Recent" => 2, "Data" => 3
    
    // It needs to be reorder!
    
    
//    NSString *keyToRemove;
    NSMutableDictionary *newTracker = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in _sectionTracker)
    {

        int val = [[_sectionTracker objectForKey:key] intValue];
        
        if ( val < section )
        {
            // No changes here
            [newTracker setValue:[_sectionTracker objectForKey:key] forKey:key];
        }
        else if ( val == section)
        {
//            keyToRemove = key;
            // Since we're removing this, we won't add this to newTracker
        }
        else  // All that's left are values greather than section
        {
            [newTracker setValue:[NSNumber numberWithInt:val-1] forKey:key];
        }
        
    }
    
//    [_sectionTracker removeObjectForKey:keyToRemove];
    _sectionTracker = newTracker;
    
    [[_topStore objectAtIndex:section] removeAllObjects];  // Remove all the objects in the NSArray at _topStore[section]
    [_topStore removeObjectAtIndex:section];               // Now remove _topStore[section]
    
    if ( _lastAccessPath.section == section )
        _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    
}


-(void) clearSectionWithTitle:(NSString*) title
{
    
    if ( [_sectionTracker objectForKey:title] == nil )  // Title is bad, just return
        return;
    
    // Since the title exists, get the section index and then remove it
    int section = [[_sectionTracker objectForKey:title] intValue];
    [ [_topStore objectAtIndex:section] removeAllObjects];
    
    _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:section];
    
}


-(void) removeSectionWithTitle:(NSString*) title
{
//    NSMutableArray *ref = [_sectionTracker objectForKey:title];
//    int section = [_topStore indexOfObject:ref];
    if ( [_sectionTracker objectForKey:title] == nil )  // Title is bad, just return
        return;

    int section = [[_sectionTracker objectForKey:title] intValue];
    [self removeSection: section];
    
//    if ( _lastAccessPath.section == section )
//        _lastAccessPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        
//    [_topStore removeObjectAtIndex:section];
//    
//    [_sectionTracker removeObjectForKey: title];
}



#pragma mark - Retrieve Objects in DataStore
// Access data in store
-(id) objectForIndexPath:(NSIndexPath*) indexPath
{
    return [[_topStore objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

-(id) objectForSectionWithTitle:(NSString*) title
{
    
    if ( [_sectionTracker objectForKey:title] == nil )
        return nil;
    
    
    return [_topStore objectAtIndex: [(NSNumber*)[_sectionTracker objectForKey:title] intValue] ];
//    return [_sectionTracker objectForKey:title];
}

-(id) objectForSection:(NSInteger) sectionIndex
{
    if ( [_topStore count] > sectionIndex )
        return [_topStore objectAtIndex:sectionIndex];
    else
        return nil;
}


-(NSString*) titleForSection:(NSInteger) sectionIndex
{

    // Since _sectionTracker contains just the index for a particular object, cycle through all entries until
    //   the sectionIndex value is found, then return the key associated with that value.
    // E.g.
    //   _sectionTracker
    //   [0] => "Favorites"
    //   [1] => "Data"
    //   [2] => "Recent"
    
    // What is the title for sectionIndex 2?  (Recent, obviously)
    
    for (NSString *key in _sectionTracker)
    {
        if ( [ [_sectionTracker objectForKey:key] integerValue] == sectionIndex )
        {
            return key;
        }
        
    }

    // If we've reached this point, sectionIndex doesn't exist so return nothing
    return nil;

}


-(NSInteger) indexForSectionTitle:(NSString*) title
{
    
    id index = [_sectionTracker objectForKey:title];
    if ( index == nil )
    {
        return -1;  // If section title doesn't exist, return a negative valie
    }
    else
        return [(NSNumber*) index intValue];
    
}


#pragma mark - Properties of DataStore
// Access properties of store
-(NSInteger) numOfSections
{
    return [_topStore count];
}

-(NSInteger) numOfRowsForSection: (int) section
{
    if ( section >= [_topStore count] )
        return 0;
    
    return [[_topStore objectAtIndex:section] count];
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
    
    [newTracker setValue:[NSNumber numberWithInt:afterIndex+1] forKey:fromKey];

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


-(NSArray*) returnAllSections
{
    NSMutableArray *listArr = [[NSMutableArray alloc] init];
    for (NSString *keys in _sectionTracker)
    {
//        NSLog(@"TVS:rAS - key: %@", keys);
        [listArr addObject:keys];
    }
    return listArr;
}


-(NSString*) description
{
    
    NSMutableString *outputStr = [[NSMutableString alloc] init];
    
//    NSLog(@"# of elements in topStore: %d", [_topStore count]);
//    NSLog(@"Last Path (s/r): %d/%d", _lastAccessPath.section, _lastAccessPath.row);
    
    for (int LCV = 0; LCV < [_topStore count]; LCV++)
    {
//        NSLog(@"Data in index %d: %@", LCV, [_topStore objectAtIndex:LCV]);
        [outputStr appendFormat:@"Data in index %d (%@): %@\n", LCV, [self titleForSection:LCV], [_topStore objectAtIndex:LCV] ];
    }

    [outputStr appendFormat:@"\n With sections:\n"];
    for (NSString *key in _sectionTracker)
    {
        [outputStr appendFormat:@"\t%@\n", key];
    }
    
    [outputStr appendFormat:@"\n# of elements in topStore: %d\n", [_topStore count] ];
    [outputStr appendFormat:@"Last Path (s/r): %d/%d\n\n", _lastAccessPath.section, _lastAccessPath.row];
    
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
        NSDictionary *tempDict = [tempArr dictionaryOfIndicesandTitlesForKey:key forSection: [NSNumber numberWithInt:[self indexForSectionTitle:title] ] ];
        
        [_timesSectionIndex addObjectsFromArray: [tempDict objectForKey:@"index"] ];
        [_timesSectionTitle addObjectsFromArray: [tempDict objectForKey:@"title"] ];
        
    }
    
    
}

-(void) generateIndexWithKey: (NSString*) key
{
        
    NSMutableArray *tempArr = (NSMutableArray*)[self objectForSection:_lastAccessPath.section];
    
    NSDictionary *tempDict = [tempArr dictionaryOfIndicesandTitlesForKey:key forSection: [NSNumber numberWithInt: _lastAccessPath.section] ];
    
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


#pragma mark - Sorting
-(void) sortBySectionTitles
{
    
    // Data store structure:
    //   _topStore -- NSMutableArray that contains all the data
    //   _sectionTracker -- quick lookup for the data store, if _topStore is being reorganized, _sectionTracker needs to be updated as well
    
    if ( [_topStore count] <= 1 )  // If there's only one item in the array, its already ordered properly
        return;
    
    NSMutableArray *newTopStore = [[NSMutableArray alloc] init];
    NSMutableDictionary *newSectionTracker = [[NSMutableDictionary alloc] init];
    

    NSArray *allKeys = [_sectionTracker allKeys];
    NSArray *sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *a, NSString *b)
           {
               return [a compare:b options:NSNumericSearch];
           }];
    
//    NSArray *sortedKeys = [_sectionTracker keysSortedByValueUsingComparator:^NSComparisonResult(NSString *a, NSString *b)
//    {
//        return [a compare:b];
//    }];
    
    int count = 0;
    for (NSString *key in sortedKeys)
    {
        NSNumber *index = [_sectionTracker objectForKey: key];
        [newTopStore addObject: [_topStore objectAtIndex:[index intValue] ] ];
        [newSectionTracker setObject: [NSNumber numberWithInt:count++] forKey:key];
    }
 
    _topStore = newTopStore;
    _sectionTracker = newSectionTracker;
    
    //    [_tableData sortUsingComparator:^NSComparisonResult(BusScheduleData *a, BusScheduleData *b)
    //     {
    //         return [[a Route] compare:[b Route] ];  // Was dateTime
    //     }];

    
}


@end
