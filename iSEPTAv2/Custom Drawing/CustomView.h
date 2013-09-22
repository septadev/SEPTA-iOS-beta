//
//  CustomView.h
//  iSEPTA
//
//  Created by septa on 7/12/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    kQuartzContentStraightLines,
    kQuartzContentCurves,
    kQuartzContentShapes,
    kQuartzContentSolidFills,
    kQuartzContentGradientFills,
    kQuartzContentImageFills,
    kQuartzContentSimpleAnimations,
    kQuartzContentBounce,
    kQuartzContentOther,
} QuartzContentMode;

@interface CustomView : UIView

@property (nonatomic, assign) QuartzContentMode mode;

-(id) initWithFrame:(CGRect)frame andWithContentMode:(QuartzContentMode) contentMode;

@end
