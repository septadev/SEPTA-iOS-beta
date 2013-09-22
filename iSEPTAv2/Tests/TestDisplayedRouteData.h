//
//  TestDisplayedRouteData.h
//  iSEPTA
//
//  Created by septa on 11/13/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayedRouteData.h"


@interface TestDisplayedRouteData : NSObject
{
    
}

-(id) init;
-(void) testCopy;
-(void) testDataStore;

-(void) testReturnDataWithFavorites:(BOOL) favs withViewed: (BOOL) views andWithRoutes: (BOOL) routes;

@end
