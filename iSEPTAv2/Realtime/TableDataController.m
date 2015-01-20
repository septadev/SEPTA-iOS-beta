//
//  TableDataController.m
//  iSEPTA
//
//  Created by apessos on 12/22/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "TableDataController.h"

@implementation TableDataController
{
    NSMutableArray *_data;    // Array of arrays, each array is a separate section
    NSMutableArray *_counter; // Holds the size of each array
    NSMutableArray *_names;
    
    bool *_hideSection;  // Array that holds the status of each section
    char _hideSectionSize;
}

@synthesize data = _data;

-(id) init
{
    
    if ( ( self = [super init] ) )
    {
        
        _numberOfSections = 0;
        _data    = [[NSMutableArray alloc] init];
        _counter = [[NSMutableArray alloc] init];
        _names   = [[NSMutableArray alloc] init];

        _hideSectionSize = 5;
        _hideSection = (bool *)malloc(_hideSectionSize * sizeof(bool) );
        for (int LCV = 0; LCV < _hideSectionSize; LCV++)
        {
            _hideSection[LCV] = NO;
        }
        
    }
    
    return self;
    
}

-(void) dealloc
{
    NSLog(@"TDC - dealloc, freeing _hideSection");
    free(_hideSection);
}

// Update the counter in case data as been written directly or indirectly into _data
-(void) updateSection:(int) section
{
    [_counter replaceObjectAtIndex:section withObject: [NSNumber numberWithInt:(int)[[_data objectAtIndex:section] count] ] ];
}

-(void) addNilPlaceholder
{
 
    NSMutableArray *blankArray = [[NSMutableArray alloc] init];
    
//    NSMutableArray *blankArray = [NSMutableArray arrayWithObject:@"emptyArray"];
    [_data addObject: blankArray];
//    [blankArray removeAllObjects];
    
    [_counter addObject:[NSNumber numberWithInt:0] ];
    _numberOfSections++;
}


-(void) hideSection:(int)section
{
    if (_hideSectionSize <= section)  // _hideSectionsSize starts at 1 to X.  section starts at 0 to Y.  Thus <= is needed instead of <
        return;
    
    _hideSection[section] = YES;
}

-(void) unhideSection:(int)section
{
    if ( _hideSectionSize <= section )
        return;
    
    _hideSection[section] = NO;
}

-(void) checkHideSections
{
    
    if ( _hideSectionSize < [_counter count] )
    {
        NSLog(@"TDC - reallocing _hideSection size from %d to %d", _hideSectionSize-2, _hideSectionSize);
        _hideSectionSize += [_counter count] - _hideSectionSize + 2;  // Increase _hideSectionSize by the difference plus 2.  Min increase: 3
        _hideSection = (bool *)realloc(_hideSection, _hideSectionSize * sizeof(bool));
    }
    
}

-(void) addObject:(id) object toSection:(int) section
{
    
//    NSLog(@"TDC - addObject, object: %@, section: %d, data size: %d", object, section, [_data count]);
    if ( _numberOfSections == section )  // When this is true, we need to create a new object
    {
        [_data addObject:object];
        [_counter addObject: [NSNumber numberWithInt:(int)[[_data objectAtIndex:section] count] ] ];
        _numberOfSections++;
        
        [self checkHideSections];
        
    }
    else if ( section > _numberOfSections )
    {
        for ( int LCV = _numberOfSections; LCV < section; LCV++ )
        {
            [_data addObject:[NSMutableArray arrayWithObject:nil] ];
            [_counter addObject:[NSNumber numberWithInt:0] ];
        }
        
        _numberOfSections = (int)[_data count];
        [_data addObject: object];
        [_counter addObject: [NSNumber numberWithInt:(int)[[_data objectAtIndex:section] count] ] ];
        
        [self checkHideSections];
    }
    else
    {
//        [_data addObject: object];
        
//        [self removeObjectsInSection:section];
        
        [[_data objectAtIndex:section] addObject: object];
        [_counter replaceObjectAtIndex:section withObject: [NSNumber numberWithInt:(int)[[_data objectAtIndex:section] count] ] ];
    }
    
    

}


-(void) removeObjectWithIndexPath:(NSIndexPath*) indexPath
{

    NSLog(@"TDC - removeObjectWithIndexPath, s/r: %ld/%ld", (long)indexPath.section, (long)indexPath.row);
    if ( indexPath.section < _numberOfSections )
    {
        if ( indexPath.row < [[_data objectAtIndex: indexPath.section] count] )
        {
            [(NSMutableArray*)[_data objectAtIndex: indexPath.section] removeObjectAtIndex:indexPath.row];
            [_counter replaceObjectAtIndex:indexPath.section withObject: [NSNumber numberWithInt:(int)[[_data objectAtIndex:indexPath.section] count] ] ];
            
//            if ( [[_counter objectAtIndex:indexPath.section] intValue] == 0 )
//            {
//                _numberOfSections--;
//            }
            
        }
        
    }
    
}


-(void) removeObjectsInSection:(int) section
{
    NSLog(@"TDC - removeObjects _data size: %lu, section: %d", (unsigned long)[_data count], section);
    if ( section < [_data count] )
    {
//        [[_data objectAtIndex:section] removeAllObjects];
        [_data    removeObjectAtIndex:section];
        [_counter removeObjectAtIndex:section];
        _numberOfSections--;
    }
    
}


//-(id) returnObjectAtIndexPath:(NSIndexPath*) indexPath
-(id) returnObjectFromSection: (int) section
{
    if ( section > _numberOfSections )
        return nil;

    return [_data objectAtIndex:section];
    
//    if ( indexPath.row > [[_data objectAtIndex:indexPath.section] count] )
//        return nil;
//    
//    return [[_data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}


-(id) returnObjectAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Add a bunch of checks here
    
    return [[_data objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
    
}


-(NSInteger) numberOfSections
{
    return [_data count];
}


-(NSInteger) numberOfRowsInSection:(int) section
{
    // Five sections, [_counter count] returns 5;  And section = 5 cooresponds to _count[4]
    if ( section > [_counter count]-1 )
        return 0;
    
    if ( _hideSection[section] )
        return 0;
    else
        return [[_counter objectAtIndex:section] intValue];
    
}


-(NSString*) nameForSection:(int) section
{
    return [_names objectAtIndex:section];
}


-(void) addName:(NSString*) name toSection: (int) section
{
    
    if ( _numberOfSections == section )  // New section, just add it to array
    {
        [_names addObject:name];
    }
    else if ( section > _numberOfSections ) // Section is past the array count
    {
        for ( int LCV = _numberOfSections; LCV < section; LCV++ )
        {
            [_names addObject:@""];  // Add blank data until sections match
        }
        
        [_names addObject:name];  // Now add the section
        
    }
    else  // Section already exists
    {
        [_names replaceObjectAtIndex:section withObject:name];  // Replace section
    }
    
    
}


-(NSString*) description
{
    
    NSString *info = @"";
    
    for(int LCV = 0; LCV < [_counter count]; LCV++)
    {
//        for (int inLCV = 0; inLCV < [[_counter objectAtIndex:LCV] intValue]; inLCV++ )
//        {
        
        NSString *name = @"<notnamed>";
        if ( LCV < [_names count])
            name = [_names objectAtIndex:LCV];
        
        if ( LCV > 0 )
            name = [NSString stringWithFormat:@", %@", name];
        
        info = [info stringByAppendingFormat:@"%@: %d", name, [[_counter objectAtIndex:LCV] intValue] ];
        
//        }
    }

    return info;
    
}


@end
