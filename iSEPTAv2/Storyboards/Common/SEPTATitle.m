//
//  SEPTATitle.m
//  iSEPTA
//
//  Created by septa on 7/22/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "SEPTATitle.h"

@implementation SEPTATitle

@synthesize title = _title;

-(id) initWithFrame:(CGRect) frame andWithTitle:(NSString*) title
{
    
    [self setTitle: title];
    return [self initWithFrame:frame];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
//        [self setAutoresizingMask:UIViewAutoresizingNone];
        [self setContentMode:UIViewContentModeLeft];
        
        CAShapeLayer *lineShape = nil;
        CGMutablePathRef linePath = nil;
        linePath = CGPathCreateMutable();
        lineShape = [CAShapeLayer layer];
        
        
        [lineShape setContentsScale: [[UIScreen mainScreen] scale] ];
        
        lineShape.lineWidth = 1.0f;
        lineShape.lineCap = kCALineCapRound;;
        lineShape.strokeColor = [[UIColor whiteColor] CGColor];
        
        int x = self.frame.size.width + 3; int y = 0;
        int toX = self.frame.size.width + 3; int toY = self.frame.size.height;
        CGPathMoveToPoint(linePath, NULL, x, y);
        CGPathAddLineToPoint(linePath, NULL, toX, toY);
        
        lineShape.path = linePath;
        CGPathRelease(linePath);
        [self.layer addSublayer:lineShape];
        
        
        CATextLayer *label = [[CATextLayer alloc] init];
        
        if ( self.title == NULL )
        {
            [self setTitle:@""];
        }
        
        [label setFont:@"TrebuchetMS-Bold"];
        [label setFontSize:45/2.0f];
        [label setFrame:CGRectMake(self.frame.size.width+10.0f, self.frame.origin.y, self.frame.size.width + 100, self.frame.size.height)];
        [label setString: self.title];
//        [label setAlignmentMode:kCAAlignmentCenter];
        [label setForegroundColor:[[UIColor whiteColor] CGColor]];
        
        [label setContentsScale: [[UIScreen mainScreen] scale] ];
        
        [self.layer addSublayer:label];
        
        CGSize size = [self.title sizeWithFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:45/2.0f] ];
        
//        NSLog(@"Before Frame: %@", NSStringFromCGRect(self.frame));
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + size.width, self.frame.size.height)];
//        NSLog(@"After  Frame: %@", NSStringFromCGRect(self.frame));
        
    }
    
    return self;
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/



// No fucking idea why this drawRect method never gets fucking called!
- (void)drawRect:(CGRect)rect
{
    
    NSLog(@"FUCKING DRAW!");
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.0, 0.0, 1.0, 1.0};
    
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, color);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 300, 400);
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
    
}


@end
