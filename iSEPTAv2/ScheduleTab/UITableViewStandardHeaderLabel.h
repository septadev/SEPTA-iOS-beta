//
//  UITableViewStandardHeaderLabel.h
//  iSEPTA
//
//  Created by septa on 11/1/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewStandardHeaderLabel : UILabel

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat leftInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) CGFloat rightInset;

-(void) addArrayOfColors:(NSArray*) colorArr;

@end
