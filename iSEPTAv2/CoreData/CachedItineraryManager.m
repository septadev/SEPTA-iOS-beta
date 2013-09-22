//
//  CachedItineraryManager.m
//  iSEPTA
//
//  Created by septa on 3/12/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "CachedItineraryManager.h"

#define DB_BASE_NAME   @"CachedItineraryData"
#define DB_FULL_NAME   @"CachedItineraryData.sqlite"
#define DB_EXTENSION   @"sqlite"


@interface CachedItineraryManager ()

// Managed Objects Fun  \(^_^)/
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel   *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end



@implementation CachedItineraryManager

@synthesize managedObjectContext       = _managedObjectContext;
@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Init
-(id) init
{
    
    if ( ( self = [super init] ) )
    {
        // Do your initialization stuff here!
        _managedObjectContext = [self managedObjectContext];
        
    }

    return self;
    
}

#pragma mark - Add Methods
-(void) addObject:(id) object
{
    
}

#pragma mark - Remove Methods
-(void) removeObject:(id) object
{
    
}

#pragma mark - Access Methods
-(void) objectForKey:(NSString*) objectKey
{
    
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
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DB_BASE_NAME withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    return _managedObjectModel;
    
}

-(NSPersistentStoreCoordinator*) persistentStoreCoordinator
{
    if ( _persistentStoreCoordinator != nil )
        return _persistentStoreCoordinator;
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: DB_FULL_NAME ];
    
    /*
     Set up the store.
     For the sake of illustration, provide a pre-populated default store.
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[storeURL path]]) {
        NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource: DB_FULL_NAME withExtension: DB_EXTENSION ];
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
#pragma mark CoreData Supporting Methods
// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
