//
//  CustomView.m
//  iSEPTA
//
//  Created by septa on 7/12/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView

@synthesize mode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    
        // Initialization code
        self.backgroundColor = [UIColor lightGrayColor];
        
    }
    return self;
}


-(id) initWithFrame:(CGRect)frame andWithContentMode:(QuartzContentMode) contentMode
{
    
    if ( ( self = [self initWithFrame:frame] ) )
    {
        self.mode = contentMode;
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


#pragma mark - Drawing Methods
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.mode)
    {
            
        case kQuartzContentStraightLines:
            [self drawStraightLinesInContext:context];
            break;
        case kQuartzContentCurves:
            [self drawCurvesInContext:context];
            break;
        case kQuartzContentShapes:
            [self drawCustomShapesInContext:context];
            break;
        case kQuartzContentSolidFills:
            [self drawSolidFillsInContext:context];
            break;
        case kQuartzContentGradientFills:
            [self drawGradientFillsInContext:context];
            break;
        case kQuartzContentImageFills:
            [self drawImageAndPatternFillsInContext:context];
            break;
        case kQuartzContentSimpleAnimations:
            [self drawSimpleAnimationsInContext:context];
            break;
        case kQuartzContentBounce:
            [self drawBouncesInContext:context];
            break;
        case kQuartzContentOther:
            [self drawOtherInContext:context];
            break;
        default:
            break;
            
    }
    
}


- (void)drawStraightLinesInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 35, 10);
    CGContextAddLineToPoint(context, 45, 65);
    CGContextSetLineWidth(context, 5.0);
    [[UIColor blueColor] setStroke];
    
//    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}


- (void)drawCurvesInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth  (context, 1.0    );
    CGContextMoveToPoint   (context, 25, 50 );
    CGContextAddLineToPoint(context, 120, 25);
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    CGContextSetLineWidth  (context, 5.0    );
    CGContextAddArc(context, 120, 120, 40, 0.25*M_PI, 1.5*M_PI, 0);
    [[UIColor redColor] setStroke];
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();
}


- (void)drawCustomShapesInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    UIGraphicsPopContext();
}


- (void)drawSolidFillsInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    UIGraphicsPopContext();
}


- (void)drawGradientFillsInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    UIGraphicsPopContext();
}


- (void)drawImageAndPatternFillsInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    UIGraphicsPopContext();
}


- (void)drawSimpleAnimationsInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    UIGraphicsPopContext();
}


- (void)drawBouncesInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    UIGraphicsPopContext();
}


- (void)drawOtherInContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    UIGraphicsPopContext();
}


@end

