//
//  SEPTATitle.h
//  iSEPTA
//
//  Created by septa on 7/22/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface SEPTATitle : UIImageView

@property (nonatomic, strong) NSString *title;

-(id) initWithFrame:(CGRect) frame andWithTitle:(NSString*) title;

@end
