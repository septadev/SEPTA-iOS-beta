//
//  NTASaveController.m
//  iSEPTA
//
//  Created by apessos on 12/21/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "NTASaveController.h"
#import "NSMutableArray+ManagedObjects.h"

#define NTA_SAVE_KEY @"NextToArrive:Saves"
#define FAVORITES    @"Favorites"
#define RECENT       @"Recent"

@implementation NTASaveController
{
    BOOL _isFavoritesDirty;
    BOOL _isRecentDirty;
    
    NSString *_recentLimit;
}


@synthesize favorites;
@synthesize recent;

-(id) init
{
    if ( ( self = [super init] ) )
    {
        // Load favorites and recent from the NTASaveObject
        
//         How to save data:
//         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_new24HourTimeValue] forKey:@"Settings:24HourTime"];
//         [[NSUserDefaults standardUserDefaults] synchronize];
//         
//         How to retrieve data:
//         id object = [[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:24HourTime"];
        
        _recentLimit = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:@"Settings:RecentlyViewedDisplayLimit"];
        if ( _recentLimit == nil )
        {
            _recentLimit = @"3";  // Default to 3 if no values have been stored
        }
        
        NSDictionary *saves = [[NSUserDefaults standardUserDefaults] objectForKey: NTA_SAVE_KEY];

        
        if ( [saves objectForKey:FAVORITES] )           // If Favorites exist in NSUserDefaults
        {
            NSData *favoriteData = [saves objectForKey:FAVORITES];  // Read the data
            favorites = [NSKeyedUnarchiver unarchiveObjectWithData:favoriteData];  // Convert data to array
        }
        else                                            // Otherwise is needs to be created
            favorites = [[NSMutableArray alloc] init]; 
        
        
        if ( [saves objectForKey:RECENT] )
        {
//            recent = [saves objectForKey:RECENT];
            
            NSData *recentData = [saves objectForKey:RECENT];  // Read the data
            recent = [NSKeyedUnarchiver unarchiveObjectWithData:recentData];  // Convert data to
            
        }
        else
            recent = [[NSMutableArray alloc] init];
        

        
        _isFavoritesDirty = NO;
        _isRecentDirty    = NO;
        
        // Favorites and Recently Viewed contain NTASaveObject
        

    }
    
    return self;
}


// This is used when the data in recent or favorites has been modify and the class needs to know
// about it.
-(void) makeSectionDirty:(NTASaveSection) section
{
    
    if ( section == kNTASectionFavorites )
        _isFavoritesDirty = YES;
    else if ( section == kNTASectionRecentlyViewed )
        _isRecentDirty = YES;
    
}

-(void) save
{
    
    if ( _isFavoritesDirty || _isRecentDirty )
    {
        NSMutableDictionary *saveDict = [[NSMutableDictionary alloc] init];
        
        NSData *favoriteData = [NSKeyedArchiver archivedDataWithRootObject:favorites];
        NSData *recentData   = [NSKeyedArchiver archivedDataWithRootObject:recent];
        
        [saveDict setObject:favoriteData forKey: FAVORITES];
        [saveDict setObject:recentData   forKey: RECENT   ];
        
        [[NSUserDefaults standardUserDefaults] setObject:saveDict forKey: NTA_SAVE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        _isFavoritesDirty = NO;
        _isRecentDirty    = NO;
    }
    
}

-(void) sortSection:(NTASaveSection) section
{
    
    switch (section) {
        case kNTASectionFavorites:
            [favorites sortUsingComparator:^NSComparisonResult(NTASaveObject *a, NTASaveObject *b)
             {
                 return [a addedDate] > [b addedDate];
             }];
            
            break;
        case kNTASectionRecentlyViewed:
            [recent sortUsingComparator:^NSComparisonResult(NTASaveObject *a, NTASaveObject *b)
             {
//                 return [[a startStopName] compare: [b startStopName] ];
                 return [a addedDate] > [b addedDate];
             }];
            
            break;
        case kNTASectionAll:
            
            // RECURSION!  ...kinda
            [self sortSection:kNTASectionFavorites];
            [self sortSection:kNTASectionRecentlyViewed];
            
            break;
        default:
            break;
    }
    
}

-(NSInteger) addObject:(NTASaveObject*) object intoSection:(NTASaveSection) section
{
    
    NSInteger foundAt = -1;
    
    switch (section)
    {
        case kNTASectionFavorites:
            // Add object to Favorites
            
            foundAt = [favorites indexOfObject:object withKeys:[NTASaveObject returnImportantKeys] ];
            if ( foundAt != NSNotFound )
            {
                // object already exists, just update addedDate
                [[favorites objectAtIndex:foundAt] setAddedDate: [NSDate date] ];
            }
            else
            {
                // object doesn't exist, let's add it!
                [object setAddedDate: [NSDate date] ];
                [favorites addObject: object];
            }
            _isFavoritesDirty = YES;
            
            break;
        case kNTASectionRecentlyViewed:
            
            foundAt = [recent indexOfObject:object withKeys:[NTASaveObject returnImportantKeys] ];
            if ( foundAt != NSNotFound )
            {
                // object already exists, just update addedDate
                [[recent objectAtIndex:foundAt] setAddedDate: [NSDate date] ];
            }
            else
            {
                
                // Check if recent count has reached or exceeded the _recentLimit
                int count = (int)[recent count];
                for (int LCV = [_recentLimit intValue]; LCV <= count; LCV++ )
                {
                    [recent removeObjectAtIndex:LCV-1];
                    // Before we add a new NTASaveObject to recent, we need to ensure that recent contains _recentLimit-1 objects.
                }
                
                // Add new object
                [object setAddedDate: [NSDate date] ];
                [recent addObject: object];
                
            }
            _isRecentDirty = YES;
            
            break;
            
        default:
            
            break;
    }
    
//    if ( _isRecentDirty || _isFavoritesDirty )
//        [self sortSection: section];
    
    return foundAt;
    
}

-(void) removeObject:(NTASaveObject*) object fromSection:(NTASaveSection) section
{

    NSInteger foundAt;
    
    switch (section) {
        case kNTASectionFavorites:

            foundAt = [favorites indexOfObject: object withKeys: [NTASaveObject returnImportantKeys] ];
            
            if ( foundAt != NSNotFound )
            {
                [favorites removeObjectAtIndex: foundAt];
                _isFavoritesDirty = YES;
            }
            
            break;
        case kNTASectionRecentlyViewed:

            foundAt = [recent indexOfObject: object withKeys: [NTASaveObject returnImportantKeys] ];
            
            if ( foundAt != NSNotFound )
            {
                [recent removeObjectAtIndex: foundAt];
                _isRecentDirty = YES;
            }
            
            break;
        default:
            break;
    }  // switch (section)
    
}


-(BOOL) isSectionDirty: (NTASaveSection) section
{
    if ( section == kNTASectionFavorites )
        return _isFavoritesDirty;
    else if ( section == kNTASectionRecentlyViewed )
        return _isRecentDirty;
    else if ( section == kNTASectionAll )
        return _isFavoritesDirty | _isRecentDirty;
    else
        return NO;  // As paraphrased from grumpy cat
    
}


-(NSString*) description
{
    return [NSString stringWithFormat:@"# of favorites: %lu, # of recent: %lu", (unsigned long)[favorites count], (unsigned long)[recent count] ];
}



@end
