//
//  mapAnnotation.h
//  iSEPTA
//
//  Created by Justin Brathwaite on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface mapAnnotation : NSObject <MKAnnotation>
{
     CLLocationCoordinate2D _coordinate; 
    NSString *currentSubTitle;
	NSString *currentTitle;
}

@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, strong) NSString *currentSubTitle;
@property (nonatomic, strong) NSString *direction;
@property (nonatomic, strong) NSNumber *id;

- (NSString *) title;
- (NSString *) subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
