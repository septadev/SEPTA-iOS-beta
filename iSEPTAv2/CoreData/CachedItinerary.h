//
//  CachedItinerary.h
//  iSEPTA
//
//  Created by septa on 3/12/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CachedItinerary : NSManagedObject

@property (nonatomic, retain) NSData * itineraryData;
@property (nonatomic, retain) NSString * hashKey;

@end
