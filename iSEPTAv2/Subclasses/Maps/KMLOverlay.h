//
//  KMLOverlay.h
//  iSEPTA
//
//  Created by septa on 9/22/15.
//  Copyright © 2015 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class KMLObject;

@interface KMLOverlay : NSObject <MKOverlay>

-(instancetype)initWithKML:(KMLObject *) kmlObject;

@end
