//
//  KMLOverlayView.h
//  iSEPTA
//
//  Created by septa on 9/22/15.
//  Copyright © 2015 SEPTA. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KMLOverlayView : MKOverlayRenderer

-(instancetype)initWithOverlay:(id<MKOverlay>)overlay overlayImage:(UIImage *)overlayImage;

@end
