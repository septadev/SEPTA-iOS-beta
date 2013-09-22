//
//  augmentedreality.h
//  iSEPTA
//
//  Created by Justin Brathwaite on 4/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WTArchitectView.h"
#import <CoreLocation/CoreLocation.h>

#define WTNUMBER_OF_POIS 50

// please replace these coordinates with your current location
#define YOUR_CURRENT_LATITUDE 39.797036
#define YOUR_CURRENT_LONGITUDE -75.082834
#define YOUR_CURRENT_ALTITUDE 200

// this is used to create random positions around you
#define WT_RANDOM(smallNumber, bigNumber) ((((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * (bigNumber - smallNumber)) + smallNumber)


@class WTPoiDetailViewController;

@interface SeptaVisionViewController: UIViewController <WTArchitectViewDelegate,CLLocationManagerDelegate>
{
    WTArchitectView                                             *_architectView;
    
    NSString                                                    *_currentSelectedPoiID;
    
    WTPoiDetailViewController                                   *_poiDetailViewController;
    
    CLLocationManager *locationManager;
   
}

@property (nonatomic, retain) WTArchitectView                   *architectView;
@property (nonatomic, retain) NSString                          *currentSelectedPoiID;
@property (nonatomic, retain) WTPoiDetailViewController         *poiDetailViewController;
@property (nonatomic, retain) CLLocationManager *locationManager;

@end
