//
//  TapableSegmentControl.h
//  iSEPTA
//
//  Created by septa on 11/5/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TapableSegmentControlIndex)
{
    kTapableSegmentIndexNow      = 0,
    kTapableSegmentIndexWeek     = 1,
    kTapableSegmentIndexSaturday = 2,
    kTapableSegmentIndexSunday   = 3,
};

@interface TapableSegmentControl : UISegmentedControl

@end
