//
//  FeedbackQuickViewController.h
//  iSEPTA
//
//  Created by septa on 6/19/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuickDialogController.h"

#import "CustomFlatBarButton.h"
#import "LineHeaderView.h"


@interface FeedbackQuickViewController : QuickDialogController

@property (nonatomic, strong) NSString *backButtonName;
@property (nonatomic, strong) NSString *viewTitle;

@end
