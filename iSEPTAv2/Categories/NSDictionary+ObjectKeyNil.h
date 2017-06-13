//
//  NSDictionary+ObjectKeyNil.h
//  iSEPTA
//
//  Created by septa on 3/10/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ObjectKeyNil)

- (id)objectForKeyOrNil:(id)key;

@end
