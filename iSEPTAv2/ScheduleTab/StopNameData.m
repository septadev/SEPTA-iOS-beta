//
//  StopNameData.m
//  iSEPTA
//
//  Created by septa on 11/19/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "StopNameData.h"

//#define NSLog //

@implementation StopNameData
{
    NSInteger sections;
    //    NSInteger sectionFlag;
    
    NSInteger directionSize;
    
    BOOL _useInboundData;  // 1 yes (where inbound is 1 anyway in the GTFS guidelines, 0 is outbound)
    
    NSMutableArray *_inboundSectionIndex;
    NSMutableArray *_inboundSectionTitle;
    
    NSMutableArray *_outboundSectionIndex;
    NSMutableArray *_outboundSectionTitle;
    
    DisplayedRouteData *displayDataRef;
    
}

@synthesize inbound;
@synthesize outbound;

@synthesize inboundName;
@synthesize outboundName;

@synthesize directions;

-(id) initWithDisplayedRouteData:(DisplayedRouteData *)data andDatabaseType:(DisplayedRouteDatabaseType) database
{
    if (  ( self = [super initWithDatabaseType:kDisplayedRouteDataUsingDBBus] ) )
    {
        //        self.sections = [[NSMutableArray alloc] init];
        
        sections = 0;
        directionSize = 0;
        _useInboundData = 0;  // Use outbound
        
//        displayDataRef = data;
        
        self.favorites      = data.favorites;
        self.recentlyViewed = data.recentlyViewed;
        self.routes         = data.routes;
        
//        NSLog(@"SND - this object: %p, parent (DRD) object: %p", self, displayDataRef);

        self.inbound  = [[NSMutableArray alloc] init];
        self.outbound = [[NSMutableArray alloc] init];
        
        self.directions = [[NSMutableArray alloc] init];
    }
    
    return self;
}



-(NSInteger) getSectionForSection: (StopNameSectionType) section withIndex:(NSInteger) index
{
    if ( section == kStopNameOutboundSection ) // Outbound
        return [[_outboundSectionIndex objectAtIndex: index] intValue];
    else
        return [[_inboundSectionIndex objectAtIndex: index] intValue];
    
}


-(NSMutableArray*) getSectionTitleForSection:(StopNameSectionType)section
{
    
    if ( section == kStopNameOutboundSection ) // Outbound
        return _outboundSectionTitle;
    else
        return _inboundSectionTitle;
    
}


-(void) setInboundOrOutbound:(BOOL)isInbound
{
    _useInboundData = isInbound;
    if ( _useInboundData )
        self.routes = self.inbound;  // displayDataRef.routes = self.inbound;
    else
        self.routes = self.outbound;  // displayDataRef.routes = self.outbound;
}


-(void) clear
{
    [self.inbound removeAllObjects];
    [self.outbound removeAllObjects];
}

-(NSInteger) numberOfRowsInSection
{
    
    if ( _useInboundData )
        return [[self inbound] count];
    else
        return [[self outbound] count];
    
}



-(NSInteger) numberOfSections
{
    return sections;
}

//-(NSInteger) numberOfRowsInSection:(DisplayedRouteDataSections)section
//{
//    return [displayDataRef numberOfRowsInSection:section];
//}
//
//
//-(RouteData*) objectWithIndexPath:(NSIndexPath *)path
//{
//    return [displayDataRef objectWithIndexPath:path];
//}

-(void) sort
{
    
//    [displayDataRef updateSectionCountForSection: kDisplayedRouteDataRoutes];
    [self updateSectionCountForSection: kDisplayedRouteDataRoutes];
    
    [self.inbound sortUsingComparator: stopSortBlock];
    [self.outbound sortUsingComparator: stopSortBlock];
    
//    sections = ([self.inbound count] || [self.outbound count] ? 1 : 0) + ([displayDataRef.favorites count] ? 1 : 0) + ([displayDataRef.recentlyViewed count] ? 1 : 0);
    
    // For stop name data, we don't want to display favorites or recentlyViewed.  Those are complete or partial trips, here we're just interested stop names for a particular route
    sections = ([self.inbound count] || [self.outbound count] ? 1 : 0); // + ([self.favorites count] ? 1 : 0) + ([self.recentlyViewed count] ? 1 : 0);
    directionSize = [self.directions count];
    
    if ( directionSize == 1 )
    {
        [self setOutboundName: [self.directions objectAtIndex: kStopNameOutboundSection] ];
        [self setInboundName: [self.directions objectAtIndex: kStopNameOutboundSection] ];
    }
    else
    {
        [self setInboundName : [self.directions objectAtIndex: kStopNameInboundSection] ];
        [self setOutboundName: [self.directions objectAtIndex: kStopNameOutboundSection] ];
    }

    
    _inboundSectionIndex  = [[NSMutableArray alloc] init];
    _outboundSectionIndex = [[NSMutableArray alloc] init];
    
    _inboundSectionTitle  = [[NSMutableArray alloc] init];
    _outboundSectionTitle = [[NSMutableArray alloc] init];
    
    NSString *lastChar = @"";
    NSString *newChar;
    NSInteger index = 0;
    NSInteger len = 1;
    
    
    // Building table index (numbers/letters on the right side of screen.  All numbers are displayed in full.  30th Street won't show up as '3' but as '30'
    for (RouteData *data in self.inbound)  // Remember, inbound is section 1
    {
        
        len = 1;
        while ( [[data.start_stop_name substringToIndex:len] intValue] )
        {
            
            int newNum = [[data.start_stop_name substringToIndex:len] intValue];
            
            if ( newNum == [[data.start_stop_name substringToIndex:len+1] intValue] )
            {
                //newChar = [data.start_stop_name substringToIndex:len];
                break;
            }
            len++;
            
        }
        
        newChar = [data.start_stop_name substringToIndex:len];
        
        
        if ( ![newChar isEqualToString:lastChar] )
        {
            [_inboundSectionTitle addObject: newChar];
            [_inboundSectionIndex addObject: [NSNumber numberWithInt:index] ];
            
            lastChar = newChar;
        }
        index++;
    }
    
    lastChar = @"";
    index    = 0;
    for (RouteData *data in self.outbound)  // Remember, outbound is section 0
    {
        len = 1;
        while ( [[data.start_stop_name substringToIndex:len] intValue] )
        {
            
            int newNum = [[data.start_stop_name substringToIndex:len] intValue];
            
            if ( newNum == [[data.start_stop_name substringToIndex:len+1] intValue] )
            {
                //newChar = [data.start_stop_name substringToIndex:len];
                break;
            }
            len++;
            
        }
        
        newChar = [data.start_stop_name substringToIndex:len];
        
        if ( ![newChar isEqualToString:lastChar] )
        {
            [_outboundSectionTitle addObject: newChar];
            [_outboundSectionIndex addObject: [NSNumber numberWithInt:index] ];
            
            lastChar = newChar;
        }
        index++;
    }
    
    
//        [self.inbound  sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//        [self.outbound sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
}


NSComparisonResult (^stopSortBlock)(id,id) = ^(id a, id b)
{
    
    //    int first = [(NSNumber*)[(NSMutableDictionary*)a objectForKey:@"stopName"] intValue];
    //    int second = [(NSNumber*)[(NSMutableDictionary*)b objectForKey:@"stopName"] intValue];
    
    return [[a start_stop_name] compare:[b start_stop_name] options:NSNumericSearch];
    
//    int first  = [[a start_stop_name] intValue];
//    int second = [[b start_stop_name] intValue];
//    
//    if ( !first && !second )
//        return first > second;
//    else if (first == 0)
//        return 1;
//    else if (second == 0)
//        return -1;
//    else
//        return (NSComparisonResult)first > second;
    
    //    return (NSComparisonResult) ([a objectForKey:@"stopName"] > [b objectForKey:@"stopName"]);
    
//    return [[(RouteData*)a start_stop_name] compare: [(RouteData*)b start_stop_name] ];
    //    return [[a start_stop_name] compare: [b start_stop_name] ];
    //    return [[a objectForKey:@"stopName"] compare: [b objectForKey:@"stopName"]];
    
};

-(NSInteger) numberOfInboundRows
{
    return [self.inbound count];
}

-(NSInteger) numberOfOutboundRows
{
    return [self.outbound count];
}

-(NSInteger) numberOfDirections
{
    return directionSize;
}

-(NSString*) directionForID:(StopNameSectionType) directionID
{
    
    // directionSize should be 2, though it occasionally can be 1 for routes that are just loops
    
    if ( directionSize == kStopNameOutboundSection )
        return nil;
    else if ( ( directionSize == kStopNameInboundSection ) && (directionID != kStopNameOutboundSection) )
        return @"";
//        return @"Goto Bottom";  // Route is a loop so have the second segmented control have no value
    
    if ( ( directionID == kStopNameOutboundSection ) || ( directionID == kStopNameInboundSection ) )
        return [self.directions objectAtIndex:directionID];
    else
        return nil;
    
}



// Override all IndexPath methods from DisplayedRouteData because we don't want to display Favorites or Recently Viewed data here
-(RouteData*) objectWithIndexPath: (NSIndexPath*) path
{
    
    if ( _useInboundData )
        return [self.inbound objectAtIndex: path.row];
    else
        return [self.outbound objectAtIndex: path.row];
    
}


-(void) removeObjectWithIndexPath:(NSIndexPath *)path
{
    
    if ( _useInboundData )
        [ [self inbound] removeObjectAtIndex: path.row];
    else
        [ [self outbound] removeObjectAtIndex: path.row];
    
}

-(void) removeAllObjects  // Ok, it's not an IndexPath method but we still don't want it touching the Favorites or Recently Viewed
{
    
    [[self inbound] removeAllObjects];
    [[self outbound] removeAllObjects];
    
}

-(void) removeAllObjectsWithSection:(DisplayedRouteDataSections) section
{
    // Capture this method call and just don't do anything
}


// TODO:  Take the time to fix this!
// Section is unnecessary as BusDisplayStopsVC has no sections.  Just two different data sets that are swapped when the segment button is changed
// Remove all unnecessary sections and just allow the segment to change the _useInboundData switch.
-(NSString*) nameForSection:(NSInteger) section
{
    
    switch (section)
    {
        case 0:
            
//            if ( [self.favorites count] > 0 ) //if ( [displayDataRef.favorites count] > 0 )
//                return @"Favorites";
//            else if ( [self.recentlyViewed count] > 0 )  // else if ( [displayDataRef.recentlyViewed count] > 0 )
//                return @"Recent";
//            else
//            {
                if ( _useInboundData )
                    return inboundName;
                else
                    return outboundName;
//            }
            
            break;
        case 1:
            
//            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )  // if ( ( [displayDataRef.recentlyViewed count] > 0 ) && ( [displayDataRef.favorites count] > 0 ) )
//                return @"Recent";
//            else
//            {
                if ( _useInboundData )
                    return inboundName;
                else
                    return outboundName;
//            }
            
            break;
        case 2:
            
//            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )  // if ( ( [displayDataRef.recentlyViewed count] > 0 ) && ( [displayDataRef.favorites count] > 0 ) )
//            {
                if ( _useInboundData )
                    return inboundName;
                else
                    return outboundName;
//            }
//            else
//                return 0;
            
            break;
        case 3:
            return _useInboundData ? inboundName : outboundName;
            break;
        default:
            return 0;
            break;
            
    }
    
    return nil;
}


-(NSString*) description
{
//    return [NSString stringWithFormat:@"# of favorites: %d, recently viewied: %d, inbound: %d, outbound: %d, sections: %d", [displayDataRef.favorites count], [displayDataRef.recentlyViewed count], [self.inbound count], [self.outbound count], [self numberOfSections] ];

    return [NSString stringWithFormat:@"# of favorites: %d, recently viewied: %d, inbound: %d, outbound: %d, sections: %d", [self.favorites count], [self.recentlyViewed count], [self.inbound count], [self.outbound count], [self numberOfSections] ];
}


@end
