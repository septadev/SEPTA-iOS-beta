//
//  DistanceView.h
//  iSEPTA
//
//  Created by septa on 8/14/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CHDigitInput.h"

@protocol DistanceViewProtocol <NSObject>

@required

-(void) inputComplete:(CGFloat) radius;

@end


@interface DistanceView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;

@property (weak, nonatomic) IBOutlet UIImageView *imgOnes;
@property (weak, nonatomic) IBOutlet UIImageView *imgDecimal;
@property (weak, nonatomic) IBOutlet UIImageView *imgTenths;

@property (weak, nonatomic) IBOutlet UIImageView *imgHundredths;
@property (weak, nonatomic) IBOutlet UIImageView *imgThousandths;


@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblMiles;


@property (weak, nonatomic) IBOutlet UILabel *lblOnes;
@property (weak, nonatomic) IBOutlet UILabel *lblDecimal;
@property (weak, nonatomic) IBOutlet UILabel *lblTenths;

@property (weak, nonatomic) IBOutlet UILabel *lblHundredths;
@property (weak, nonatomic) IBOutlet UILabel *lblThousandths;

@property (weak, nonatomic) id <DistanceViewProtocol> delegate;

-(void) hide;
-(void) show;

-(BOOL) isHidden;
-(void) hideKeyboard;

-(CGFloat) getRadius;
-(void) setRadius:(CGFloat) radius;

@end
