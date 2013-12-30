//
//  DisplayedRouteData.m
//  iSEPTA
//
//  Created by septa on 11/12/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "DisplayedRouteData.h"
#import "NSMutableArray+ManagedObjects.h"

@interface DisplayedRouteData ()

// Managed Objects Fun  \(^_^)/
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel   *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(NSURL*) applicationDocumentsDirectory;
-(void) saveContext;

@end

@implementation DisplayedRouteData
{
//    NSString *routesName;
    BOOL _isDirty;
    BOOL _isShowOnlyRoutes;

    int _recentlyViewedDisplayLimit;
    
    NSInteger numOfSections;
    
    NSMutableArray *_order;
}

@synthesize favorites      = _favorites;
@synthesize recentlyViewed = _recentlyViewed;
@synthesize routes         = _routes;
@synthesize routesName     = _routesName;

@synthesize current        = _current;

@synthesize databaseType   = _databaseType;  // Change name to storage_type?

@synthesize managedObjectContext       = _managedObjectContext;
@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


//-(id) init
//{
//    return [self initWithDatabaseType:KDisplayedRouteDataUndefined];
//}

-(id) initWithDatabaseType:(DisplayedRouteDatabaseType)databaseType
{
    
    if ( ( self = [super init] ) )
    {
        
//        if ( (databaseType != kDisplayedRouteDataUsingDBBus) && (databaseType != kDisplayedRouteDataUsingDBRail) )
        if ( ( databaseType < 0 ) || ( databaseType > KDisplayedRouteDataUndefined ) )
        {
            self = nil;  // The databaseType needs to be valid or you get nothing!
        }
        else
        {
        
            // Initialization here
            self.favorites      = [[NSMutableArray alloc] init];
            self.recentlyViewed = [[NSMutableArray alloc] init];
            self.routes         = [[NSMutableArray alloc] init];
            
            self.current        = [[RouteData alloc] init];
            _order              = [[NSMutableArray alloc] init];
            _isDirty            = NO;
            _isShowOnlyRoutes   = NO;
            
            _routesName = @"Routes";
            _databaseType = databaseType;
            
            _managedObjectContext = [self managedObjectContext];
            
            // Use managedObjectContext to populate favorites and recentlyViewed, assuming the object story actual contains any data
            [self updatePreferencesFromStore];

            
            NSString *limit = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:RecentlyViewedDisplayLimit"];
            if ( limit == nil )
            {
                _recentlyViewedDisplayLimit = 3;  // Default valus is 3
            }
            else
            {
                _recentlyViewedDisplayLimit = [limit intValue];
            }
        
            
        }  // if not valid databaseType
    }
    
    return self;
    
}

// Used during viewDidAppear method, to check if the user left the current view to update the settings
-(void) refreshSettings
{
    
    NSString *limit = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:RecentlyViewedDisplayLimit"];
    if ( limit == nil )
    {
        _recentlyViewedDisplayLimit = 3;  // Default valus is 3
    }
    else
    {
        _recentlyViewedDisplayLimit = [limit intValue];
    }
    
}

-(void) reloadSection:(DisplayedRouteDataSections) section
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    NSError *error;
    NSArray *fetchedObjects;
    
    [fetchRequest setEntity: entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(preference == %d) AND (database_type == %d)", section, _databaseType] ];
    [fetchRequest setPredicate: predicate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"added_date" ascending:NO];
    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sort] ];
    
    
    switch (section)
    {
        case kDisplayedRouteDataFavorites:
            
            fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error]; // An array of Event objects.
            [self.favorites setArray: fetchedObjects];
            [self updateSectionCountForSection:section];
            
            break;
        case kDisplayedRouteDataRecentlyViewed:

            fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];  // An array of Event objects.
            [self.recentlyViewed setArray: fetchedObjects];
            [self updateSectionCountForSection:section];

            break;
        default:
            break;
    } // switch (section)
    
    fetchedObjects = nil;
    
}

-(void) updatePreferencesFromStore
{

    [self reloadSection:kDisplayedRouteDataFavorites];
    [self reloadSection:kDisplayedRouteDataRecentlyViewed];
    
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
//    NSError *error;
//    
//    [fetchRequest setEntity: entity];
//    
//    NSPredicate *favoritePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(preference == 0) AND (database_type == %d)", _databaseType] ];
//    NSPredicate *recentlyPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(preference == 1) AND (database_type == %d)", _databaseType] ];
//
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"added_date" ascending:NO];
//    
//    [fetchRequest setPredicate: favoritePredicate];
//    [fetchRequest setSortDescriptors: [NSArray arrayWithObject:sort] ];
//    
//    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error]; // An array of Event objects.  Nice, but not altogether useful
//    [self.favorites setArray: fetchedObjects];
//    
//    
//    
//    [fetchRequest setPredicate: recentlyPredicate];
//    fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];  // An array of Event objects.  Nice, but not altogether useful
//
//    [self.recentlyViewed setArray: fetchedObjects];
//    fetchedObjects = nil;  // We no longer need this
    
//    NSLog(@"hasChanges: %d", [_managedObjectContext hasChanges]);  // Starts at 0 as the data was just loaded
//    [[self.recentlyViewed objectAtIndex:0] setAdded_date:[NSDate date] ];  // Modifies one of the Event objects
//    NSLog(@"hasChanges: %d", [_managedObjectContext hasChanges]);  // hasChanges now is 1
    
}


- (void)saveContext
{
    
    NSError *error;
    if (_managedObjectContext != nil)
    {
        
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error] )
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }  // if (_managedObjectContext != nil) {
    
}


#pragma mark - Core Data Stack
-(NSManagedObjectContext*) managedObjectContext
{
    
    if ( _managedObjectContext != nil )
        return _managedObjectContext;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if ( coordinator != nil )
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
    
}

-(NSManagedObjectModel*) managedObjectModel
{
    if ( _managedObjectModel != nil )
        return _managedObjectModel;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RouteDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    return _managedObjectModel;
    
}

-(NSPersistentStoreCoordinator*) persistentStoreCoordinator
{
    if ( _persistentStoreCoordinator != nil )
        return _persistentStoreCoordinator;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RouteDataModel.sqlite"];
    
    /*
     Set up the store.
     For the sake of illustration, provide a pre-populated default store.
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[storeURL path]]) {
        NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:@"RouteDataModel" withExtension:@"sqlite"];
        if (defaultStoreURL) {
            [fileManager copyItemAtURL:defaultStoreURL toURL:storeURL error:NULL];
        }
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSError *error;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        // TODO: Instead of aborting, handle this by deleting the old store and creating a new one
        
    }
    
    return _persistentStoreCoordinator;
    
}


#pragma mark -
#pragma mark Application's documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - UITableView Accessors

-(NSInteger) numberOfSections
{
    return numOfSections;
}

-(DisplayedRouteDataSections) sectionForIndexPath: (NSIndexPath*) path
{
    /*
     F V R | 1 2 3
    --------------
     0 0 0 | xxxxx
     0 0 1 | R
     0 1 0 | V
     0 1 1 | V R
     1 0 0 | F
     1 0 1 | F R
     1 1 0 | F V
     1 1 1 | F V R
     
     Looking for patterns.  
       * If F is 1, F is in the first position.
       * If F is 1 and V is 1, V is always in the second position.
       * Otherwise, if V is 1 (and F is 0) V is always first.
       * If R is 1, it is always in the last available slot
     
     if ( F is 1 )
       mark F is first
     
     if ( V is 1 )
       put V in the next slot
     
     if ( R is 1 )
       put R in the next slot
     
     */
    
    return [[_order objectAtIndex:path.section] intValue];
    
}

-(NSString*) sectionNameForSection:(DisplayedRouteDataSections) section
{
    
    NSInteger retrievedSection = [[_order objectAtIndex:section] intValue];
    
    switch (retrievedSection)
    {
        case kDisplayedRouteDataFavorites:
            return @"Favorites";
            break;
        case kDisplayedRouteDataRecentlyViewed:
            return @"Recently Viewed";
            break;
        case kDisplayedRouteDataRoutes:
            return _routesName;
            break;
        default:
            return nil;
            break;
    }
    
}

-(NSInteger) sectionNumberForSection:(DisplayedRouteDataSections) section
{
    /*
     
     Usage:  What is the section number for kDisplayedRouteDataFavorites?
       [routeData sectionNumberForSection: kDisplayedRouteDataFavorites];  returns NSNotFound if not found, otherwise index number
     
     */
    
    NSInteger index = [_order indexOfObject:[NSNumber numberWithInt:section] ];
    if ( index != NSNotFound )
        return [[_order objectAtIndex:index] integerValue];
    else
        return NSNotFound;
    
}

-(NSInteger) numberOfRowsInSection: (NSInteger) section
{

    if ( _order == nil )
    {
        NSLog(@"DRD - numberOfRowsInSection, _order is NIL!  DRD: %p", self);
        return 0;
    }
    
//    NSInteger index = [_order indexOfObject:[NSNumber numberWithInt:section] ];
//    if ( index != NSNotFound )
//    {
//        NSInteger retrievedSection = [[_order objectAtIndex:index] integerValue];
    
    if ( ( section >= [_order count] ) && ( section >= 0 ) )  // Check to verify that section isn't trying to access an object outside the range of _order
        return 0;
    
    NSInteger retrievedSection = [[_order objectAtIndex:section] integerValue];
        switch ( retrievedSection )
        {
            case kDisplayedRouteDataFavorites:
                return [self.favorites count];
                break;
            case kDisplayedRouteDataRecentlyViewed:
                if ( [self.recentlyViewed count] > _recentlyViewedDisplayLimit )
                    return _recentlyViewedDisplayLimit;
                else
                    return [self.recentlyViewed count];
                break;
            case kDisplayedRouteDataRoutes:
                return [self.routes count];
                break;
            default:
                return 0;
                break;
                
        } // switch (retrievedSection)
//
//    }  // if ( index != NSNotFound )
//    else
//        return 0;  // No rows for that section
    
}

#pragma mark - Fetching Data

-(RouteData*) objectWithIndexPath: (NSIndexPath*) path
{

    // favorites and recentlyViewed have an additional layer of abstraction.  Each array contains a list of Event objects, an NSManagedObject.
    // As we want to return RouteData, we'll need to do some KVC magic to copy the data from Event to the selected section.

    // This solution is much, much simpler than this.   See numberOfRowsInSection:
//    if ( path.section == kDisplayedRouteDataRecentlyViewed )
//    {
//        if ( path.row > (_recentlyViewedDisplayLimit-1) )
//        {
//            return nil;
//        }
//    }
    
    
    RouteData *route = [[RouteData alloc] init];  // Need to alloc a section of memory roughly RouteData sized to hold the retrieved data.
    NSInteger retrievedSection = [[_order objectAtIndex:path.section] intValue];
    if ( _order == nil )
    {
        NSLog(@"DRD - (RouteData*)objectWithIndexPath, _order is nil, self: %p", self);
        return nil;
    }
        
        
    NSDictionary *dict;

    switch ( retrievedSection )
    {
        case kDisplayedRouteDataFavorites:
        
            if ( [self.favorites count] < path.row )
                return nil;
        
            dict = [ [self.favorites objectAtIndex:path.row ] dictionaryWithValuesForKeys:[RouteData returnAllKeyValues] ];
            [route setValuesForKeysWithDictionary:dict];
            return route;
            break;
            
        case kDisplayedRouteDataRecentlyViewed:
        
            if ( [self.recentlyViewed count] < path.row )
                return nil;
        
            dict = [ [self.recentlyViewed objectAtIndex:path.row ] dictionaryWithValuesForKeys:[RouteData returnAllKeyValues] ];
            [route setValuesForKeysWithDictionary:dict];
            return route;
            
            break;
        case kDisplayedRouteDataRoutes:
            return [self.routes objectAtIndex: path.row];
            break;
        default:
            return nil;
            break;
    }
    
}


#pragma mark - Removing Objects

-(void) removeObjectWithIndexPath:(NSIndexPath *)path
{
    
    NSInteger retrievedSection = [[_order objectAtIndex:path.section] intValue];
    
    switch ( retrievedSection )
    {
        case kDisplayedRouteDataFavorites:
            
            [_managedObjectContext deleteObject: [self.favorites objectAtIndex:path.row] ];
            [self.favorites removeObjectAtIndex: path.row];
            [self saveContext];
            
//            if ( [self.favorites count] <= 0 )
//                [_order removeObjectAtIndex: [_order indexOfObject:[NSNumber numberWithInt:kDisplayedRouteDataFavorites] ] ];
            
            break;
            
        case kDisplayedRouteDataRecentlyViewed:

            [_managedObjectContext deleteObject: [self.recentlyViewed objectAtIndex:path.row] ];
            [self.recentlyViewed removeObjectAtIndex: path.row];
            [self saveContext];

//            if ( [self.recentlyViewed count] <= 0 )
//                [_order removeObjectAtIndex: [_order indexOfObject:[NSNumber numberWithInt:kDisplayedRouteDataRecentlyViewed] ] ];

            break;
        case kDisplayedRouteDataRoutes:
            
            [self.routes removeObjectAtIndex: path.row];

//            if ( [self.routes count] <= 0 )
//                [_order removeObjectAtIndex: [_order indexOfObject:[NSNumber numberWithInt:kDisplayedRouteDataRoutes] ] ];

            break;
        default:
            break;
    }
    
    [self updateSectionCountForSection:path.section];
    
}

//-(void) removeAllObjectsWithIndexPath:(NSIndexPath *)path
-(void) removeAllObjects
{
    for (NSNumber *number in _order)
    {
        DisplayedRouteDataSections section = [number intValue];
        [self removeAllObjectsWithSection: section];
    }
    
    [self updateSectionCountForSection:kDisplayedRouteDataFavorites];
}


-(void) removeObject:(RouteData*) object fromSection:(DisplayedRouteDataSections) section
{
    
    NSMutableArray *keys = [[RouteData returnImportantKeyValues] mutableCopy];
//    [keys removeObject:@"added_date"];
    
    NSMutableArray *genericArray;
    
    switch ( section )
    {
        case kDisplayedRouteDataFavorites:
            genericArray = self.favorites;
            break;
        case kDisplayedRouteDataRecentlyViewed:
            genericArray = self.recentlyViewed;
            break;
        default:
            return;
            break;
    }
    

    NSDictionary *objectDict = [object dictionaryWithValuesForKeys:keys];
    for (Event *ev in genericArray)
    {
        
        NSDictionary *eventDict = [ev dictionaryWithValuesForKeys:keys];

        
        if ([eventDict isEqualToDictionary: objectDict])
        {
            [_managedObjectContext deleteObject: ev];
            [self.favorites removeObject: ev];
            [self saveContext];
            break;
        }
        
    }
    
}


-(void) removeAllObjectsWithSection:(DisplayedRouteDataSections) section
{
    
    switch ( section )
    {
        case kDisplayedRouteDataFavorites:  // 0
            // Remove object from favorites
            
            for (Event *ev in self.favorites)
            {
                [_managedObjectContext deleteObject: ev];
            }
            [self saveContext];
            [self.favorites removeAllObjects];
            
            break;
        case kDisplayedRouteDataRecentlyViewed:  // 1
            // Remove object from recentlyViewed

            for (Event *ev in self.recentlyViewed)
            {
                [_managedObjectContext deleteObject: ev];
            }
            [self saveContext];
            [self.recentlyViewed removeAllObjects];
            
            break;
        case kDisplayedRouteDataRoutes:  // 2
            // Remove object from current
            [self.routes removeAllObjects];
            break;
        default:
            return;  // Default, nothing happened, just return and skip the section update.
            break;
    }
    
//    NSUInteger index = [_order indexOfObject:[NSNumber numberWithInt:section] ];
//    if ( index != NSNotFound )
//        [_order removeObjectAtIndex: index];
    
    [self updateSectionCountForSection: section];
    
}

#pragma mark - Looking for Objects in Favorites
-(BOOL) isObject:(RouteData*)object inSection:(DisplayedRouteDataSections) section
{
    
    NSMutableArray *keys = [[RouteData returnImportantKeyValues] mutableCopy];
//    [keys removeObject:@"added_date"];
    
    NSMutableArray *genericArray;
    
    switch ( section )
    {
        case kDisplayedRouteDataFavorites:
            genericArray = self.favorites;
            break;
        case kDisplayedRouteDataRecentlyViewed:
            genericArray = self.recentlyViewed;
            break;
        default:
            genericArray = nil;
            break;
    }

    
    if ( [genericArray containsObject: object withKeys:keys] )
    {
        return YES;
    }
    else
        return NO;
    
}

#pragma mark - Adding Objects to the Class
-(void) addObject:(RouteData*)object toSection:(DisplayedRouteDataSections)section
{
    
    NSMutableArray *genericArray = nil;
    
    switch ( section )
    {
        case kDisplayedRouteDataFavorites:
            genericArray = self.favorites;
            break;
        case kDisplayedRouteDataRecentlyViewed:
        {
            genericArray = self.recentlyViewed;
            
            NSMutableArray *array = [[RouteData returnImportantKeyValues] mutableCopy];
//            [array removeObject:@"added_date"];
            
            if ( [self.favorites containsObject: object withKeys: array ] )
            {
                NSLog(@"DRD - object is in favorites, update added date");
                [self addObject:object toSection:kDisplayedRouteDataFavorites];
                return;
            }
        }
            break;
        case kDisplayedRouteDataRoutes:
            [self.routes addObject: object];
            [self updateSectionCountForSection:section];
            return;
        default:
            break;
    }
    
    if ( genericArray == nil )
        return;  // If the genericArray is nil, the section parameter was bad.  Otherwise continue on.

        
    NSMutableArray *keys;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:_managedObjectContext];
    NSError *error;
    
    [fetchRequest setEntity: entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(preference == %d) AND (database_type == %d)", section, _databaseType] ];
    NSSortDescriptor *sortDescrip  = [NSSortDescriptor sortDescriptorWithKey:@"added_date" ascending:NO];
    
    NSArray *fetchedObjects; // = [_managedObjectContext executeFetchRequest:fetchRequest error:&error]; // An array of Event objects.  Nice, but not altogether useful

    [fetchRequest setPredicate: predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject: sortDescrip] ];
  
    Event *event;
    [object setPreference: section];  // Set preference so the favorites and recently viewed can be easily sorted
    [object setDatabase_type: _databaseType];
    [object setAdded_date: [NSDate date] ];

    keys = [[RouteData returnImportantKeyValues] mutableCopy];
//    [keys removeObject:@"added_date"];  // Date makes it easier to sort but adds an additional layer of complexity.  When comparing objects, we want to exclude the data field
    
    
    fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (![fetchedObjects containsObject:object withKeys: keys ])  // If object is not found in fetchedObjects, we need to add it
    {
        event = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
        [event setValuesForKeysWithDictionary: [object dictionaryWithValuesForKeys:[RouteData returnAllKeyValues] ] ];
     
        
//        if ( ( section == kDisplayedRouteDataRecentlyViewed ) && ([genericArray count] >= RECENTLY_VIEWED_MAX_DISPLAYED ) ) // Check if we've hit the recentlyViewed display limit
//        {  // Seem we've hit the limit.  Remove the last object.
//            [_managedObjectContext deleteObject: [genericArray objectAtIndex:RECENTLY_VIEWED_MAX_DISPLAYED-1] ];
//            [genericArray removeObjectAtIndex:RECENTLY_VIEWED_MAX_DISPLAYED-1];
//        }


        if ( ( section == kDisplayedRouteDataRecentlyViewed ) && ([genericArray count] >= _recentlyViewedDisplayLimit ) ) // Check if we've hit the recentlyViewed display limit
        {  // Seem we've hit the limit.  Remove the last object.
            if (_recentlyViewedDisplayLimit > 0 )
            {
                [_managedObjectContext deleteObject: [genericArray objectAtIndex:_recentlyViewedDisplayLimit-1] ];
                [genericArray removeObjectAtIndex:_recentlyViewedDisplayLimit-1];
            }
        }

        
        [genericArray insertObject:event atIndex:0];  // Remember, favorites stores a reference to the event managed object, not a RouteData object
        [self saveContext];
        [self updateSectionCountForSection:section];
    }
    else  // Otherwise the event was found in the fetchedObjects, so let's move that object ot the top of the list
    {
        
        // One of the routes already in recentlyViewed was selected, move it to the top.
        NSInteger index = [genericArray indexOfObject:object withKeys: keys];
        if ( ( index != NSNotFound ) && ( index != 0 ) )  // if index is 0, it's at the top, can't move the event object any higher.
        {
            [[genericArray objectAtIndex:index] setAdded_date:[NSDate date] ];  // Update the event object stored in the array
            [self saveContext];  // Save the object
            
            [genericArray insertObject:[genericArray objectAtIndex:index] atIndex:0];  // Reorder the data
            [genericArray removeObjectAtIndex:index+1];
        }
    }
    
    
    
//    switch ( section )
//    {
//        case kDisplayedRouteDataFavorites:
//
//            fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
//            
//            if (![fetchedObjects containsObject:object withKeys: keys ])  // If event is not found in fetchedObjects, we need to add it
//            {
//                event = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
//                [event setValuesForKeysWithDictionary: [object dictionaryWithValuesForKeys:[RouteData returnKeyValues] ] ];
//
//                [self.favorites insertObject:event atIndex:0];  // Remember, favorites stores a reference to the event managed object, not a RouteData object
//                [self saveContext];
//                [self updateSectionCountForSection:section];
//            }
//            else  // Otherwise the event was found in the fetchedObjects, so let's move that object ot the top of the list
//            {
//                
//            }
//            
//            break;
//        case kDisplayedRouteDataRecentlyViewed:  // 1
//            
//            fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
//            
//            if (![fetchedObjects containsObject:object withKeys:keys ])  // If event is not found in fetchedObjects, we need to add it
//            {
//
//                event = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];
//                [event setValuesForKeysWithDictionary: [object dictionaryWithValuesForKeys:[RouteData returnKeyValues] ] ];
//                
//
//                
//                [self.recentlyViewed insertObject:event atIndex:0];
//                [self saveContext];
//                [self updateSectionCountForSection:section];
//            }
//            else  // Otherwise the event was found in the fetchedObjects, so let's move that object to the top of the list
//            {
//                
//                    // One of the routes already in recentlyViewed was selected, move it to the top.
//                    NSInteger index = [self.recentlyViewed indexOfObject:object withKeys: keys];
//                    if ( ( index != NSNotFound ) && ( index != 0 ) )  // if index is 0, it's at the top, can't move the event object any higher.
//                    {
//                        [[self.recentlyViewed objectAtIndex:index] setAdded_date:[NSDate date] ];  // Update the evetn object stored in the array
//                        [self saveContext];  // Save the object
//                        
//                        [self.recentlyViewed insertObject:[self.recentlyViewed objectAtIndex:index] atIndex:0];  // Reorder the data
//                        [self.recentlyViewed removeObjectAtIndex:index+1];
//                    }
//                
//            }
//            
//            break;
//        case kDisplayedRouteDataRoutes:  // 2
//            [self.routes addObject: object];
//            [self updateSectionCountForSection:section];
//            break;
//        default:  // If no valid section was giving, just return.  There's nothing new to be added to the context.
//            return;
//            break;
//    }
    
}


-(void) addSelectionToCurrent:(NSIndexPath*) path
{
    
    RouteData *myRoute = [[RouteData alloc] init];
    NSDictionary *dict;
    
    NSInteger retrievedSection = [[_order objectAtIndex:path.section] intValue];

    switch (retrievedSection)
    {
        case kDisplayedRouteDataFavorites:
            
            dict = [ [self.favorites objectAtIndex:path.row ] dictionaryWithValuesForKeys:[RouteData returnAllKeyValues] ];
            [myRoute setValuesForKeysWithDictionary:dict];
            self.current = myRoute;
            
            break;
        case kDisplayedRouteDataRecentlyViewed:
            
            dict = [ [self.recentlyViewed objectAtIndex:path.row ] dictionaryWithValuesForKeys:[RouteData returnAllKeyValues] ];
            [myRoute setValuesForKeysWithDictionary:dict];
            self.current = myRoute;
            
            break;
        case kDisplayedRouteDataRoutes:
            
            self.current = [self.routes objectAtIndex: path.row];
            
            break;
        default:
            // Do nothing
            break;
    }
    
}

-(void) addCurrentToSection:(DisplayedRouteDataSections)section
{
    
    [self addObject: self.current toSection:section];
    return;
    
    
////    BOOL matchFound = NO;
//    NSMutableArray *genericArray = nil;
//    NSMutableArray *theOtherArray = nil;
//    
//    switch ( section )
//    {
//        case kDisplayedRouteDataFavorites:  // 0
//            genericArray = self.favorites;
//            theOtherArray = nil;
//            break;
//        case kDisplayedRouteDataRecentlyViewed:  // 1
//            genericArray = self.recentlyViewed;
//            theOtherArray = self.favorites;
//            break;
//        default:
//            break;
//    }
//    
//    
//    if ( genericArray != nil )
//    {
//        
//        // Check if the current RouteData object is already in the genericArray (favorites or recentlyViewed)
//        // If so, do nothing.  Otherwise add it.
//        
//        [self.current setPreference: section];  // Set preference so the favorites and recently viewed can be easily sorted.  0 is Favorites, 1 is Recent
//        [self.current setDatabase_type: _databaseType];
//        [self.current setAdded_date: [NSDate date] ];
//        
//        NSMutableArray *keys = [[RouteData returnKeyValues] mutableCopy];
//        [keys removeObject:@"added_date"];  // Date makes it easier to sort but adds an additional layer of complexity.  When comparing objects, we want to exclude the data field
//        
//        
//        if ( theOtherArray != nil )  // First, if theOtherArray is nil, there's nothing to do
//        {
//            // Since theOtherArray is not nil, let's see if the current RouteData object (self.current) is contained in it
//            if ( [theOtherArray containsObject: self.current withKeys:keys] )
//            {
//                // Yes, self.current already exists in theOtherArray.  That's all we wanted to know.  Since the data already exists in theOtherArray, why
//                // add it to the genericArray
//                return;
//            }
//        }
//        
//        
//        if ( [genericArray containsObject: self.current withKeys: keys ] )  // Is the current RouteData object (self.current) already contained in genericArray?
//        {
//            // Why yes, it is!  But where exactly in the genericArray is it?  Well, gee golly, let's find out.
//            
//            NSInteger index = [genericArray indexOfObject: self.current withKeys:keys ];  // Oh, here it is!
//            
//            if ( index != 0 )  // If it's at the top, that's exactly where we want it.  Awesome, nothing to do.
//            {
//                // But the object wasn't in the top spot (crud!) and it needs to be.  Let's do this the easy way...
//                
//                [[genericArray objectAtIndex:index] setAdded_date: [NSDate date] ];  // Update the added_date field in the genericArray
//                
//                [self saveContext];  // We've updated the date one of our managed object, so save the context
//                [self updateSectionCountForSection:section];  // If an update happened, update the section count.  Though this might not be strictly necessary
//                
//                [genericArray insertObject:[genericArray objectAtIndex:index] atIndex:0];
//                [genericArray removeObjectAtIndex:index+1];                
//                
//            } // if ( index != 0 )
//            
//            
//        }  // if ( [genericArray containsObject: self.current withKeys: keys ] )
//        else
//        {
//            
//            // Oh, the object wasn't found in genericArray.  Assuming no trickery, let's add it.  It'll be fun.
//            
//            Event *event = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:_managedObjectContext];  // Our object model
//            [event setValuesForKeysWithDictionary: [self.current dictionaryWithValuesForKeys:[RouteData returnKeyValues] ] ];                    // Populating the model with good data
//            
//            // While I'd love to keep this generic, recentlyViewed does have different rules from favorites.  Namely, how many recentlyViewed entries to maintain.
//            if ( section == kDisplayedRouteDataRecentlyViewed )
//            {
//                if ( [self.recentlyViewed count] >= RECENTLY_VIEWED_MAX_DISPLAYED )  // Has the maximum number of displayed recentlyViewed been reached?
//                {
//                    // Seems so.  Remove the last element in the array to make room for the new one
//                    [_managedObjectContext deleteObject: [self.recentlyViewed objectAtIndex:RECENTLY_VIEWED_MAX_DISPLAYED-1] ];  // Delete it from the context first
//                    [self.recentlyViewed removeObjectAtIndex:RECENTLY_VIEWED_MAX_DISPLAYED-1];  // Now that this points to a deleted object, just remove it
//                }
//            }
//            
//            [genericArray insertObject: event atIndex:0];  // Because this is the most recently viewed object, put it at the top spot!
//            [self saveContext];  // And because event was created above in the scratchpad area, to save it to the data store, we just need to save the context
//            [self updateSectionCountForSection:section];  // If an update happened, update the section count.
//        }
//        
//    }  // if ( genericArray != nil )

        // Favorites and RecentlyViewed are essential partial or fully completed routes.
        // Where as Routes is a generic handle of either the route_short_names or stop_names
        // Thus, it makes sense for there to exist mulitple favorites for the same route_short_name while the route_short_name is not removed from the full list
    
}


-(void) updateSectionCountForSection:(DisplayedRouteDataSections) section
{

//    static NSInteger DRDupdateSectionCount = 0;
//    DRDupdateSectionCount++;
//    NSLog(@"DRD - Number of times updateSelectionCount has been called: %d", DRDupdateSectionCount);
    
    
    /*
     
     Purpose is to recalculate _order to properly reflect the number of sections to display, and more importantly, their order.
     Passed to this method is the value that has changes.  ONLY that should be checked against.
     
     */
    
//    if ( !_isShowOnlyRoutes )
//    {
//        
//        NSInteger index = [_order indexOfObject:[NSNumber numberWithInt:section] ];
//        
//        if ( index == NSNotFound )
//        {
//            // Section does not exist in _order.  Should it?
//            switch (section)
//            {
//                case kDisplayedRouteDataFavorites:
//                    if ( [self.favorites count] )
//                    break;
//                case kDisplayedRouteDataRecentlyViewed:
//                    break;
//                case kDisplayedRouteDataRoutes:
//                    break;
//                default:
//                    break;
//            }
//        }
//        
//        switch ( section)
//        {
//            case kDisplayedRouteDataFavorites:
//                
//                break;
//            case kDisplayedRouteDataRecentlyViewed:
//                
//
//                
//                
//                if ( [_recentlyViewed count] )
//                {
////                    [newOrder addObject:[NSNumber numberWithInt: kDisplayedRouteDataRecentlyViewed] ];
//                }
//                else
//                {
//                    
//                }
//                break;
//            case kDisplayedRouteDataRoutes:
//                
//                break;
//            default:
//                break;
//        }
//        
//    }
    
    
    if ( !_isShowOnlyRoutes)
    {
//        if ( ![_order containsObject:[NSNumber numberWithInt:section] ] )
//        {
            // Section does not exist in _order, add it
            
            NSMutableArray *newOrder = [[NSMutableArray alloc] init];

            if ( [_favorites count] )
                [newOrder addObject:[NSNumber numberWithInt: kDisplayedRouteDataFavorites] ];
            
            if ( [_recentlyViewed count] )
                [newOrder addObject:[NSNumber numberWithInt: kDisplayedRouteDataRecentlyViewed] ];
            
            if ( [_routes count] )
                [newOrder addObject:[NSNumber numberWithInt: kDisplayedRouteDataRoutes] ];
            
            numOfSections = ([_routes count] ? 1 : 0) + ([_favorites count] ? 1 : 0) + ([_recentlyViewed count] ? 1 : 0);
            [_order setArray: newOrder];
            
//        }
    }  // if (!_isShowOnlyRoutes)
    else
    {
        NSMutableArray *newOrder = [[NSMutableArray alloc] init];
        [newOrder addObject:[NSNumber numberWithInt: kDisplayedRouteDataRoutes] ];
        
        [_order setArray: newOrder];
        numOfSections = [_order count] + 1;
    }
    
}


-(NSString*) description
{
    return [NSString stringWithFormat:@"# of favorites: %d, recently viewied: %d, routes: %d, sections: %d", [self.favorites count], [self.recentlyViewed count], [self.routes count], [self numberOfSections] ];
}


#pragma mark - Show Only Routes
-(void) showOnlyRoutes:(BOOL) yesNo
{
    _isShowOnlyRoutes = yesNo;  // When we don't want to show Favorites and Recently Viewed, and only want to show routes
    
    [self updateSectionCountForSection:kDisplayedRouteDataRoutes];
    if ( !_isShowOnlyRoutes )
    {
        [self updateSectionCountForSection:kDisplayedRouteDataFavorites];
        [self updateSectionCountForSection:kDisplayedRouteDataRecentlyViewed];
    }
    
}


-(void) reverseSortWithSection:(DisplayedRouteDataSections)section
{
    
    NSMutableArray *ref = self.routes;
    
    
    [ref sortUsingComparator:^NSComparisonResult(id a, id b)
     {
         
         return [[b route_short_name] compare:[a route_short_name] options:NSNumericSearch];
         
         //        int first  = [[a route_short_name] intValue];
         //        int second = [[b route_short_name] intValue];
         //
         //        if ( !first && !second )
         //            return first > second;
         //        else if (first == 0)
         //            return 1;
         //        else if (second == 0)
         //            return -1;
         //        else
         //            return first > second;
         //     
         //        return a > b;
         
     }];
    
    
    
}

-(void) sortWithSection:(DisplayedRouteDataSections)section
{
    
    NSMutableArray *ref = self.routes;

    
    [ref sortUsingComparator:^NSComparisonResult(id a, id b)
    {

        return [[a route_short_name] compare:[b route_short_name] options:NSNumericSearch];
        
//        int first  = [[a route_short_name] intValue];
//        int second = [[b route_short_name] intValue];
//        
//        if ( !first && !second )
//            return first > second;
//        else if (first == 0)
//            return 1;
//        else if (second == 0)
//            return -1;
//        else
//            return first > second;
//     
//        return a > b;
        
    }];

    
    
}

@end
