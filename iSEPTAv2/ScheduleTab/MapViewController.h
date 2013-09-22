//
//  MapViewController.h
//  iSEPTA
//
//  Created by septa on 3/22/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

// --==  KML Parsing  ==--
#import "KMLParser.h"

// --==  Custom Objects  ==--
#import "ItineraryObject.h"

// --==  MapView Helper  ==--
#import "mapAnnotation.h"


@interface MapViewController : UIViewController <MKMapViewDelegate>
{
    

}

@property (nonatomic, strong) ItineraryObject *itinerary;
@property (nonatomic, strong) NSString *travelMode;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
