//
//  MapMemoryTestViewController.h
//  iSEPTA
//
//  Created by septa on 10/4/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


#import "GTFSCommon.h"
#import "TrainViewObject.h"
#import "mapAnnotation.h"


@interface MapMemoryTestViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, readwrite) int counter;

@end
