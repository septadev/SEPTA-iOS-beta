//
//  NSArray+Indices.m
//  iSEPTA
//
//  Created by apessos on 3/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NSArray+Indices.h"

@implementation NSArray (Indices)

-(NSDictionary*) dictionaryOfIndicesandTitlesForKey:(NSString *)titleKey
{
    
//    NSDictionary *selfDict = [data   dictionaryWithValuesForKeys: keys];

    // gga, 01/05/15, apparently this little loop did nothing.  Perhaps the loop was a precursor to some functionality I wanted to add once upon a time
//    for (id object in self)
//    {
////        NSLog(@"Found %@ (%@) and %@ (%@)", [self valueForKey:indexKey], indexKey, [self valueForKey:titleKey], titleKey);
//        NSLog(@"Found %@ from key %@", [self valueForKey:titleKey], titleKey);
//        // gga - was [self valueForKey:titleKey], titleKey]; replaced self with object
//    }
    
    return nil;
    
}


// Doesn't work.  Probably a stupid idea to start with... ;_;

//-(NSArray*) sortByKey:(NSString *)key
//{
//    
//    return [self sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
//        
//        id aValue = [a valueForKey:key];
//        id bValue = [b valueForKey:key];
//        
//        if ( aValue < bValue )
//        {
//            return (NSComparisonResult)NSOrderedAscending;
//        }
//        else if ( aValue > bValue )
//        {
//            return (NSComparisonResult)NSOrderedDescending;
//        }
//     
//     return (NSComparisonResult) NSOrderedSame;
//        
//    }];
//    
//}

@end
