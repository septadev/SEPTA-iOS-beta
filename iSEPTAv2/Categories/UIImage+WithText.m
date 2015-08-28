//
//  UIImage+WithText.m
//  iSEPTA
//
//  Created by septa on 7/17/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "UIImage+WithText.h"

@implementation UIImage (WithText)


+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    // Define font type and size
    UIFont *font = [UIFont fontWithName:@"TrebuchetMS" size:22.5];
    
    // Get Graphic Context
    UIGraphicsBeginImageContext(image.size);
    
    
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
//    [text drawInRect:CGRectIntegral(rect) withFont:font];  // This was depreciated
    
    NSDictionary *attributes = @{ NSFontAttributeName: font};
    [text drawInRect:CGRectIntegral(rect) withAttributes: attributes];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
