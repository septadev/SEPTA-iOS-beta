//
//  KMLParser.h
//  iSEPTA
//
//  Created by Justin Brathwaite on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MKMultiPolyLine.h"

@class KMLPlacemark;
@class KMLStyle;

@interface KMLParser : NSObject <NSXMLParserDelegate> {
    NSMutableDictionary *_styles;
    NSMutableArray *_placemarksArray;
    
    KMLPlacemark *_placemark;
    KMLStyle *_style;
    
    NSXMLParser *_xmlParser;
}

- (id)initWithURL:(NSURL *)url;
- (void)parseKML;

- (void) clear;

@property (unsafe_unretained, nonatomic, readonly) NSArray *overlays;
@property (unsafe_unretained, nonatomic, readonly) NSArray *points;

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point;
- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay;

-(void) details;

@end
