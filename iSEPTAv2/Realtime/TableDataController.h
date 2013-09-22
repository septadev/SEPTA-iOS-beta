//
//  TableDataController.h
//  iSEPTA
//
//  Created by apessos on 12/22/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableDataController : NSObject
{

    int _numberOfSections;
    
}

@property (nonatomic, strong) NSMutableArray *data;

-(id) init;

-(void) updateSection:(int) section;

-(void) addNilPlaceholder;

-(void) addObject:(id) object toSection:(int) section;
-(void) removeObjectsInSection:(int) section;
-(void) removeObjectWithIndexPath:(NSIndexPath*) indexPath;

-(id) returnObjectAtIndexPath:(NSIndexPath*) indexPath;
-(id) returnObjectFromSection: (int) section;

-(NSInteger) numberOfSections;
-(NSInteger) numberOfRowsInSection:(int) section;

-(NSString*) nameForSection:(int) section;
-(void) addName:(NSString*) name toSection: (int) section;

-(void) hideSection  :(int) section;
-(void) unhideSection:(int) section;

@end
