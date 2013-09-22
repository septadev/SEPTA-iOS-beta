//
//  UIImage+WithText.h
//  iSEPTA
//
//  Created by septa on 7/17/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WithText)

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point;

@end
