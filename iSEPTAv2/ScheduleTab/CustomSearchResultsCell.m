//
//  CustomSearchResultsCell.m
//  iSEPTA
//
//  Created by septa on 10/15/12.
//  Copyright (c) 2012 SEPTA. All rights reserved.
//

#import "CustomSearchResultsCell.h"

@implementation CustomSearchResultsCell
{
    
}

@synthesize lblRoute;
@synthesize lblResults;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
            
        lblRoute = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 42, 43)];
        lblResults = [[UILabel alloc] initWithFrame:CGRectMake(56, 2, 224, 39)];
        
//        [lblRoute setMinimumFontSize:5.0f];
        [lblRoute setMinimumScaleFactor:5.0f/[UIFont labelFontSize] ];
//        [lblRoute setAdjustsFontSizeToFitWidth:YES];
        
//        [lblRoute setAutoresizingMask:UIViewContentModeScaleAspectFill];
        [lblRoute setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [lblRoute setLineBreakMode:UILineBreakModeClip];
        [lblRoute setLineBreakMode: NSLineBreakByClipping];
        [lblRoute setAdjustsFontSizeToFitWidth:YES];

//        [lblResults setMinimumFontSize:8.0f];
        [lblResults setMinimumScaleFactor:8.0f/[UIFont labelFontSize] ];
        
//        [lblResults setAutoresizingMask:UIViewContentModeScaleAspectFill];
        [lblResults setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [lblResults setLineBreakMode:UILineBreakModeClip];
        [lblResults setLineBreakMode: NSLineBreakByClipping];
        [lblResults setAdjustsFontSizeToFitWidth:YES];
        
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        [self addSubview:lblRoute];
        [self addSubview:lblResults];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
