//
//  KMLOverlayView.m
//  iSEPTA
//
//  Created by septa on 9/22/15.
//  Copyright © 2015 SEPTA. All rights reserved.
//


#import "KMLOverlayView.h"

@interface KMLOverlayView()

@property (nonatomic, strong) UIImage *overlayImage;

@end


@implementation KMLOverlayView

-(instancetype)initWithOverlay:(id<MKOverlay>)overlay overlayImage:(UIImage *)overlayImage
{
    
    self = [super initWithOverlay:overlay];
    if ( self )
    {
        _overlayImage = overlayImage;
    }
    return self;
    
}


- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    CGImageRef imageReference = self.overlayImage.CGImage;
    
    MKMapRect theMapRect = self.overlay.boundingMapRect;
    CGRect theRect = [self rectForMapRect:theMapRect];
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    CGContextDrawImage(context, theRect, imageReference);
}


@end
