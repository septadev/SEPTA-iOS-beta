//
//  NSMutableArray+Indices.h
//  iSEPTA
//
//  Created by apessos on 3/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableArray (Indices)

-(NSDictionary*) dictionaryOfIndicesandTitlesForKey:(NSString *)titleKey;
-(NSDictionary*) dictionaryOfIndicesandTitlesForKey:(NSString *)titleKey forSection:(NSNumber*) section;

//-(void) sortByKey:(NSString*) key;

@end
