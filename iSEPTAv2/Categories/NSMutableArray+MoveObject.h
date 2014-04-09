//
//  NSMutableArray+MoveObject.h
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

// From QuickDialog, used in TableViewData or whatever the hell I called that stupid thing
@interface NSMutableArray (MoveObject)

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;


@end
