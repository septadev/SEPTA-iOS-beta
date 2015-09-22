//
//  KMLAnnotation.h
//  iSEPTA
//
//  Created by septa on 9/22/15.
//  Copyright © 2015 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, KMLAttractionType)
{
    kKMLTrolleyBlue = 0,
    kKMLTrolleyRed,
    kKMLBusBlue,
    kKMLBusRed,
    kKMLTrainBlue,
    kKMLTrainRed,
    kKMLNone,
};


@interface KMLAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D _coordinate;
    NSString *currentSubTitle;
    NSString *currentTitle;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) KMLAttractionType type;

@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, strong) NSString *currentSubTitle;
@property (nonatomic, strong) NSString *direction;
@property (nonatomic, strong) NSNumber *vehicle_id;
@property (nonatomic, strong) NSNumber *seconds;

- (NSString *) title;
- (NSString *) subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
