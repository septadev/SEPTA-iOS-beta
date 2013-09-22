//
//  NSMutableArray+Indices.m
//  iSEPTA
//
//  Created by apessos on 3/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "NSMutableArray+Indices.h"

@implementation NSMutableArray (Indices)

-(NSDictionary*) dictionaryOfIndicesandTitlesForKey:(NSString *)titleKey forSection:(NSNumber*) section
{
    
    NSString *lastChar = @"";
    NSString *newChar;
    NSInteger index = 0;
    NSInteger len = 1;
    
    id value;
    NSMutableArray *sectionTitle = [[NSMutableArray alloc] init];
    NSMutableArray *sectionIndex = [[NSMutableArray alloc] init];
    BOOL useSection;
    
    if ( section == NULL )
        useSection = NO;
    else
        useSection = YES;
    
    
    for (id object in self)
    {
        //        NSLog(@"Found %@ from key %@", [object valueForKey:titleKey], titleKey);
        
        value = [object valueForKey:titleKey];
        if ( ![value isKindOfClass:[NSString class] ] )
            break;
        
        len = 1;
        while ( ( [[value substringToIndex:len] intValue] ) && ( len < [value length] ) )
        {
            
            int newNum = [[value substringToIndex:len] intValue];
            
            if ( newNum == [[value substringToIndex:len+1] intValue] )
            {
                break;
            }
            len++;
            
        }
        
        newChar = [value substringToIndex:len];
        
        if ( ![newChar isEqualToString:lastChar] )
        {
            [sectionTitle addObject: newChar];
            
            if ( useSection == NO )
                [sectionIndex addObject: [NSNumber numberWithInt:index] ];
            else
                [sectionIndex addObject: [NSIndexPath indexPathForRow:index inSection:[section intValue] ] ];
            
            // NSLog(@"STM - title: %@, index: %d", newChar, index);
            
            lastChar = newChar;
        }
        index++;
        
    }  // for (id object in self)
    
    
    return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:sectionIndex, sectionTitle, nil] forKeys:[NSArray arrayWithObjects:@"index",@"title", nil] ];

}

-(NSDictionary*) dictionaryOfIndicesandTitlesForKey:(NSString *)titleKey
{
    
    return [self dictionaryOfIndicesandTitlesForKey:titleKey forSection:NULL];
    
}



// Well, this doesn't friggin' work.


//-(void) sortByKey:(NSString *)key
//{
//    
//    NSMutableArray *copy = [self mutableCopy];
//    
//    [copy sortUsingComparator:^NSComparisonResult(id a, id b) {
//
//        int aValue = [(NSNumber*)[a valueForKey:key] intValue];
//        int bValue = [(NSNumber*)[b valueForKey:key] intValue];
//        
////        return [aValue compare:bValue options:NSNumericSearch];
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
//        return (NSComparisonResult) NSOrderedSame;
//        
//    }];
//    
//    
//    NSLog(@"%@", copy);
//    
//}

@end
