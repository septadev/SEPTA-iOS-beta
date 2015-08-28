/*
 File: KMLParser.m 
 Abstract: 
 Implements a limited KML parser.
 The following KML types are supported:
 Style,
 LineString,
 Point,
 Polygon,
 Placemark.
 All other types are ignored
 
 Version: 1.3 
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
 
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
 
 */

#import "KMLParser.h"

#define ADD_MULTIGEOMETRY_SUPPORT

//#define NSLog //

// KMLElement and subclasses declared here implement a class hierarchy for
// storing a KML document structure.  The actual KML file is parsed with a SAX
// parser and only the relevant document structure is retained in the object
// graph produced by the parser.  Data parsed is also transformed into
// appropriate UIKit and MapKit classes as necessary.

// Abstract KMLElement type.  Handles storing an element identifier (id="...")
// as well as a buffer for accumulating character data parsed from the xml.
// In general, subclasses should have beginElement and endElement classes for
// keeping track of parsing state.  The parser will call beginElement when
// an interesting element is encountered, then all character data found in the
// element will be stored into accum, and then when endElement is called accum
// will be parsed according to the conventions for that particular element type
// in order to save the data from the element.  Finally, clearString will be
// called to reset the character data accumulator.

@interface KMLElement : NSObject {
    NSString *identifier;
    NSMutableString *accum;
}

- (id)initWithIdentifier:(NSString *)ident;

@property (nonatomic, readonly) NSString *identifier;

// Returns YES if we're currently parsing an element that has character
// data contents that we are interested in saving.
- (BOOL)canAddString;
// Add character data parsed from the xml
- (void)addString:(NSString *)str;
// Once the character data for an element has been parsed, use clearString to
// reset the character buffer to get ready to parse another element.
- (void)clearString;

@end

// Represents a KML <Style> element.  <Style> elements may either be specified
// at the top level of the KML document with identifiers or they may be
// specified anonymously within a Geometry element.
@interface KMLStyle : KMLElement {    
    UIColor *strokeColor;
    CGFloat strokeWidth;
    UIColor *fillColor;
    
    BOOL fill;
    BOOL stroke;
    
    struct { 
        int inLineStyle:1;
        int inPolyStyle:1;
        
        int inColor:1;
        int inWidth:1;
        int inFill:1;
        int inOutline:1;
    } flags;
}

- (void)beginLineStyle;
- (void)endLineStyle;

- (void)beginPolyStyle;
- (void)endPolyStyle;

- (void)beginColor;
- (void)endColor;

- (void)beginWidth;
- (void)endWidth;

- (void)beginFill;
- (void)endFill;

- (void)beginOutline;
- (void)endOutline;

- (void)applyToOverlayPathView:(MKOverlayPathRenderer *)view;

@end

@interface KMLGeometry : KMLElement {
    struct {
        int inCoords:1;
        int inMultiGeometry:1;
        int firstTime:1;
    } flags;
}

-(void)beginMultiGeometry;
-(void)endMultiGeometry;

- (void)beginCoordinates;
- (void)endCoordinates;

-(void)setFirstTimeInGeometry;

// Create (if necessary) and return the corresponding Map Kit MKShape object
// corresponding to this KML Geometry node.
- (MKShape *)mapkitShape;

// Create (if necessary) and return the corresponding MKOverlayPathView for
// the MKShape object.
- (MKOverlayPathRenderer *)createOverlayView:(MKShape *)shape;

@end

// A KMLPoint element corresponds to an MKAnnotation and MKPinAnnotationView
@interface KMLPoint : KMLGeometry
{
    CLLocationCoordinate2D point;
}

@property (nonatomic, readonly) CLLocationCoordinate2D point;

@end

// A KMLPolygon element corresponds to an MKPolygon and MKPolygonView
@interface KMLPolygon : KMLGeometry
{
    NSString *outerRing;
    NSMutableArray *innerRings;
    
    struct {
        int inOuterBoundary:1;
        int inInnerBoundary:1;
        int inLinearRing:1;
    } polyFlags;
}

- (void)beginOuterBoundary;
- (void)endOuterBoundary;

- (void)beginInnerBoundary;
- (void)endInnerBoundary;

- (void)beginLinearRing;
- (void)endLinearRing;

@end

@interface KMLLineString : KMLGeometry
{
    CLLocationCoordinate2D *points;
    NSUInteger length;
}

@property (nonatomic, readonly) CLLocationCoordinate2D *points;
@property (nonatomic, readonly) NSUInteger length;

//-(void) addCoordinatesFromString:(NSString*) string;
//-(void)convertCoordinateStringToPoints;

@end

@interface KMLPlacemark : KMLElement
{
    
    KMLStyle *style;
    KMLGeometry *geometry;
    
#ifdef ADD_MULTIGEOMETRY_SUPPORT
    NSMutableArray *geometries;
    NSMutableArray *mkShapes;
    
    MKMultiPolyLine *_polylines;
    NSMutableArray *overlayViews;
#else
#endif
    
    NSString *name;
    NSString *placemarkDescription;
    
    NSString *styleUrl;
    
    MKShape *mkShape;
    
    MKAnnotationView *annotationView;
    MKOverlayPathRenderer *overlayView;
    
    struct {
        int inName:1;
        int inDescription:1;
        int inStyle:1;
        int inGeometry:1;
        int inStyleUrl:1;
        int inMultiGeometry:1;
        int firstTimeInGeometry:1;
    } flags;
    
}

- (void)beginName;
- (void)endName;

- (void)beginDescription;
- (void)endDescription;

- (void)beginStyleWithIdentifier:(NSString *)ident;
- (void)endStyle;

-(void)beginMultiGeometry;
-(void)endMultiGeometry;

- (void)beginGeometryOfType:(NSString *)type withIdentifier:(NSString *)ident;
- (void)endGeometry;

- (void)beginStyleUrl;
- (void)endStyleUrl;

// Corresponds to the title property on MKAnnotation
@property (nonatomic, readonly) NSString *name; 
// Corresponds to the subtitle property on MKAnnotation
@property (nonatomic, readonly) NSString *placemarkDescription;

#ifdef ADD_MULTIGEOMETRY_SUPPORT
@property (nonatomic, readonly) NSMutableArray *geometries;
@property (nonatomic, retain) MKMultiPolyLine *polylines;
#endif

@property (nonatomic, readonly) KMLGeometry *geometry;
@property (unsafe_unretained, nonatomic, readonly) KMLPolygon *polygon;

@property (nonatomic, assign) KMLStyle *plStyle;  // Add assign as the compile was going to default to that anyway
@property (nonatomic, readonly) NSString *styleUrl;

- (id <MKOverlay>)overlay;
-(NSMutableArray*) overlays;
- (id <MKAnnotation>)point;

//- (MKOverlayView *)overlayViews;
- (MKOverlayView *)overlayView;
- (MKAnnotationView *)annotationView;

//-(void) strAddToCoords: (NSString) *str withCoords: CLLocationCoordinate2D **coordsOut, NSUInteger *coordsLenOut);

@end

// Convert a KML coordinate list string to a C array of CLLocationCoordinate2Ds.
// KML coordinate lists are longitude,latitude[,altitude] tuples specified by whitespace.




//static void strAddToCoords(NSString *str, CLLocationCoordinate2D **coordsOut, NSUInteger *coordsLenOut)
//{                       //         accum,                        &points    ,            &length  -->  where points is CLLocationCoordinate2D *coordinates
//
//    static NSUInteger spaceRemaining = 0;
//    static CLLocationCoordinate2D *oldCoordintes;
//    
//    NSUInteger read = *coordsLenOut;
//    NSUInteger addSpace = 10;
//    NSUInteger space = read + addSpace;
//
//    
//    if ( oldCoordintes != *coordsOut )  // If the oldCoordinatePoint does not equal the current one, make them equal
//    {
//        oldCoordintes = *coordsOut;
//        spaceRemaining = 0;
//    }
//    else
//    {
//        space = read + spaceRemaining;
//    }
//    
//    CLLocationCoordinate2D *coords = *coordsOut;
//
//    // Situation:  We've realloc'ed 80 sizeof(CLLocationCoordinate2D) into coords but only used 64 of them, leaving 16 unwritten
//    // When this function is called for the next one, we don't want to realloc when there's still space left.
//    
//    if ( spaceRemaining == 0 )
//    {
//        
//        coords = realloc(coords, sizeof(CLLocationCoordinate2D) * addSpace);
//        if ( coords == nil )
//        {
//            NSLog(@"Unable to allocate enough space...");
//        }
//        
//    }
//    
//    NSLog(@"KML - strAddToCoords (start) -- read: %d, addSpace: %d, space: %d, str length: %d", read, addSpace, space, [str length]);
//    
//    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
//    NSArray *tuples = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    for (NSString *tuple in tuples)
//    {
//        
//        if (read == space )
//        {
//            addSpace *= 2;
//            space = read + addSpace;
//            coords = realloc(coords, sizeof(CLLocationCoordinate2D) * addSpace);
//            spaceRemaining = addSpace;
//        }
//        
//        double lat, lon;
//        NSScanner *scanner = [[NSScanner alloc] initWithString:tuple];
//        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
//        BOOL success = [scanner scanDouble:&lon];
//        if (success)
//            success = [scanner scanDouble:&lat];
//        if (success)
//        {
//            CLLocationCoordinate2D c = CLLocationCoordinate2DMake(lat, lon);
//            if (CLLocationCoordinate2DIsValid(c))
//            {
//                coords[read++] = c;  spaceRemaining--;
//            }
//        }
//        
//    }
//    
//    NSLog(@"KML - strAddToCoords (after) -- read: %d, addSpace: %d, space: %d, str length: %d", read, addSpace, space, [str length]);
//
//    
//    *coordsOut = coords;
//    *coordsLenOut = read;
//    
//    oldCoordintes = coords;
//
//    
//    
//}


static void strToCoords(NSString *str, CLLocationCoordinate2D **coordsOut, NSUInteger *coordsLenOut)
{
    
    NSUInteger read = 0, space = 10;
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * space);
    
    NSArray *tuples = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString *tuple in tuples)
    {
        
        if (read == space)
        {
            space *= 2;
            coords = realloc(coords, sizeof(CLLocationCoordinate2D) * space);
        }
        
        double lat, lon;
        NSScanner *scanner = [[NSScanner alloc] initWithString:tuple];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
        BOOL success = [scanner scanDouble:&lon];
        if (success)
        {
            success = [scanner scanDouble:&lat];
        }
        
        if (success)
        {
            CLLocationCoordinate2D c = CLLocationCoordinate2DMake(lat, lon);
            if (CLLocationCoordinate2DIsValid(c))
                coords[read++] = c;
        }
        
    }
    
    
    NSLog(@"KML - strToCoords -- read: %lu, space: %lu, str length: %lu", (unsigned long)read, (unsigned long)space, (unsigned long)[str length]);

    
    *coordsOut = coords;
    *coordsLenOut = read;
    
}

@interface UIColor (KMLExtras)

// Parse a KML string based color into a UIColor.  KML colors are agbr hex encoded.
+ (UIColor *)colorWithKMLString:(NSString *)kmlColorString;

@end

@implementation KMLParser


-(void) clear
{
    
    _styles = nil;
    
    for (KMLPlacemark *pMark in _placemarksArray)
    {
        [pMark clearString];
    }
    
    [_placemarksArray removeAllObjects];
    _placemarksArray = nil;
    
    _placemark = nil;
    _style = nil;
    
    _xmlParser = nil;
    
}



// After parsing has completed, this method loops over all placemarks that have
// been parsed and looks up their corresponding KMLStyle objects according to
// the placemark's styleUrl property and the global KMLStyle object's identifier.
- (void)_assignStyles
{
    for (KMLPlacemark *placemark in _placemarksArray)
    {
        if (!placemark.plStyle && placemark.styleUrl)
        {
            
            NSString *styleUrl = placemark.styleUrl;
            NSRange range = [styleUrl rangeOfString:@"#"];
            if (range.length == 1 && range.location == 0)
            {
                NSString *styleID = [styleUrl substringFromIndex:1];
                KMLStyle *style = [_styles objectForKey:styleID];
                placemark.plStyle = style;
            }
            
        }
        
    }
    
}

- (id)initWithURL:(NSURL *)url
{
    
    if (self = [super init])
    {
        _styles = [[NSMutableDictionary alloc] init];
        _placemarksArray = [[NSMutableArray alloc] init];
        _xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        
        [_xmlParser setDelegate:self];
    }
    
    return self;
    
}


-(void) details
{
    
    for (KMLPlacemark *placemark in _placemarksArray)
    {

#ifdef ADD_MULTIGEOMETRY_SUPPORT
        // An example of getting information on each geometry find inside the multiple geometry tags
        for (KMLGeometry *singleGeometry in placemark.geometries)
        {
            CLLocationCoordinate2D *pts = ((KMLLineString*)singleGeometry).points;
            NSUInteger length = ((KMLLineString*)singleGeometry).length;
            NSLog(@"length: %04lu, first point: (%6.4f, %6.4f), last point: (%6.4f, %6.4f)\t\t%@", (unsigned long)length, (pts+0)->longitude, (pts+0)->latitude, (pts+length-1)->longitude, (pts+length-1)->latitude, placemark.name);
        }
#endif
        
        CLLocationCoordinate2D *pts = ((KMLLineString*)placemark.geometry).points;
        NSUInteger length = ((KMLLineString*)placemark.geometry).length;
        NSLog(@"length: %04lu, first point: (%6.4f, %6.4f), last point: (%6.4f, %6.4f)\t\t%@", (unsigned long)length, (pts+0)->longitude, (pts+0)->latitude, (pts+length-1)->longitude, (pts+length-1)->latitude, placemark.name);
        
    }
    
}


- (void)dealloc
{

//    [_styles release];
//    [_placemarksArray release];
//    [_xmlParser release];
    
//    [super dealloc];
    
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;
{
//    NSLog(@"KML - parseErrorOccurred: %@", parseError);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
//    NSLog(@"KML - parser validationErrorOccurred: %@", validationError);
}

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName
{
//    NSLog(@"KML - foundUnparsedEntityDeclarationWithName: %@", name);
}

- (void)parseKML
{
    
    
    
    if ( [_xmlParser parse] )
    {
//        NSLog(@"KML - xml parse successful");
    }
//    else
//    {
//        NSLog(@"KML - xlm parsing was unsuccessful");
//    }
    
    
//    NSError *error = [_xmlParser parserError];
//    NSLog(@"KML - parse error: %@", error);
    
    [self _assignStyles];
}

// Return the list of KMLPlacemarks from the object graph that contain overlays
// (as opposed to simply point annotations).
- (NSArray *)overlays
{
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
    
    for (KMLPlacemark *placemark in _placemarksArray)
    {

#ifdef ADD_MULTIGEOMETRY_SUPPORT
//        NSMutableArray *overlay = [placemark overlays];  // Returns an NSMutableArray of mkShapes created with [self _createShape]
//        if (overlay)
//        {
//            [overlays addObjectsFromArray:overlay];  // overlay will contain at least one mkShape object
//        }
        
        id <MKOverlay> multiOverlay = [placemark overlay];
        if ( multiOverlay )
        {
            [overlays addObject:multiOverlay];
        }
        
#else
        id <MKOverlay> overlay = [placemark overlay];
        if (overlay)
        {
            [overlays addObject: overlay];
        }
#endif
        
    }
    
    return overlays;
}

// Return the list of KMLPlacemarks from the object graph that are simply
// MKPointAnnotations and are not MKOverlays.
- (NSArray *)points
{
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (KMLPlacemark *placemark in _placemarksArray) {
        id <MKAnnotation> point = [placemark point];
        if (point)
            [points addObject:point];
    }
    return points;
}

- (MKAnnotationView *)viewForAnnotation:(id <MKAnnotation>)point
{
    // Find the KMLPlacemark object that owns this point and get
    // the view from it.
    for (KMLPlacemark *placemark in _placemarksArray) {
        if ([placemark point] == point)
            return [placemark annotationView];
    }
    return nil;
}

- (MKOverlayView *)viewForOverlay:(id <MKOverlay>)overlay
{
    
    // Find the KMLPlacemark object that owns this overlay and get
    // the view from it.
    for (KMLPlacemark *placemark in _placemarksArray)
    {

#ifdef ADD_MULTIGEOMETRY_SUPPORT
        // Each placemark can have multiple shapes, retrieved from [placemark overlays]
//        for ( MKShape* shape in [placemark overlays] )
//        {
//            if ( shape == overlay )
//            {
//                return [placemark overlayView];
//            }
//        }
        if ( [placemark overlay] == overlay)
            return [placemark overlayView];
        
#else
        // Originally [placemark overlay] returned just one shape.  Unfortunately, multiple <LineString> tags means we need multiple shapes per placemark
        // Each individual shape/overlay has been added to placemark overlays.  This method gets called once for each overlay added.
        if ( [placemark overlay] == overlay )
            return [placemark overlayView];
#endif
        
    }
    
    return nil;
    
}


#pragma mark NSXMLParserDelegate

#define ELTYPE(typeName) (NSOrderedSame == [elementName caseInsensitiveCompare:@#typeName])
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    
//    NSLog(@"start: %@, namespace: %@, qName: %@, dict: %@", elementName, namespaceURI, qName, attributeDict);
    
//    if ( [elementName isEqualToString:@"styleUrl"] )
//    {
//        NSLog(@"break here");
//    }
    
    NSString *ident = [attributeDict objectForKey:@"id"];
    
    KMLStyle *style = [_placemark plStyle] ? [_placemark plStyle] : _style;
    
    // Style and sub-elements
    if (ELTYPE(Style))
    {
        
        if (_placemark)
        {
            [_placemark beginStyleWithIdentifier:ident];
        } else if (ident != nil) {
            _style = [[KMLStyle alloc] initWithIdentifier:ident];
        }
        
    } else if (ELTYPE(PolyStyle)) {
        [style beginPolyStyle];
    } else if (ELTYPE(LineStyle)) {
        [style beginLineStyle];
    } else if (ELTYPE(color)) {
        [style beginColor];
    } else if (ELTYPE(width)) {
        [style beginWidth];
    } else if (ELTYPE(fill)) {
        [style beginFill];
    } else if (ELTYPE(outline)) {
        [style beginOutline];
    }
    // Placemark and sub-elements
    else if (ELTYPE(Placemark))
    {
        // Create new placemark when <Placemark> tag has been found
        _placemark = [[KMLPlacemark alloc] initWithIdentifier:ident];
        
    } else if (ELTYPE(Name)) {
        [_placemark beginName];
    } else if (ELTYPE(Description)) {
        [_placemark beginDescription];
    } else if (ELTYPE(styleUrl)) {
        [_placemark beginStyleUrl];
    } else if (ELTYPE(MultiGeometry) )
    {
        [_placemark beginMultiGeometry];
    }
    else if (ELTYPE(Polygon) || ELTYPE(Point) || ELTYPE(LineString))  // Supported Geometry elements
    {
        [_placemark beginGeometryOfType:elementName withIdentifier:ident];
    }
    else if (ELTYPE(coordinates))  // Geometry sub-elements
    {
        [_placemark.geometry beginCoordinates];
    } 
    // Polygon sub-elements
    else if (ELTYPE(outerBoundaryIs)) {
        [_placemark.polygon beginOuterBoundary];
    } else if (ELTYPE(innerBoundaryIs)) {
        [_placemark.polygon beginInnerBoundary];
    } else if (ELTYPE(LinearRing)) {
        [_placemark.polygon beginLinearRing];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    
//    NSLog(@"end  : %@, namespace: %@, qName: %@", elementName, namespaceURI, qName);
    
//    if ( [elementName isEqualToString:@"styleUrl"] )
//    {
//        NSLog(@"break here");
//    }
    
    KMLStyle *style = [_placemark plStyle] ? [_placemark plStyle] : _style;
    
    // Style and sub-elements
    if (ELTYPE(Style)) {
        if (_placemark) {
            [_placemark endStyle];
        } else if (_style) {
            [_styles setObject:_style forKey:_style.identifier];
            _style = nil;
        }
    } else if (ELTYPE(PolyStyle)) {
        [style endPolyStyle];
    } else if (ELTYPE(LineStyle)) {
        [style endLineStyle];
    } else if (ELTYPE(color)) {
        [style endColor];
    } else if (ELTYPE(width)) {
        [style endWidth];
    } else if (ELTYPE(fill)) {
        [style endFill];
    } else if (ELTYPE(outline)) {
        [style endOutline];
    }
    // Placemark and sub-elements
    else if (ELTYPE(Placemark))
    {
        
        // </Placemark> found
        if (_placemark)
        {
            // As long as _placemark exists, add it to the _placemarksArray
            [_placemarksArray addObject:_placemark];
            _placemark = nil;
        }
        
    } else if (ELTYPE(Name)) {
        [_placemark endName];
    } else if (ELTYPE(Description)) {
        [_placemark endDescription];
    } else if (ELTYPE(styleUrl)) {
        [_placemark endStyleUrl];
    } else if (ELTYPE(MultiGeometry) )
    {
        [_placemark endMultiGeometry];
    }
    else if (ELTYPE(Polygon) || ELTYPE(Point) || ELTYPE(LineString))
    {
        // <LineString>
        //    <coordinates> lat,long,z::space:: lat,long,z::space:: </coordinates>
        // </LineString>
        
        // Add geometry into geometries
#ifdef ADD_MULTIGEOMETRY_SUPPORT
        // What if instead of adding the geometry object to geometries, we just make the mapKitShape
        // and store it in polylines.  We can free points then too, right?
        
//            NSLog(@"KML - didEndElement: Adding geometry (%p) into geometries", _placemark.geometry);
        [_placemark.geometries addObject: _placemark.geometry];

        // Build the polylines directly
//        if ( ![_placemark polylines] )
//        {
//            NSLog(@"Creating polylines");
//            _placemark.polylines = [[MKMultiPolyLine alloc] init];
//        }
//        else
//        {
//            NSLog(@"Adding to polylines");
//            [[_placemark polylines] addPolyline: [[_placemark geometry] mapkitShape] ];
//        }
        
#endif
        
        [_placemark endGeometry];  // Sets inGeometry flag to NO
        
    }
    // Geometry sub-elements
    else if (ELTYPE(coordinates))
    {
        // Populate geometry with the values from <coordinates> </coordinates>
        [_placemark.geometry endCoordinates]; // Frees points, mallocs and copies coordinates in accum into points, clears accum
    } 
    // Polygon sub-elements
    else if (ELTYPE(outerBoundaryIs)) {
        [_placemark.polygon endOuterBoundary];
    } else if (ELTYPE(innerBoundaryIs)) {
        [_placemark.polygon endInnerBoundary];
    } else if (ELTYPE(LinearRing)) {
        [_placemark.polygon endLinearRing];
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
//    NSLog(@"KML - foundCharacters: %@", string);
    KMLElement *element = _placemark ? (KMLElement *)_placemark : (KMLElement *)_style;
    [element addString:string];
}

@end

// Begin the implementations of KMLElement and subclasses.  These objects
// act as state machines during parsing time and then once the document is
// fully parsed they act as an object graph for describing the placemarks and
// styles that have been parsed.

@implementation KMLElement

@synthesize identifier;

- (id)initWithIdentifier:(NSString *)ident
{
    if (self = [super init]) {
        identifier = ident;
    }
    return self;
}


- (BOOL)canAddString
{
    return NO;
}

- (void)addString:(NSString *)str
{
    if ([self canAddString]) {
        if (!accum)
            accum = [[NSMutableString alloc] init];
        [accum appendString:str];
    }
}

- (void)clearString
{
    accum = nil;
}

@end

@implementation KMLStyle 

- (BOOL)canAddString
{
    return flags.inColor || flags.inWidth || flags.inFill || flags.inOutline;
}

- (void)beginLineStyle
{
    flags.inLineStyle = YES;
}
- (void)endLineStyle
{
    flags.inLineStyle = NO;
}

- (void)beginPolyStyle
{
    flags.inPolyStyle = YES;
}
- (void)endPolyStyle
{
    flags.inPolyStyle = NO;
}

- (void)beginColor
{
    flags.inColor = YES;
}
- (void)endColor
{
    flags.inColor = NO;
    
    if (flags.inLineStyle) {
        strokeColor = [UIColor colorWithKMLString:accum];
    } else if (flags.inPolyStyle) {
        fillColor = [UIColor colorWithKMLString:accum];
    }
    
    [self clearString];
}

- (void)beginWidth
{
    flags.inWidth = YES;
}
- (void)endWidth
{
    flags.inWidth = NO;
    strokeWidth = [accum floatValue];
    [self clearString];
}

- (void)beginFill
{
    flags.inFill = YES;
}
- (void)endFill
{
    flags.inFill = NO;
    fill = [accum boolValue];
    [self clearString];
}

- (void)beginOutline
{
    flags.inOutline = YES;
}
- (void)endOutline
{
    stroke = [accum boolValue];
    [self clearString];
}


// MKOverlayPathView was depreciated in iOS 7, using MKOverlayPathRenderer
- (void)applyToOverlayPathView:(MKOverlayPathRenderer *)view
{
    view.strokeColor = strokeColor;
    view.fillColor = fillColor;
    view.lineWidth = strokeWidth;
}

@end

@implementation KMLGeometry

- (BOOL)canAddString
{
    return flags.inCoords;
}

- (void)beginCoordinates
{
    flags.inCoords = YES;
}

- (void)endCoordinates
{
    flags.inCoords = NO;
}

-(void)setFirstTimeInGeometry
{
    flags.firstTime = YES;
}

-(void)beginMultiGeometry
{
    flags.inMultiGeometry = YES;
}

-(void)endMultiGeometry
{
    flags.inMultiGeometry = NO;
    flags.firstTime = NO;
}

- (MKShape *)mapkitShape
{
    return nil;
}

- (MKOverlayPathRenderer *)createOverlayView:(MKShape *)shape
{
    return nil;
}

@end

@implementation KMLPoint

@synthesize point;

- (void)endCoordinates
{
    flags.inCoords = NO;
    
    CLLocationCoordinate2D *points = NULL;
    NSUInteger len = 0;
    
    strToCoords(accum, &points, &len);
    if (len == 1) {
        point = points[0];
    }
    free(points);
    
    [self clearString];
}

- (MKShape *)mapkitShape
{
    // KMLPoint corresponds to MKPointAnnotation
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = point;
    return annotation;
}

// KMLPoint does not override createOverlayView: because there is no such
// thing as an overlay view for a point.  They use MKAnnotationViews which
// are vended by the KMLPlacemark class.

@end

@implementation KMLPolygon


- (BOOL)canAddString
{
    return polyFlags.inLinearRing && flags.inCoords;
}

- (void)beginOuterBoundary
{
    polyFlags.inOuterBoundary = YES;
}
- (void)endOuterBoundary
{
    polyFlags.inOuterBoundary = NO;
    outerRing = [accum copy];
    [self clearString];
}

- (void)beginInnerBoundary
{
    polyFlags.inInnerBoundary = YES;
}
- (void)endInnerBoundary
{
    polyFlags.inInnerBoundary = NO;
    NSString *ring = [accum copy];
    if (!innerRings) {
        innerRings = [[NSMutableArray alloc] init];
    }
    [innerRings addObject:ring];
    [self clearString];
}

- (void)beginLinearRing
{
    polyFlags.inLinearRing = YES;
}
- (void)endLinearRing
{
    polyFlags.inLinearRing = NO;
}

- (MKShape *)mapkitShape
{
    // KMLPolygon corresponds to MKPolygon
    
    // The inner and outer rings of the polygon are stored as kml coordinate
    // list strings until we're asked for mapkitShape.  Only once we're here
    // do we lazily transform them into CLLocationCoordinate2D arrays.
    
    // First build up a list of MKPolygon cutouts for the interior rings.
    NSMutableArray *innerPolys = nil;
    if (innerRings) {
        innerPolys = [[NSMutableArray alloc] initWithCapacity:[innerPolys count]];
        for (NSString *coordStr in innerRings) {
            CLLocationCoordinate2D *coords = NULL;
            NSUInteger coordsLen = 0;
            strToCoords(coordStr, &coords, &coordsLen);
            [innerPolys addObject:[MKPolygon polygonWithCoordinates:coords count:coordsLen]];
            free(coords);
        }
    }
    // Now parse the outer ring.
    CLLocationCoordinate2D *coords = NULL;
    NSUInteger coordsLen = 0;
    strToCoords(outerRing, &coords, &coordsLen);
    
    // Build a polygon using both the outer coordinates and the list (if applicable)
    // of interior polygons parsed.
    MKPolygon *poly = [MKPolygon polygonWithCoordinates:coords count:coordsLen interiorPolygons:innerPolys];
    free(coords);
    return poly;
}

- (MKOverlayPathRenderer *)createOverlayView:(MKShape *)shape
{
    // KMLPolygon corresponds to MKPolygonView
    
    MKPolygonRenderer *polyView = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon *)shape];
    return polyView;
}

@end

@implementation KMLLineString
{
    NSUInteger spaceAllocated;
}

@synthesize points, length;

-(id) initWithIdentifier:(NSString *) ident
{
    if ( ( self = [super initWithIdentifier:ident]) )
    {

    }
    
    return self;
}

- (void)dealloc
{
    
    // As far as I am aware (and I'll verify this) but ARC does not free memory created with malloc
    if (points)
        free(points);
    
//    [super dealloc];
    
}

- (void) endCoordinates
{
    
//    NSLog(@"KML - LineString, endCoordinates tag found");
    flags.inCoords = NO;
    [self updatePoints];
    
}

-(void) endMultiGeometry
{
//    [self convertCoordinateStringToPoints];
}

-(void) updatePoints
{
    
    if ( flags.inMultiGeometry == NO )
    {
        if (points)
        {
            free(points);
        }
        
        strToCoords(accum, &points, &length);
    }
    else
    {
//        [self addCoordinatesFromString:accum];
        coordsFromString(accum, &points, &length, &spaceAllocated);
    }
    
    [self clearString];

    
    
    // Either don't free points until the </MultiGeometry> tag been found, or somehow continue to add coordinates to points
    // This is why only the last <LineString> coordinates are displayed, the previous ones are being discarded.

}


- (MKShape *)mapkitShape
{
    // KMLLineString corresponds to MKPolyline
//    NSLog(@"KMLLineString -mapkitShape, length: %d", length);
//    NSLog(@"KMLLineString -mapkitShape, length: %04d, first point: (%6.4f, %6.4f), last point: (%6.4f, %6.4f)", length, (*points).latitude, (*points).longitude, (*(points+length-1)).latitude, (*(points+length-1)).longitude );

    
//    MKPolyline *poly = [MKPolyline polylineWithCoordinates:points count:length];
//    NSLog(@"KMLLineString -mapkitShape: %@", poly);
//    return poly;
    
    return [MKPolyline polylineWithCoordinates:points count:length];
    
}

- (MKOverlayPathRenderer *)createOverlayView:(MKShape *)shape
{
    // KMLLineString corresponds to MKPolylineView
//    NSLog(@"KMLLineString -createOverlayView, shape: %@", shape);
//    MKPolylineView *lineView = [[MKPolylineView alloc] initWithPolyline:(MKPolyline *)shape];
//    return lineView;
    
    return [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)shape];
}

static void coordsFromString(NSString *str, CLLocationCoordinate2D **coordsOut, NSUInteger *coordsLenOut, NSUInteger *allocated)
{

    NSUInteger read = *coordsLenOut;
    NSUInteger space = 1;
    NSUInteger spaceAllocated = *allocated;
    
    
    NSUInteger count = ([[str componentsSeparatedByString:@","] count]-1)/2;
    spaceAllocated += count+1;
    
    
    CLLocationCoordinate2D *coords;
    if ( read == 0 )  // read is 0 when this class gets initialized
    {
        // This is the only time that we're going to malloc the space for coords
        coords = malloc(sizeof(CLLocationCoordinate2D) * spaceAllocated);
    }
    else
    {
        // Because read is not 0, coords has already been populated.  Link coords to coordsOut.
        coords = *coordsOut;
        spaceAllocated--;
        coords = realloc(coords, sizeof(CLLocationCoordinate2D) * spaceAllocated);
    }
    
    
    NSArray *tuples = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString *tuple in tuples)
    {

        if ( read == spaceAllocated)
        {
            // Reallocation is necessary
            NSLog(@"KML - Reallocation is necessary");
//            space++;
            spaceAllocated += space++;
            coords = realloc(coords, sizeof(CLLocationCoordinate2D) * spaceAllocated);

        }  // if ( read == spaceAllocated)s
        
        double lat, lon;
        NSScanner *scanner = [[NSScanner alloc] initWithString:tuple];
        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
        BOOL success = [scanner scanDouble:&lon];
        if (success)
            success = [scanner scanDouble:&lat];
        if (success)
        {
            CLLocationCoordinate2D c = CLLocationCoordinate2DMake(lat, lon);
            if (CLLocationCoordinate2DIsValid(c))
                coords[read++] = c;
        } // if (success)
        
    } // for (NSString *tuple in tuples)
    
    *coordsOut    = coords;
    *coordsLenOut = read;
    *allocated    = spaceAllocated;
 
//    NSLog(@"KML - coordsFrStr -- read: %d, space: %d, str length: %d", read, spaceAllocated, [str length]);
    
}



//-(void) addCoordinatesFromString:(NSString*) string
//{
//    
//    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
//    NSArray *tuples = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    for (NSString *tuple in tuples)
//    {
//        
//        double lat, lon;
//        NSScanner *scanner = [[NSScanner alloc] initWithString:tuple];
//        [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@","]];
//        BOOL success = [scanner scanDouble:&lon];
//        if (success)
//            success = [scanner scanDouble:&lat];
//        if (success)
//        {
//            CLLocation *c = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
//            if (CLLocationCoordinate2DIsValid([c coordinate]))
//            {
//                [coordinates addObject: c];
//            }
//        }  // if (success)
//        
//    }
//    
//}


//-(void)convertCoordinateStringToPoints
//{
//    
////    NSUInteger size = [coordinates count];
//    NSUInteger counter = 0;
//    
//    if ( size == 0 )
//        return;
//    
//    //    *points = malloc(sizeof(CLLocationCoordinate2D) * size);
//    
//    points = malloc(sizeof(CLLocationCoordinate2D) * size);
//    
//    for (CLLocation* location in coordinates)
//    {
//        points[counter++] = [location coordinate];
//    }
//    
//    length = [coordinates count];
//    [coordinates removeAllObjects];
//    
//}

@end

@implementation KMLPlacemark

@synthesize styleUrl, geometry, name, placemarkDescription;
@synthesize plStyle;

#ifdef ADD_MULTIGEOMETRY_SUPPORT
@synthesize geometries;
@synthesize polylines = _polylines;
#endif

- (BOOL)canAddString
{
    return flags.inName || flags.inStyleUrl || flags.inDescription;
}

- (void)addString:(NSString *)str
{
    if (flags.inStyle)
        [style addString:str];
    else if (flags.inGeometry)
        [geometry addString:str];
    else
        [super addString:str];
}

- (void)beginName
{
    flags.inName = YES;
}
- (void)endName
{
    flags.inName = NO;
    name = [accum copy];
    [self clearString];
}

- (void)beginDescription
{
    flags.inDescription = YES;
}
- (void)endDescription
{
    flags.inDescription = NO;
    placemarkDescription = [accum copy];
    [self clearString];
}

- (void)beginStyleUrl
{
    flags.inStyleUrl = YES;
}

- (void)endStyleUrl
{
    flags.inStyleUrl = NO;
    styleUrl = [accum copy];
    [self clearString];
}

- (void)beginStyleWithIdentifier:(NSString *)ident
{
    flags.inStyle = YES;
    style = [[KMLStyle alloc] initWithIdentifier:ident];
}

- (void)endStyle
{
    flags.inStyle = NO;
}

-(void)beginMultiGeometry
{
//    NSLog(@"KML - Placemark -- MultiGeometry tag found for %@", name);
    flags.inMultiGeometry = YES;
    flags.firstTimeInGeometry = YES;
}

-(void)endMultiGeometry
{
//    NSLog(@"KML - Placemark -- MultiGeometry end tag found for %@", name);
    flags.inMultiGeometry = NO;
    flags.firstTimeInGeometry = NO;
    [geometry endMultiGeometry];
    
    
}

- (void)beginGeometryOfType:(NSString *)elementName withIdentifier:(NSString *)ident
{
    flags.inGeometry = YES;
    
    if ( ELTYPE(Point) )
        geometry = [[KMLPoint alloc] initWithIdentifier:ident];
    else if (ELTYPE(Polygon))
        geometry = [[KMLPolygon alloc] initWithIdentifier:ident];
    else if (ELTYPE(LineString))
    {
        
        // Check if geometries exists at the beginning of a geometry
#ifdef ADD_MULTIGEOMETRY_SUPPORT
        if ( geometries == nil)
        {
//            NSLog(@"KML - beginGeometryOfType: creating geometries");
            geometries = [[NSMutableArray alloc] init];  // Alloc/init geometries if it doesn't exist
        }
#endif
        
        geometry = [[KMLLineString alloc] initWithIdentifier:ident];
        [geometry beginMultiGeometry];
        
//        if (flags.inMultiGeometry)
//        {
//            
////            NSLog(@"KML - Placemark -- begin Geometry for LineString for %@", name);
//            // <MultieGeometry> tag found.  Initialize the geometry object only once!
//            if ( flags.firstTimeInGeometry )
//            {
//            
////                NSLog(@"KML - Placemark -- begin Geometry for LineString, create geometry object for %@", name);
//                geometry = [[KMLLineString alloc] initWithIdentifier:ident];
//                [geometry beginMultiGeometry];
//
//                [geometry setFirstTimeInGeometry];
//                flags.firstTimeInGeometry = NO;  // Guarantees the geometry object and MultiGeometry tags won't get set twice
//
//            
//            }  // if ( flags.firstTimeInGeometry )
//            else
//            {
////                NSLog(@"KML - Placemark -- begin Geometry for LineString, next LineString tag found, do not create geometry object for %@", name);
//            }
//        
//        }  // if (flags.inMultiGeometry)
//        else
//        {
////            NSLog(@"KML - Placemark -- I SHOULD NOT SEE THIS!");
//            // Default behavior when just a simple <Geometry> tag is encountered
//            geometry = [[KMLLineString alloc] initWithIdentifier:ident];
//        }  // else if (flag.inMultiGeometry)
        
    }  // else if (ELTYPE(LineString)

}
- (void)endGeometry
{
    flags.inGeometry = NO;
}

- (KMLGeometry *)geometry
{
    return geometry;
}

- (KMLPolygon *)polygon
{
    return [geometry isKindOfClass:[KMLPolygon class]] ? (id)geometry : nil;
}

- (void)_createShape
{
    
    // 1/22/13 -- Dealing with MultiGeometries
#ifdef ADD_MULTIGEOMETRY_SUPPORT
    
    if ( ![self polylines] )  // As long as polylines contains some MKPolylines...
    {
        
//        NSLog(@"KML - _createShape: Creating new mkShapes.  Should never execute.");
//        return;
        mkShapes = [[NSMutableArray alloc] init];
        
        for (KMLGeometry *singleGeometry in geometries)
        {

            MKShape *tempShape = [singleGeometry mapkitShape];
            if ( ( [tempShape conformsToProtocol:@protocol(MKOverlay)] ) )
            {
                [tempShape setTitle: name];
                [mkShapes addObject: tempShape];
            }
            else
            {
//                NSLog(@"KML - shape does not conform to MKOverlay protocol; not stored");
            }
            
        }  // for (KMLGeometry *singleGeometry in geometries)

        
        if ( [mkShapes count] )
        {
//            NSLog(@"KML - _createShape: creating MKMultiPolyLine with %d shapes", [mkShapes count] );
            self.polylines   = [[MKMultiPolyLine alloc] initWithPolylines:mkShapes];
            mkShapes   = nil;
            geometries = nil;  // Memory occupied by geometries is no longer needed
        } // if ( [mkShapes count] )

        
    }  // if ( !mkShapes )
#else
    if (!mkShape)
    {
        
        mkShape = [geometry mapkitShape];  // Inside KMLPlacemark that calls geometry mapkitShape
        mkShape.title = name;
        // Skip setting the subtitle for now because they're frequently
        // too verbose for viewing on in a callout in most kml files.
        //        mkShape.subtitle = placemarkDescription;
    }
#endif
    
}

-(NSMutableArray*) overlays
{
//    NSLog(@"KML -(NSMutableArray*)overlays: about to _createShape");
    [self _createShape];
    
    // Should probably ensure that each object added to mkShapes conformsToProtocol MKOverlay
//    if ([ [mkShapes objectAtIndex:0] conformsToProtocol:@protocol(MKOverlay) ] )
//    {
        return mkShapes;
//    }

    return nil;
    
}

- (id <MKOverlay>)overlay
{
    
//    NSLog(@"KML -(id<MKOverlay>)overlay: about to _createShape");
    [self _createShape];
    
#ifdef ADD_MULTIGEOMETRY_SUPPORT
    if ([self.polylines conformsToProtocol:@protocol(MKOverlay)])
        return (id <MKOverlay>)self.polylines;
#else
    if ([mkShape conformsToProtocol:@protocol(MKOverlay)])
        return (id <MKOverlay>)mkShape;
#endif
    
    return nil;
    
}

- (id <MKAnnotation>)point
{
    
    [self _createShape];
    
    // Make sure to check if this is an MKPointAnnotation.  MKOverlays also
    // conform to MKAnnotation, so it isn't sufficient to just check to
    // conformance to MKAnnotation.
    if ([mkShape isKindOfClass:[MKPointAnnotation class]])
        return (id <MKAnnotation>)mkShape;
    
    return nil;
}


//-(MKOverlayView *)overlayViewWithOverlay: (id<MKOverlay>) overlay
//{
//    
//    if ( !overlayView )
//    {
//        overlayView = [geometry createOverlayView:overlay];
//        [plStyle applyToOverlayPathView:overlayView];
//    }
//    
//    return nil;
//    
//}


- (MKOverlayRenderer *)overlayView
{
    
    if (!overlayView)
    {
        
#ifdef ADD_MULTIGEOMETRY_SUPPORT
        

        overlayView = [[MKMultiPolylineRenderer alloc] initWithOverlay: self.polylines];
//        overlayView = [[MKMultiPolylineView alloc] initWithOverlay: self.polylines];
        [plStyle applyToOverlayPathView:overlayView];
        self.polylines = nil; // Only needed to create the overlayView.  And since it's checked if it's nil, overlayView is only created once.
#else
        id <MKOverlay> overlay = [self overlay];
        if (overlay)
        {
            overlayView = [geometry createOverlayView:overlay];
            [plStyle applyToOverlayPathView:overlayView];
        }
#endif
        
    }
    
    return overlayView;
    
}


- (MKAnnotationView *)annotationView
{
    if (!annotationView) {
        id <MKAnnotation> annotation = [self point];
        if (annotation) {
            MKPinAnnotationView *pin =
            [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
            pin.canShowCallout = YES;
            pin.animatesDrop = YES;
            annotationView = pin;
        }
    }
    return annotationView;
}


@end

@implementation UIColor (KMLExtras)

+ (UIColor *)colorWithKMLString:(NSString *)kmlColorString
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:kmlColorString];
    unsigned color = 0;
    [scanner scanHexInt:&color];
    
    unsigned a = (color >> 24) & 0x000000FF;
    unsigned b = (color >> 16) & 0x000000FF;
    unsigned g = (color >> 8) & 0x000000FF;
    unsigned r = color & 0x000000FF;
    
    CGFloat rf = (CGFloat)r / 255.f;
    CGFloat gf = (CGFloat)g / 255.f;
    CGFloat bf = (CGFloat)b / 255.f;
    CGFloat af = (CGFloat)a / 255.f;
    
    
    return [UIColor colorWithRed:rf green:gf blue:bf alpha:af];
}

@end


