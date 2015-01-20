//
//  ShowTimesModel.m
//  iSEPTA
//
//  Created by septa on 11/5/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "ShowTimesModel.h"

@implementation ShowTimesModel
{
    NSInteger _placeholders;
    
    NSMutableArray *_timesSectionIndex;
    NSMutableArray *_timesSectionTitle;
}

//@synthesize times = _times;
//@synthesize stops = _stops;


-(id) init
{
    
    if ( ( self = [super init] ) )
    {
        
//        _stops = [[NSMutableDictionary alloc] init];
        _times = [[NSMutableArray alloc] init];
        _placeholders = 0;
    }
    
    return self;
    
}

-(id) initWithPlaceholders:(NSInteger) numberOfPlaceholders
{
    if ( ( self = [super init] ) )
    {
        _times = [[NSMutableArray alloc] init];
        
        _placeholders = numberOfPlaceholders;
        for (int LCV=0; LCV < numberOfPlaceholders; LCV++)
        {
            //        [_times addObject:[NSDictionary dictionaryWithObject:@"Click to enter destination" forKey:@"stop_name"] ];  // Placeholder for the start cell
            TripData *trip = [[TripData alloc] init];
            [trip setStart_stop_name : @"Click to enter destination"];
            [trip setEnd_stop_name   : @"Click to enter destination"];
            [_times addObject: trip];
        }
        
    }  // if ( ( self = [super init] ) )
    
    return self;
    
}

-(void) insert:(TripData *) times atIndex: (NSUInteger) index
{
    [_times insertObject:times atIndex:index];
}

-(void) addTimes:(TripData *)times
{
    [_times addObject: times];
}

-(NSInteger) numberOfRows
{
    return [_times count];
}

-(NSInteger) numberOfSections
{
    return 1;  // Right now this Data Model only has 1 section
}

-(TripData*) objectForIndexPath:(NSIndexPath *)path
{
    return [_times objectAtIndex:path.row];
}


-(void) clearIndex
{
    _timesSectionIndex = nil;
    _timesSectionTitle = nil;
}


-(void) generateIndex
{
    
    _timesSectionIndex  = [[NSMutableArray alloc] init];
    _timesSectionTitle  = [[NSMutableArray alloc] init];
    
    NSString *lastChar = @"";
    NSString *newChar;
    NSInteger index = 0;
    NSInteger len = 1;
    
//    NSLog(@"STM - sequence length: %d", [_times count]);

    // Uncomment these two blocks of code to reduce the index size by half once the stop sequences exceed a certain length.  Avoids the solid circle between inserted inbetween letters
//    BOOL everyOther = NO;
//    if ( [_times count] > 26 )
//    {
//        everyOther = YES;
//    }
    
    for (TripData *data in _times)  // Remember, inbound is section 1
    {
        
//        if ( everyOther )
//        {
//        
//            if ( ( ( index % 2 ) == 1 ) && ( index != ([_times count]-1) ) )  // Right side of the AND statement ensures the last stop is listed in the index
//            {
//                index++;
//                continue;
//            }
//            
//        }
        
        len = 1;
        while ( ( [[data.start_stop_name substringToIndex:len] intValue] ) && ( len < [data.start_stop_name length] ) )
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
            [_timesSectionTitle addObject: newChar];
            [_timesSectionIndex addObject: [NSNumber numberWithInt:(int)index] ];
            
//            NSLog(@"STM - title: %@, index: %d", newChar, index);
            
            lastChar = newChar;
        }
        index++;
    }
    
}

-(void) sort
{
    [_times sortUsingComparator: sortTimesBlock];
    [self generateIndex];
}


//NSComparisonResult (^sortBlock)(id,id) = ^(id a, id b)
//{
//    
//    //    int first = [(NSNumber*)[(NSMutableDictionary*)a objectForKey:@"stopName"] intValue];
//    //    int second = [(NSNumber*)[(NSMutableDictionary*)b objectForKey:@"stopName"] intValue];
//    
//    //    if ( !first && !second )
//    //        return first > second;
//    //    else if (first == 0)
//    //        return 1;
//    //    else if (second == 0)
//    //        return -1;
//    //    else
//    //        return (NSComparisonResult)first > second;
//    
//    //    return (NSComparisonResult) ([a objectForKey:@"stopName"] > [b objectForKey:@"stopName"]);
//    
//    return [[(RouteData*)a start_stop_name] compare: [(RouteData*)b start_stop_name] ];
//    //    return [[a start_stop_name] compare: [b start_stop_name] ];
//    //    return [[a objectForKey:@"stopName"] compare: [b objectForKey:@"stopName"]];
//    
//};

NSComparisonResult (^sortTimesBlock)(id,id) = ^(id a, id b)
{
//  This sort here is good, and Imma gonna let you finish, but I just wanted to say that it won't properly handle numbers
//    return [[a start_stop_name] compare: [b start_stop_name]];

//  And why doesn't it handle numbers properly?  Because you're an idiot and didn't select the right option.
    
    return [[a start_stop_name] compare:[b start_stop_name] options:NSNumericSearch];  // Oh, look at that.  It handles numbers properly.
    
    
    // NSComparisonResult...  -1 is Ascending, 0 is Ordered same and 1 is Descending
    
//    int aInt = [[a start_stop_name] intValue];  // Returns 0 if the a does not begin with a valid number
//    int bInt = [[b start_stop_name] intValue];  // Returns 0 if the b does not being with a valid numbe
//    
////    NSLog(@"a: %@, b: %@", [a start_stop_name], [b start_stop_name]);
//    
//    if ( aInt && bInt )             // As long as both aInt and bInt aren't 0, they're integers and we want to do a simple numeric comparsion
//        return (NSComparisonResult)(aInt > bInt);         // Straight up, dead simple numeric comparsion here
//    else if ( aInt && !bInt )       // If aInt is an integer and b isn't make sure that a comes first;  steadyfast rule: Integers Before Strings
//        return (NSComparisonResult)-1;                  // This means, a in relationship to b should be above b, or they need to be layed out in ascending order (-1)
//    else if ( bInt && !aInt )       // But if bInt is the integer and a isn't, make sure that b comes first
//        return (NSComparisonResult)1;                   // This means, a in relationship to b should be below b, or they need to be layed out in descending order (1)
//    else
//        return [[a start_stop_name] compare:[b start_stop_name] ];  // If we got to this point, both a and b are strings and we just want a simple string comparison
    

};


-(NSInteger) getSectionWithIndex:(NSInteger)index
{
    return [[_timesSectionIndex objectAtIndex: index] intValue];
}


-(NSMutableArray*) getSectionTitle
{
    return _timesSectionTitle;
}



-(void) replaceObjectForIndexPath:(NSIndexPath*) path withObject:(id) object
{
    [_times replaceObjectAtIndex:path.row withObject:object];
}

-(void) clearData
{
    // Retain the placeholders, but remove everything else
    NSRange range = NSMakeRange(_placeholders, [_times count] - _placeholders);
    [_times removeObjectsInRange:range];
    [self clearIndex];
}

-(void) flipStartEnd
{
    
    [(TripData*)[_times objectAtIndex:0] switchStartEnd ];
    [(TripData*)[_times objectAtIndex:1] switchStartEnd ];

    TripData *temp = [[_times objectAtIndex:0] copy];
    [_times replaceObjectAtIndex:0 withObject:[_times objectAtIndex:1] ];
    [_times replaceObjectAtIndex:1 withObject:temp];
    
}


-(void) switchRow:(NSInteger)firstRow withRow:(NSInteger)secondRow
{
    NSMutableArray *holder = [[_times objectAtIndex:firstRow] copy];    
    [_times replaceObjectAtIndex:firstRow withObject:[_times objectAtIndex:secondRow] ];
    [_times replaceObjectAtIndex:secondRow withObject:holder];
    
    
    
}

@end
