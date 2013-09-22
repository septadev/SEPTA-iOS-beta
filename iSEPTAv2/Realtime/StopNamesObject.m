//
//  StopNamesObject.m
//  iSEPTA
//
//  Created by apessos on 12/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "StopNamesObject.h"

@implementation StopNamesObject

@synthesize stop_name;
@synthesize stop_id;

-(NSString*) description
{
    return [NSString stringWithFormat:@"stop_name: %@, stop_id: %d", stop_name, [stop_id intValue] ];
}

@end
