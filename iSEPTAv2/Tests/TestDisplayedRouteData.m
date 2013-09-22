//
//  TestDisplayedRouteData.m
//  iSEPTA
//
//  Created by septa on 11/13/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "TestDisplayedRouteData.h"

@implementation TestDisplayedRouteData
{
    RouteData *_dataSet1;
    RouteData *_dataSet2;
    
    DisplayedRouteData *_routeData;
    
}


-(id) init
{
    
    if ( ( self = [super init] ) )
    {
//        _dataSet1 = [[RouteData alloc] init];
//        _dataSet2 = [[RouteData alloc] init];
//        
//        _routeData = [[DisplayedRouteData alloc] init];
    }
    
    return self;
    
}

-(void) testCopy
{
    
    _dataSet1 = [[RouteData alloc] init];
    _dataSet2 = [[RouteData alloc] init];
    
    // Populate _dataSet1
    [_dataSet1 setStart_stop_name: @"first stop"];
    [_dataSet1 setStart_stop_id  : 25];
    
    [_dataSet1 setEnd_stop_name: @"last stop"];
    [_dataSet1 setEnd_stop_id  : 1000];
    
    [_dataSet1 setRoute_id: @"16934"];
    [_dataSet1 setRoute_short_name:@"1"];
    
    _dataSet2 = [_dataSet1 copy];
    
    // TODO: Is there a KVC way test _dataSet1 and _dataSet2
    NSDictionary *dictForDataSet1 = [_dataSet1 dictionaryWithValuesForKeys:[RouteData returnAllKeyValues] ];
    NSDictionary *dictForDataSet2 = [_dataSet2 dictionaryWithValuesForKeys:[RouteData returnAllKeyValues] ];
    
//    if ( [_dataSet2.startStopName isEqualToString: _dataSet1.startStopName] && [_dataSet2.endStopName isEqualToString: _dataSet1.endStopName] )
    if ( [dictForDataSet1 isEqualToDictionary: dictForDataSet2] )
    {
        NSLog(@"_dataSet1 copies its data into _dataSet2 successfully");
    }
    else
    {
        NSLog(@"_dataSet2 data does not match _dataSet1");
    }
    
}

-(void) testDataStore
{
    
    // Create Data Store
//    _routeData = [[DisplayedRouteData alloc] init];
//    [_routeData setDatabaseType:kDisplayedRouteDataUsingDBBus];
    
    static NSInteger uid = 0;
    uid = (NSInteger)(arc4random() % 10000);
    uid++;
    
    _routeData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingDBBus];
    
    // Populate Data Store
    _dataSet1 = [[RouteData alloc] init];
    _dataSet2 = [[RouteData alloc] init];
    
    // Populate _dataSet1
    [_dataSet1 setStart_stop_name: @"favorite stop"];
    [_dataSet1 setStart_stop_id  : uid];
    
    [_dataSet1 setEnd_stop_name: @"last stop"];
    [_dataSet1 setEnd_stop_id  : uid+100];
    
    [_dataSet1 setRoute_id: @"16934"];
    [_dataSet1 setRoute_short_name:@"1"];
    
    // Copy _dataSet1 into _dataSet2
    _dataSet2 = [_dataSet1 copy];
    
    // Make some minor changes to _dataSet2
    uid++;
    [_dataSet2 setStart_stop_id  : uid];
    [_dataSet2 setStart_stop_name: @"viewed start"];
    [_dataSet2 setEnd_stop_name  : @"viewed end"];
    [_dataSet2 setEnd_stop_id  : uid+100 ];
    
    [_routeData addObject:_dataSet1 toSection:kDisplayedRouteDataFavorites];
    [_routeData addObject:_dataSet1 toSection:kDisplayedRouteDataFavorites];
    [_routeData addObject:_dataSet1 toSection:kDisplayedRouteDataFavorites];
    
    [_routeData addObject:_dataSet2 toSection:kDisplayedRouteDataRecentlyViewed];
    
    // Fetch Data from Data Store
//    RouteData *test1 = [_routeData objectWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:kDisplayedRouteDataFavorites] ];
//    RouteData *test2 = [_routeData objectWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:kDisplayedRouteDataRecentlyViewed] ];
//    
//    NSLog(@"Test1: %@", test1);
//    NSLog(@"Test2: %@", test2);
    
    NSLog(@"Post Add              - RouteData Info: %@", _routeData );
    
    // Delete Data Store
    [_routeData removeObjectWithIndexPath:[NSIndexPath indexPathForRow:0 inSection: kDisplayedRouteDataFavorites] ];
    NSLog(@"Post Favorites Delete - RouteData Info: %@", _routeData );
    [_routeData removeObjectWithIndexPath:[NSIndexPath indexPathForRow:0 inSection: kDisplayedRouteDataFavorites] ];
    NSLog(@"Post Favorites Delete - RouteData Info: %@", _routeData );
    
    [_routeData removeObjectWithIndexPath:[NSIndexPath indexPathForRow:0 inSection: kDisplayedRouteDataRecentlyViewed] ];
    NSLog(@"Post Recently Delete  - RouteData Info: %@", _routeData );
    
    [_routeData addObject:_dataSet1 toSection:kDisplayedRouteDataFavorites];
    [_dataSet1 setStart_stop_id: _dataSet1.start_stop_id+1];
    [_dataSet1 setEnd_stop_id  : _dataSet1.end_stop_id+1  ];

    [_routeData addObject:_dataSet1 toSection:kDisplayedRouteDataFavorites];
    [_dataSet1 setStart_stop_id: _dataSet1.start_stop_id+1];
    [_dataSet1 setEnd_stop_id  : _dataSet1.end_stop_id+1  ];

    [_routeData addObject:_dataSet1 toSection:kDisplayedRouteDataFavorites];
    [_dataSet1 setStart_stop_id: _dataSet1.start_stop_id+1];
    [_dataSet1 setEnd_stop_id  : _dataSet1.end_stop_id+1  ];

    [_routeData addObject:_dataSet1 toSection:kDisplayedRouteDataFavorites];
    [_dataSet1 setStart_stop_id: _dataSet1.start_stop_id+1];
    [_dataSet1 setEnd_stop_id  : _dataSet1.end_stop_id+1  ];

    NSLog(@"Post Add Four Favs    - RouteData Info: %@", _routeData );
    
    [_routeData removeAllObjectsWithSection:kDisplayedRouteDataFavorites];
    NSLog(@"Post Fav. All Delete  - RouteData Info: %@", _routeData );

    
}


-(void) testReturnDataWithFavorites:(BOOL) favs withViewed: (BOOL) views andWithRoutes: (BOOL) routes
{
 
    NSLog(@"testReturnDataWithFavorites: %d, withViewed: %d, andWithRoutes: %d", favs, views, routes);
    
    NSInteger arraySize = 10;
    BOOL disableFavorites = !favs;
    BOOL disableViewed    = !views;
    BOOL disableRoutes    = !routes;
    
    DisplayedRouteData *routeData = [[DisplayedRouteData alloc] initWithDatabaseType:kDisplayedRouteDataUsingDBBus];
    [routeData removeAllObjectsWithSection:kDisplayedRouteDataFavorites];
    [routeData removeAllObjectsWithSection:kDisplayedRouteDataRecentlyViewed];
    [routeData removeAllObjectsWithSection:kDisplayedRouteDataRoutes];
    
    
    RouteData *favorites1 = [[RouteData alloc] init];
    RouteData *favorites2 = [[RouteData alloc] init];
    RouteData *favorites3 = [[RouteData alloc] init];
    
    // Generate Data
    if ( !disableFavorites )
    {
        [self randomlyPopulate:favorites1 withString:@"Favorites0"];
        [self randomlyPopulate:favorites2 withString:@"Favorites1"];
        [self randomlyPopulate:favorites3 withString:@"Favorites2"];
        
        [routeData addObject:favorites1 toSection:kDisplayedRouteDataFavorites];
        [routeData addObject:favorites2 toSection:kDisplayedRouteDataFavorites];
        [routeData addObject:favorites3 toSection:kDisplayedRouteDataFavorites];
    }


    RouteData *viewed1    = [[RouteData alloc] init];
    RouteData *viewed2    = [[RouteData alloc] init];
    RouteData *viewed3    = [[RouteData alloc] init];
    
    if ( !disableViewed )
    {
        [self randomlyPopulate:viewed1 withString:@"Viewed0"];
        [self randomlyPopulate:viewed2 withString:@"Viewed1"];
        [self randomlyPopulate:viewed3 withString:@"Viewed2"];
        
        [routeData addObject:viewed1    toSection:kDisplayedRouteDataRecentlyViewed];
        [routeData addObject:viewed2    toSection:kDisplayedRouteDataRecentlyViewed];
        [routeData addObject:viewed3    toSection:kDisplayedRouteDataRecentlyViewed];
    }
    
    
    if ( !disableRoutes )
    {
        NSMutableArray *routes = [[NSMutableArray alloc] init];
        
        for(int LCV = 0; LCV < arraySize; LCV++)
        {
            RouteData *temp = [[RouteData alloc] init];
            [self randomlyPopulate:temp withString:[NSString stringWithFormat:@"Routes%d", LCV] ];
            [routes addObject: temp];
            [routeData addObject: [routes objectAtIndex:LCV] toSection:kDisplayedRouteDataRoutes];
        }
        
    }
    
    
    NSLog(@"Route Info: %@", routeData);
    
    RouteData *store;
    
    //int sections = !disableFavorites + !disableViewed + !disableRoutes;
    int sections = 0;
    
    if ( !disableFavorites )
    {
        store = [routeData objectWithIndexPath:[NSIndexPath indexPathForRow:0 inSection:sections] ];
        NSLog(@"Reading Favorite Row 0  - %@, header name: %@", [store end_stop_name], [routeData sectionNameForSection:sections]);
        store = [routeData objectWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:sections] ];
        NSLog(@"Reading Favorite Row 2  - %@, header name: %@", [store end_stop_name], [routeData sectionNameForSection:sections]);
        sections++;
    }
    
    if ( !disableViewed )
    {
        store = [routeData objectWithIndexPath:[NSIndexPath indexPathForRow:1 inSection:sections] ];
        NSLog(@"Reading Viewed Row 1    - %@, header name: %@", [store end_stop_name], [routeData sectionNameForSection:sections]);
        store = [routeData objectWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:sections] ];
        NSLog(@"Reading Viewed Row 2    - %@, header name: %@", [store end_stop_name], [routeData sectionNameForSection:sections]);
        sections++;
    }

    if ( !disableRoutes )
    {
        store = [routeData objectWithIndexPath:[NSIndexPath indexPathForRow:2 inSection:sections] ];
        NSLog(@"Reading Routes Row 2    - %@, header name: %@", [store end_stop_name], [routeData sectionNameForSection:sections]);
        store = [routeData objectWithIndexPath:[NSIndexPath indexPathForRow:4 inSection:sections] ];
        NSLog(@"Reading Routes Row 4    - %@, header name: %@", [store end_stop_name], [routeData sectionNameForSection:sections]);
        store = [routeData objectWithIndexPath:[NSIndexPath indexPathForRow:5 inSection:sections] ];
        NSLog(@"Reading Routes Row 5    - %@, header name: %@", [store end_stop_name], [routeData sectionNameForSection:sections]);
        store = [routeData objectWithIndexPath:[NSIndexPath indexPathForRow:7 inSection:sections] ];
        NSLog(@"Reading Routes Row 7    - %@, header name: %@", [store end_stop_name], [routeData sectionNameForSection:sections]);
    }

    
    [routeData removeAllObjectsWithSection:kDisplayedRouteDataFavorites];
    [routeData removeAllObjectsWithSection:kDisplayedRouteDataRecentlyViewed];
    [routeData removeAllObjectsWithSection:kDisplayedRouteDataRoutes];
    
    NSLog(@" ");
    
}


-(void) randomlyPopulate:(RouteData*) data withString:(NSString*) string
{
    
    [data setStart_stop_name: string];
    [data setEnd_stop_name  : string];
    
    [data setStart_stop_id: arc4random() % 10000];
    [data setEnd_stop_id  : arc4random() % 10000];
    
    [data setRoute_short_name: string];
    [data setRoute_id: string];
    
    [data setDirection_id: arc4random() % 2];
    
}

@end
