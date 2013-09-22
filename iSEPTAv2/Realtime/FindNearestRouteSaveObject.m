//
//  FindNearestRouteSaveObject.m
//  iSEPTA
//
//  Created by septa on 1/15/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "FindNearestRouteSaveObject.h"

@implementation FindNearestRouteSaveObject

@synthesize radius;

-(id) initWithRadius: (NSNumber*) newRadius
{
    if ( ( self = [super init] ) )
    {
        radius = newRadius;
    }
    
    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:radius forKey:@"radius"];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    NSNumber *myRadius = [aDecoder decodeObjectForKey:@"radius"];
    return [self initWithRadius:myRadius];
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"radius - %6.3f", [radius floatValue] ];
}


+(NSArray*) returnAllKeys
{
    return [NSArray arrayWithObjects:@"radius", nil];
}

@end
