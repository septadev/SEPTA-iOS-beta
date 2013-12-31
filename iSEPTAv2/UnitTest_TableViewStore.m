//
//  UnitTest_TableViewStore.m
//  iSEPTA
//
//  Created by septa on 6/28/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "UnitTest_TableViewStore.h"

#import "TableViewStore.h"

@implementation UnitTest_TableViewStore
{
    TableViewStore *dataStore;
}


-(id) init
{
    
    if ( ( self = [super init] ) )
    {
        
    }
    
    return self;
    
}


-(void) setup
{
    dataStore = [[TableViewStore alloc] init];
}


-(void) run
{
    
    // --
    // -- Basic Test:  Add a few objects to the first section
    // --
    
    // Add value
    [dataStore addObject:@"This"];
    [dataStore addObject:@"Is"];
    [dataStore addObject:@"A"];
    [dataStore addObject:@"Mess"];
    
    NSInteger section = 0;
    for (NSString *sectionNames in [dataStore returnAllSections] )
    {
        NSLog(@"Sections: %@", sectionNames);
        for (int LCV = 0; LCV < [dataStore numOfRowsForSection:section]; LCV++ )
        {
            NSLog(@"%d - %@", LCV, [dataStore objectForIndexPath:[NSIndexPath indexPathForRow:LCV inSection:section] ] );
        }
        section++;
    }

    NSAssert([(NSString*)[dataStore objectForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ] isEqualToString:@"This"], @"dataStore : Could not find 'This'");
    NSAssert([(NSString*)[dataStore objectForIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] ] isEqualToString:@"Is"]  , @"dataStore : Could not find 'Is'");
    NSAssert([(NSString*)[dataStore objectForIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] ] isEqualToString:@"A"]   , @"dataStore : Could not find 'A'");
    NSAssert([(NSString*)[dataStore objectForIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] ] isEqualToString:@"Mess"], @"dataStore : Could not find 'Mess'");


    // --
    // --  Now clear all objects
    // --
    
    [dataStore removeAllObjects];
    
    
    // Verify that the object is empty
    NSAssert([(NSArray*)[dataStore returnAllSections] count] == 0, @"dataStore: Is Not Empty");  // This is a horrible idea as it uses a dictionary to build the NSArray and you're never guaranteed the elements will be ordered in any particular order.  Since there is only one section, this is fine.
    NSAssert([dataStore numOfSections]         == 0, @"dataStore: Is Not Empty");
    NSAssert([dataStore numOfRowsForSection:0] == 0, @"dataStore: Is Not Empty");
    NSAssert([dataStore lastSection]           == 0, @"dataStore: Is Not Empty");
    NSAssert([dataStore lastRow]               == 0, @"dataStore: Is Not Empty");
    
    
    // --
    // --  Add object without section title, then add a new object with a different section title
    // --
    
    [dataStore addObject:@"Goodbye"];                        // Creates new section with the default section name, "Generic Section 0"
    [dataStore addObject:@"Hello" forTitle:@"New Section"];  // As section does not exist, it will be created then the object will be added

    // Verify that there are two sections
    NSAssert([(NSArray*)[dataStore returnAllSections] count] == 2, @"dataStore: There should be two sections");
    
    NSArray *testArr = [dataStore returnAllSections];
    NSAssert([testArr containsObject:@"New Section"], @"dataStore: Section Name Mismatch");
    
    //NSAssert([[(NSArray*)[dataStore returnAllSections] objectAtIndex:1] isEqualToString:@"New Section"], @"dataStore: Section Name Mismatch");
    
    // Now add a two new objects.
    [dataStore addObject:@"Later" forSection:0];
    [dataStore addObject:@"Hi" forSection:1];
    [dataStore addObject:@"Hey there" forTitle:@"New Section"];
    
    // Verify that the data was written into the correct places
    NSAssert([dataStore numOfSections] == 2, @"dataStore: numOfSections is wrong");
    NSAssert([dataStore numOfRowsForSection:0] == 2, @"dataStore: numOfRowsForSection0 is wrong");
    NSAssert([dataStore numOfRowsForSection:1] == 3, @"dataStore: numOfRowsForSection1 is wrong");
    
    
    // Verify that the lastSection and lastRow are in the proper places
    NSAssert([dataStore lastSection] == 1, @"dataStore: lastSection is incorrect");
    NSAssert([dataStore lastRow] == 2, @"dataStore: lastRow is incorrect");
    
    [dataStore addObject:@"Take care" forSection:0];
    
    NSAssert([dataStore lastSection] == 0, @"dataStore: lastSection is incorrect");
    NSAssert([dataStore lastRow] == 2, @"dataStore: lastRow is incorrect");

    
    // --
    // --  Now clear all objects (again)
    // --

    [dataStore clearSectionWithTitle:@"New Section"];
    NSAssert([dataStore numOfSections] == 2, @"dataStore: numOfSections is incorrect");
    NSAssert([dataStore numOfRowsForSection:1] == 0, @"dataStore: numOfRowsForSection:1 is incorrect");
    
    [dataStore addObject:@"Hasta La Vista" forTitle:@"New Section"];
    NSAssert([dataStore numOfRowsForSection:[dataStore indexForSectionTitle:@"New Section"] ] == 1, @"dataStore: numOfRowsForSection:1 is incorrect");
    
    [dataStore removeAllObjects];
    
    
    // Verify that the object is empty
    NSAssert([(NSArray*)[dataStore returnAllSections] count] == 0, @"dataStore: Is Not Empty");  // This is a horrible idea as it uses a dictionary to build the NSArray and you're never guaranteed the elements will be ordered in any particular order.  Since there is only one section, this is fine.
    NSAssert([dataStore numOfSections] == 0, @"dataStore: Is Not Empty");
    NSAssert([dataStore numOfRowsForSection:0] == 0, @"dataStore: Is Not Empty");
    NSAssert([dataStore lastSection] == 0, @"dataStore: Is Not Empty");
    NSAssert([dataStore lastRow] == 0, @"dataStore: Is Not Empty");
 
    
    [dataStore addSectionWithTitle:@"First!"];
    [dataStore addSection];
    [dataStore addSection];
    [dataStore addSectionWithTitle:@"Fourth!"];
    
    
    // TODO: Check numOfSections, numOfRowsForSection, lastSection, lastRow
    
    
    // Method 1 for getting section names
    NSAssert([[dataStore titleForSection:0] isEqualToString: @"First!"], @"dataStore: wrong title returned");
    NSAssert([[dataStore titleForSection:1] isEqualToString: @"Generic Section 1"], @"dataStore: wrong title returned");
    NSAssert([[dataStore titleForSection:2] isEqualToString: @"Generic Section 2"], @"dataStore: wrong title returned");
    NSAssert([[dataStore titleForSection:3] isEqualToString: @"Fourth!"], @"dataStore: wrong title returned");
    
    NSAssert([dataStore numOfSections] == 4, @"dataStore: numOfSections should be 4");
    
    // Method 2 for getting section names
    testArr = [dataStore returnAllSections];
    NSAssert([testArr containsObject:@"First!"], @"dataStore: Section Name Mismatch");
    NSAssert([testArr containsObject:@"Generic Section 1"], @"dataStore: Section Name Mismatch");
    NSAssert([testArr containsObject:@"Generic Section 2"], @"dataStore: Section Name Mismatch");
    NSAssert([testArr containsObject:@"Fourth!"], @"dataStore: Section Name Mismatch");
    
    
    NSAssert([dataStore indexForSectionTitle:@"First!"] == 0, @"dataStore: Index does not match section title");
    NSAssert([dataStore indexForSectionTitle:@"Generic Section 1"] == 1, @"dataStore: Index does not match section title");
    NSAssert([dataStore indexForSectionTitle:@"Generic Section 2"] == 2, @"dataStore: Index does not match section title");
    NSAssert([dataStore indexForSectionTitle:@"Fourth!"] == 3, @"dataStore: Index does not match section title");
    
    // --
    // --  Now let's remove the middle two Generic objects!
    // --
    
    [dataStore removeSection:1];  // <--  Oh, this is dangerous, be careful
    NSAssert([dataStore numOfSections] == 3, @"dataStore: numOfSections should be 3!");

    testArr = [dataStore returnAllSections];
    NSAssert(![testArr containsObject:@"Generic Section 1"], @"dataStore: Section Name Mismatch");
    
    [dataStore removeSectionWithTitle:@"Generic Section 2"];
    testArr = [dataStore returnAllSections];
    NSAssert(![testArr containsObject:@"Generic Section 2"], @"dataStore: Section Name Mismatch");
    
    
    // --
    // --  Clear all the objects again
    // --
    [dataStore removeAllObjects];
    
    
    [dataStore addObject:@"Goodbye"];                        // Creates new section with the default section name, "Generic Section 0"
    [dataStore addObject:@"Hello" forTitle:@"New Section"];  // As section does not exist, it will be created then the object will be added
    
    // Now add a two new objects.
    [dataStore addObject:@"Later" forSection:0];
    [dataStore addObject:@"Hi" forSection:1];
    [dataStore addObject:@"Hey there" forTitle:@"New Section"];

    [dataStore addObject:@"Take care" forSection:0];
    
    NSAssert([(NSString*)[dataStore objectForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ] isEqualToString:@"Goodbye"], @"dataStore : Could not find 'Goodbye'");
    NSAssert([(NSString*)[dataStore objectForIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] ] isEqualToString:@"Hello"], @"dataStore : Could not find 'Hello'");
    
    
//    NSArray *sectionArr; // = [dataStore objectForSection:0];
    // TODO: Being lazy, add NSAssert section here
    
//    NSArray *newArr = [dataStore objectForSectionWithTitle:@"New Section"];
    // TODO: Being lazy, add NSAssert section here
    // TODO: Check numOfSections, numOfRowsForSection, lastSection, lastRow
    
    
    // Change the name of the Generic section
//    BOOL success = [dataStore modifySectionTitle:@"Old Section" forSectionIndex:0];
//    NSAssert(success, @"dataStore: Was able to modify section title");
    
    testArr = [dataStore returnAllSections];
    NSAssert(![testArr containsObject:@"Generic Section 0"], @"dataStore: Section Name Mismatch");
    NSAssert([testArr containsObject:@"Old Section"], @"dataStore: Section Name Mismatch");
    
    [dataStore removeObjectWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] ];
//    sectionArr = [dataStore objectForSection:0];  // Should be one row lighter
    
    [dataStore removeAllObjects];


    [dataStore addObject:@"Route 33" forTitle:@"33"];
    [dataStore addObject:@"Route 17" forTitle:@"17"];
    [dataStore addObject:@"Route MFO" forTitle:@"MFO"];
    
    [dataStore sortBySectionTitles];
    
    NSAssert([[dataStore titleForSection:0] isEqualToString:@"17"], @"dataStore: 17 is not the first section title");
    
    [dataStore removeAllObjects];
    
    [dataStore addObject:@"Itinerary" forTitle:@"Itinerary" withTag:1];
    [dataStore addObject:@"Data"      forTitle:@"Data"      withTag:10];
    [dataStore addObject:@"Recent"    forTitle:@"Recent"    withTag:5];
    
    NSAssert([[dataStore titleForSection:0] isEqualToString:@"Itinerary"], @"dataStore: Itinerary is not the first section title");
    NSAssert([[dataStore titleForSection:1] isEqualToString:@"Data"]     , @"dataStore: Itinerary is not the second section title");
    NSAssert([[dataStore titleForSection:2] isEqualToString:@"Recent"]   , @"dataStore: Itinerary is not the third section title");
    
    [dataStore sortByTags];

    NSAssert([[dataStore titleForSection:0] isEqualToString:@"Itinerary"], @"dataStore: Itinerary is not the first section title");
    NSAssert([[dataStore titleForSection:1] isEqualToString:@"Recent"]   , @"dataStore: Itinerary is not the third section title");
    NSAssert([[dataStore titleForSection:2] isEqualToString:@"Data"]     , @"dataStore: Itinerary is not the second section title");

    [dataStore addObject:@"Favorites" forTitle:@"Favorites" withTag:2];
    [dataStore sortByTags];
    
    NSAssert([[dataStore titleForSection:0] isEqualToString:@"Itinerary"], @"dataStore: Itinerary is not the first section title");
    NSAssert([[dataStore titleForSection:1] isEqualToString:@"Favorites"], @"dataStore: Itinerary is not the third section title");
    NSAssert([[dataStore titleForSection:2] isEqualToString:@"Recent"]   , @"dataStore: Itinerary is not the second section title");
    NSAssert([[dataStore titleForSection:3] isEqualToString:@"Data"]     , @"dataStore: Itinerary is not the second section title");
    
    [dataStore removeAllObjects];
    
    NSLog(@"Test has finished! Yay!");
    
}


-(void) cleanup
{
    dataStore = nil;
}


@end
