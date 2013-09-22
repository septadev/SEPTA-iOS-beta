//
//  SplitButton.h
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SplitButton : UIButton

//-(void) setActionsForTop:(SEL) topSelector andBottom: (SEL) bottomSelector;
//@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) BOOL topSelected;

@end
