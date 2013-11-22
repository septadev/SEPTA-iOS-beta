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
    self = [super initWithCustomView: [UIButton buttonWithType:UIButtonTypeCustom] ];
    
    if ( self != nil )
    {
    
        UIButton *myButton = (UIButton*)[self customView];
        UIImage *backButtonImage = [UIImage imageNamed: imageName];

        [myButton setImage: backButtonImage forState:UIControlStateNormal];
        
        myButton.frame = CGRectMake(0, 0, backButtonImage.size.width, backButtonImage.size.height);
        myButton.bounds = CGRectOffset(myButton.bounds, -20, -20);

        if ( ![delegate respondsToSelector:sel] )
        {
            NSAssert([delegate respondsToSelector:sel], @"Calling method does not implement the selector");
            return nil;
        }
        
        [myButton addTarget:delegate action:sel forControlEvents:UIControlEventTouchUpInside];
        [self setButton: myButton];
        
    }
    return self;
    
}



-(void) addImage:(UIImage*) image forState:(UIControlState) state
{
    [self.button setImage: image forState: state];
}




@end
