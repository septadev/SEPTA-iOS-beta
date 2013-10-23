//
//  LineHeaderView.m
//  iSEPTA
//
//  Created by septa on 7/23/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "LineHeaderView.h"

@implementation LineHeaderView
{
//    CATextLayer *_title;
    
    int _textStart;
    int _padding;
    
//    CATextLayer *_label;
    UILabel *_label;
    CAShapeLayer *_lineShape;
    
    CGFloat _fontSize;
    
}


//@synthesize title = _title;


-(id)initWithFrame:(CGRect)frame withTitle:(NSString*) title withFontSize:(CGFloat) fontSize
{
    
    self = [super initWithFrame: frame];
    if ( self )
    {
        
        _fontSize = fontSize;
        
        [self setBackgroundColor:[UIColor clearColor] ];
        [self setContentMode:UIViewContentModeLeft];
        
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask: UIViewAutoresizingFlexibleWidth ];
        
        [self createLineWithTitle];
        [self createLabelWithFrame: frame withTitle: title];
        
    }
    return self;
    
}


-(id)initWithFrame:(CGRect)frame withTitle:(NSString*) title
{
    
    self = [super initWithFrame: frame];
    if ( self )
    {
     
        _fontSize = 45.0f/2.0f;
        
        [self setBackgroundColor : [UIColor clearColor] ];
        [self setContentMode     : UIViewContentModeLeft];

        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask: UIViewAutoresizingFlexibleWidth ];
        
        [self createLineWithTitle];
        [self createLabelWithFrame: frame withTitle: title];
        
    }
    return self;
    
}


-(void) updateWidth: (CGFloat) width
{
    
    CGRect sFrame = self.frame;
    CGRect lFrame = _label.frame;
    
    sFrame.size.width = width;
    lFrame.size.width = width;
    
    [self setFrame: sFrame];
    
    [_label setFrame: lFrame];
    
}


-(void) updateFrame: (CGRect) frame
{

//    [self setFrame:frame];
//    [self setFrame:frame];
    [_label setFrame: CGRectOffset(frame, 12, 0)];
    
}


-(void) createLineWithTitle
{
    
    int lineStart = 5;
    _textStart = 17;
    
    // Title is used in this case to size the line and nothing else
    NSString *title = @"Blah";
    CGSize size = [title sizeWithFont: [UIFont fontWithName: @"TrebuchetMS-Bold" size: _fontSize] ];
    
    int barHeight = 32;
    _padding = (barHeight - (size.height) ) / 2;
    
    _lineShape = nil;
    CGMutablePathRef linePath = nil;
    linePath = CGPathCreateMutable();
    _lineShape = [CAShapeLayer layer];
    
    
    [_lineShape setContentsScale: [[UIScreen mainScreen] scale] ];
    
    _lineShape.lineWidth   = 1.0f;
    _lineShape.lineCap     = kCALineCapRound;;
    _lineShape.strokeColor = [[UIColor whiteColor] CGColor];
    
    int x = lineStart;
    int y = _padding;
    
    int toX = lineStart;
    int toY = barHeight - _padding;
    
    CGPathMoveToPoint(linePath, NULL, x, y);
    CGPathAddLineToPoint(linePath, NULL, toX, toY);
    
    _lineShape.path = linePath;
    CGPathRelease(linePath);
    [self.layer addSublayer:_lineShape];
    
}


-(void) createLabelWithFrame: (CGRect) frame withTitle: (NSString*) title
{
        
    // UIView will contain two elements, a line and a UILabel
    _label = [[UILabel alloc] initWithFrame:CGRectOffset(frame, 0, 0)];
    [_label setTextAlignment: NSTextAlignmentLeft];
    
    [_label setMinimumFontSize: 10.0f];
    [_label setAdjustsFontSizeToFitWidth:YES];
    
    //[label setTextAlignment: NSTextAlignmentLeft];
    
//    NSString *title = @"Norristown High Speed Party Line and Cruise";
    
    
    CGSize size;
//    float fontSize = 45.0f/2.0f;
    BOOL stop = 0;
    int count = 0;
    
    float delta = (_fontSize - 0);
    float lastFontSize = 0;
    
    do
    {
        
        size = [title sizeWithFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:_fontSize] ];
        
        if ( count == 0 && size.width < self.frame.size.width )
        {
            stop = 1;
        }
        else
        {
            
            delta /= 2;
            lastFontSize = _fontSize;
            
            if ( size.width > self.frame.size.width )
            {
                // The width of the text is still too large.  Drop fontSize
                _fontSize -= delta;
            }
            else
            {
                _fontSize += delta;
            }
            
        }
        count++;
        
    } while ( ( fabsf(lastFontSize-_fontSize) > .500) && !stop);
    
    
//    NSLog(@"LHV - fontSize: %6.3f, count: %d", fontSize, count);
    
    
    [_label setText:title];
    
    [_label setFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size: _fontSize] ];
    [_label setTextColor: [UIColor whiteColor] ];
    [_label setBackgroundColor:[UIColor clearColor] ];
    //        [label setAdjustsFontSizeToFitWidth:YES];
    //        [label setMinimumFontSize:9.0f];
    
    
    // Offset the _label a few pixels from the line, otherwise, there will be exactly 1 pixel separating them
    [_label setFrame: CGRectOffset(_label.frame, 10, 0)];
    
    
    NSLog(@"LHV - label size: %@", NSStringFromCGRect( _label.frame ) );
    
    [self addSubview: _label];
    
    
}

//- (id)initWithFrame:(CGRect)frame withNewTitle:(NSString *) title
//{
//    
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//    
//        // Initialization code
//        [self setBackgroundColor:[UIColor clearColor] ];
//        
//        [self setContentMode:UIViewContentModeLeft];
//    
//        int lineStart = 5;
//        _textStart = 17;
//    
//        CGSize size = [title sizeWithFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:45/2.0f] ];
//
//        int barHeight = 44;
//        _padding = (barHeight - (size.height) ) / 2;
//        
//        CAShapeLayer *lineShape = nil;
//        CGMutablePathRef linePath = nil;
//        linePath = CGPathCreateMutable();
//        lineShape = [CAShapeLayer layer];
//        
//        
//        [lineShape setContentsScale: [[UIScreen mainScreen] scale] ];
//        
//        lineShape.lineWidth = 1.0f;
//        lineShape.lineCap = kCALineCapRound;;
//        lineShape.strokeColor = [[UIColor whiteColor] CGColor];
//        
//        int x = lineStart;
//        int y = _padding;
//        
//        int toX = lineStart;
//        int toY = 44 - _padding;
//        
//        CGPathMoveToPoint(linePath, NULL, x, y);
//        CGPathAddLineToPoint(linePath, NULL, toX, toY);
//        
//        lineShape.path = linePath;
//        CGPathRelease(linePath);
//        [self.layer addSublayer:lineShape];
//        
//        
//        // --
//        // --==  Label
//        // --
//        [self setTitle: title];
//
//        
//    }
//    
//    return self;
//}


-(void) setTitle:(NSString *)myTitle
{
    [_label setText: myTitle];
}


//-(void) setTitle:(NSString*) myTitle
//{
// 
//    return;
//    // TODO: Needs to be smart enough to resize the font or truncate it if it's too long
//    // TODO: Title needs to be resized upon orientation change
//    if ( _label != NULL )
//    {
//        [_label removeFromSuperlayer];
//    }
//    
//    _label = [[CATextLayer alloc] init];
//    
//        
//    CGSize size;
//    float fontSize = 45.0f/2.0f;
//    BOOL stop = 0;
//    int count = 0;
//
//    myTitle = @"Norristown High Speed Line";;
//    float delta = (fontSize - 0);
//    float lastFontSize = 0;
//    
//    do
//    {
//        
//        size = [myTitle sizeWithFont:[UIFont fontWithName:@"TrebuchetMS-Bold" size:fontSize] ];
//        
//        if ( count == 0 && size.width < 240 )
//        {
//            stop = 1;
//        }
//        else
//        {
//
//            delta /= 2;
//            lastFontSize = fontSize;
//
//            if ( size.width > 240 )
//            {
//                // The width of the text is still too large.  Drop fontSize
//                fontSize -= delta;
//            }
//            else
//            {
//                fontSize += delta;
//            }
//            
//        }
//        count++;
//        
//    } while ( ( fabsf(lastFontSize-fontSize) > .500) && !stop);
//
//    NSLog(@"LHV - fontSize: %6.3f, count: %d", fontSize, count);
//    
//    
////    NSAttributedString *string = [[NSAttributedString alloc] initWithString:myTitle attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"One", @"Two", nil] forKeys:[NSArray arrayWithObjects:@"One", @"Two", nil]] ];
//
////                                                NSForegroundColorAttributeName : [UIColor whiteColor],
////    NSAttributedString *labelText = [[NSAttributedString alloc] initWithString:
////                                     [NSString stringWithString: myTitle] attributes:@{
////                                                          NSFontAttributeName : @"TrebuchetMS-Bold",
////                                                                                }];
//
//
//
////    float newWidth = [self boundingHeightForWidth:100.0f withAttributedString:labelText];
//
//    CFStringRef string = (__bridge CFStringRef)myTitle;
//    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
//    CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), string);
//
//    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    CGFloat components[] = { 1.0, 0.0, 0.0, 0.8 };
//    CGColorRef red = CGColorCreate(rgbColorSpace, components);
//    CGColorSpaceRelease(rgbColorSpace);
//
//    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 20), kCTForegroundColorAttributeName, red);
//
//    CTFontRef font = CTFontCreateWithName(CFSTR("TrebuchetMS"), 12, NULL);
//    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 20), kCTFontAttributeName, font);
//
//
//
////CFStringRef fontNameRef = CFSTR("TrebuchetMS");
////fontSize = 50.0f;
////CFNumberRef fontSizeRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberFloat32Type, &fontSize);
////
////CFMutableDictionaryRef attributes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
////CFDictionaryAddValue(attributes, kCTFontFamilyNameAttribute, fontNameRef);
////
////CFMutableDictionaryRef traits = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
////CFDictionaryAddValue(traits, kCTFontSymbolicTrait, fontSizeRef);
////CFDictionaryAddValue(attributes, kCTFontTraitsAttribute, traits);
////
////CFRelease(traits);
////CFRelease(fontSizeRef);
////
////CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithAttributes(attributes);
////CFRelease(attributes);
////
////CTFontRef font = CTFontCreateWithFontDescriptor(descriptor, 50.0f, NULL);
////CFRelease(descriptor);
////
////CGFloat lineHeight = 0.0f;
////lineHeight += CTFontGetAscent(font);
////lineHeight += CTFontGetDescent(font);
////lineHeight += CTFontGetLeading(font);
//
//
//
////CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 20), kCTFontAttributeName, CFSTR("TrebuchetMS") );
////CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 20), kCTFontSizeAttribute, CFSTR("50") );
//
//
//CGMutablePathRef path = CGPathCreateMutable();
//CGPathAddRect(path, NULL, self.frame);
//CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
//CFRelease(attrString);
//
//CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
//CFRange frameRange = CTFrameGetVisibleStringRange(frame);
//
//NSLog(@"frame length: %ld", frameRange.length);
//
//
////    fontSize = 45.0f/2.0f;
////    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)labelText);
////    CGRect columnRect = CGRectMake(0, 0 , 320, 150);
////    
////    CGMutablePathRef path = CGPathCreateMutable();
////    CGPathAddRect(path, NULL, columnRect);
////    
////    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
////    
////    CFRange frameRange = CTFrameGetVisibleStringRange(frame);
//
//
//    
//    
//
//    [_label setFont:@"TrebuchetMS-Bold"];
//    [_label setFontSize:fontSize];
//    [_label setFrame:CGRectMake(_textStart, (44 - (size.height) ) / 2, self.frame.size.width + 100, self.frame.size.height)];
//    [_label setString: myTitle];
//    
//    //        [label setAlignmentMode:kCAAlignmentCenter];
//    [_label setForegroundColor:[[UIColor whiteColor] CGColor]];
//    [_label setContentsScale: [[UIScreen mainScreen] scale] ];
//    
//    
//    
//    // Add label to UIView
//    [self.layer addSublayer:_label];
//    
//    // Resize the UIView to the new size, from the start of the line to the end of the text
//    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width + size.width, self.frame.size.height)];
//    
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    NSLog(@"LHV:drawRect - If this ever prints, so help me...");
//}


/*
 
 NSString *const NSFontAttributeName;
 NSString *const NSParagraphStyleAttributeName;
 NSString *const NSForegroundColorAttributeName;
 NSString *const NSBackgroundColorAttributeName;
 NSString *const NSLigatureAttributeName;
 NSString *const NSKernAttributeName;
 NSString *const NSStrikethroughStyleAttributeName;
 NSString *const NSUnderlineStyleAttributeName;
 NSString *const NSStrokeColorAttributeName;
 NSString *const NSStrokeWidthAttributeName;
 NSString *const NSShadowAttributeName;
 NSString *const NSVerticalGlyphFormAttributeName;
 
 */

//- (CGFloat)boundingHeightForWidth:(CGFloat)inWidth withAttributedString:(NSAttributedString *)attributedString
//{
//    
//    CTFramesetterRef framesetter  = CTFramesetterCreateWithAttributedString( (__bridge CFAttributedStringRef)(attributedString) );
////    CTFramesetterRef framesetter2 = CTFramesetterCreateWithAttributedString( (__bridge CFMutableAttributedStringRef) attributedString);
//    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(inWidth, CGFLOAT_MAX), NULL);
//    CFRelease(framesetter);
//    return suggestedSize.width;
//    
//}


@end
