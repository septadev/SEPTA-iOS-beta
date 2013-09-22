//
//  CustomBackBarButton.m
//  iSEPTA
//
//  Created by septa on 7/24/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "CustomFlatBarButton.h"

@implementation CustomFlatBarButton

@synthesize backBarButtonItem;
@synthesize button;

-(id) initWithImageNamed:(NSString*) imageName withTarget:(id) delegate andWithAction:(SEL) sel
{

    // I feel that this is a horrible idea, but meh.
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if ( self == [super initWithCustomView: button] )
    {

        UIImage *backButtonImage = [UIImage imageNamed: imageName];

        [button setImage:backButtonImage
                forState:UIControlStateNormal];
        
        button.frame = CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height);
        button.bounds = CGRectOffset(button.bounds, -20, -20);
        
//        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height)];
//        [button setBounds: CGRectOffset(button.bounds, -20, -20)];
//        [buttonView addSubview:button];
        
        
        if ( ![delegate respondsToSelector:sel] )
        {
            NSAssert([delegate respondsToSelector:sel], @"Calling method does not implement the selector");
            return nil;
        }
        
        [button addTarget:delegate
                   action:sel
         forControlEvents:UIControlEventTouchUpInside];
        
    }
    else
    {
        button = nil;
    }
    
    return self;
}




@end
