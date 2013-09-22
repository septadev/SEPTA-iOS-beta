//
//  AttributionsTextViewController.h
//  iSEPTA
//
//  Created by septa on 9/13/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AttributionData.h"

@interface AttributionsTextViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *txtViewAttribution;

@property (nonatomic, strong) AttributionData *data;



@end
