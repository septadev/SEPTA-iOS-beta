//
//  TripDetailsTableController.h
//  iSEPTA
//
//  Created by apessos on 3/23/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

// --==  Objects  ==--
#import "TripObject.h"

// --==  Categories  ==--
#import "NSArray+Indices.h"


@interface TripDetailsTableController : UITableViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) NSString *tripID;
@property (nonatomic, strong) NSString *travelMode;
@property (nonatomic, strong) TripObject *trip;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;

@end
