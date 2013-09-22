//
//  UITableViewStandardHeaderLabel.m
//  iSEPTA
//
//  Created by septa on 11/1/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "UITableViewStandardHeaderLabel.h"

@implementation UITableViewStandardHeaderLabel
{
    size_t _numLocations;
    CGFloat *_locations;
    
    CGFloat *_components;
    
    NSMutableData *locationData;
    NSMutableData *componentData;
    
}

/*
 size_t num_locations = 2;
 CGFloat locations[2] = { 0.0f, 1.0f };
 
 //    CGFloat components[8] = { 13.0f/255.0f, 164.0f/255.0f, 74.0f/255.0f, 0.8, 45.0f/255.0f, 115.0f/255.0f, 67.0f/255.0f, 0.8f };
 CGFloat components[8] = { 13.0f/255.0f, 200.0f/255.0f, 74.0f/255.0f, 0.8f, 26.0/255.0f, 120.0f/255.0f, 37.0f/255.0f, 0.8f };
 */

@synthesize topInset, leftInset, bottomInset, rightInset;


//-(void) viewDidUnload
//{
//    NSLog(@"I doubt that this will work");
//}
//
//-(void) dealloc
//{
//    NSLog(@"NOOOOOOOOOOOOOOOOOOOOOOOO");
//}



//UIColor *color = [UIColor colorWithRed:13.0/255.0 green:67.0/255.0 blue:200.0/255.0 alpha:1.0f];
//const CGFloat *components = CGColorGetComponents([color CGColor]);
// CGFloat red = component[0];
// CGFloat green = component[1];
// CGFloat blue = component[2];
// CGFloat alpha = componnet[3];

-(void) addArrayOfColors:(NSArray*) colorArr
{
    
    // colorArr needs to contain UIColor objects
    _numLocations = [colorArr count];
    
    locationData = [NSMutableData dataWithLength: sizeof(CGFloat) * _numLocations];
    componentData = [NSMutableData dataWithLength: sizeof(CGFloat) * _numLocations * 4];
    
    _locations  = [locationData mutableBytes];
    _components = [componentData mutableBytes];
    
    CGFloat delta = 1.0f/( _numLocations-1 );
    
    for (int LCV = 0; LCV < _numLocations; LCV++)
    {
        _locations[LCV] = LCV * delta;
    }
    

    int offset = 0;
    for (UIColor *color in colorArr)
    {
        const CGFloat *components = CGColorGetComponents([color CGColor]);
        for(int LCV = 0; LCV < 4; LCV++)
        {
            _components[LCV + offset] = components[LCV];
        }
        offset += 4;
    }
    
}


//-(BOOL) addArrayOfColors:(NSArray*) colorArr
//{
//    
//    int count = [colorArr count];
//    
//    // The format has to be r,g,b,a; r,g,b,a; ...
//    if ( ( count % 4 ) != 0 )
//    {
//        return NO;
//    }
//    
//    
//    _numLocations = count / 4;
//
//    locationData = [NSMutableData dataWithLength: sizeof(CGFloat) * _numLocations];
//    componentData = [NSMutableData dataWithLength: sizeof(CGFloat) * count];
//    
//    _locations  = [locationData mutableBytes];
//    _components = [componentData mutableBytes];
//    
////    _locations = malloc(sizeof(CGFloat) * (_numLocations) );
//    
//    CGFloat delta = 1.0f/( _numLocations-1 );
//    
//    for (int LCV = 0; LCV < _numLocations; LCV++)
//    {
//        _locations[LCV] = LCV * delta;
//    }
//    
//    
////    _components = malloc(sizeof(CGFloat) * (count) );
//    for (int LCV = 0; LCV < count; LCV++)
//    {
//        if ( ((LCV+1) % 4) == 0 )
//            _components[LCV] = [[colorArr objectAtIndex:LCV] floatValue];  // This is the alpha component
//        else
//            _components[LCV] = [[colorArr objectAtIndex:LCV] floatValue]/255.0f;
//    }
//    
//    return YES;
//    
//}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
//        self.userInteractionEnabled = YES;
        _numLocations = 0;
    }
    
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {self.topInset, self.leftInset, self.bottomInset, self.rightInset};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGGradientRef backgroundGradient;
    CGColorSpaceRef rgbColorspace;
    
    
//    size_t num_locations = 2;
//    CGFloat locations[2] = { 0.0f, 1.0f };
//    
////    CGFloat components[8] = { 13.0f/255.0f, 164.0f/255.0f, 74.0f/255.0f, 0.8, 45.0f/255.0f, 115.0f/255.0f, 67.0f/255.0f, 0.8f };
//    CGFloat components[8] = { 13.0f/255.0f, 200.0f/255.0f, 74.0f/255.0f, 0.8f, 26.0/255.0f, 120.0f/255.0f, 37.0f/255.0f, 0.8f };
    
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
//    backgroundGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    backgroundGradient = CGGradientCreateWithColorComponents(rgbColorspace, _components, _locations, _numLocations);
    CFRelease(rgbColorspace);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMinY(currentBounds));
    CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
    
    CGContextDrawLinearGradient(context, backgroundGradient, topCenter, bottomCenter, 0);
    CFRelease(backgroundGradient);
    
//    UIColor *topBorderLineColor = [UIColor colorWithRed:113.0f/255.0f  green:125.0f/255.0f blue:133.0f/255.0f alpha:1.0];
//    UIColor *secondLineColor = [UIColor colorWithRed:165.0f/255.0f  green:177.0f/255.0f blue:187.0f/255.0f alpha:1.0];
//    UIColor *bottomBorderLineColor = [UIColor colorWithRed:151.0f/255.0f  green:157.0f/255.0f blue:164.0f/255.0f alpha:1.0];
//    
//    [topBorderLineColor setFill];
//    CGContextFillRect(context, CGRectMake(0, 0, CGRectGetMaxX(currentBounds), 1));
//    
//    [bottomBorderLineColor setFill];
//    CGContextFillRect(context, CGRectMake(0, CGRectGetMaxY(currentBounds)-1, CGRectGetMaxX(currentBounds), 1));
//    
//    [secondLineColor setFill];
//    CGContextFillRect(context, CGRectMake(0, 1, CGRectGetMaxX(currentBounds), 1));
    
    [super drawRect:rect];
}


//-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"UITVSHL - captured touch in Header");
//}

@end
