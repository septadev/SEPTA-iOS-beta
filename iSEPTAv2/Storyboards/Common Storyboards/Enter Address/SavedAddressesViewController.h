//
//  SavedAddressesViewController.h
//  iSEPTA
//
//  Created by septa on 9/20/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SavedAddressesProtocol <NSObject>

-(void) addressSelected:(CLPlacemark*) placemark;

@end

@interface SavedAddressesViewController : UITableViewController

@property (nonatomic, weak) id <SavedAddressesProtocol> delegate;

@end
