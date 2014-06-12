//
//  SlidingAlertView.m
//  iSEPTA
//
//  Created by septa on 6/12/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "SlidingAlertView.h"

@implementation SlidingAlertView

- (id)initWithFrame:(CGRect)frame
{
    
    
    self = [super initWithFrame:frame];
    if (self)
    {
        
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor] ];
        
    }
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 */

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
    {
        NSLog(@"Landscape");
    }
    else if ( toInterfaceOrientation == UIInterfaceOrientationMaskPortrait )
    {
        NSLog(@"Portrait");
    }
    else
    {
        NSLog(@"No change");
    }
    
    return YES;
    
}


-(void) rotate:(UIInterfaceOrientation)toInterfaceOrientation
{
    
    NSLog(@"Frame Before: %@", NSStringFromCGRect(self.frame));
    NSLog(@"Bound Before: %@", NSStringFromCGRect(self.bounds));
    
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) )
    {
        [self setFrame:CGRectMake(8, 212, 304, 149)];
    }
    else if ( toInterfaceOrientation == UIInterfaceOrientationMaskPortrait )
    {
        [self setFrame:CGRectMake(212, 8, 149, 304)];
    }

    NSLog(@"Frame After: %@", NSStringFromCGRect(self.frame));
    NSLog(@"Bound After: %@", NSStringFromCGRect(self.bounds));
    
    [self setNeedsDisplay];
    
}


- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGRect frame = self.bounds;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:10.0];
    [[UIColor colorWithRed:247.0/255.0 green:192.0/255.0 blue:37.0/255.0 alpha:1.0f] setFill];
    
    [path fill];
    

    
}


@end
