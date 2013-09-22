//
//  SaveController.h
//  iSEPTA
//
//  Created by septa on 1/15/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveController : NSObject
{
}

/*
 
 What is needed to work with NSUserDefaults.
 1) A key that stores the data needed or the data to be populated
 2) (optional) additional keys
 3) A reference to whatever structure (a custom Data object, right?  Right!?) the previous key(s) referenced
 
 init
 save (object)
 clear (object)
 update (object)
 
*/

//@property (nonatomic, strong) id object;

-(id) initWithKey:(NSString*) key;  // @"NextToArrive:Saves" or (this might work) @"NextToArrive:Saves.Favorites"

-(void) save;
-(void) clear;

-(void) setObject:(id)newObject;
-(id) object;



@end
