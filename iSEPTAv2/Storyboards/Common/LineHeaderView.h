//
//  LineHeaderView.h
//  iSEPTA
//
//  Created by septa on 7/23/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>


@interface LineHeaderView : UIView

-(id)initWithFrame:(CGRect)frame withTitle:(NSString*) title withFontSize:(CGFloat) fontSize;
- (id)initWithFrame:(CGRect)frame withTitle:(NSString *) title;

//@property (nonatomic, strong) CATextLayer *title;
-(void) setTitle:(NSString*) myTitle;

-(void) updateWidth: (CGFloat) width;
-(void) updateFrame: (CGRect) frame;

@end
