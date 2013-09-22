//
//  SplitButton.m
//  iSEPTA
//
//  Created by septa on 7/25/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "SplitButton.h"

@implementation SplitButton

@synthesize topSelected;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self)
    {
        // Initialization code
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



//-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//
//    [super touchesEnded:touches withEvent:event];
//    
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint point = [touch locationInView:self];
//    
//    CGRect topHalfRect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height/2);
//    CGRect btmHalfRect = CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height);
//    
//    if ( CGRectContainsPoint(topHalfRect, point) )
//    {
//        NSLog(@"Top Half Selected");
//    }
//    else if ( CGRectContainsPoint(btmHalfRect, point) )
//    {
//        NSLog(@"Bottom Half Selected");
//    }
//
//    
//}



@end
