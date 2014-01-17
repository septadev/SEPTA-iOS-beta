//
//  UpdateStateMachineObject.m
//  iSEPTA
//
//  Created by septa on 1/17/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "UpdateStateMachineObject.h"

@implementation UpdateStateMachineObject

@synthesize effective_date;
@synthesize saved_state;
@synthesize md5;

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:effective_date forKey:@"effective_date"];
    [aCoder encodeObject:saved_state    forKey:@"saved_state"];
    [aCoder encodeObject:md5            forKey:@"md5"];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    NSString *date   = [aDecoder decodeObjectForKey:@"effective_date"];
    NSNumber *state  = [aDecoder decodeObjectForKey:@"saved_state"   ];
    NSString *theMD5 = [aDecoder decodeObjectForKey:@"md5"           ];
    
    return [self initWithEffectiveDate:date md5: theMD5 andSavedState:state];
    
}

-(id) initWithEffectiveDate: (NSString*) date md5:(NSString*) theMD5 andSavedState:(NSNumber *) state
{
    
    if ( ( self = [super init] ) )
    {
        self.effective_date = date;
        self.saved_state    = state;
        self.md5            = theMD5;
    }
    
    return self;
    
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"md5: %@, saved_state: %d, effective_data: %@", self.md5, [self.saved_state intValue], self.effective_date];
}

@end
