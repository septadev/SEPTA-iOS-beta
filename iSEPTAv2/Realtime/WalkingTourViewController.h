//
//  WalkingTourViewController.h
//  iSEPTA
//
//  Created by septa on 6/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import "CoreLocation/CoreLocation.h"

// Data Objects
#import "WalkingTourStops.h"
#import "NotificationInfo.h"


@interface WalkingTourViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;



@end
