//
//  GTFSFunctions.h
//  iSEPTA
//
//  Created by septa on 4/10/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GTFSCommon.h"

// --==  PODs  ==--
#import <ZipArchive.h>
#import <FMDatabase.h>


@interface GTFSFunctions : NSObject

// Read DB
-(NSString*) getDBPath;

//

//-(UInt32) getServiceID;
//-(UInt32) getServiceIDForRouteType:

-(NSInteger) getServiceIDFor:(NSString*) date;


@end
