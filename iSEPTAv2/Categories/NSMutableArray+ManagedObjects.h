//
//  NSMutableArray+ManagedObjects.h
//  iSEPTA
//
//  Created by septa on 11/13/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (ManagedObjects)

-(BOOL) containsObject:(id) object withKeys: (NSArray*) keys;
-(NSInteger) indexOfObject:(id) object withKeys: (NSArray*) keys;

@end

@interface NSMutableArray (ManagedObjects)

-(BOOL) containsObject:(id) object withKeys: (NSArray*) keys;
-(NSInteger) indexOfObject:(id) object withKeys: (NSArray*) keys;

@end
