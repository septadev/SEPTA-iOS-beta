//
//  NSDictionary+ObjectKeyNil.m
//  iSEPTA
//
//  Created by septa on 3/10/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

#import "NSDictionary+ObjectKeyNil.h"

@implementation NSDictionary (ObjectKeyNil)

// Taken from here: http://stackoverflow.com/questions/16668263/checking-a-null-value-from-json-response-in-objective-c
- (id)objectForKeyOrNil:(id)key
{

    id val = [self objectForKey:key];
    if ([val isEqual:[NSNull null]] || val==nil)
    {
        return nil;
    }
    
    return val;
}

@end
