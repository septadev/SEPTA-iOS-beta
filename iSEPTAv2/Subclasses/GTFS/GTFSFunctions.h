//
//  GTFSFunctions.h
//  iSEPTA
//
//  Created by septa on 4/10/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTFSFunctions : NSObject

// Read DB
-(NSString*) getDBPath;

//

-(UInt32) getServiceID;
-(UInt32) getServiceIDFor:(NSString*) date;


@end
