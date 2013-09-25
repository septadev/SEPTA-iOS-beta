//
//  CurrentLocationProtocol.h
//  iSEPTA
//
//  Created by septa on 9/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasicRouteObject.h"

@protocol CurrentLocationProtocol <NSObject>

-(void) currentLocationSelectionMade:(BasicRouteObject*) routeObj;

@end