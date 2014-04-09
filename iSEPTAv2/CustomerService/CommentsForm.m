//
//  CommentsForm.m
//  iSEPTA
//
//  Created by septa on 4/9/14.
//  Copyright (c) 2014 SEPTA. All rights reserved.
//

#import "CommentsForm.h"

@implementation CommentsForm

-(NSDictionary*) dateTimeField
{
    
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setDateFormat:@"M/d/yy hh:mm a"];
    NSString *currentTime = [dateFormatter stringFromDate:today];

    //NSLog(@"User's current time in their preference format:%@",currentTime);
    
    return @{@"textLabel.color": [UIColor redColor], @"detailTextLabel.text": currentTime};
}


-(NSDictionary*) whereField
{
    return @{@"textLabel.color": [UIColor redColor]};
}

-(NSDictionary*) commentField
{
    return @{@"textLabel.color": [UIColor redColor]};
}

-(NSDictionary*) firstNameField
{
    return @{@"textLabel.color": [UIColor redColor]};
}

-(NSDictionary*) lastNameField
{
    return @{@"textLabel.color": [UIColor redColor]};
}

-(NSDictionary*) emailAddressField
{
    return @{@"textLabel.color": [UIColor redColor]};
}




- (NSArray *)fields
{
    return @[
    
             @{FXFormFieldKey:@"dateTime", FXFormFieldHeader: @"Incident Date Time", FXFormFieldType: FXFormFieldTypeDateTime, FXFormFieldTitle: @"When?"},
             
             @{FXFormFieldKey:@"where", FXFormFieldHeader: @"Details", FXFormFieldType: FXFormFieldTypeLongText, FXFormFieldTitle: @"Where?"},
             @{FXFormFieldKey:@"mode", FXFormFieldOptions: @[@"Regional Rail",@"Market-Frankford Line",@"Broad Street Line", @"Trolley Lines", @"Norristown High Speed Line", @"Buses", @"CCT Connect"], FXFormFieldCell: [FXFormOptionPickerCell class]},
             @"route",
             @"destination",
             @{FXFormFieldKey:@"blockTrain", FXFormFieldTitle: @"Block or Train"},
             @{FXFormFieldKey:@"vehicle", FXFormFieldTitle: @"Vehicle or Car"},
             @{FXFormFieldKey:@"comment", FXFormFieldType: FXFormFieldTypeLongText},
             @{FXFormFieldKey:@"employee_description", FXFormFieldTitle: @"Employee Description", FXFormFieldType: FXFormFieldTypeLongText},
             
             @{FXFormFieldKey: @"firstName", FXFormFieldHeader: @"Your Contact Info"},
             @"lastName",
             
             @"phoneNumber",
             @{FXFormFieldKey: @"emailAddress", FXFormFieldType: FXFormFieldTypeEmail},
             
             @{FXFormFieldTitle: @"Submit", FXFormFieldHeader: @" ", FXFormFieldAction: @"submitRegistrationForm:"},
             ];
    
}

@end
