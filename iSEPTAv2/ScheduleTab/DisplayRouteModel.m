//
//  DisplayRouteModel.m
//  iSEPTA
//
//  Created by septa on 11/2/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "DisplayRouteModel.h"
#import "RouteData.h"
#import "DisplayedRouteData.h"

@implementation DisplayRouteModel
{
    NSInteger sections;
//    NSInteger sectionFlag;
    
    NSInteger directionSize;
    
    BOOL _useInboundData;  // 1 yes (where inbound is 1 anyway in the GTFS guidelines, 0 is outbound)
    
    NSMutableArray *_inboundSectionIndex;
    NSMutableArray *_inboundSectionTitle;
    
    NSMutableArray *_outboundSectionIndex;
    NSMutableArray *_outboundSectionTitle;
}

//@synthesize sections = _sections;

@synthesize inbound  = _inbound;
@synthesize outbound = _outbound;

@synthesize favorites      = _favorites;
@synthesize recentlyViewed = _recentlyViewed;

@synthesize directions = _directions;

@synthesize inboundName;
@synthesize outboundName;

//@synthesize sectionName;

-(id) init
{
    if (  ( self = [super init] ) )
    {
//        self.sections = [[NSMutableArray alloc] init];
        
        sections = 0;
        directionSize = 0;
        _useInboundData = 0;  // Use outbound
        
        self.inbound = [[NSMutableArray alloc] init];
        self.outbound = [[NSMutableArray alloc] init];
        
        self.directions = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(NSString*) nameForSection:(NSInteger)section
{

    switch (section)
    {
        case 0:
            
            if ( [self.favorites count] > 0 )
                return @"Favorites";
            else if ( [self.recentlyViewed count] > 0 )
                return @"Recent";
            else
            {
                if ( _useInboundData )
                    return inboundName;
                else
                    return outboundName;
            }
            
            break;
        case 1:
            
            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )
                return @"Recent";
            else
            {
                if ( _useInboundData )
                    return inboundName;
                else
                    return outboundName;
            }
            
            break;
        case 2:
            
            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )
            {
                if ( _useInboundData )
                    return inboundName;
                else
                    return outboundName;
            }
            else
                return 0;
            
            break;
        case 3:
            return _useInboundData ? inboundName : outboundName;
            break;
        default:
            return 0;
            break;
            
    }
    
    
//    switch (section)
//    {
//        case 0:
//            
//            if ( [self.favorites count] > 0 )  // if ( sectionFlag & 8 )
//                return @"Favorites";
//            else if ( [self.recentlyViewed count] > 0 )  // if ( sectionFlag & 4 )
//                return @"Recently Viewed";
//            else
//                return outboundName;
//            
//            break;
//        case 1:
//            
//            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )  // if ( sectionFlag & 12 )
//                return @"Recently Viewed";
//            else if ( ( [self.recentlyViewed count] == 0 ) && ( [self.favorites count] == 0 ) ) // if ( !(sectionFlag & 12 ) )
//                return inboundName;
//            else
//                return outboundName;
//            
//            break;
//        case 2:
//            
//            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) ) // if ( sectionFlag & 12 )
//                return outboundName;
//            else
//                return inboundName;
//            
//            break;
//        case 3:
//            return inboundName;
//            break;
//        default:
//            return nil;
//            break;
//            
//    }
    
    return nil;
}


-(NSInteger) numberOfSections
{
    return sections;
}


-(NSInteger) numberOfRowsForSection:(NSInteger)section
{
    
    /*
         old
      F  R  O  I |
     ------------|------------
      0  0  0  0 | xxxxxxxxxx  (I && O will always be one)
      0  0  0  1 | xxxxxxxxxx
      0  0  1  0 | xxxxxxxxxx
      0  0  1  1 | O:0, I:1
      0  1  0  0 | xxxxxxxxxx
      0  1  0  1 | xxxxxxxxxx
      0  1  1  0 | xxxxxxxxxx
      0  1  1  1 | R:0, O:1, I:2
      1  0  0  0 | xxxxxxxxxx
      1  0  0  1 | xxxxxxxxxx
      1  0  1  0 | xxxxxxxxxx
      1  0  1  1 | F:0, O:1, I:2
      1  1  0  0 | xxxxxxxxxx
      1  1  0  1 | xxxxxxxxxx
      1  1  1  0 | xxxxxxxxxx
      1  1  1  1 | F:0, R:1, O:2, I:3

     What does this mean?  Section 0 can be either F, R or I.  Section 1 can be R, I, or O.  Section 2 can be I or O while Section 3 is only O.
     
        (NEW)
     F  R  IO |
     ---------|------------
     0  0  0  | xxxxxxxxxx  (I && O will always be one)
     0  0  1  | IO:0
     0  1  0  | xxxxxxxxxx
     0  1  1  | R :0, IO:1
     1  0  0  | xxxxxxxxxx
     1  0  1  | F :0, IO:1
     1  1  0  | xxxxxxxxxx
     1  1  1  | F :0, R :1, IO:2
     
     */
    
    switch (section)
    {
        case 0:
            
            if ( [self.favorites count] > 0 )
                return [self.favorites count];
            else if ( [self.recentlyViewed count] > 0 )  
                return [self.recentlyViewed count];
            else
            {
                if ( _useInboundData )
                    return [self numberOfInboundRows];
                else
                    return [self numberOfOutboundRows];
            }
            
            break;
        case 1:

            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )
                return [self.recentlyViewed count];
            else
            {
                if ( _useInboundData )
                    return [self numberOfInboundRows];
                else
                    return [self numberOfOutboundRows];
            }
            
            break;
        case 2:
            
            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )
            {
                if ( _useInboundData )
                    return [self numberOfInboundRows];
                else
                    return [self numberOfOutboundRows];
            }
            else
                return 0;
            
            break;
        case 3:
            return _useInboundData ? [self numberOfInboundRows] : [self numberOfOutboundRows];
            break;
        default:
            return 0;
            break;
            
    }

    
}


-(id) objectForIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section)
    {
        case 0:
            
            if ( [self.favorites count] > 0 )
                return [self.favorites objectAtIndex:indexPath.row];
            else if ( [self.recentlyViewed count] > 0 )
                return [self.recentlyViewed objectAtIndex: indexPath.row];
            else
            {
                if ( _useInboundData )
                    return [self.inbound objectAtIndex: indexPath.row];
                else
                    return [self.outbound objectAtIndex: indexPath.row];
            }
            
            break;
        case 1:
            
            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )
                return [self.recentlyViewed objectAtIndex: indexPath.row];
            else
            {
                if ( _useInboundData )
                    return [self.inbound objectAtIndex: indexPath.row];
                else
                    return [self.outbound objectAtIndex: indexPath.row];
            }
            
            break;
        case 2:
            
            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )
            {
                if ( _useInboundData )
                    return [self.inbound objectAtIndex: indexPath.row];
                else
                    return [self.outbound objectAtIndex: indexPath.row];
            }
            else
                return 0;
            
            break;
        case 3:
            return _useInboundData ? [self.inbound objectAtIndex: indexPath.row] : [self.outbound objectAtIndex: indexPath.row];
            break;
        default:
            return 0;
            break;
            
    }
    
    
//    switch ( indexPath.section )
//    {
//        case 0:
//            
//            if ( [self.favorites count] > 0 )  // if ( sectionFlag & 8 )
//                return [self.favorites objectAtIndex:indexPath.row];
//            else if ( [self.recentlyViewed count] > 0 )  // if ( sectionFlag & 4 )
//                return [self.recentlyViewed objectAtIndex:indexPath.row];
//            else
//                return [self.outbound objectAtIndex:indexPath.row];
//            
//            break;
//        case 1:
//            
//            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) )  // if ( sectionFlag & 12 )
//                return [self.recentlyViewed objectAtIndex:indexPath.row];
//            else if ( ( [self.recentlyViewed count] == 0 ) && ( [self.favorites count] == 0 ) ) // if ( !(sectionFlag & 12 ) )
//                return [self.inbound objectAtIndex:indexPath.row];
//            else
//                return [self.outbound objectAtIndex:indexPath.row];
//            
//            break;
//        case 2:
//            
//            if ( ( [self.recentlyViewed count] > 0 ) && ( [self.favorites count] > 0 ) ) // if ( sectionFlag & 12 )
//                return [self.outbound objectAtIndex:indexPath.row];
//            else
//                return [self.inbound objectAtIndex:indexPath.row];
//            
//            break;
//        case 3:
//            return [self.inbound objectAtIndex:indexPath.row];
//            break;
//        default:
//            return 0;
//            break;
//            
//    }
    
//    if ( indexPath.section == 0 )
//    {
//        return [self.outbound objectAtIndex:indexPath.row];
//    }
//    else if ( indexPath.section == 1 )
//    {
//        return [self.inbound objectAtIndex:indexPath.row];
//    }
//    else
//        return nil;
    
}


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


-(NSString*) directionForID:(DisplayRouteSectionType) directionID
{
    
    // directionSize should be 2, though it occasionally can be 1 for routes that are just loops
    
    if ( directionSize == kDisplayRouteOutboundSection )
        return nil;
    else if ( ( directionSize == kDisplayRouteInboundSection ) && (directionID != kDisplayRouteOutboundSection) )
        return @"Goto Bottom";  // Route is a loop so have the second segmented control have no value
    
    if ( ( directionID == kDisplayRouteOutboundSection ) || ( directionID == kDisplayRouteInboundSection ) )
        return [self.directions objectAtIndex:directionID];
    else
        return nil;
    
}


-(NSInteger) getSectionForSection: (DisplayRouteSectionType) section withIndex:(NSInteger) index
{
    if ( section == kDisplayRouteOutboundSection ) // Outbound
        return [[_outboundSectionIndex objectAtIndex: index] intValue];
    else
        return [[_inboundSectionIndex objectAtIndex: index] intValue];
    
}


-(NSMutableArray*) getSectionTitleForSection:(DisplayRouteSectionType)section
{
    
    if ( section == kDisplayRouteOutboundSection ) // Outbound
        return _outboundSectionTitle;
    else
        return _inboundSectionTitle;
    
}


-(void) setInboundOrOutbound:(BOOL)inbound
{
    _useInboundData = inbound;
}


-(void) sort
{
    
    sections = ([self.inbound count] || [self.outbound count] ? 1 : 0) + ([self.favorites count] ? 1 : 0) + ([self.recentlyViewed count] ? 1 : 0);
    directionSize = [self.directions count];

    
    _inboundSectionIndex  = [[NSMutableArray alloc] init];
    _outboundSectionIndex = [[NSMutableArray alloc] init];
    
    _inboundSectionTitle  = [[NSMutableArray alloc] init];
    _outboundSectionTitle = [[NSMutableArray alloc] init];
    
    NSString *lastChar = @"";
    NSString *newChar;
    NSInteger index = 0;
        
    for (RouteData *data in self.inbound)  // Remember, inbound is section 1
    {
        newChar = [data.start_stop_name substringToIndex:1];
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
        newChar = [data.start_stop_name substringToIndex:1];
        if ( ![newChar isEqualToString:lastChar] )
        {
            [_outboundSectionTitle addObject: newChar];
            [_outboundSectionIndex addObject: [NSNumber numberWithInt:index] ];
            
            lastChar = newChar;
        }
        index++;
    }
    
    
//    [self.inbound  sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//    [self.outbound sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
//    [self.inbound sortUsingComparator: sortBlock];
//    [self.outbound sortUsingComparator: sortBlock];
    
}

// Basic sorting algorithm.  If one string is larger than another, it's safe to assume it's a larger number.
// otherwise if the lengths are the same, sort normally.
// E.g.
//   "10" > "1"  - since "10" is longer it's larger  return 1
//   "2"  > "10" - since "2" is not longer than "10" return -1

// A more complicated algorithm.  The bus route ID is mostly a number stored in a string.  But there are
//   a handful of cases where it's an alphanumeric character.  In which case the above example does not work
//   out so well.  In order to address this we do a simple check to determine if the number in the string is
//   actually a number.  [string intValue] returns 0 for non-numbers and the actual number for everything else.
//   Hopefully no Bus Route will ever be 0.

// The logic:  Check both values to see if they're alphanumerics.  If they are, just compare one against the other.  Easy Peasy.
// If they're not both 0, check if one of them is.  If it's the first value return 1 (advancing the second value in the array.)
// If it's the second value return -1 (advancing the first value in the array.)

NSComparisonResult (^sortBlock)(id,id) = ^(id a, id b)
{
    
    //    int first = [(NSNumber*)[(NSMutableDictionary*)a objectForKey:@"stopName"] intValue];
    //    int second = [(NSNumber*)[(NSMutableDictionary*)b objectForKey:@"stopName"] intValue];
    
    //    if ( !first && !second )
    //        return first > second;
    //    else if (first == 0)
    //        return 1;
    //    else if (second == 0)
    //        return -1;
    //    else
    //        return (NSComparisonResult)first > second;
    
    //    return (NSComparisonResult) ([a objectForKey:@"stopName"] > [b objectForKey:@"stopName"]);
    
    return [[(RouteData*)a start_stop_name] compare: [(RouteData*)b start_stop_name] ];
    //    return [[a start_stop_name] compare: [b start_stop_name] ];
    //    return [[a objectForKey:@"stopName"] compare: [b objectForKey:@"stopName"]];
    
};


//        [self.inbound sortUsingComparator: sortBlock ];
//        [inboundArray sortUsingComparator:^NSComparisonResult(id a, id b)
//        {
//            int first = [[a objectAtIndex:0] intValue];
//            int second = [[b objectAtIndex:0] intValue];

//            if ( !first && !second )
//                return first > second;
//            else if (first == 0)
//                return 1;
//            else if (second == 0)
//                return -1;
//            else
//                return first > second;
//        }];


-(NSString*) description
{
    
    NSString *descriptionString = [NSString stringWithFormat:@"DisplayRouteModel - # of sections: %d, outbound: %d, inbound: %d, favs: %d, recent: %d, directions: %d", [self numberOfSections], [self numberOfOutboundRows], [self numberOfInboundRows], [self.favorites count], [self.recentlyViewed count], [self numberOfDirections] ];
    return descriptionString;
    
}


@end
