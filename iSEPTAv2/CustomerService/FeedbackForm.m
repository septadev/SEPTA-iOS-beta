//
//  FeedbackForm.m
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "FeedbackForm.h"

@implementation FeedbackForm


-(NSDictionary*) feedbackTypeField
{
    return @{@"textLabel.color": [UIColor redColor]};
}

-(NSDictionary*) detailsField
{
    return @{@"textLabel.color": [UIColor redColor]};
}


- (NSArray *)fields
{
    return @[
             
             @{FXFormFieldKey:@"feedbackType", FXFormFieldOptions: @[@" ",@"Bug", @"Crash", @"Suggestion", @"Bad Data", @"Other"], FXFormFieldCell: [FXFormOptionPickerCell class]},
             @{FXFormFieldKey:@"details", FXFormFieldType: FXFormFieldTypeLongText},
             
             @{FXFormFieldTitle: @"Submit", FXFormFieldHeader: @" ", FXFormFieldAction: @"submitRegistrationForm:"},
             ];
    
}

@end
