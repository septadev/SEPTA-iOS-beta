//
//  TabbedButton.h
//  iSEPTA
//
//  Created by Administrator on 8/6/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAShapeLayer.h>


@protocol TabbedButtonProtocol <NSObject>

@required
-(void) tabbedButtonPressed:(NSInteger) tab;

@end

@interface TabbedButton : UIButton

// Initialize one button at a time?
//-(id) initWithFrame:(CGRect)frame withButtons: (NSArray*) buttonsArr;
//-(id) initWithFrame:(CGRect)frame withImages: (NSArray*) imageArr;

//-(void) changeFrame:(CGRect)frame;
//-(void) changedOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@property (weak, nonatomic) id<TabbedButtonProtocol> delegate;

-(void) setBackgroundColor:(UIColor *)backgroundColor forTab:(NSInteger) tab forState: (UIControlState) state;

-(void) changeFrameWidth: (CGFloat) width;      // usage: [self changeFrameWidth: self.view.frame.width];

-(void) setTabsScale: (CGFloat *) widthArr ofSize:(NSInteger) size;     // usage: [self setTabsScales: [0.3, 0.3, 0.4] ];
-(void) setButtons: (NSArray*) buttonArr;       // usage: [self setButtons: [NSArray arraysOfObjects: xBtn, yBtn, zBtn, nil];

-(void) setNumberOfTabs: (NSInteger) numTabs;
-(void) setOffset: (CGPoint) offset;

@end
