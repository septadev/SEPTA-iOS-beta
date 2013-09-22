//
//  SaveController.m
//  iSEPTA
//
//  Created by septa on 1/15/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "SaveController.h"
@interface SaveController ()

    // Private methods

@end


@implementation SaveController
{
    // Private variables
    id _object;
    NSString *objectKey;
//    id originalObject;
    BOOL _isDirty;
}

//@synthesize object = _object;

-(id) initWithKey:(NSString*) key  // @"NextToArrive:Saves" or (this might work) @"NextToArrive:Saves.Favorites"
{
    if ( ( self = [super init] ) )
    {
        // Load data from NSUserDefaults with key "key"
        
        _object = [[NSUserDefaults standardUserDefaults] objectForKey: key];
        objectKey = key;
        _isDirty = NO;
    }
    
    return self;
}

-(void) save
{
    
    NSLog(@"SC - save: _object: %p", _object);
    
    if ( _object == nil )
        return;
    
    
    if ( _isDirty )
    {
        
        NSLog(@"SC - _isDirty!");
        // Save
        
        if ( _object == nil )
        {
            NSLog(@"We do have a problem");
            return;
        }
        
        if ( [_object respondsToSelector:@selector(encodeWithCoder:)] )
        {  // _object needs to have implemented encodeWithCoder to work properly.  All NSArrays, NSDictionaries, etc. support <NSCoding>
            
            NSData *objectData = [NSKeyedArchiver archivedDataWithRootObject:_object];
            [[NSUserDefaults standardUserDefaults] setObject:objectData forKey: objectKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
    }
    else
    {
//        NSLog(@"SC - Object hasn't changed.  No save occurred.");
    }
    
    NSLog(@"SC - save: finished");
    
}

-(void) clear
{
    if ( _object == nil )
        return;
    
    _isDirty = YES;  // This isn't always strictly true

    NSLog(@"SC - clear: _object: %p", _object);

    if ( [_object respondsToSelector:@selector(removeAllObjects)] )
    {
        [_object removeAllObjects];
    }
    
}

-(void) setObject:(id)newObject
{
    
    if ( self.object != newObject )
    {
        NSLog(@"SC - setting newObject to self.object");
        _object = newObject;
        _isDirty = YES;
    }
    
}

-(id) object
{
    return _object;
}



@end
