//
//  NextToArriveAlerts.m
//  iSEPTA
//
//  Created by septa on 4/3/15.
//  Copyright (c) 2015 SEPTA. All rights reserved.
//

#import "NextToArriveAlerts.h"

@implementation NextToArriveAlerts

@synthesize lblAlertText;

CGFloat _height;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void) updateAlertTitle:(NSString*) title andText: (NSString*) text
{
    
}

-(void) updateAlertText: (NSString*) textStr
{
    
    // text will (should) be in the following format:
    //   RRD: blah blah blah blah
    
    //   Everything up to and including the RRD will be bolded.  The rest can remain a normal weight.
    

    NSRange endRange = [textStr rangeOfString:@":"];

    NSString *title = @"";
    NSString *text  = @"";
    
    if (endRange.length != NSNotFound )
    {
        title = [textStr substringToIndex:endRange.location+1];
        text = [textStr substringFromIndex:endRange.location+2];
    }
    
    
//    NSRange boldRange = NSMakeRange(0, endRange.location);
    
    

    

    
    UIFont *boldFont    = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14.0];
    UIFont *defaultFont = [UIFont fontWithName:@"Trebuchet MS"      size:14.0];
    
    NSDictionary *titleDict = [NSDictionary dictionaryWithObject: boldFont forKey:NSFontAttributeName];
    NSMutableAttributedString *titleAttrString = [[NSMutableAttributedString alloc] initWithString:title attributes: titleDict];
    
    NSDictionary *textDict = [NSDictionary dictionaryWithObject:defaultFont forKey:NSFontAttributeName];
    NSMutableAttributedString *textAttrString = [[NSMutableAttributedString alloc]initWithString: text attributes:textDict];
    [textAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:(NSMakeRange(0, 15))];
    
    [titleAttrString appendAttributedString:textAttrString];
    


    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect rect = [titleAttrString boundingRectWithSize:CGSizeMake(width,9999) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  context:nil];
    
//    CGSize sizeNew = [titleAttrString size];
//    NSLog(@"width: %6.4f",[UIScreen mainScreen].bounds.size.width);
    
    _height = rect.size.height;
    
    [self.lblAlertText setAttributedText: titleAttrString];
    
}

-(CGFloat) getHeight
{
    return _height;
}


@end
