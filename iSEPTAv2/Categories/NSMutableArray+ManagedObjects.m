//
//  NSMutableArray+ManagedObjects.m
//  iSEPTA
//
//  Created by septa on 11/13/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "NSMutableArray+ManagedObjects.h"

@implementation NSArray (ManagedObjects)


-(BOOL) containsObject:(id)object withKeys:(NSArray *)keys
{
    
    for (id data in self)
    {
        
//        if ( [object isKindOfClass:[data class] ] )
//        {
        NSDictionary *selfDict = [data dictionaryWithValuesForKeys  :keys ];
        NSDictionary *newDict  = [object dictionaryWithValuesForKeys:keys ];
        
        if ( [selfDict isEqual: newDict] )
        {
            return YES;
        }
//        }
        
    }
    
    return NO;
}

-(NSInteger) indexOfObject:(id)object withKeys:(NSArray *)keys
{
    
    NSInteger index = 0;
    for (id data in self)
    {
        NSDictionary *selfDict = [data   dictionaryWithValuesForKeys: keys];
        NSDictionary *newDict  = [object dictionaryWithValuesForKeys: keys];
        
        if ( [selfDict isEqualToDictionary: newDict] )
        {
            return index;
        }
        index++;
    }
    
    return NSNotFound;
    
}


@end

@implementation NSMutableArray (ManagedObjects)

-(BOOL) containsObject:(id) object withKeys: (NSArray*) keys
{

    for (id data in self)
    {
    
//        if ( [object isKindOfClass:[data class] ] )
//        {
        NSDictionary *selfDict = [data dictionaryWithValuesForKeys  :keys ];
        NSDictionary *newDict  = [object dictionaryWithValuesForKeys:keys ];
        
        if ( [selfDict isEqual: newDict] )
        {
            return YES;
            }
//        }
        
    }

    
    return NO;
}

-(NSInteger) indexOfObject:(id)object withKeys:(NSArray *)keys
{
    
    NSInteger index = 0;
    for (id data in self)
    {
        NSDictionary *selfDict = [data   dictionaryWithValuesForKeys: keys];
        NSDictionary *newDict  = [object dictionaryWithValuesForKeys: keys];
        
        if ( [selfDict isEqualToDictionary: newDict] )
        {
            return index;
        }
        index++;
    }
    
    return NSNotFound;
    
}


@end
