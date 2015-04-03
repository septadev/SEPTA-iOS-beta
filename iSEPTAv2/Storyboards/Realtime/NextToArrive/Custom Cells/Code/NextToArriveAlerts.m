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

@synthesize numLines;

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
    
    UIFont *boldFont    = [UIFont fontWithName:@"Trebuchet MS Bold" size:14.0];
    UIFont *defaultFont = [UIFont fontWithName:@"Trebuchet MS"      size:14.0];
    
    NSDictionary *titleDict = [NSDictionary dictionaryWithObject: boldFont forKey:NSFontAttributeName];
    NSMutableAttributedString *titleAttrString = [[NSMutableAttributedString alloc] initWithString:title attributes: titleDict];
    
    NSDictionary *textDict = [NSDictionary dictionaryWithObject:defaultFont forKey:NSFontAttributeName];
    NSMutableAttributedString *textAttrString = [[NSMutableAttributedString alloc]initWithString: text attributes:textDict];
    [textAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:(NSMakeRange(0, 15))];
    
    [titleAttrString appendAttributedString:textAttrString];
    
    CGSize sizeNew = [titleAttrString size];
    
    self.numLines = [NSNumber numberWithFloat: sizeNew.height];
    
    [self.lblAlertText setAttributedText: titleAttrString];
    
}


@end
