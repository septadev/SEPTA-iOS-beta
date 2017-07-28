//
//  AppDelegate.h
//  TestCoreData
//
//  Created by Mark Broski on 7/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

