//
//  DisplayedRouteData.h
//  iSEPTA
//
//  Created by septa on 11/12/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RouteData.h"

//#import "sqlite3.h"
#import "Event.h"

// Section 1: Favorites, if any
// Section 2: Recently Viewed, if any
// Section 3: Current Route Information

//#define RECENTLY_VIEWED_LIMIT 4;  // Most recently viewed
#define RECENTLY_VIEWED_MAX_DISPLAYED 3

//typedef NS_ENUM(NSInteger, UITableViewRowAnimation) {

typedef NS_ENUM(NSInteger, DisplayedRouteDataSections)
{
    kDisplayedRouteDataFavorites      = 0,
    kDisplayedRouteDataRecentlyViewed = 1,
    kDisplayedRouteDataRoutes         = 2,
    kDisplayedRouteDataAlerts         = 3,
    kDisplayedRouteDataOther,
};


typedef NS_ENUM(NSInteger, DisplayedRouteDatabaseType)
{
    kDisplayedRouteDataUsingDBBus,
    kDisplayedRouteDataUsingDBRail,
    kDisplayedRouteDataUsingMFL,  // Uses SEPTAbus
    kDisplayedRouteDataUsingNHSL, // Uses SEPTAbus
    kDisplayedRouteDataUsingBSS,  // Uses SEPTAbus
    kDisplayedRouteDataUsingTrolley,
    KDisplayedRouteDataUndefined,
};

@interface DisplayedRouteData : NSObject
{
    NSMutableArray *_favorites;
    NSMutableArray *_recentlyViewed;
    NSMutableArray *_alerts;
    NSMutableArray *_routes;
    RouteData      *_current;
    
    NSString       *_routesName;
    DisplayedRouteDatabaseType _databaseType;
    
//    sqlite3 *dbh;

}

// Public Properties
@property (nonatomic, strong) NSMutableArray *favorites;
@property (nonatomic, strong) NSMutableArray *recentlyViewed;

@property (nonatomic, strong) NSMutableArray *alerts;
@property (nonatomic, strong) NSMutableArray *routes;
@property (nonatomic, strong) RouteData      *current;

@property (nonatomic, strong) NSString *routesName;

@property (nonatomic) DisplayedRouteDatabaseType databaseType;

// Public Methods
-(id) initWithDatabaseType: (DisplayedRouteDatabaseType) databaseType;

-(NSInteger) numberOfSections;
-(NSString*) sectionNameForSection: (DisplayedRouteDataSections) section;
-(NSInteger) numberOfRowsInSection: (NSInteger) section;
-(NSInteger) sectionNumberForSection: (DisplayedRouteDataSections) section;

-(RouteData*) objectWithIndexPath: (NSIndexPath*) path;
-(void) removeObjectWithIndexPath: (NSIndexPath*) path;
-(void) removeObject:(RouteData*) object fromSection:(DisplayedRouteDataSections) section;

-(void) removeAllObjectsWithSection:(DisplayedRouteDataSections) section;
-(void) removeAllObjects;

-(DisplayedRouteDataSections) sectionForIndexPath: (NSIndexPath*) path;

-(void) addObject:(RouteData*) object toSection: (DisplayedRouteDataSections) section;
-(void) addCurrentToSection: (DisplayedRouteDataSections) section;
-(void) addSelectionToCurrent:(NSIndexPath*) path;

-(BOOL) isObject:(RouteData*)object inSection:(DisplayedRouteDataSections) section;

-(void) showOnlyRoutes: (BOOL) yesNo;

#pragma mark - Sorting
-(void) reverseSortWithSection:(DisplayedRouteDataSections)section;
-(void) sortWithSection: (DisplayedRouteDataSections) section;


-(void) updateSectionCountForSection:(DisplayedRouteDataSections) section;
-(void) reloadSection:(DisplayedRouteDataSections) section;

-(void) refreshSettings;

@end
