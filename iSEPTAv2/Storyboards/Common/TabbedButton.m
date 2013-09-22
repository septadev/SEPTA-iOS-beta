//
//  TabbedButton.m
//  iSEPTA
//
//  Created by Administrator on 8/6/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "TabbedButton.h"

@implementation TabbedButton
{
//    NSInteger _numButtons;
//    NSArray   *_buttonsArr;
//    
//    // --== OR ==--
//    NSArray *_imageArr;
//    CGFloat _width;
    
    NSInteger _numTabs;

    NSMutableArray *_tabScaling;
    NSMutableArray *_frameArr;
    
    NSArray *_buttonArr;
    CGPoint _offset;
    
}



//-(id) initWithFrame:(CGRect)frame withImages: (NSArray*) imageArr
//{
//    
//    self = [super initWithFrame:frame];
//    if ( self )
//    {
//        _imageArr = imageArr;
////        _width = [UIScreen mainScreen].applicationFrame.size.width;
////        NSLog(@"width: %6.3f", _width);
//        [self createButton];
//    }
//    return self;
//    
//}
//
//
//
//-(id) initWithFrame:(CGRect)frame withButtons: (NSArray*) buttonsArr
//{
//    
//    self = [super initWithFrame:frame];
//    if ( self )
//    {
//        _numButtons = [buttonsArr count];
//        _buttonsArr = buttonsArr;
//        [self addButtons];
//    }
//    return self;
//    
//}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        _backgroundColorArr = [[NSMutableArray alloc] init];
        _offset = CGPointZero;
        
    }
    return self;
}


-(void) setOffset: (CGPoint) offset
{
    _offset = offset;
}


//-(void) addButtons
//{
//
//    float padding = 4.0f;
//    
//    float x = self.frame.origin.x + padding;
//    float y = self.frame.origin.y;
//    float w = self.frame.size.width / (float)_numButtons;
//    float h = self.frame.size.height;
//    
//
//    for (UIButton *button in _buttonsArr)
//    {
//        
//        x += w;
//        [button setFrame:CGRectMake(self.frame.origin.x + x, y, w, h)];
//        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
//        [self addSubview: button];
//    }
//    
//}
//
//
//-(void) buttonPressed: (UIButton*) thisButton
//{
//    
//    for (UIButton *button in _buttonsArr)
//    {
//        [button setSelected:YES];
//    }
//
//    if ( [self.delegate respondsToSelector:@selector(tabbedButtonPressed)] )
//        [self.delegate tabbedButtonPressed];
//
//}
//
//
//-(void) createButton
//{
//
//    
//}
//
//-(void) changedOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    
//    if ( toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight )
//    {
//        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width * 1.5f, self.frame.size.height)];
//    }
//    else
//    {
//        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width / 1.5f, self.frame.size.height)];
//    }
//    
//}
//
//
//-(void) changeFrame:(CGRect)frame
//{
////    NSLog(@"TABBTN: changeOrientation: %d, frame: %@", toInterfaceOrientation, NSStringFromCGRect([UIScreen mainScreen].bounds));
//    
//    self.frame = frame;
//    [self setNeedsDisplay];
//    
//    
//}



-(void) changeFrameWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
    [self updateFrame];
    [self updateButtons];
}


-(void) setTabsScale:(CGFloat*)widthArr ofSize:(NSInteger)size
{
    _tabScaling = [[NSMutableArray alloc] initWithCapacity:size];
    _frameArr   = [[NSMutableArray alloc] initWithCapacity:size];
    for(int LCV = 0; LCV < size; LCV++)
    {
        [_tabScaling addObject: [NSNumber numberWithFloat: widthArr[LCV] ] ];
    }
    [self updateFrame];
}


-(void) setBackgroundColor:(UIColor *)backgroundColor forTab:(NSInteger)tab forState:(UIControlState)state
{

    NSAssert(_buttonArr != nil, @"_buttonArr cannot be empty");
    
    // Convert color into an image
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [backgroundColor CGColor]);

    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Now that we have our img color, let's store it in _backgroundColorArr
//    if ( _backgroundColorArr == nil )
//        _backgroundColorArr = [[NSMutableArray alloc] initWithCapacity: [_frameArr count] ];
    
    
//    NSMutableDictionary *stateDict = [[NSMutableDictionary alloc] init];
//    [stateDict setObject: [NSNumber numberWithInt:state] forKey:@""];

    
    
    //[_backgroundColorArr insertObject: img atIndex: tab];
    
    for (UIButton *button in [_buttonArr objectAtIndex:tab])
    {
        [button setBackgroundImage:img forState:state];
    }
    
    
}

-(void) updateButtons
{
    
    // TODO: Probably should make this an NSAssert as this is important.  _frameArr needs to exist first
    if ( [_frameArr count] == 0 )
        return;
    
    
    float xn = 0.0f;
    //    int n = 0;
    int s = 0;
    
    int index = 0;
    for (NSArray *array in _buttonArr)  // buttonArr is a 2D array, containing an array of UIButton objects
    {
        s = [array count];
        if ( s == 0 )
            continue;  // If s is 0, there's nothing to do here, move on.
        
        CGRect frame = [(NSValue*)[_frameArr objectAtIndex: index] CGRectValue];
        id value = [array objectAtIndex: 0];         // Just for debugging purposes
        if ( [value isKindOfClass:[NSNull class] ])  // Just for debugging purposes
            return;
        
        
        for (int LCV = 0; LCV < s; LCV++)
        {
            xn = ((float)LCV/(float)s) * frame.size.width;
            UIButton *button = [array objectAtIndex:LCV];
            [button setFrame:CGRectMake(frame.origin.x + xn + _offset.x, frame.origin.y + _offset.y, frame.size.width/s, frame.size.height)];

            float x = 4.5f;
            float y = 4.5f;
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: button.bounds
                                                           byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight
                                                                 cornerRadii: CGSizeMake(x,y)];
            
            CAShapeLayer *maskLayer = [CAShapeLayer layer];
            maskLayer.frame = button.bounds;
            maskLayer.path = maskPath.CGPath;
            
            button.layer.mask = maskLayer;
            
            [button setTag:index];
            
            // Check if the button is already in the array
            if ( ![self.subviews containsObject: button] )  // Things to do only once
            {
                [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
                [button addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview: button];
            }
        }
        
        index++;
        
    }

    
}

-(void) setButtons:(NSArray *)buttonArr
{

    if ( [buttonArr count] == 0 )
        return;

    _buttonArr = buttonArr;
    
    [self updateButtons];
    return;
    
}


-(void) setNumberOfTabs:(NSInteger)numTabs
{
    _numTabs = numTabs;
}


-(void) updateFrame
{
    
    float padding = 4.0f;
    
    float x = self.frame.origin.x;
    float y = self.frame.origin.y;
    
    float w = (self.frame.size.width - ([_tabScaling count]+1) * padding);
    float h = self.frame.size.height;
    
    float newX = x + padding;
    
    
    //    int count = 1;
    [_frameArr removeAllObjects];
    for (NSNumber *scale in _tabScaling)
    {
        CGFloat scaleFactor = [scale floatValue];
        CGRect rectangle;
        
        rectangle = CGRectMake(newX, y, w * scaleFactor, h);

        newX += (w * scaleFactor) + padding;
                
        [_frameArr addObject: [NSValue valueWithCGRect: rectangle] ];
        //        count++;
    }
    
}


- (void)drawRect:(CGRect)rect
{
    
    return;
    
    // Drawing code
//    NSLog(@"TABBTN: drawRect");
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    CGContextSetLineWidth(context, 2.0);
//    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    
    for (NSValue *value in _frameArr)
    {
        CGRect rectangle = [value CGRectValue];
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextFillRect(context, rectangle);
    }
    
    
    return;

    
    
    // Create rectangle
    float padding = 4.0f;
    
    float x = self.frame.origin.x;
    float y = self.frame.origin.y;
    
    float w = (self.frame.size.width - ([_tabScaling count]+1) * padding);
    float h = self.frame.size.height;
    
    float newX = x + padding;
    
    
//    int count = 1;
    for (NSNumber *scale in _tabScaling)
    {
        CGFloat scaleFactor = [scale floatValue];
        CGRect rectangle;
        
        rectangle = CGRectMake(newX, y, w * scaleFactor, h);
        
        newX += (w * scaleFactor) + padding;

//        CGContextAddRect(context, rectangle);
//        CGContextStrokePath(context);
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextFillRect(context, rectangle);

        [_frameArr addObject: [NSValue valueWithCGRect: rectangle] ];
//        count++;
    }
    
}


-(void) buttonTouchUp: (UIButton*) button
{
//    NSLog(@"TABBTN - buttonTouchUp");
    int index = button.tag;
    
    int count = 0;
    for (id object in _buttonArr)
    {
        
        // Object can either be a single UIButton or an NSArray of UIButtons
        if ( [object isKindOfClass:[UIButton class] ] )
        {
            if ( count == index )  // When current button or array of buttons match index, select them
                [(UIButton*) object setSelected:YES];
            else                   // Otherwise turn them off
                [(UIButton*) object setSelected:NO];
            
            [(UIButton*) object setHighlighted:NO];
            continue;
        }
        
        
        for (UIButton *button in (NSArray*)object )
        {
            if ( count == index )
                [button setSelected:YES];
            else
                [button setSelected:NO];

            [button setHighlighted:NO];
        }
        
        
        count++;
        
    }
    
}




-(void) buttonTouchDown: (UIButton*) button
{
//    NSLog(@"TABBTN - buttonTouchDown");
    int index = button.tag;
    
    if ([self.delegate respondsToSelector:@selector(tabbedButtonPressed:)])
    {
        [self.delegate tabbedButtonPressed: index];
    }
    
    int count = 0;
    for (id object in _buttonArr)
    {
        
        // Object can either be a single UIButton or an NSArray of UIButtons
        if ( [object isKindOfClass:[UIButton class] ] )
        {
            if ( count == index )  // When current button or array of buttons match index, select them
                [(UIButton*) object setHighlighted:YES];
            else                   // Otherwise turn them off
                [(UIButton*) object setHighlighted:NO];
            
            continue;
        }
        
        
        for (UIButton *button in (NSArray*)object )
        {
            if ( count == index )
                [button setHighlighted:YES];
            else
                [button setHighlighted:NO];
        }
        

        count++;
        
    }
    
    
}

@end
