//
//  WalkingTourStops.h
//  iSEPTA
//
//  Created by septa on 6/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PinLocation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}


@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *myTitle;
@property (nonatomic, strong) NSString *mySubtitle;


@end


@interface WalkingTourStops : NSObject
{
    
}

-(NSArray*) allStops;

@end
