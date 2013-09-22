//
//  DistanceView.m
//  iSEPTA
//
//  Created by septa on 8/14/13.
//  Copyright (c) 2013 SEPTA. All rights reserved.
//

#import "DistanceView.h"


@implementation DistanceView
{

    CHDigitInput *_digitInput;
    BOOL _visible;
    BOOL _beganEditing;
    CGRect _originalFrame;
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
//        [[NSBundle mainBundle] loadNibNamed:@"DistanceView" owner:self options:nil];
        
    }
    return self;
}


-(void) awakeFromNib
{
    
//    NSLog(@"DV - Holy Shit!  I just got called!!");
    [super awakeFromNib];
        
    _visible = NO;
    
    _digitInput = [[CHDigitInput alloc] initWithNumberOfDigits:5];
    [_digitInput setDecimalPosition: kCHDecimalPositionThousandths withPlaceholder: @"."];

    [_digitInput setPlaceHolderCharacter:@"0"];
    
//    [_digitInput setDigitOverlayImage:    [UIImage imageNamed:@"digitOverlay"  ] ];
    [_digitInput setDigitOverlayImage: nil];
    
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor colorWithRed:100.0/255.0 green:101.0/255.0 blue:102.0/255.0 alpha:1.0] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _beganEditing = NO;
    
    [_digitInput setDigitBackgroundImage: img];
//    [_digitInput setDigitBackgroundImage: [UIImage imageNamed:@"digitControlBG"] ];

    // we are using an overlayimage, so make the bg color clear color
    
    _digitInput.digitViewBackgroundColor = [UIColor clearColor];
    _digitInput.digitViewHighlightedBackgroundColor = [UIColor clearColor];
    
    _digitInput.digitViewTextColor = [UIColor whiteColor];
    _digitInput.digitViewHighlightedTextColor = [UIColor orangeColor];
    
    [_digitInput setDigitViewFont: [UIFont fontWithName:@"TrebuchetMS-Bold" size:34.0f] ];
    
    [_digitInput redrawControl];
    
    _digitInput.frame = CGRectMake(20, self.frame.size.height * .25, self.frame.size.width - 40, 55);
    
    [self addSubview: _digitInput];
    
//    [_digitInput setValue:[NSString stringWithFormat:@"%05.3f", 0.5] ];
    [self setRadius:0.5f];

    [_digitInput addTarget:self action:@selector(didBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [_digitInput addTarget:self action:@selector(didEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    [_digitInput addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_digitInput addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    
    [self.lblDecimal setHidden:YES];
    [self.lblOnes setHidden:YES];
    [self.lblTenths setHidden:YES];
    [self.lblHundredths setHidden:YES];
    [self.lblThousandths setHidden:YES];
    
    [self.imgDecimal setHidden:YES];
    [self.imgOnes setHidden:YES];
    [self.imgTenths setHidden:YES];
    [self.imgHundredths setHidden:YES];
    [self.imgThousandths setHidden:YES];
    
//    _originalFrame = self.frame;
    
    
}

-(void) setRadius:(CGFloat) radius
{
    [_digitInput setValue:[NSString stringWithFormat:@"%05.3f", radius] ];

}


-(void) show
{
//    NSLog(@"DW:before show - %@", NSStringFromCGRect(self.frame));
    CGRect frame = self.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    
//    frame.origin.y = -(frame.origin.y + frame.size.height);
    frame.origin.y = 60;
    [self setFrame: frame];
    
    [UIView commitAnimations];
    _visible = YES;
//    NSLog(@"DW:after  show - %@", NSStringFromCGRect(self.frame));
}


-(void) hide
{
//    NSLog(@"DW:before hide - %@", NSStringFromCGRect(self.frame));
    CGRect frame = self.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25f];
    
    frame.origin.y = -frame.size.height;
    [self setFrame: frame];
    
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    [UIView commitAnimations];
    
    _visible = NO;
    
    // Check if the keyboard is still active and, if it is, dismiss it
    [_digitInput complete];

}

-(BOOL) isHidden
{
    return !_visible;
}

-(void) hideKeyboard
{
    [_digitInput complete];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)didBeginEditing:(id)sender
{
    CHDigitInput *input = (CHDigitInput *)sender;
    NSLog(@"DV:dBE - did begin editing %@",input.value);
    _beganEditing = YES;
}


-(void)didEndEditing:(id)sender
{
    CHDigitInput *input = (CHDigitInput *)sender;
    _beganEditing = NO;
    NSLog(@"DV:dEE - did end editing %@",input.value);
    
    if ( [self.delegate respondsToSelector:@selector(inputComplete:)] )
        [self.delegate inputComplete: [input.value floatValue] ];
    
}


-(void)textDidChange:(id)sender
{
    CHDigitInput *input = (CHDigitInput *)sender;
    NSLog(@"DV:tDC - text did change %@",input.value);
}

-(void)valueChanged:(id)sender
{
    CHDigitInput *input = (CHDigitInput *)sender;
    NSLog(@"DV:vC - value changed %@",input.value);
}


-(CGFloat) getRadius
{
    return [_digitInput.value floatValue];
}

@end
